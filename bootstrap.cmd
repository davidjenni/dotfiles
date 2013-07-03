@if "%_echo%"=="" echo off
REM Win32 bootstrap: tested on Win7 x64, Win8 & WinServer2012
REM second half of script will request to run with admin elevation (for mklink to work)
setlocal
set myGithub=https://github.com/davidjenni
set githubDotfiles=%myGithub%/dotfiles.git

set _HOME=%USERPROFILE%
if "%_HOME%" == "" (echo ERROR: Cannot determine home directory for user %USERDOMAIN%\%USER% & exit /b 1)
set dotPath=%_HOME%\dotfiles

if /i "%1"=="setup"         goto :doSetup
if /i "%1"=="elevatedSetup" (shift && goto :elevatedSetup)
if /i "%1"=="restore"       goto :restoreAutorun
if "%1" NEQ ""              (echo ERROR: unknown verb: '%1'& exit /b 1)

set _gitBin=%ProgramFiles(x86)%\Git\bin
set _gitExe=%_gitBin%\git.exe

echo Boot strap a console environment at: %_HOME%
choice /c YN /m "OK to proceed with setup?"
if %ERRORLEVEL% EQU 1 goto :startSetup
exit /b 4

:startSetup
    if not exist "%_gitExe%" (echo ERROR: requires Git to be installed, script needs git, curl and unzip&&exit /b 1)

    echo Cloning %dotPath% from origin repository: %githubDotfiles%
    call "%_gitExe%" clone --recursive %githubDotfiles% %dotPath%
    if ERRORLEVEL 1 (echo ERROR cloning git repo %githubDotfiles% & exit /b 1)

    echo Cloning submodules...
    call "%_gitExe%" submodule update --init

    :: to complete bootstrap, relaunch this script from freshly cloned repository
    set this=%~nx0
    call %dotPath%\%this% setup
    exit /b 0

:doSetup
    :: for each new cmd line window, hook in win32-rc (similar idea like .bashrc on unix)
    set _win32rc=%dotPath%\win\win32-rc.cmd
    if not exist "%_win32rc%" (echo ERROR cannot find %_win32rc%; is the dotfiles repository up-to-date?& exit /b 1)
    reg add "HKCU\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d "%_win32rc%" /f > nul

    :: generate git secrets file:
    echo.
    set _gitSecretsFile=%_HOME%\.gitSecrets.cmd
    echo Enter email address to be used with Git (empty string will skip creating %_gitSecretsFile%).
    set /P _gitEmail=.  email: 
    if ERRORLEVEL 1 goto :setConsoleDefaults
        set _defaultGitUser=%USERNAME%@%COMPUTERNAME%
        echo Enter user name to be used with Git (default is %_defaultGitUser%).
        set /P _gitUser=.  name : || set _gitUser=%_defaultGitUser%
        echo set GIT_AUTHOR_NAME=%_gitUser%> %_gitSecretsFile%
        echo set GIT_AUTHOR_EMAIL=%_gitEmail%>> %_gitSecretsFile%
        echo set GIT_COMMITTER_NAME=%%GIT_AUTHOR_NAME%%>> %_gitSecretsFile%
        echo set GIT_COMMITTER_EMAIL=%%GIT_AUTHOR_EMAIL%%>> %_gitSecretsFile%
        echo.
        echo Git secrets file created: %_gitSecretsFile%

    :setConsoleDefaults
        echo setting Console properties:
        set _consolePath=HKCU\Console
        reg add %_consolePath% /v QuickEdit         /d 0x1              /t REG_DWORD /f > nul
        reg add %_consolePath% /v WindowSize        /d 0x00320078       /t REG_DWORD /f > nul
        reg add %_consolePath% /v ScreenBufferSize  /d 0x23280078       /t REG_DWORD /f > nul
        reg add %_consolePath% /v FontFamily        /d 0x36             /t REG_DWORD /f > nul
        reg add %_consolePath% /v HistoryBufferSize /d 0x64             /t REG_DWORD /f > nul
        reg add %_consolePath% /v FaceName          /d "Consolas"       /t REG_SZ    /f > nul
        reg add %_consolePath% /v FontSize          /d 0x000E0000       /t REG_DWORD /f > nul
        set _consolePath=
    echo.
    :: prime current cmd window
    call %_win32rc%
    echo Registry for current user has been updated.

    :: Check for admin permissions
    OPENFILES.exe > nul 2>&1
    if ERRORLEVEL 1 (
        echo Requesting elevated privileges...
        call :requestUAC
    ) else (
        call :elevatedSetup %_HOME%
    )
    exit /b 0

