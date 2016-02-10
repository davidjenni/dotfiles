@if '%_echo%' == '' echo off
setlocal enabledelayedexpansion
set _puttySshDir=%~dp0
cmd.exe /v:on /d /c SET _keyFiles=& FOR /f "tokens=*" %%P IN ('dir /b %_puttySshDir%\*.ppk') DO SET _keyFiles=!_keyFiles! "%_puttySshDir%%%P"
echo Will load these private SSH keys: %_keyFiles%
:: restart pageant, if necessary
taskkill.exe /f /t /im pageant.exe  2>nul
start "" pageant.exe %_keyFiles%
endlocal
