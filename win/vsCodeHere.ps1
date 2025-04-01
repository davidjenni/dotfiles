#Requires -RunAsAdministrator

<#
    .SYNOPSIS
    Configure FileExplorer context menu for VSCode

    .DESCRIPTION
    Discovers the VSCode installation path and adds a context menu entry to open the current folder in VSCode.
    This script must be run as administrator to modify the registry.
#>
[CmdletBinding()]
param ()

$ErrorActionPreference = 'Stop'

$vsCodePath = (Get-Command -Name "code" -ErrorAction SilentlyContinue)
if (-not $vsCodePath) {
    Write-Warning "VSCode not found in PATH. Please install VSCode via 'winget install Microsoft.VisualStudioCode'"
    exit 1
}
# code.cmd is in a subfolder .../bin, but the code.exe is in its parent folder
$vsCodeExe = Get-Command (Join-Path (Split-Path -Parent (Split-Path $vsCodePath.Source -Parent)) "Code.exe")
Write-Verbose "Found VSCode version $($vsCodeExe.Version) in $($vsCodeExe.Source)"

$regKeys = @(
    'Registry::HKEY_CLASSES_ROOT\`*\shell'
    'Registry::HKEY_CLASSES_ROOT\Directory\shell',
    'Registry::HKEY_CLASSES_ROOT\Directory\background\shell'
)

foreach ($regKey in $regKeys) {
    if (-not (Test-Path -Path $regKey\VSCode)) {
        Write-Verbose "Creating $regKey\VSCode..."
        New-Item -Path  $regKey -Name 'VSCode' -Value 'Open with Code' -Force -ErrorAction SilentlyContinue | Out-Null
        New-ItemProperty -Path $regKey\VSCode -Name 'Icon' -Value "$($vsCodeExe.Source)" -Force -ErrorAction SilentlyContinue | Out-Null
        New-Item -Path $regKey\VSCode -Name 'command' -Value "`"$($vsCodeExe.Source)`" `"%1`"" -Force -ErrorAction SilentlyContinue | Out-Null
    }
}
Write-Verbose "VSCode context menu entries created successfully."
