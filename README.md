# dot files

DotFiles for my macOS, Win32 & Linux environments. Geared towards use of git and vim.

## Bootstrap

### Windows 10/11

to bootstrap, run this in a Windows PowerShell prompt:

````shell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
irm 'https://raw.githubusercontent.com/davidjenni/dotfiles/main/bootstrap.ps1' | iex
````

### macOS

to bootstrap, run this in a default Terminal.app prompt:

````shell
    curl -fsSL https://github.com/davidjenni/dotfiles/raw/master/bootstrap.sh | bash
````

### Linux (Ubuntu/Debian)

NOTE: WIP, bootstrap doesn't work reliably in Debian(bookworm) nor Ubuntu 22 yet,
still missing apps!

* open terminal/WSL:

````shell
    curl -fsSL https://github.com/davidjenni/dotfiles/raw/master/bootstrap.sh | bash
````
