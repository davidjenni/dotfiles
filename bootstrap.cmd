REM incomplete Win32 bootstrap
REM requires to run with admin elevation (for mklink to work)
setlocal 
set _HOME=%HOMEDRIVE%%HOMEPATH%
ren %_HOME%\_vimrc %_HOME%\_vimrc.o

mklink %_HOME%\_vimrc %_HOME%\dotfiles\vimrc

ren %_HOME%\vimfiles %_HOME%\vimfiles.o

mklink /j %_HOME%\vimfiles %_HOME%\dotfiles\vimfiles

