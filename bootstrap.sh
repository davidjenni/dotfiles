#!/bin/bash
# install with:
# > curl -fsSL https://raw.githubusercontent.com/davidjenni/dotfiles/main/bootstrap.sh | bash

originGitHub='https://github.com/davidjenni/dotfiles.git'
dotPath=$HOME/dotfiles
scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

shopt -s nocasematch

function have {
  hash "$1" >&/dev/null
}

function ensureLocalGit {
  if have git; then
    echo "git is installed"
    return
  fi
  echo "No local git is installed"
  # TODO: Install temp copy of git
}

function ensureGitNames {
  prompt=$1
  username=$(git config --global user.name)
  if [ -z $username ] ; then
    defUsername="$USER@$(hostname -s)"
  else
    defUsername=$username
  fi
  if [ -z $prompt ] ; then
    read -p "Enter git username (default: $defUsername): " username
  fi
  if [ -z $username ] ; then
    username=$defUsername
  fi
  git config --global user.name "$username"

  email=$(git config --global user.email)
  if [ -z $email ] ; then
    defEmail="3200210+davidjenni@users.noreply.github.com"
  else
    defEmail=$email
  fi
  if [ -z $prompt ] ; then
    read -p "Enter git email (default: $defEmail): " email
  fi
  if [ -z $email ] ; then
    email=$defEmail
  fi
  git config --global user.email "$email"
}

function writeGitConfig {
  local var configGitIni=$1
  cat $configGitIni \
  | grep -v "^\s*#" \
  | while IFS='=' read -r key value; do \
        # echo "git config --global $key $value"
        git config --global $key "$value"
    done
}

function initBrew {
  case `uname` in
    'Darwin') eval "$(/opt/homebrew/bin/brew shellenv)" ;;
    'Linux') eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" ;;
  esac
}

function ensureBrew {
  if have brew; then
    echo "$(brew --version) is installed"
    # skip update for now, causes errors in CI:
    # brew update
    return
  fi
  case `uname` in
    'Darwin')
      xcode-select --install
    ;;
    'Linux')
      sudo apt-get install -y build-essential procps curl file git
    ;;
  esac
  echo "Installing Homebrew..."
  # https://brew.sh/
  # https://docs.brew.sh/Homebrew-on-Linux
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  initBrew
}

function cloneDotFiles {
  echo "Cloning $originGitHub -> $dotPath"
  read -p "OK to proceed with clone of repo? [Y/n] " answer
  answer=${answer:-Y}
  if [[ $answer != "Y" ]]; then
    echo "Aborting clone."
    exit 4
  fi
  echo "Cloning dotfiles..."
  # setup config for git: username, email, etc.
  ensureGitNames
  git clone $originGitHub $dotPath
}

function installApps {
  echo "Installing apps via brew..."
  local var apps=(
    7zip
    bat
    dust
    eza
    fd
    fish
    fzf
    git-delta
    helix
    less
    lua-language-server
    neofetch
    neovim
    ripgrep
    starship
    tmux
    tre-command
    tokei
    zoxide
    xz
    )

  local var casks=(
    alacritty
    font-jetbrains-mono-nerd-font
    ghostty
    )

  local var _apps=${apps[*]}
  echo ">> brew install $_apps"
  initBrew
  brew install $_apps
  if [ $? -ne 0 ] ; then
    echo "Failed to install apps via brew"
    exit 2
  fi

  local var _casks=${casks[*]}
  case `uname` in
    'Darwin')
      echo ">> brew install --cask $_casks"
      brew install --cask $_casks
    ;;
  esac
  return $?
}

function copyFile {
  local sourceRelPath=$1
  local target=$2
  if [ -f $target ] ; then
    # TODO: add backup story
    rm -f $target >&/dev/null
  fi
  targetDir=$(dirname $target)
  mkdir -p $targetDir
  sourceFile=$scriptDir/$sourceRelPath
  echo "  $sourceFile -> $target"
  cp $sourceFile $target
}

