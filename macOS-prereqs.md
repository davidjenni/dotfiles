# Pre-required packages installed via OS package managers

## macOS

- [brew](https://brew.sh/)

    `bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

- [git](https://git-scm.com/downloads)/git-lfs

    `brew install git git-lfs`

- Terminal and browser:
    - [iTerm2](https://iterm2.com/)
    - [min browser](https://minbrowser.org/)

        ```console
        brew install --cask iterm2
        brew install min
        ```

    - [iTerm2 themes](https://iterm2colorschemes.com/)

- Shells:
    - [fish](https://fishshell.com/)
    - [bash](https://www.gnu.org/software/bash/)

        `brew install fish bash`

- Shell helpers:
    - [tmux](https://github.com/tmux/tmux)
    - [lsd next-gen ls](https://github.com/Peltoche/lsd)
    - [tre tree improved](https://github.com/dduan/tre)
    - [ripgrep](https://github.com/BurntSushi/ripgrep)
    - [fzf](https://github.com/junegunn/fzf)

        `brew install tmux lsd tre-command ripgrep fzf`

    - [fisher](https://github.com/jorgebucaran/fisher)

        ```console
        curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
        ```

    - [oh-my-zsh](https://ohmyz.sh/)

        ```console
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        ```

- Nerd fonts:
    See: <https://www.nerdfonts.com/>

    ```console
    brew tap homebrew/cask-fonts
    brew install --cask font-meslo-lg-nerd-font
    ```

- Shell prompt:
    - [Fish Tide](https://github.com/IlanCosman/tide)

        ```console
        fisher install IlanCosman/tide@v5
        ```

    - [Fish Z jump](https://github.com/jethrokuan/z)

        ```console
        fisher install jethrokuan/z
        ```

- Editors
    - [neovim](https://neovim.io/)

    - [VSCode](https://code.visualstudio.com/Download)

        preferable to download installer from web, then let VSCode do its auto-update thingy

Note to myself:
Copy files from ~ to dotfiles
.zprofile
.config/fish/config.fish
.config/lsd/*
