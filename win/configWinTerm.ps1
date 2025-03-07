<#
    .SYNOPSIS
    Configures Windows Terminal with preferred settings for appearance and themes.

    .DESCRIPTION
    See details in  https://learn.microsoft.com/en-us/windows/terminal/customize-settings/startup
#>
[CmdletBinding()]
param ()

$ErrorActionPreference = 'Stop'

$wtSettingsFile = (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json")
$wtFragmentsRoot = (Join-Path $env:LOCALAPPDATA "Microsoft\Windows Terminal\Fragments")

function winTermConfiguration {
    if (-not (Test-Path $wtSettingsFile)) {
        Write-Warning "Windows Terminal settings file not found: $wtSettingsFile"
        # TODO: launch wt.exe to have it create its default settings file
        return
    }

    $_s = Get-Content -Path $wtSettingsFile -Encoding utf8 | ConvertFrom-Json

    # sigh, PS is weird, need to add non-existing properties to the object before setting them
    $_s | Add-Member -MemberType NoteProperty -Force -Name confirmCloseAllTabs -Value $false
    $_s | Add-Member -MemberType NoteProperty -Force -Name copyFormatting -Value "none"
    $_s | Add-Member -MemberType NoteProperty -Force -Name copyOnSelect -Value $true
    $_s | Add-Member -MemberType NoteProperty -Force -Name initialCols -Value 150
    $_s | Add-Member -MemberType NoteProperty -Force -Name initialRows -Value 50
    $_s | Add-Member -MemberType NoteProperty -Force -Name multiLinePasteWarning -Value $false
    $_s | Add-Member -MemberType NoteProperty -Force -Name useAcrylicInTabRow -Value $true

    $_s.profiles.defaults | Add-Member -MemberType NoteProperty -Force -Name adjustIndistinguishableColors -Value "always"
    $_s.profiles.defaults | Add-Member -MemberType NoteProperty -Force -Name bellStyle -Value "taskbar"
    $_s.profiles.defaults | Add-Member -MemberType NoteProperty -Force -Name cursorShape -Value "vintage"
    $_s.profiles.defaults | Add-Member -MemberType NoteProperty -Force -Name cursorHeight -Value 25
    $_s.profiles.defaults | Add-Member -MemberType NoteProperty -Force -Name font -Value (New-Object PSObject)
    $_s.profiles.defaults.font | Add-Member -MemberType NoteProperty -Force -Name face -Value "JetBrainsMono Nerd Font Mono"
    $_s.profiles.defaults.font | Add-Member -MemberType NoteProperty -Force -Name size -Value 10.0
    $_s.profiles.defaults.font | Add-Member -MemberType NoteProperty -Force -Name weight -Value light
    $_s.profiles.defaults | Add-Member -MemberType NoteProperty -Force -Name opacity -Value 86
    $_s.profiles.defaults | Add-Member -MemberType NoteProperty -Force -Name useAcrylic -Value $true

    # schema must exist before setting it:
    # $_s.profiles.defaults | Add-Member -MemberType NoteProperty -Force -Name colorScheme -Value "Catppuccin Frappe"

    Set-Content -Path $wtSettingsFile -Encoding utf8 -Value ($_s | ConvertTo-Json -Depth 20)
    Write-Host "Windows Terminal settings updated."
}

winTermConfiguration
