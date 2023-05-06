# to bootstrap, run this in a PowerShell prompt:
# > Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
# > irm 'https://raw.githubusercontent.com/davidjenni/dotfiles/main/bootstrap.ps1' | iex
#
[CmdletBinding()]
param (
    [Parameter()] [string] $userName = $env:USERNAME,
    [Parameter()] [string] $computerName = $env:COMPUTERNAME,
    [Parameter()] [string] $email = $null
)

$originGitHub='https://github.com/davidjenni/dotfiles.git'
$dotPath=(Join-Path $env:USERPROFILE 'dotfiles')

# should be the default on all Win10+, but just in case...
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor
                                              [Net.SecurityProtocolType]::Tls12

function modernizeWinPowerShell {
    if ($PSVersionTable.PSEdition -eq "Core") {
        Write-Host "Core edition detected, skipping modernization."
        return
    }
    Write-Host "Modernizing Desktop PowerShell $($PSVersionTable.PSVersion)..."

    Write-Host " - Installing NuGet provider..."
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser | Out-Null
    Register-PackageSource -Provider NuGet -Name nugetRepository -Location https://www.nuget.org/api/v2 -Force -Trusted | Out-Null

    function upgradeModule {
        param (
            [string] $name,
            [Version] $minVersion
        )
        Write-Host -NoNewline " - Checking $($name.PadRight(40))"
        $info = Import-Module -Name $name -PassThru -ErrorAction SilentlyContinue
        if ($null -ne $info -and $info.Version -ge $minVersion) {
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
    if ($null -eq $psgallery -or $psgallery.InstallationPolicy -ne 'Trusted') {
        Write-Host "   - Registering PSGallery..."
        Register-PSRepository -Default -ErrorAction SilentlyContinue
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }

    upgradeModule 'PowerShellGet' '2.2.5'
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

    upgradeModule 'PSReadLine' '2.2.6'
}

function ensureWinGet {
    $wget = Get-Command "winget.exe" -ErrorAction SilentlyContinue
    if ($null -ne $wget) {
        Write-Host "winget already installed."
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

function ensureLocalGit {
    $git = Get-Command 'git' -ErrorAction SilentlyContinue
    if ($null -ne $git) {
        return
    }

    # bootstrap with a local git to avoid early elevating for winget and the git installer:
    $localGitFolder = (Join-Path $env:USERPROFILE (Join-Path "Downloads" "localGit"))
    Write-Host "Installing local git into $localGitFolder..."

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
    $sc = Get-Command "scoop" -ErrorAction SilentlyContinue
    if ($null -eq $sc) {
        # https://scoop.sh/
        Write-Host "Installing scoop..."
        Invoke-RestMethod 'get.scoop.sh' | Invoke-Expression
        # by default, scoop does not like to run elevated:
        # Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
        $scoopPath = (Join-Path $env:USERPROFILE (Join-Path 'scoop' 'shims'))
        $env:Path += ";$scoopPath"
    }
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
    & git.exe config --global user.name $userName@$computerName
    & git.exe config --global user.email $email

    # requires elevation:
    & winget install Microsoft.Powershell --accept-source-agreements --disable-interactivity

    # per user, no elevation required:
    # $env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
    & winget install Microsoft.WindowsTerminal --accept-source-agreements --disable-interactivity
    & winget install Microsoft.VisualStudioCode --accept-source-agreements --disable-interactivity
}

function main {
    Write-Host
    Write-Host "Bootstrap $originGitHub -> $dotPath"
    Write-Host -NoNewline "OK to proceed with setup? [Y/n] "
    $answer = (Read-Host).ToUpper()
    if ($answer -ne 'Y' -and $answer -ne '') {
        Write-Warning "Aborting."
        return
    }

    if (($null -eq $email -or $email -eq '') -and $null -ne (Get-Command 'git' -ErrorAction SilentlyContinue)) {
        $email = (& git config --global --get user.email)
    }
    if ($null -eq $email -or $email -eq '') {
        $email = Read-Host "Enter your email address for git commits"
        if ($email -eq '') {
            Write-Warning "Need email address, aborting."
            return
        }
    }

    modernizeWinPowerShell
    ensureWinGet

    ensureLocalGit
    & git clone $originGitHub $dotPath

    # TODO: relaunch this script from repo
    # TODO: either symlink or copy gitconfig, profile.ps1, init.lua etc to $env:USERPROFILE

    installScoopApps
    installWinGetApps
}

main
