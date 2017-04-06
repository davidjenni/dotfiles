# http://psget.net/
Install-Module PsGet
# https://github.com/jrjurman/powerls
Install-Module PowerLS
Set-Alias -Name ls -Value PowerLS -Option AllScope

# https://github.com/dahlbyk/posh-git
Install-Module posh-git
$GitPromptSettings.DefaultPromptPrefix = '($((get-date).tostring("HH:mm:ss"))) '
$GitPromptSettings.DefaultPromptSuffix = '`n$(''>'' * ($nestedPromptLevel + 1)) '
$GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true

function _addToPath {
    param ( [string[]]$directory )

    if (Test-Path $directory) {
        $env:Path += ";$directory"
    }
}

_addToPath "$env:HOME\dotfiles\win"
_addToPath "$env:HOME\PuTTY"
_addToPath "$env:ProgramFiles\Git\usr\bin"
_addToPath "$env:ProgramFiles\7-Zip"
_addToPath "$env:HOME\NTTools"

$env:LESS="-i -M -N -q -x4 -R"
$env:LESSBINFMT="*d[%02x]"
$env:VISUAL="gvim.exe"

# replay cmd git secrets env variables into PS:
CMD /d /c "$env:HOME/.gitSecrets.cmd && set GIT" | .{process{
    if ($_ -match '^([^=]+)=(.*)') {
        $gitVar = $matches[1]
        $gitValue = $matches[2]
        Set-Item -Path "Env:$gitVar" -Value "$gitValue"
    }
}}

New-Alias -Name "bb" -Value "pushd $env:HOME"
# New-Alias -Name ".." -Value "cd .."
# New-Alias -Name "..." -Value "cd ..\.."
New-Alias -Name "l" less
# New-Alias -Name "xx" -Value "exit"
New-Alias -Name "c" cd
New-Alias -Name "cc" pushd
# New-Alias -Name "-" popd
# New-Alias -Name "ff" -Value "dir /a-d /b /s"
# New-Alias -Name "fff" -Value "findstr /n /s"
# New-Alias -Name "pageant" -Value "$env:HOME\.ssh\pageant.cmd"

