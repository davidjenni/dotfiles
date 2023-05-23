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
ensureModule ZLocation
# alternative: https://github.com/badmotorfinger/z

addToPath "$env:ProgramFiles\Git\usr\bin"

$env:LESS="-i -M -q -x4 -R"
$env:LESSBINFMT="*d[%02x]"
$env:VISUAL="code --wait"

if ($null -ne (Get-Alias -Name curl -ErrorAction SilentlyContinue)) {
    Remove-Item alias:\curl -Force
}

Remove-Item alias:\rm -Force    # favor git's rm.exe

# nudge WinPS and pwsh to use bat/less instead of more:
Set-Alias -Name 'more' -Value 'less'
$env:PAGER='bat'

Remove-Item alias:\cat -Force
Set-Alias -Name 'cat' bat
Set-Alias -Name 'l' bat
Set-Alias -Name 'vi' nvim
Set-Alias -Name 'vim' nvim

# scoop install lsd
# https://github.com/Peltoche/lsd
# https://github.com/ogham/exa not yet for Windows

Remove-Item alias:\ls -force
# lsd doesn't work properly on domain joined machines:
$inDomain = $false
try {
    # $inDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain().Name -ne $null
    $inDomain = ($env:USERDNSDOMAIN.ToLower().Contains('.com'))
}
catch {
}
if ($inDomain) {
    function ls { param ( [string[]] [Parameter(ValueFromRemainingArguments)] $rest ) Get-ChildItem -Name $rest }
    function ll { param ( [string[]] [Parameter(ValueFromRemainingArguments)] $rest ) Get-ChildItem $rest }
} else {
    # https://github.com/Peltoche/lsd/pull/297
    # https://github.com/Peltoche/lsd/pull/475#issuecomment-777101864
    function ls { param ( [string[]] [Parameter(ValueFromRemainingArguments)] $rest ) lsd -F --group-directories-first --extensionsort $rest }
    function ll { param ( [string[]] [Parameter(ValueFromRemainingArguments)] $rest ) & ls -l $rest }
}


function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function bb { Push-Location $env:USERPROFILE }
function c { param ([string] $folder) Set-Location -Path $folder }
function cc { param ([string] $folder) if (!$folder) { Get-Location -Stack} else { Push-Location -Path $folder } }
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

Invoke-Expression (&starship init powershell)
# needs to be late in profile script
Enable-TransientPrompt