function copyDir {
  local sourceRelPath=$1
  local targetDir=$2
  if [ -d $targetDir ] ; then
    # TODO: add backup story
    rm -rf $targetDir >&/dev/null
  fi
  mkdir -p $targetDir
  sourceDir=$scriptDir/$sourceRelPath
  echo "  $sourceDir -> $targetDir"
  cp -R $sourceDir/* $targetDir
}

function setupShellEnv {
  echo "Setting up shell environment..."
  ensureGitNames noprompt
  writeGitConfig $scriptDir/gitconfig.ini

  local configDir=$HOME/.config
  if [ ! -d "$configDir" ] ; then
      mkdir -p $configDir
  fi
  # neovim
  local nvimDir=$configDir/nvim
  copyDir nvim $nvimDir

  # alacritty
  local alacrittyDir=$configDir/alacritty
  copyFile alacritty.toml $alacrittyDir/alacritty.toml

  # ghostty
  local ghosttyDirMac="$HOME/Library/Application Support/com.mitchellh.ghostty"
  copyFile ghostty/config $ghosttyDirMac/config

  # bat: https://github.com/sharkdp/bat#configuration-file
  copyFile bat_config $configDir/bat/config

  copyFile bash/bash_aliases.sh $HOME/.bash_aliases
  copyFile bash/inputrc $HOME/.inputrc
  copyFile bash/tmux.conf $HOME/.tmux.conf

  # starship.rs:
  copyFile starship.toml $configDir/starship.toml

  # fish:
  local fishConfigDir=$configDir/fish
  # rm -f $fishConfigDir/functions/fisher.fish >&/dev/null
  # curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
  copyFile fish/config.fish $fishConfigDir/config.fish
  copyFile fish/fish_plugins $fishConfigDir/fish_plugins
  # copyFile fish/functions/fisher.fish $fishConfigDir/functions
  copyFile fish/functions/c.fish $fishConfigDir/functions/c.fish
  copyFile fish/functions/cg.fish $fishConfigDir/functions/cg.fish
  copyFile fish/functions/l.fish $fishConfigDir/functions/l.fish
  copyFile fish/functions/la.fish $fishConfigDir/functions/la.fish
  copyFile fish/functions/ll.fish $fishConfigDir/functions/ll.fish
  copyFile fish/functions/ls.fish $fishConfigDir/functions/ls.fish

  # setup ssh to play with 1Password as identity agent:
  sshConfig=$HOME/.ssh/config
  copyFile ssh/config $sshConfig
  sshPerms=u+rwx,go-rwx
  chmod $sshPerms $HOME/.ssh
  chmod $sshPerms $sshConfig
  touch $HOME/.ssh/known_hosts && chmod $sshPerms $HOME/.ssh/known_hosts
  case `uname` in
      'Darwin')
        if [ -d "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password" ] ; then
          echo "   1Password socket exists, setting symlink."
          mkdir -p $HOME/.1password && chmod $sshPerms $HOME/.1password
          ln -s "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" $HOME/.1password/agent.sock
        fi
      ;;
      'Linux')
      if uname -r | grep -q "WSL"; then
        echo "on WSL, let the Windows host OS' 1Password identity agent resolve ssh authN"
        # https://developer.1password.com/docs/ssh/integrations/wsl
        rm $sshConfig >&/dev/null
        git config --global core.sshCommand ssh.exe
      fi
      ;;
  esac

}

main() {
  case $1 in
    "clone")
      if [ -x "$dotPath/.git" ] ; then
          echo "local git repo already exists, skipping."
          main setup
          return
      fi
      cloneDotFiles
      if [ $? -ne 0 ] ; then
        exit $?
      fi
      # continue with now-local bootstrap.ps1 from cloned repo:
      bash $dotPath/bootstrap.sh setup
      exit $?
      ;;
    "setup")
      echo "Setting up..."
      ensureBrew
      main apps
      ;;
    "apps")
      installApps
      if [ $? -ne 0 ] ; then
        exit $?
      fi
      main env
      ;;
    "env")
      setupShellEnv
      exit 0
      ;;
    "-h" | "--help")
      echo "Usage: $0 {clone|setup|apps|env}"
      echo "  clone:       clone the dotfiles repo and continue with 'setup' etc."
      echo "  setup:       setup package managers, git. Includes 'apps' and 'env'."
      echo "  apps:        install apps via package manager"
      echo "  env:         setups consoles and configurations for git, neovim etc."
      exit 9
      ;;
    *)
      main clone
      ;;
  esac

  echo "Done."
}

echo "Starting bootstrap.sh (in $scriptDir with working dir: $(pwd))..."
main $*