:restoreAutorun
    reg delete "HKCU\Software\Microsoft\Command Processor" /v AutoRun /f > nul 2>&1
    set _consolePath=HKCU\Console
    reg add %_consolePath% /v QuickEdit         /d 0x0              /t REG_DWORD /f > nul
    reg add %_consolePath% /v WindowSize        /d 0x00190050       /t REG_DWORD /f > nul
    reg add %_consolePath% /v ScreenBufferSize  /d 0x012C0050       /t REG_DWORD /f > nul
    reg add %_consolePath% /v HistoryBufferSize /d 0x32             /t REG_DWORD /f > nul
    reg add %_consolePath% /v FontFamily        /d 0x0              /t REG_DWORD /f > nul
    reg delete %_consolePath% /v FaceName                                        /f > nul 2>&1
    reg add %_consolePath% /v FontSize          /d 0x0              /t REG_DWORD /f > nul
    set _consolePath=
    echo.
    echo Registry for current user has been restored.
    exit /b 0

:requestUAC
    set _uacVbsScript=%LocalAppData%\bootstrapWithUac.vbs
    echo set objShell = CreateObject^("Shell.Application"^) > %_uacVbsScript%
    echo objShell.ShellExecute "%~f0", "elevatedSetup %_HOME%", "", "runas", 1 >> %_uacVbsScript%

    echo.
    echo Relaunching this script with elevation. Script will continue in a new window...
    cscript "%_uacVbsScript%" //nologo
    :: only for Win7 and newer!
    waitfor /t 20 elevatedSetupCompleted > nul
    if ERRORLEVEL 1 (
        echo ERROR: Bootstrapping is INCOMPLETE, likely due to a failure to elevate.
        echo Bootstrapping can be resumed with:
        echo     %~f0 setup
        exit /b 1
    )
    echo.
    echo Bootstrapping complete.
    exit /B 0
    goto :eof

:elevatedSetup
    :: param1 home directory
    echo Continuing bootstrapping with elevated privileges...
    if "%1" == "" (echo ERROR: Must specify home directory as first parameter!& exit 2)
    set _HOME=%1

    for /F "tokens=2,3,4,5,6,7 delims=/: " %%i in ('echo %date%:%time: =0%') do set JULIANDATE=%%k%%i%%j-%%l%%m
    set _bootstrapBackupsDir=%_HOME%\bootstrapBackups-%JULIANDATE%
    mkdir %_bootstrapBackupsDir%

    :: TODO use for loop and create helper subroutine safeLink that does the copying & nklink dance
    copy %_HOME%\.gitconfig %_bootstrapBackupsDir% > nul 2>&1
    del /q %_HOME%\.gitconfig > nul 2>&1
    mklink %_HOME%\.gitconfig %_HOME%\dotfiles\gitconfig

    copy %_HOME%\.os.gitconfig %_bootstrapBackupsDir% > nul 2>&1
    del /q %_HOME%\.os.gitconfig > nul 2>&1
    mklink %_HOME%\.os.gitconfig %_HOME%\dotfiles\win\os.gitconfig

    copy %_HOME%\.hgrc %_bootstrapBackupsDir% > nul 2>&1
    del /q %_HOME%\.hgrc > nul 2>&1
    mklink %_HOME%\.hgrc %_HOME%\dotfiles\hgrc

    copy %_HOME%\.os.hgrc %_bootstrapBackupsDir% > nul 2>&1
    del /q %_HOME%\.os.hgrc > nul 2>&1
    mklink %_HOME%\.os.hgrc %_HOME%\dotfiles\win\os.hgrc

    copy %_HOME%\_vsvimrc %_bootstrapBackupsDir% > nul 2>&1
    del /q %_HOME%\_vsvimrc > nul 2>&1
    mklink %_HOME%\_vsvimrc %_HOME%\dotfiles\win\vsvimrc

    copy %_HOME%\.viemurc %_bootstrapBackupsDir% > nul 2>&1
    del /q %_HOME%\.viemurc > nul 2>&1
    mklink %_HOME%\.viemurc %_HOME%\dotfiles\win\viemurc

    copy %_HOME%\_vimrc %_bootstrapBackupsDir% > nul 2>&1
    del /q %_HOME%\_vimrc > nul 2>&1
    mklink %_HOME%\_vimrc %_HOME%\dotfiles\vimrc

:: .. ren %_HOME%\vimfiles %_HOME%\vimfiles.o
:: .. mklink /j %_HOME%\vimfiles %_HOME%\dotfiles\vimfiles

    echo.
    echo Saved previously sym-linked files in directory: %_bootstrapBackupsDir%
    dir /b %_bootstrapBackupsDir% 2>nul
    echo.

    echo remap CapsLock to LeftCtrl key:
    REM see http://www.experts-exchange.com/OS/Microsoft_Operating_Systems/Windows/A_2155-Keyboard-Remapping-CAPSLOCK-to-Ctrl-and-Beyond.html
    REM http://msdn.microsoft.com/en-us/windows/hardware/gg463447.aspx
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout" /v "Scancode Map" /d 0000000000000000020000001D003A0000000000 /t REG_BINARY /f > nul
    echo CapsLock remapped, will be effective after next system reboot.
 
    echo.
    echo Bootstrapping with elevation complete.
pause
    :: only for Win7 and newer!
    waitfor /si elevatedSetupCompleted
    goto :eof

:eof
