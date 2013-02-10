dot files
=========

DotFiles for my OSX, Win32 & Linux environments. Geared towards use of git and vim.

Uses pathogen and git submodules to manage plugin refresh.

Bootstrap
---------
To bootstrap on a clean login, download the bootstrap script and execute it.

OSX:
* install [Git](http://git-scm.com/download/mac)
* open terminal:
````shell
    curl -L -o /tmp/bootstrap.sh https://github.com/davidjenni/dotfiles/raw/master/bootstrap.sh
    bash /tmp/bootstrap.sh
````

Linux (Debian):
* install curl and git (while at it, also get vim and hg):
````shell
    sudo apt-get install curl git vim mercurial
````

* open terminal:
````shell
    curl -L -o /tmp/bootstrap.sh https://github.com/davidjenni/dotfiles/raw/master/bootstrap.sh
    bash /tmp/bootstrap.sh
````

Win32:
* install [Git](http://git-scm.com/download/win) into the default location,
  deselect all options (no explorer integration, no PATH modifications since the cmd script will setup paths)
* open cmd prompt and run:
````
    "%ProgramFiles(x86)%\git\bin\curl.exe" -L -o "%temp%\bootstrap.cmd" https://github.com/davidjenni/dotfiles/raw/master/bootstrap.cmd
    "%temp%\bootstrap.cmd"
````

The separately downloaded bootstrap script can be deleted once the dotfiles repo is created.

Status
------

Still work in progress:
* cleanup and orgianize vimrc
* better refactoring of bash rc

