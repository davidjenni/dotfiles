Param(
)
$env:HOME = $env:USERPROFILE

function runElevated {
    param (
        [parameter(Mandatory = $true)][scriptblock] $block,
        [string] $execPolicy = "RemoteSigned"
    )
    $res = Start-Process powershell -Wait -PassThru -Verb Runas -ArgumentList "-NoProfile -ExecutionPolicy $execPolicy -Command ""$block"""
    return $res.ExitCode -eq 0
}
function ensurePkgManager {
    $pkgMgr = 'choco'
    if ($null -ne (Get-Command $pkgMgr -ErrorAction SilentlyContinue)) {
        Write-Host "> $pkgMgr is already installed."
        # return
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

function Install {
    Write-Host "Bootstrap console environment into: '$($env:HOME)'"
    $minVer = [Version]("5.1")
    if ($PSVersionTable.PSVersion -lt $minVer) {
        throw "Requires either windows/desktop Powershell $minVer or Powershell Core"
    }

    ensurePkgManager

    Write-Host "Completed."
}

Install
