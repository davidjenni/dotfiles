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

set PATH=%PATH%;%MY_BIN%\dotfiles\win
if exist %USERPROFILE%\SkyDrive\Bin\Win\nul set PATH=%PATH%;%USERPROFILE%\SkyDrive\Bin\Win
set PATH=%PATH%;%MY_BIN%\PuTTY
set PATH=%PATH%;%MY_BIN%\vim\vim73
if exist "%ProgramFiles%\TortoiseHg\" set PATH=%PATH%;%ProgramFiles%\TortoiseHg
set PATH=%PATH%;%ProgramFiles(x86)%\Git\bin
if exist "%ProgramFiles%\7-Zip\" set PATH=%PATH%;%ProgramFiles%\7-Zip
set PATH=%PATH%;%MY_BIN%\NTTools
if exist %MY_BIN%\ruby-1.9.1\bin\nul set PATH=%PATH%;%MY_BIN%\ruby-1.9.1\bin
if exist %MY_BIN%\Python-2.7\nul set PATH=%PATH%;%MY_BIN%\Python-2.7

:setEnv
set LESS=-i -M -N -q -x4
set LESSBINFMT=*d[%02x]

set _gitSecrets=%HOME%\.gitSecrets.cmd
if exist "%_gitSecrets%" call "%_gitSecrets%"
set _gitSecrets=

set VISUAL=gvim.exe
:: interacts badly with SD and windiff -lo
::set PAGER=vim.exe -R

set HGEDITOR=%VISUAL%

set DIRCMD=/ogen

call :loadDoskeyIfExists %HERE%\aliases.doskey
if /i "%PROCESSOR_ARCHITECTURE%"=="amd64" (
	call :loadDoskeyIfExists %HERE%\aliases-x64.doskey
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

:eof
set HERE=
