Param(
)
$env:HOME = $env:USERPROFILE

function runElevated {
    param (
        [parameter(Mandatory = $true)][scriptblock] $block,
        [string] $execPolicy = "RemoteSigned"
    )
    $res = Start-Process powershell -Wait -PassThru -Verb Runas -ArgumentList "-noexit -NoProfile -ExecutionPolicy $execPolicy -Command ""$block"""
    return $res.ExitCode -eq 0
}
function ensurePkgManager {
    $pkgMgr = 'choco'
    if ($null -ne (Get-Command $pkgMgr -ErrorAction SilentlyContinue)) {
        Write-Host "> $pkgMgr is already installed."
        return
    }

    Write-Host 'Installing chocolatey in elevated PS prompt...'
    $ok = runElevated -execPolicy RemoteSigned -block  {
        $host.ui.RawUI.WindowTitle = 'Installing chocolatey...'
        $exitCode = 0
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-Expression((Invoke-WebRequest -Uri 'https://chocolatey.org/install.ps1').Content)
        }
        catch {
            Write-Host "Error: $_"
            Write-Host "Hit 'Enter' to continue."
            Read-Host
            $exitCode = 1
        }
        exit $exitCode
    }
    if (!$ok) {
        throw "Error while installing package manager!"
    }
}

function ensurePkgsInstalled {
    param (
        [Parameter(Mandatory = $true)][string] $title,
        [string[]] $needed = ( "7zip", "git" )
    )
    Write-Host "Query installed packages for: $title ($needed)..."
    $installed = (choco list -l -r -i) -split '\r?\n' | ForEach-Object { $_.split('|')[0]}
    $toInstall = $needed | Where-Object { -not ($installed.Contains("$_")) }
    if ($null -eq $toInstall) {
        Write-Host "> all installed"
        return
    }
    Write-Host "Installing missing packages: $toInstall ..."
    $cmdText = @"
        `$host.ui.RawUI.WindowTitle = 'choco - installing packages...'
        & { "choco install /y $toInstall" }
        if (`$global:LASTEXITCODE -ne 0) {
            Write-Host "Hit 'Enter' to continue."
            Read-Host
            exit 1
        }
        exit 0
"@
    $cmd = [System.Management.Automation.ScriptBlock]::Create($cmdText)
    $ok = runElevated -execPolicy RemoteSigned -block $cmd
    if (!$ok) {
        throw "Error while installing packages!"
    }
}

function Install {
    Write-Host "Bootstrap console environment into: '$($env:HOME)'"
    $minVer = [Version]("5.1")
    if ($PSVersionTable.PSVersion -lt $minVer) {
        throw "Requires either windows/desktop Powershell $minVer or Powershell Core"
    }

    ensurePkgManager

    ensurePkgsInstalled "basic tools" ( "7zip", "git", "neovim", "ripgrep", "tree" )
    # ensurePkgsInstalled "prog languages" ( "deno", "golang", "miniconda3", "nodejs-lts", "powershell-core", "rustup.install" )
    ensurePkgsInstalled "prog languages" ( "deno", "golang", "miniconda3", "nodejs-lts", "powershell-core" )
    ensurePkgsInstalled "tools" ( "azure-cli", "ilspy", "microsoft-windows-terminal", "neovim", "NugetPackageExplorer", "pandoc", "vscode" )
    ensurePkgsInstalled "fonts" ( "cascadiacode", "hackfont" )

    Write-Host "Completed."
}

Install
