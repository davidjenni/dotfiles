<#
    .SYNOPSIS
    Bootstrap Windows command prompts (cmd, PS, PSCore) with my dotfiles and apps.

    .DESCRIPTION
    to bootstrap directly from github, run these 2 cmdlets in a PowerShell prompt:
    > Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    > irm 'https://raw.githubusercontent.com/davidjenni/dotfiles/main/bootstrap.ps1' | iex
#>
[CmdletBinding()]
param (
    [ValidateSet('clone', 'bootstrap', 'apps', 'env', IgnoreCase = $true)]
    [Parameter(Position = 0)] [string]
    # verb that indicates stage:
    #  clone:       clone the dotfiles repo and continue with 'bootstrap' etc.
    #  bootstrap:   setup PS, package managers, git. Includes 'apps' and 'env'.
    #  apps:        install apps via winget and scoop
    #  env:         setups consoles and configurations for git, neovim, PowerShell etc.
    $verb = 'clone',
    [Parameter()] [string]
    # user name for git commits, defaults to '$env:USERNAME@$env:COMPUTERNAME'
    $userName = $null,
    [Parameter()] [string]
    # email address for git commits, defaults to existing git config or prompts for input
    $email = $null
)

$ErrorActionPreference = 'Stop'

$originGitHub='https://github.com/davidjenni/dotfiles.git'
$dotPath=(Join-Path $env:USERPROFILE 'dotfiles')

# should be the default on all Win10+, but just in case...
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor
                                              [Net.SecurityProtocolType]::Tls12

function ensureLocalGit {
    if (Get-Command 'git' -ErrorAction SilentlyContinue) {
        return
    }

    # bootstrap with a local git to avoid early elevating for winget and the git installer:
    $localGitFolder = (Join-Path $env:USERPROFILE (Join-Path "Downloads" "localGit"))
    Write-Host "Installing ad-hoc git into $localGitFolder..."

    $gitUrl = Invoke-RestMethod 'https://api.github.com/repos/git-for-windows/git/releases/latest' |
        Select-Object -ExpandProperty 'assets' |
        Where-Object { $_.name -Match 'MinGit' -and $_.name -Match '64-bit' -and $_.name -notmatch 'busybox' } |
        Select-Object -ExpandProperty 'browser_download_url'
    $localGitZip = (Join-Path $localGitFolder "MinGit.zip")
    New-Item -ItemType Directory -Path $localGitFolder -Force | Out-Null
    # Invoke-RestMethod with its progress bar is about 10x slower than WebClient.DownloadFile...
    (New-Object Net.WebClient).DownloadFile($gitUrl, $localGitZip)
    Expand-Archive -Path $localGitZip -DestinationPath $localGitFolder -Force

    $gitPath = (Join-Path $localGitFolder 'cmd')
    $env:Path += ";$gitPath"
}

function cloneDotfiles {
    Write-Host "Cloning $originGitHub -> $dotPath"
    Write-Host -NoNewline "OK to proceed with setup? [Y/n] "
    $answer = (Read-Host).ToUpper()
    if ($answer -ne 'Y' -and $answer -ne '') {
        Write-Warning "Aborting."
        return 4
    }

    ensureLocalGit

    if (-not $userName -or $userName -eq '') {
        $userName = (& git config --global --get user.name)
    }
    if (-not $username -or $username -eq '') {
        $username = "$env:USERNAME@$env:COMPUTERNAME"
    }

    if (-not $email -or $email -eq '') {
        $email = (& git config --global --get user.email)
    }
    if (-not $email -or $email -eq '') {
        $email = Read-Host "Enter your email address for git commits"
        if ($email -eq '') {
            Write-Warning "Need email address, aborting."
            return 3
        }
    }

    & git.exe config --global user.name $userName
    # https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-email-preferences/setting-your-commit-email-address
    & git.exe config --global user.email $email

    & git clone $originGitHub $dotPath
    return 0
}

