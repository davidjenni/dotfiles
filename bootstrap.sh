#!/bin/bash

originGitHub='https://github.com/davidjenni/dotfiles.git'
dotPath=$HOME/dotfiles

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

function ensureBrew {
  if have brew; then
    echo "Homebrew is installed"
    return
  fi
  echo "Installing Homebrew..."
  # TODO: Test brew install
  echo ">> curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
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

function installAppsMacOS {
  echo "Installing apps via brew..."
  local var apps=(
    7zip
    bat
    dust
    fd
    fish
    fzf
    git-delta
    helix
    less
    lsd
    neofetch
    neovim
    nvm
    ripgrep
    starship
    tmux
    tre-command
    tokei
    wget
    xz
    )

  local var casks=(
    alacritty
    font-jetbrains-mono-nerd-font
    )
  local var _apps=${apps[*]}
  # echo ">> brew install $_apps"
  brew install $_apps
  if [ $? -ne 0 ] ; then
    echo "Failed to install apps via brew"
    exit 2
  fi
  local var _casks=${casks[*]}
  # echo ">> brew install --cask $_casks"
  brew install --casks $_casks
  exit $?
}

function installAppsLinux {
  echo "Installing apps via apt..."
  echo "NOTE: apps install for Linux is still very brittle and incomplete, YMMV !!!"
  local var apps=(
    bat
    fd-find
    fish
    fzf
    git
    # git-delta # no apt installer for git-delta, but snap has it?
    less
    # lsd # no lsd installer for linux :-()
    neovim
    ripgrep
    tmux
    wget
    xz-utils
    )

  # curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  # curl -sS https://starship.rs/install.sh | sh

  local var _apps=${apps[*]}
  # echo ">> sudo apt install $_apps"
  sudo apt install $_apps
  exit $?
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
  sourceFile=$dotPath/$sourceRelPath
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
  sourceDir=$dotPath/$sourceRelPath
  echo "  $sourceDir -> $targetDir"
  cp -R $sourceDir/* $targetDir
}

function setupShellEnv {
  echo "Setting up shell environment..."
  ensureGitNames noprompt
  writeGitConfig $dotPath/gitconfig.ini

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

  # bat: https://github.com/sharkdp/bat#configuration-file
  copyFile bat_config $configDir/bat/config

  copyFile bash/bash_aliases $HOME/.bash_aliases
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
  copyFile fish/functions/l.fish $fishConfigDir/functions/l.fish
  copyFile fish/functions/la.fish $fishConfigDir/functions/la.fish
  copyFile fish/functions/ll.fish $fishConfigDir/functions/ll.fish
  copyFile fish/functions/ls.fish $fishConfigDir/functions/ls.fish
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
      case `uname` in
          'Darwin') ensureBrew ;;
          'Linux') ;;
      esac
      main apps
      ;;
    "apps")
      case `uname` in
          'Darwin') installAppsMacOS ;;
          'Linux') installAppsLinux ;;
      esac
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

echo "Starting bootstrap.sh..."
main $*
