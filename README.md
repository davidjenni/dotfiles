# dot files


DotFiles for my macOS, Win32 & Linux environments. Geared towards use of git and vim.

## Bootstrap

### Windows 10/11

to bootstrap, run this in a PowerShell prompt:

````shell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
irm 'https://raw.githubusercontent.com/davidjenni/dotfiles/main/bootstrap.ps1' | iex
````

### macOS

* install [Git](http://git-scm.com/download/mac)
* open terminal:

````shell
    curl -L -o /tmp/bootstrap.sh https://github.com/davidjenni/dotfiles/raw/master/bootstrap.sh
    bash /tmp/bootstrap.sh
````

### Linux (Debian)

* install curl and git (while at it, also get vim and hg):

````shell
    sudo apt-get install curl git vim mercurial
````

* open terminal:

````shell
    curl -L -o /tmp/bootstrap.sh https://github.com/davidjenni/dotfiles/raw/master/bootstrap.sh
    bash /tmp/bootstrap.sh
````

Status
------

Still work in progress:
* cleanup and orgianize vimrc
* better refactoring of bash rc

