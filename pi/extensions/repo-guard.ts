/**
 * Repo Guard Extension
 *
 * Blocks destructive file operations from targeting paths outside the current
 * git repository root. Read-only tools (read, ls, find, grep) are unrestricted.
 *
 * Blocked operations outside the repo:
 *   - write / edit: Direct file creation and modification
 *   - bash: Destructive commands (rm, chmod, mv, cp, shred, etc.) targeting outside paths
 *
 * Installation:
 *   Place in .pi/extensions/repo-guard.ts (project-local) or
 *   ~/.pi/agent/extensions/repo-guard.ts (global)
 *
 * Configuration via CLI flags:
 *   --repo-guard-strict  Block ALL access (including read) outside the repo
 *   --repo-guard-silent  Suppress UI notifications, just block silently
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";
import { join, resolve, relative, sep } from "node:path";

// ---- Constants ----

const DESTRUCTIVE_BASH_PATTERNS = [
	// Deletion
	{ regex: /\brm\b(?!\s+-*[^f]|-)/, desc: "rm (not rm -f only in safe mode)", severity: "high" },
	{ regex: /\brm\s+(-[a-zA-Z]*[fr])\b/, desc: "rm -r or rm -f (deletion)", severity: "high" },
	{ regex: /\b(?:shred|wipe|dd)\b/, desc: "data destruction (shred, wipe, dd)", severity: "critical" },
	{ regex: /\btruncate\b/, desc: "truncate (file truncation)", severity: "high" },
	{ regex: /\bfallocate\s+-l\s+0\b/, desc: "fallocate to zero (truncate-like)", severity: "medium" },

	// Permission changes
	{ regex: /\bchmod\b/, desc: "chmod (permission change)", severity: "high" },
	{ regex: /\bchown\b/, desc: "chown (ownership change)", severity: "high" },
	{ regex: /\bchgrp\b/, desc: "chgrp (group change)", severity: "medium" },

	// Moving/copying
	{ regex: /\bmv\b/, desc: "mv (move/rename)", severity: "high" },
	{ regex: /\bcp\s+-[a-zA-Z]*r\b/, desc: "cp -r (recursive copy)", severity: "medium" },
	{ regex: /\bcurl\b.*>-/, desc: "curl redirect (writing downloaded data)", severity: "high" },
	{ regex: /\bwget\b.*>-/, desc: "wget redirect (writing downloaded data)", severity: "medium" },
	{ regex: /\btee\s+-a\b/, desc: "tee -a (append to file)", severity: "medium" },
	{ regex: /\btee\b(?!\s+-a)/, desc: "tee (write/overwrite file)", severity: "high" },
	{ regex: />\s*\/?([a-zA-Z])/, desc: "shell redirect > (write)", severity: "high" },

	// Package managers (global installs)
	{ regex: />>\s*\/?([a-zA-Z])/, desc: "shell redirect >> (append)", severity: "medium" },

	// Package managers (global installs)
	{ regex: /\bapt-get\s+(remove|purge)\b/, desc: "apt-get remove/purge (system packages)", severity: "critical" },
	{ regex: /\bpip\s+(uninstall|freeze)\b/, desc: "pip uninstall/freeze", severity: "high" },
	{ regex: /\bpip3\s+(uninstall|freeze)\b/, desc: "pip3 uninstall/freeze", severity: "high" },
	{ regex: /\bnpm\s+remove\b/, desc: "npm remove", severity: "medium" },
	{ regex: /\byum\s+(remove|erase)\b/, desc: "yum remove/erase (system packages)", severity: "critical" },

	// Other destructive
	{ regex: /\bsync\b(?!\s*\/)/, desc: "sync (filesystem flush, can cause data loss if interrupted)", severity: "medium" },
	{ regex: /\breboot\b|\bshutdown\b|\bpoweroff\b/, desc: "system power action", severity: "critical" },
];

// File paths referenced by destructive bash commands
const BASH_FILE_PATH_RE = /(?:^|\s)(?:>|>>|>|-\w*o\s*)(\/[^\s;|&]*)|(?:(?:rm|chmod|chown|mv|cp|tee|shred|truncate|dd)\s+(?:-[a-zA-Z]+\s+)*)+([^\s;|&]+)/;

/**
 * Check if a path is inside the git root.
 * Handles both Unix and Windows paths.
 */
