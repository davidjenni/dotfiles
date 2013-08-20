@if "%_echo%"=="" echo off
setlocal EnableDelayedExpansion

set _vimOrigin=ftp://ftp.vim.org/pub/vim/pc
set _vimVersion=74

if not exist "%ProgramFiles(x86)%\Git\bin\curl.exe" (echo ERROR: requires Git to be installed, script needs curl and unzip&&exit /b 1)
echo Downloading VIM %_vimVersion% for Win32...
set vimPackages=%vimPackages% %_vimOrigin%/vim%_vimVersion%rt.zip
set vimPackages=%vimPackages% %_vimOrigin%/gvim%_vimVersion%.zip
set vimPackages=%vimPackages% %_vimOrigin%/vim%_vimVersion%w32.zip

set downloadDir=%TEMP%\vimDL
set vimTargetDir=%USERPROFILE%
if not exist %downloadDir%\nul mkdir %downloadDir%

pushd %downloadDir%
for %%p in (%vimPackages%) do (
        echo Downloading %%p...
        curl.exe -O %%p
    )
popd

echo Unzipping VIM under %vimTargetDir% ...
unzip.exe %downloadDir%\*.zip -d %vimTargetDir%
rmdir /q /s %downloadDir%
echo Installed VIM.

