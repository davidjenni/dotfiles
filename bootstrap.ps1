
$chocoHome = (Join-Path -Path $env:USERPROFILE ".choco")
Write-Host "Installing chocolatey into $chocoHome..."
$env:ChocolateyInstall = $chocoHome
$env:ChocolateyAllowInsecureRootDirectory = 'true'
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
$env:Path+=";$chocoHome\bin"

# build tooling
Write-Host "Installing git & nodejs..."
& choco.exe install -y git

if (-not (Get-Command -Name git -ErrorAction SilentlyContinue)) {
    Write-Error "git not installed!"
}

# choco install /y 7zip git hackfont less neovim ripgrep tree vim-tux vscode
# programming
# choco install /y dotnetcore golang julia miniconda3 nodejs rustup.install zip

# https://github.com/Jaykul/WindowsConsoleFonts
# Install-Module -Name WindowsConsoleFonts

# soft link
# New-Item -ItemType SymbolicLink -Name .\SYMfoo.txt  -Target .\real\foo.txt
