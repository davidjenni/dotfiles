function ensureModule {
    param (
        [Parameter()] [string] $name,
        [Parameter()] [string] $loadForHost
    )

    if (-not (Get-Module -ListAvailable -Name $name)) {
        Write-Host "Installing $name..."
        Find-Module -Name $name | Install-Module -AllowClobber -Scope CurrentUser
    }
    if (-not $loadForHost -or ($loadForHost -eq $host.Name)) {
        Import-Module -Name $name
    }
}

function addToPath {
    param ( [string]$directory )

    if (Test-Path $directory) {
        $env:Path += ";$directory"
    }
}

# Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
# for more modules, see also: https://github.com/janikvonrotz/awesome-powershell
# https://hodgkins.io/ultimate-powershell-prompt-and-git-setup

# http://psget.net/     cannot co-exist with PS gallery's Install-Module
# ensureModule PsGet

# Install-Module as recommended by https://powershellgallery.com
ensureModule PowerShellGet
# https://github.com/PowerShell/PSReadLine*
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

# https://github.com/posh-projects/Tree
# requires: https://chocolatey.org/packages/tree/
ensureModule Tree

# https://github.com/vors/ZLocation
ensureModule ZLocation

# https://github.com/jrjurman/powerls
# Install-Module -Name PowerLS
# Set-Alias -Name ls -Value PowerLS -Option AllScope
# Set-PSRepository -Name PSGallery -InstallationPolicy Untrusted

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}


addToPath "$env:HOME\dotfiles\win"
addToPath "$env:HOME\PuTTY"
addToPath "$env:ProgramFiles\7-Zip"
addToPath "$env:HOME\NTTools"
addToPath "$env:ProgramFiles\Git\usr\bin"

$env:LESS="-i -M -N -q -x4 -R"
$env:LESSBINFMT="*d[%02x]"
$env:VISUAL="code --wait"

# replay cmd git secrets env variables into PS:
Get-Content "$env:HOME/.gitSecrets.cmd" | .{process{
    if ($_ -match '^set ([^=]+)=(.*)') {
        $gitVar = $matches[1]
        $gitValue = $matches[2]
        Set-Item -Path "Env:$gitVar" -Value "$gitValue"
    }
}}

if ((Get-Alias -Name curl -ErrorAction SilentlyContinue) -ne $null) {
    Remove-Item alias:\curl -Force
}
Set-Alias -Name "l" less

function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function bb { Push-Location $env:HOME }
function c { param ([string] $folder) Set-Location -Path $folder }
function cc { param ([string] $folder) if (!$folder) { Get-Location -Stack} else { Push-Location -Path $folder } }
function ff { param ([string] $pattern) Get-ChildItem -Path . -Filter "$pattern" -Recurse -ErrorAction SilentlyContinue -Force |Select-Object -Property FullName }
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
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $Function:OnViModeChange
Set-PSReadlineOption -EditMode vi
Set-PSReadLineOption -BellStyle None


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
    &pac complete -s "$($commandAst.ToString())" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