function isInsideRepo(filePath: string, gitRoot: string): boolean {
	// Resolve to absolute paths
	const resolved = resolve(filePath);
	const resolvedRoot = resolve(gitRoot);

	// Ensure gitRoot ends with separator for proper prefix check
	const rootWithSep = resolvedRoot + sep;

	// The file is inside if:
	// 1. It matches the git root exactly, or
	// 2. It's a direct child under the git root
	return resolved === resolvedRoot || resolved.startsWith(rootWithSep);
}

/**
 * Extract potential file paths from a bash command.
 * Returns a list of absolute paths found in the command.
 */
function extractFilePaths(command: string): string[] {
	const paths: string[] = [];

	// Extract paths from common argument patterns:
	// rm /path/to/file, chmod 755 /path, mv src /dest, cp -r /src /dest
	// Also handle relative paths
	const argPatterns = [
		/\b(?:rm|chmod|chown|chgrp|rmdir|shred|truncate)\s+(-[a-zA-Z]+\s+)*([^\s;|&]+)/g,
		/\bmv\s+([^\s;|&]+)\s+([^\s;|&]+)/g,
		/\bcp\s+(-[a-zA-Z]+\s+)*([^\s;|&]+)\s+([^\s;|&]+)/g,
		/\b(?:tee|cat|wc|file|stat)\s+(-[a-zA-Z]+\s+)*([^\s;|&]+)/g,
	];

	const seen = new Set<string>();

	for (const pattern of argPatterns) {
		let match: RegExpExecArray | null;
		const regex = new RegExp(pattern);
		while ((match = regex.exec(command)) !== null) {
			const args = match.slice(2); // skip the full match and flag groups
			for (const arg of args) {
				if (arg.startsWith("-") || arg === "/dev/null" || arg === "/dev/zero") continue;
				if (seen.has(arg)) continue;
				seen.add(arg);
				if (arg.startsWith("/")) {
					paths.push(resolve(arg));
				} else if (arg.startsWith("./") || arg.startsWith("../")) {
					paths.push(resolve(arg));
				} else if (arg.length > 0) {
					paths.push(resolve(arg));
				}
			}
		}
	}

	// Also check for shell redirect targets: > /path or >> /path
	const redirectPattern = /(?:>>?\s+)(\/[^\s;|&]+)/g;
	let match: RegExpExecArray | null;
	while ((match = redirectPattern.exec(command)) !== null) {
		if (!seen.has(match[1])) {
			seen.add(match[1]);
			paths.push(resolve(match[1]));
		}
	}

	// Check for pipe to file: | tee /path
	const teePattern = /\btee\s+(-[a-zA-Z]+\s+)*([^\s;|&]+)/g;
	while ((match = teePattern.exec(command)) !== null) {
		const target = match[2];
		if (!target.startsWith("-") && !seen.has(target)) {
			seen.add(target);
			paths.push(resolve(target));
		}
	}

	// Check for subshell command substitution writing to file: $(command > /path)
	const subshellRedirect = /\$\(\s*[^\)]*>\s*(\/[^\s;|&]*)/g;
	while ((match = subshellRedirect.exec(command)) !== null) {
		if (!seen.has(match[1])) {
			seen.add(match[1]);
			paths.push(resolve(match[1]));
		}
	}

	return paths;
}

/**
 * Check if a bash command matches any destructive pattern.
 * Returns the first match info, or null.
 */
function isDestructiveCommand(command: string): { pattern: string; desc: string; severity: string } | null {
	for (const { regex, desc, severity } of DESTRUCTIVE_BASH_PATTERNS) {
		if (regex.test(command)) {
			return { pattern: regex.toString(), desc, severity };
		}
	}
	return null;
}

