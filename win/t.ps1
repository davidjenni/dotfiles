<#
    .SYNOPSIS
    Attach to a psmux session, either a formerly visited zoxide directory or named after the current directory '.'

    .DESCRIPTION
    PowerShell port of fish/functions/t.fish.
    Without arguments (or with a query string), pick a directory from zoxide's history via fzf.
    With '.', use the current directory. The session is named after the directory's leaf name.
    Creates the session if it doesn't exist yet, then attaches to it (or switches the client when
    already running inside the multiplexer).

    Uses psmux on Windows (https://github.com/psmux/psmux)

    .PARAMETER Query
    zoxide query to preselect in fzf, or '.' to use the current directory.

    .EXAMPLE
    t .

    .EXAMPLE
    t dotfiles
#>
[CmdletBinding()]
param (
    [Parameter(Position = 0)] [string] $Query,
    [Alias('h')] [switch] $Help
)

if ($Help) {
    Write-Host "Attach to a tmux session, either a formerly visited zoxide directory or named after the current directory '.'"
    Write-Host "Usage: t [zoxide_dir_query | '.'] [-h | -Help]"
    exit 1
}

$mux = (Get-Command 'psmux' -ErrorAction SilentlyContinue).Source

if ($Query -eq '.') {
    $dir = $PWD.Path
} else {
    $optFzfQuery = if ($Query) { "--query=$Query" } else { $null }
    $dir = (&zoxide query --list `
        | &fzf --ansi $optFzfQuery `
            --height=50% --layout=reverse-list --border --margin=1 --padding=1)
    if (-not $dir) {
        # user bailed out of fzf
        return
    }
}

$session = (Split-Path -Leaf $dir) -replace '[.:]', '_'

# '-t=' forces an exact match instead of tmux's prefix matching
& $mux has-session -t="$session" 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    & $mux new-session -d -s $session -c $dir
}

if ($env:TMUX -or $env:PSMUX_SESSION) {
    # already inside tmux: attaching would nest, so switch the client instead
    & $mux switch-client -t="$session"
} else {
    & $mux attach-session -t="$session"
}
