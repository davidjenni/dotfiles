dot files
=========

DotFiles for my OSX, Win32 & Linux environments. Geared towards use of git and vim.

Uses pathogen and git submodules to manage plugin refresh.

Bootstrap
---------
To bootstrap on a clean login, copy the bootstrap script and execute it. For OSX & Linux,
use [this shell script](https://github.com/w7cf/dotfiles/blob/master/bootstrap.sh); for Win32 this is your cmd script.

The script uses ssh access to github. If your login hasn't connected yet to github,
initialize and verify the ssh connection with:

    ssh -vT git@github.com


OSX/Linux:

    cd ~
    wget https://github.com/w7cf/dotfiles/raw/master/bootstrap.sh
    sh bootstrap.sh

Win32:

    tbd

The separately downloaded bootstrap script can be deleted once the dotfiles repo is created.

Status
------

Still work in progress:
* lacking bootstrap and install scripts for Win32
* better refactoring of bash rc
* proper testing in Linux(debian), OSX and Win32 (Win7/WS08R2/Win7/WS12)