/**
 * Check if any destructive paths in a bash command are outside the repo.
 */
function hasDestructivePathOutsideRepo(command: string, gitRoot: string): {
	outsidePaths: string[];
	firstOutsideDescription?: string;
} | null {
	const paths = extractFilePaths(command);
	const outsidePaths: string[] = [];

	for (const p of paths) {
		if (!isInsideRepo(p, gitRoot)) {
			// Resolve relative to git root to give a useful description
			try {
				const rel = relative(gitRoot, p);
				outsidePaths.push(rel);
			} catch {
				outsidePaths.push(p);
			}
		}
	}

	if (outsidePaths.length === 0) return null;

	// Get a description of the first outside path for the user
	let firstDesc: string | undefined;
	for (const p of outsidePaths) {
		if (p.includes("..")) {
			firstDesc = `../../${p.replace(/\.\.\//g, "")}`;
			break;
		}
		firstDesc = p;
		break;
	}

	return { outsidePaths, firstOutsideDescription: firstDesc };
}

/**
 * Show a confirmation dialog if strict mode is not enabled and user wants a choice.
 */
async function confirmDestructiveOutside(
	ctx: ExtensionContext,
	toolName: string,
	gitRoot: string,
	extra: string,
	strict: boolean,
): Promise<boolean> {
	if (strict) {
		return false; // Strict mode = auto-block
	}

	const message = extra
		? `This ${toolName} operation targets files outside the current repo (git root: ${gitRoot}).\n${extra}\n\nBlock this operation?`
		: `This ${toolName} operation targets files outside the current repo (git root: ${gitRoot}).\n\nBlock this operation?`;

	return !(await ctx.ui.confirm("Repo Guard: Access Outside Git Repo", message));
}

/**
 * Discover the git repository root for a directory.
 */
async function findGitRoot(cwd: string, execFn: (cmd: string, args: string[]) => Promise<{ code: number; stdout: string; stderr: string }>): Promise<string | null> {
	try {
		const { code, stdout } = await execFn("git", ["rev-parse", "--show-toplevel"]);
		if (code === 0 && stdout.trim()) {
			return stdout.trim();
		}
		return null;
	} catch {
		return null;
	}
}

// ---- Main Extension ----

