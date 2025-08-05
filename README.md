# dot files

DotFiles for my macOS, Win32 & Linux environments. Geared towards use of git and neovim.

[![PullRequest](https://github.com/davidjenni/dotfiles/actions/workflows/PR.yml/badge.svg)](https://github.com/davidjenni/dotfiles/actions/workflows/PR.yml)

## Screenshots

macOS

![macOS terminal](assets/mac-terminal.png)

Win11
![Windows terminal](assets/win-terminal.png)

## Installation

### Windows 10/11

to bootstrap, run this in a Windows PowerShell prompt:

````shell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
irm 'https://raw.githubusercontent.com/davidjenni/dotfiles/main/bootstrap.ps1' | iex
````

For a headless install (elevated), run

```bash
powershell -NoProfile -ExecutionPolicy RemoteSigned -command { Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; $env:DOT_HEADLESS=1; irm https://raw.githubusercontent.com/davidjenni/dotfiles/main/bootstrap.ps1 | iex }
```

### macOS 14+/Ubuntu 22+ (WSL or VM)

to bootstrap, run this in a default Terminal.app prompt:

````shell
curl -fsSL https://raw.githubusercontent.com/davidjenni/dotfiles/main/bootstrap.sh | bash
````
