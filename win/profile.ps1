# this profile assumes PowerShell Core (pwsh)
#
# ===== Prerequisits that need one-off installation handled by bootstrap.ps1:
#
# 1) install scoop:
# 2) then install starship.rs (https://starship.rs/):
# > scoop install starship
# 3) install a NerdFont from https://www.nerdfonts.com/, e.g. Hack Nerd Font, JetBrainsMono Nerd Font
# 4) Configure Windows Terminal and/or VS Code terminal to use the installed nerd font
#
# https://thirty25.com/posts/2021/12/optimizing-your-powershell-load-times

if ($PSVersionTable.PSEdition -ne 'Core') {
    Write-Host "This profile is for PowerShell Core (pwsh) only."
    return
}

[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

function ensureModule {
    param (
        [Parameter()] [string] $name,
        [Parameter()] [string] $loadForHost
    )

    $retryImport = $false
    do {
        if (-not $loadForHost -or ($loadForHost -eq $host.Name)) {
            Write-Host  -NoNewline "Loading $($name.PadRight(40))"
            $foundModule = Import-Module -Name $name -PassThru -ErrorAction SilentlyContinue
            if ($null -ne $foundModule) {
                Write-Host "`u{2705}" # checkmark emoji
                return
            }
        } else {
            Write-Verbose "skipping import of module $name, selected host $loadForHost is not matching current host: $($host.Name)"
            return
        }

        $retryImport = $true
        Write-Verbose "Module $name not locally present, check if known..."
        if (-not (Get-Module -ListAvailable -Name $name)) {
            Write-Verbose "Installing $name..."
            $info = Find-Module -Name $name -ErrorAction SilentlyContinue
            if ($null -eq $info) {
                Write-Host "Cannot find module $name in gallery, cannot install."
                return
            }

            Write-Host  -NoNewline "Installing... "
            Install-Module -Name $name -AllowClobber -Scope CurrentUser
        }
    } while (
        $retryImport
    )
}

function addToPath {
    param ( [string]$directory )

    if (Test-Path $directory) {
        $env:Path += ";$directory"
    }
}


# https://github.com/PowerShell/PSReadLine
ensureModule PSReadLine 'ConsoleHost'
# https://github.com/mmims/PSConsoleTheme
ensureModule PSConsoleTheme
# https://github.com/dahlbyk/posh-git
ensureModule posh-git
# NOTE: if git's ssh-agent was run, posh-git will read SSH_AGENT_PID from: %TEMP%\.ssh
$GitPromptSettings.DefaultPromptPrefix = '($((get-date).tostring("HH:mm:ss"))) '
$GitPromptSettings.DefaultPromptSuffix = '`n$(''>'' * ($nestedPromptLevel + 1)) '
$GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true
# Set-Alias ssh-agent "$env:ProgramFiles\git\usr\bin\ssh-agent.exe"
# Set-Alias ssh-add "$env:ProgramFiles\git\usr\bin\ssh-add.exe"
# Set-Alias ssh "$env:ProgramFiles\git\usr\bin\ssh.exe"
# Start-SshAgent
$env:GIT_SSH = $((Get-Command ssh).Source)

# https://github.com/vors/ZLocation
# ensureModule ZLocation

addToPath "$env:ProgramFiles\Git\usr\bin"

$env:LESS="-i -M -q -x4 -R"
$env:LESSBINFMT="*d[%02x]"
$env:VISUAL="code --wait"

if ($null -ne (Get-Alias -Name curl -ErrorAction SilentlyContinue)) {
    Remove-Item alias:\curl -force -ErrorAction SilentlyContinue | Out-Null
}

Remove-Item alias:\rm -force -ErrorAction SilentlyContinue | Out-Null # favor git's rm.exe

# nudge WinPS and pwsh to use bat/less instead of more:
Set-Alias -Name 'more' -Value 'less'
$env:PAGER='bat'

Remove-Item alias:\cat -Force
Set-Alias -Name 'cat' bat
Set-Alias -Name 'l' bat
Set-Alias -Name 'v' nvim
Set-Alias -Name 'vi' nvim
Set-Alias -Name 'vim' nvim


# https://github.com/eza-community/eza
Remove-Item alias:\ls -force -ErrorAction SilentlyContinue | Out-Null
function ls { param ( [string[]] [Parameter(ValueFromRemainingArguments)] $rest )
    # hacky attempt to handle wilrdcard expansion:
    # https://github.com/eza-community/eza/issues/337
    if ($rest -ne $null) {
        $args = $rest | Where-Object { $_.StartsWith("-") }
        $files = $rest | Get-Item -ErrorAction SilentlyContinue | ForEach-Object { $_.Name }
    }
    eza --sort ext --group-directories-first --classify --color=auto --icons=never $args $files
}
function ll { param ( [string[]] [Parameter(ValueFromRemainingArguments)] $rest )  ls -l $rest }

# setup eza themes: https://github.com/eza-community/eza-themes?tab=readme-ov-file
$env:EZA_CONFIG_DIR = "$env:USERPROFILE\dotfiles\eza-themes"

function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function bb { Push-Location $env:USERPROFILE }
function cc { param ([string] $folder) if (!$folder) { Get-Location -Stack} else { Push-Location -Path $folder } }

# cd to directory with fuzzy search:
function c { param ([string] $optSearchTerm)
    $optFzfSearchTerm=($optSearchTerm -ne $null) ? "--query=$optSearchTerm" : $null
    (&fd --type d `
        | &fzf $optFzfSearchTerm --height=40% --layout=reverse --border --margin=1 --select-1 )`
        | Set-Location
}

# cd to git root:
function cg { param ()
    $root = (&git rev-parse --show-toplevel 2>&1)
    if ($LASTEXITCODE -eq 0) {
        Set-Location $root
    } else {
        Write-Host "Not in a git repo."
    }
}

# find files:
function ff { param ([string] $optSearchTerm)
    $optFzfSearchTerm=($optSearchTerm -ne $null) ? "--query=$optSearchTerm" : $null
     &fd $optSearchTerm --type f `
        | &fzf $optFzfSearchTerm --height=40% --layout=reverse --info=inline --border --margin=1 --preview='bat --color=always {}' --bind 'enter:execute(code {})'
}

# find in files content:
function fff {  param ([string] $optSearchTerm)
    $optFzfSearchTerm=($optSearchTerm -ne $null) ? "--query=$optSearchTerm" : $null
    &rg $optSearchTerm --smart-case --color=always --line-number --no-heading --smart-case  `
        | &fzf $optFzfSearchTerm --ansi --delimiter : --height=75% --layout=reverse --color 'hl:-1:underline,hl+:-1:underline:reverse' --border --margin=1 `
            --preview='bat --color=always {1} --highlight-line {2}' --bind 'enter:execute(code {1})'
}

function which { param ([string] $cmd) Get-Command $cmd }
function xx { exit }
function msb { param ( [string[]] [Parameter(ValueFromRemainingArguments)] $rest )
    & dotnet msbuild "-p:TreatWarningsAsErrors=true" "-nr:false" "-m" `
        "-clp:verbosity=minimal" `
        "-flp:Verbosity=normal;LogFile=$env:TMP\msbuild.log" `
        "-flp3:PerformanceSummary;Verbosity=diag;LogFile=$env:TMP\msbuild.diagnostics.log" `
        $rest
        Write-Host 'logs at: $env:TMP\msbuild.log & $env:TMP\msbuild.diagnostics.log'
}
function msbl { param ( [string[]] [Parameter(ValueFromRemainingArguments)] $rest )
    & dotnet msbuild "-nr:false" "-m" `
        "-clp:verbosity=minimal" `
        "-bl:$env:TMP\msbuild.binlog" `
        $rest
        Write-Host 'log at: $env:TMP\msbuild.binlog'
}
function msblnoref { param ( [string[]] [Parameter(ValueFromRemainingArguments)] $rest )
    & dotnet msbuild "-nr:false" "-m" `
        "-clp:verbosity=minimal" `
        "-bl:$env:TMP\msbuild.binlog" `
        "-p:BuildProjectReferences=false" `
        $rest
        Write-Host 'log at: $env:TMP\msbuild.binlog'
}

function OnViModeChange {
    if ($args[0] -eq 'Command') {
        # Set the cursor to a blinking block.
        Write-Host -NoNewLine "`e[1 q"
    } else {
        # Set the cursor to a blinking line.
        Write-Host -NoNewLine "`e[5 q"
    }
}

if ($host.Name -eq 'ConsoleHost') {
    # https://github.com/PowerShell/PSReadLine
    if ($PSVersionTable.PSEdition -ne 'Desktop') {
        Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $Function:OnViModeChange
    }
    Set-PSReadlineOption -EditMode vi
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -ShowToolTips
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    # https://devblogs.microsoft.com/powershell/announcing-psreadline-2-1-with-predictive-intellisense/
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    # fancy PSReadline profile settings:
    # https://github.com/PowerShell/PSReadLine/blob/master/PSReadLine/SamplePSReadLineProfile.ps1
}

# auto-complete for dotnet:
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    &dotnet complete "$($commandAst.ToString())" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# auto-complete for PowerApps CLI (pac):
Register-ArgumentCompleter -Native -CommandName pac -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    &pac complete -s "$($commandAst.ToString()) " | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# https://starship.rs/
function Invoke-Starship-PreCommand {
    $gitDir = (Get-GitDirectory)
    if ($null -ne $gitDir) {
        $currDir = "git: " + [System.IO.Path]::GetFileName([System.IO.Path]::GetDirectoryName((Get-GitDirectory)))
    } else {
        $currDir = $pwd
    }
#   $host.ui.Write("`e]0; $currDir `a")
  $host.ui.RawUI.WindowTitle = $currDir
}

# https://starship.rs/advanced-config/#transientprompt-in-powershell
function Invoke-Starship-TransientFunction {
  &starship module character
}

if ((Get-Command 'starship' -ErrorAction SilentlyContinue)) {
    Invoke-Expression (&starship init powershell)
    # needs to be late in profile script
    Enable-TransientPrompt
}

# Zoxide: load last to ensure its CD hooks work
if ((Get-Command 'zoxide' -ErrorAction SilentlyContinue)) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })

    function zz { param ([string] $optSearchTerm='')
        $optFzfSearchTerm = if ($optSearchTerm) { "--query=$optSearchTerm" } else { $null }
        (&zoxide query --list `
            | &fzf $optFzfSearchTerm --height=40% --layout=reverse --border --margin=1  --select-1 )`
            | Set-Location
    }
}

