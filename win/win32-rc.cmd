@if "%_echo%"=="" echo off
REM win32-rc.cmd: environment settings to be used with every Win32 command prompt
REM hooked into: "HKCU\Software\Microsoft\Command Processor" @AutoRun
REM autorun hook is set from bootstrap.cmd

REM only run once
if defined MY_BIN goto :eof

set _HERE=%~dp0
set HERE=%_HERE:~0,-1%
set _HERE=

set HOME=%USERPROFILE%
set MY_BIN=%HOME%

call :addToPath "%MY_BIN%\dotfiles\win"
call :addToPath "%USERPROFILE%\SkyDrive\Bin\Win"
call :addToPath "%MY_BIN%\PuTTY"
call :addToPath "%MY_BIN%\vim\vim74"
:: install emacs from: http://emacsbinw64.sourceforge.net/
call :addToPath "%MY_BIN%\emacs\bin"
call :addToPath "%ProgramFiles%\TortoiseHg"
call :addToPath "%ProgramFiles(x86)%\Git\bin"
:: Git for windows >= 2.6 installs as x64
call :addToPath "%ProgramFiles%\Git\bin"
call :addToPath "%ProgramFiles%\Git\usr\bin"
call :addToPath "%ProgramFiles%\7-Zip"
call :addToPath "%MY_BIN%\NTTools"
call :addToPath "%MY_BIN%\ruby-1.9.1\bin"
call :addToPath "%MY_BIN%\Python-2.7"
call :addToPath "%MY_BIN%\node_modules\.bin"

:setEnv
set LESS=-i -M -N -q -x4 -R
set LESSBINFMT=*d[%02x]

set _gitSecrets=%HOME%\.gitSecrets.cmd
if exist "%_gitSecrets%" call "%_gitSecrets%"
set _gitSecrets=
:: setup putty/plink to work properly with git: remotes
if exist %MY_BIN%\putty set GIT_SSH=%MY_BIN%\putty\plink.exe

set VISUAL=gvim.exe
:: interacts badly with SD and windiff -lo
::set PAGER=vim.exe -R

set HGEDITOR=%VISUAL%

set DIRCMD=/ogen

call :loadDoskeyIfExists %HERE%\aliases.doskey
if /i "%PROCESSOR_ARCHITECTURE%"=="amd64" (
    call :loaddoskeyifexists %here%\aliases-x64.doskey
) else (
    call :loadDoskeyIfExists %HERE%\aliases-x86.doskey
)

REM set prompt to the following:
REM (20:51:41.60) [D:\]
REM >
prompt $C$T$F $M[$+$P]$_$G$S
color 1e
goto :eof

:loadDoskeyIfExists
    :: param1 path to doskey macro file
    if exist "%1" call doskey.exe /macrofile="%1"
    exit /b 0

:addToPath
    :: param1 path to add if it exists
    if exist "%~f1" PATH=%PATH%;%~f1
    exit /b 0

:eof
set HERE=
