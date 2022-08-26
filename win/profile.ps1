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
        Write-Host "Module $name not locally present, check if known..."
        if (-not (Get-Module -ListAvailable -Name $name)) {
            Write-Verbose "Installing $name..."
            $info = Find-Module -Name $name -ErrorAction SilentlyContinue
            if ($null -eq $info) {
                Write-Host "Cannot find module $name in gallery, cannot install."
                return
            }

            # Install-Module as recommended by https://powershellgallery.com
            ensureModule PowerShellGet $loadForHost

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

# Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
# for more modules, see also: https://github.com/janikvonrotz/awesome-powershell
# https://hodgkins.io/ultimate-powershell-prompt-and-git-setup

# http://psget.net/     cannot co-exist with PS gallery's Install-Module
# ensureModule PsGet

# https://github.com/PowerShell/PSReadLine
# upgrading if needed: https://github.com/PowerShell/PSReadLine#upgrading
# elevated cmd: {pwsh | powershell} -noprofile -command "Install-Module PSReadLine -Force -SkipPublisherCheck"
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
Invoke-Expression (&starship init powershell)

# https://github.com/vors/ZLocation
ensureModule ZLocation

# https://scoop.sh/
# https://www.nerdfonts.com/font-downloads
# https://github.com/dduan/tre

# Set-PSRepository -Name PSGallery -InstallationPolicy Untrusted

# $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
# if (Test-Path($ChocolateyProfile)) {
#   Import-Module "$ChocolateyProfile"
# }

addToPath "$env:USERPROFILE\dotfiles\win"
addToPath "$env:USERPROFILE\PuTTY"
addToPath "$env:ProgramFiles\7-Zip"
addToPath "$env:USERPROFILE\NTTools"
addToPath "$env:ProgramFiles\Git\usr\bin"

$env:LESS="-i -M -N -q -x4 -R"
$env:LESSBINFMT="*d[%02x]"
$env:VISUAL="code --wait"

# replay cmd git secrets env variables into PS:
Get-Content "$env:USERPROFILE/.gitSecrets.cmd" | .{process{
    if ($_ -match '^set ([^=]+)=(.*)') {
        $gitVar = $matches[1]
        $gitValue = $matches[2]
        Set-Item -Path "Env:$gitVar" -Value "$gitValue"
    }
}}

if ($null -ne (Get-Alias -Name curl -ErrorAction SilentlyContinue)) {
    Remove-Item alias:\curl -Force
}
Set-Alias -Name "l" less

function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function bb { Push-Location $env:USERPROFILE }
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
