@if "%_echo%"=="" echo off
setlocal EnableDelayedExpansion

set _origin=ftp://ftp.chiark.greenend.org.uk/users/sgtatham
set _puttyVersion=latest

if not exist "%ProgramFiles(x86)%\Git\bin\curl.exe" (echo ERROR: requires Git to be installed, script needs curl and unzip&&exit /b 1)
echo Downloading PuTTY %_puttyVersion% for Win32...
set puttyPacks=%puttyPacks% %_origin%/putty-%_puttyVersion%/x86/putty.zip

set downloadDir=%TEMP%\puttyDL
set puttyTargetDir=%USERPROFILE%\PuTTY
if not exist %downloadDir%\nul mkdir %downloadDir%

pushd %downloadDir%
for %%p in (%puttyPacks%) do (
        echo Downloading %%p...
        curl.exe -O %%p
    )
popd

echo Unzipping PuTTY under %puttyTargetDir% ...
unzip.exe %downloadDir%\*.zip -d %puttyTargetDir%
rmdir /q /s %downloadDir%
echo Installed PuTTY.