export default function (pi: ExtensionAPI) {
	// Lazy state - initialized on session_start
	let gitRoot: string | null = null;
	let gitRootChecked = false;

	// Resolve path to cwd for resolving relative paths in tools
	let cwdResolved: string = "";

	// CLI flag: --repo-guard-strict
	let strictMode = false;

	pi.registerFlag("repo-guard-strict", {
		description: "Block ALL file operations (including read) outside the git repo",
		type: "boolean",
		default: false,
	});

	pi.on("session_start", async (event, ctx) => {
		gitRoot = null;
		gitRootChecked = false;
		cwdResolved = resolve(ctx.cwd);

		// Silent logging for discovery
		if (event.reason === "startup") {
			ctx.ui.setStatus("repo-guard", "Discovering git root...");
		}
	});

	pi.on("before_agent_start", async (_event, ctx) => {
		// Inject a system prompt reminder
		return {
			systemPrompt: `\n\n# Repo Guard Policy\n\nYou are working inside a git repository at ${ctx.cwd}.\n\n**CRITICAL: Do NOT write, modify, move, or delete files outside this repository.**\n\n- Never write files (using \`write\`, \`edit\`, or bash) to paths outside this git repo\n- Never run destructive bash commands (rm, chmod, mv, cp) targeting paths outside this repo\n- Read-only operations (read, ls, find, grep) outside the repo are fine for reference\n\nIf you need to access files outside the repo for reference, read them but do not modify them.\n`,
		};
	});

	pi.on("tool_call", async (event, ctx) => {
		const flagResult = pi.getFlag("repo-guard-strict");
		strictMode = flagResult === true;

		// Initialize git root lazily on first tool call
		if (!gitRootChecked) {
			gitRoot = await findGitRoot(ctx.cwd, (cmd, args) =>
				pi.exec(cmd, args) as Promise<{ code: number; stdout: string; stderr: string }>,
			);
			gitRootChecked = true;
			if (!gitRoot) {
				ctx.ui.setStatus("repo-guard", "⚠ No git repo detected (no protection)");
			} else {
				try {
					const rel = relative(ctx.cwd, gitRoot);
					ctx.ui.setStatus("repo-guard", `✓ Git: ${rel || "."}`);
				} catch {
					ctx.ui.setStatus("repo-guard", `✓ Git: ${gitRoot}`);
				}
			}
		}

		// If no git root found, allow everything (no false positives in non-repo dirs)
		if (!gitRoot) {
			return undefined;
		}

		// --- Handle write tool ---
		if (isToolCallEventType("write", event)) {
			const targetPath = resolve(event.input.path);
			if (!isInsideRepo(targetPath, gitRoot)) {
				const rel = relative(gitRoot, targetPath);
				const msg = strictMode
					? `blocked`
					: `This write would create/modify a file outside the repo: ../${rel}`;

				if (ctx.hasUI) {
					const allowed = await confirmDestructiveOutside(
						ctx,
						"write",
						gitRoot,
						msg,
						strictMode,
					);
					if (!allowed) {
						return { block: true, reason: `Repo Guard: write outside git repo (${rel})` };
					}
				} else {
					return { block: true, reason: `Repo Guard: write outside git repo (${rel})` };
				}
			}
			return undefined;
		}

		// --- Handle edit tool ---
		if (isToolCallEventType("edit", event)) {
			// Edit tool input has a path field
			const editInput = event.input as Record<string, unknown>;
			const filePath = editInput.path as string | undefined;
			if (filePath) {
				const targetPath = resolve(filePath);
				if (!isInsideRepo(targetPath, gitRoot)) {
					const rel = relative(gitRoot, targetPath);
					const msg = strictMode ? `blocked` : `This edit would modify a file outside the repo: ../${rel}`;

					if (ctx.hasUI) {
						const allowed = await confirmDestructiveOutside(
							ctx,
							"edit",
							gitRoot,
							msg,
							strictMode,
						);
						if (!allowed) {
							return { block: true, reason: `Repo Guard: edit outside git repo (${rel})` };
						}
					} else {
						return { block: true, reason: `Repo Guard: edit outside git repo (${rel})` };
					}
				}
			}
			return undefined;
		}

		// --- Handle bash tool ---
		if (isToolCallEventType("bash", event)) {
			const command = event.input.command;

			// Check if the command matches a destructive pattern
			const destructiveMatch = isDestructiveCommand(command);
			if (!destructiveMatch) {
				return undefined; // Not a destructive command
			}

			// Extract file paths from the command
			const pathAnalysis = hasDestructivePathOutsideRepo(command, gitRoot);
			if (!pathAnalysis) {
				return undefined; // Destructive but all targets are inside the repo
			}

			const targets = pathAnalysis.outsidePaths.join(", ");
			const extra = strictMode
				? `All access outside repo is blocked (strict mode).`
				: `Targets outside repo: ${targets}`;

			if (ctx.hasUI) {
				const allowed = await confirmDestructiveOutside(
					ctx,
					"bash",
					gitRoot,
					extra,
					strictMode,
				);
				if (!allowed) {
					return {
						block: true,
						reason: `Repo Guard: destructive bash command targeting outside repo (${destructiveMatch.desc}). Targets: ${targets}`,
					};
				}
			} else {
				return {
					block: true,
					reason: `Repo Guard: destructive bash command targeting outside repo (${destructiveMatch.desc}). Targets: ${targets}`,
				};
			}
			return undefined;
		}

		// --- Read-only tools (read, ls, find, grep) - always allowed ---
		// These are read-only and don't cause damage

		return undefined;
	});

	pi.on("session_shutdown", async (event, ctx) => {
		ctx.ui.setStatus("repo-guard", undefined);
	});
}
