function ensureModule {
    param (
        [Parameter()] [string] $name,
        [Parameter()] [string] $loadForHost
    )

    if (-not (Get-Module -ListAvailable -Name $name)) {
        Write-Host "Installing $name..."
        Find-Module -Name $name | Install-Module -AllowClobber
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

# http://psget.net/     cannot co-exist with PS gallery's Install-Module
# ensureModule PsGet

# Install-Module as recommended by https://powershellgallery.com
ensureModule PowerShellGet
# https://github.com/PowerShell/PSReadLine*
ensureModule PSReadLine 'ConsoleHost'
# https://github.com/dahlbyk/posh-git
ensureModule posh-git
$GitPromptSettings.DefaultPromptPrefix = '($((get-date).tostring("HH:mm:ss"))) '
$GitPromptSettings.DefaultPromptSuffix = '`n$(''>'' * ($nestedPromptLevel + 1)) '
$GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true

# https://github.com/jrjurman/powerls
# Install-Module -Name PowerLS
# Set-Alias -Name ls -Value PowerLS -Option AllScope

# see also: https://github.com/janikvonrotz/awesome-powershell

addToPath "$env:HOME\dotfiles\win"
addToPath "$env:HOME\PuTTY"
addToPath "$env:ProgramFiles\7-Zip"
addToPath "$env:HOME\NTTools"
addToPath "$env:ProgramFiles\Git\usr\bin"

$env:LESS="-i -M -N -q -x4 -R"
$env:LESSBINFMT="*d[%02x]"
$env:VISUAL="gvim.exe"

# replay cmd git secrets env variables into PS:
Get-Content "$env:HOME/.gitSecrets.cmd" | .{process{
    if ($_ -match '^set ([^=]+)=(.*)') {
        $gitVar = $matches[1]
        $gitValue = $matches[2]
        Set-Item -Path "Env:$gitVar" -Value "$gitValue"
    }
}}

Remove-Item alias:\curl
Set-Alias -Name "l" less

function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function bb { Push-Location $env:HOME }
function c { param ([string] $folder) Set-Location -Path $folder }
function cc { param ([string] $folder) if (!$folder) { Get-Location -Stack} else { Push-Location -Path $folder } }
function ff { param ([string] $pattern) Get-ChildItem -Path . -Filter "$pattern" -Recurse -ErrorAction SilentlyContinue -Force |Select-Object -Property FullName }
function which { param ([string] $cmd) Get-Command $cmd }

