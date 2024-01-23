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

call :addToPath "%ProgramFiles%\Git\usr\bin"

:setEnv
set LESS=-i -M -N -q -x4 -R
set LESSBINFMT=*d[%02x]

set EDITOR=code --wait
set VISUAL=code --wait

set DIRCMD=/ogen

call :loadDoskeyIfExists %HERE%\aliases.doskey
if /i "%PROCESSOR_ARCHITECTURE%"=="amd64" (
    call :loaddoskeyifexists %here%\aliases-x64.doskey
) else (
    call :loadDoskeyIfExists %HERE%\aliases-x86.doskey
)

if exist %MY_BIN%\go (
    set GOPATH=%MY_BIN%\go
    call :addToPath "%MY_BIN%\go\bin"
)

REM set prompt to the following:
REM (20:51:41.60) [D:\]
REM >
prompt $C$T$F $M[$+$P]$_$G$S
:: color 1e
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