function modernizeWinPowerShell {
    if ($PSVersionTable.PSEdition -eq "Core") {
        Write-Host "Core edition detected, skipping modernization."
        return
    }
    Write-Host "Modernizing PowerShell $($PSVersionTable.PSVersion)..."

    Write-Host " - Installing NuGet provider..."
    Import-Module PackageManagement -ErrorAction SilentlyContinue
    if (-not (Get-PackageSource -ProviderName nuget -erroraction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser | Out-Null
        Register-PackageSource -Provider NuGet -Name nugetRepository -Location https://www.nuget.org/api/v2 -Force -Trusted | Out-Null
    }

    function upgradeModule {
        param (
            [string] $name,
            [Version] $minVersion
        )
        Write-Host -NoNewline " - Checking $($name.PadRight(40))"
        $info = Import-Module -Name $name -PassThru -ErrorAction SilentlyContinue
        if ($info -and $info.Version -ge $minVersion) {
            Write-Host "(up-to-date: $minVersion)"
            return
        }
        Write-Host -NoNewline "upgrading to $minVersion"
        Remove-Module -Name $name -Force -ErrorAction SilentlyContinue
        Install-Module -Name $name -MinimumVersion $minVersion -AllowClobber -Force -Scope CurrentUser
        Import-Module -Name $name -Force
        Write-Host "; done."
    }

    # upgradeModule 'PackageManagement' '1.4.8.1'

    Write-Host " - PSGallery:"
    $psgallery = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
    if (-not $psgallery -or $psgallery.InstallationPolicy -ne 'Trusted') {
        Write-Host "   - Registering PSGallery..."
        Register-PSRepository -Default -ErrorAction SilentlyContinue
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }

    upgradeModule 'PowerShellGet' '2.2.5'
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

    upgradeModule 'PSReadLine' '2.2.6'
}

function ensureWinGet {
    if (Get-Command "winget.exe" -ErrorAction SilentlyContinue) {
        Write-Host "winget already installed."
        return
    }
    if ($PSVersionTable.PSEdition -ne "Desktop") {
        Write-Host "Installing winget requires Desktop PowerShell, aborting."
        return
    }

    Write-Host "Installing winget..."
    # https://learn.microsoft.com/en-us/troubleshoot/developer/visualstudio/cpp/libraries/c-runtime-packages-desktop-bridge#how-to-install-and-update-desktop-framework-packages
    $vc14 = (Join-Path $env:TEMP "vc14.appx")
    (New-Object Net.WebClient).DownloadFile('https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx', $vc14)
    Add-AppxPackage -Path $vc14

    $uixaml = Install-Package Microsoft.UI.Xaml -scope currentuser -RequiredVersion 2.7.3 -force
    Add-AppxPackage -Path $env:LOCALAPPDATA\PackageManagement\nuget\Packages\Microsoft.UI.Xaml.$($uixaml.Version)\tools\AppX\x64\Release\Microsoft.UI.Xaml.*.appx

    # https://github.com/microsoft/winget-cli/releases
    Add-AppxPackage -Path https://github.com/microsoft/winget-cli/releases/download/v1.5.441-preview/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
}

function ensureScoop {
    if (Get-Command "scoop" -ErrorAction SilentlyContinue) {
        Write-Host "scoop already installed."
        return
    }

    # https://scoop.sh/
    Write-Host "Installing scoop..."
    Invoke-RestMethod 'get.scoop.sh' | Invoke-Expression
    # TODO: check if elevated and run as admin if needed:
    # https://stackoverflow.com/questions/60209449/how-to-elevate-a-powershell-script-from-within-a-script
    # by default, scoop does not like to run elevated:
    # Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
    $scoopPath = (Join-Path $env:USERPROFILE (Join-Path 'scoop' 'shims'))
    $env:Path += ";$scoopPath"
}

function mklink {
    param (
        [Parameter(Mandatory = $true)] [string] $target,
        [Parameter(Mandatory = $true)] [string] $link
    )
    if (Test-Path $link) {
        Remove-Item -Path $link
    }
    Write-Host "Creating link $link -> $target"
    New-Item -ItemType SymbolicLink -Path $link -value $target
}

function installScoopApps {
    Write-Host "Installing apps via scoop..."
    & scoop install 7zip bat delta fd fzf helix less lsd neovim nuget nvm ripgrep starship tre-command
    & scoop bucket add nerd-fonts
    & scoop install hack-nf-mono hack-nf
    & scoop bucket add extras
    & scoop install alacritty git-credential-manager ilspy vcredist2022
}

function installWinGetApps {
    Write-Host "Installing apps via winget..."
    # requires elevation:
    # TODO: https://stackoverflow.com/questions/60209449/how-to-elevate-a-powershell-script-from-within-a-script
    & winget install Git.Git --accept-source-agreements --disable-interactivity
    # TODO: need to figure out how this interacts with a soft-linked gitconfig from this repo
    # TODO: one option: loop over simple git setting file and make 'git config --global key value' calls

    # requires elevation:
    & winget install Microsoft.Powershell --accept-source-agreements --disable-interactivity

    # per user, no elevation required:
    & winget install Microsoft.WindowsTerminal --accept-source-agreements --disable-interactivity
    & winget install Microsoft.VisualStudioCode --accept-source-agreements --disable-interactivity
}

function bootstrap {
    modernizeWinPowerShell
    ensureWinGet
    ensureScoop
}

function installApps {
    installScoopApps
    installWinGetApps
}

function setupShellEnvs {
    Write-Host "setting cmd console properties:"
    $consolePath='HKCU\Console'
    & reg add $consolePath /v QuickEdit         /d 0x1              /t REG_DWORD /f | Out-Null
    & reg add $consolePath /v WindowSize        /d 0x00320078       /t REG_DWORD /f | Out-Null
    & reg add $consolePath /v ScreenBufferSize  /d 0x23280078       /t REG_DWORD /f | Out-Null
    & reg add $consolePath /v FontFamily        /d 0x36             /t REG_DWORD /f | Out-Null
    & reg add $consolePath /v HistoryBufferSize /d 0x64             /t REG_DWORD /f | Out-Null
    & reg add $consolePath /v FaceName          /d "Hack Nerd Font Mono" /t REG_SZ  /f | Out-Null
    & reg add $consolePath /v FontSize          /d 0x00100000       /t REG_DWORD /f | Out-Null

    $win32rc=(Join-Path $dotPath (Join-Path 'win' 'win32-rc.cmd'))
    Write-Host "setting up cmd autorun: $win32rc"
    & reg add "HKCU\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d $win32rc /f | Out-Null

    # TODO: needs elevation
    # Write-Host "remap CapsLock to LeftCtrl key:"
    # # see http://www.experts-exchange.com/OS/Microsoft_Operating_Systems/Windows/A_2155-Keyboard-Remapping-CAPSLOCK-to-Ctrl-and-Beyond.html
    # # http://msdn.microsoft.com/en-us/windows/hardware/gg463447.aspx
    # & reg add "HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout" /v "Scancode Map" /d 0000000000000000020000001D003A0000000000 /t REG_BINARY /f | Out-Null
    # Write-Host "CapsLock remapped, will be effective after next system reboot."

    # TODO: initialize Terminal, but its .json file won't exist until after the first launch
    # $env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
}

function main {
    param (
        [Parameter(Mandatory = $true)] [string] $verbAction
    )

    Write-Verbose "PS: $($PSVersionTable.PSVersion)-$($PSVersionTable.PSEdition)"
    switch ($verbAction) {
        'clone' {
            Write-Host
            if (Test-Path (Join-Path $dotPath '.git')) {
                Write-Host "local git repo already exists, skipping."
                # continue in-proc:
                main bootstrap
                return
            }

            $rc = cloneDotfiles
            if ($rc -ne 0) {
                Write-Error "Cloning dotfiles failed, aborting."
                return
            }
            # continue with now-local bootstrap.ps1 from cloned repo:
            # still stick with desktop PS since PSCore is not necessarily installed yet
            $script= (Join-Path $dotPath 'bootstrap.ps1')
            Write-Host "Continue $script in child process"
            Start-Process -PassThru -NoNewWindow -FilePath "powershell.exe" -ArgumentList "-NoProfile -File $script bootstrap" |
                Wait-Process
        }

        'bootstrap' {
            Write-Host "Bootstrapping..."
            bootstrap
            installApps
            setupShellEnvs
            Write-Host "Done (bootstrap)."
            exit
        }

        'apps' { installApps }

        'env' { setupShellEnvs }
    }

    # TODO: either symlink or copy gitconfig, profile.ps1, init.lua etc to $env:USERPROFILE
    Write-Host "Done."
}

main $verb
