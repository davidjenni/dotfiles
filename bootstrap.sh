#!/bin/bash

originGitHub='https://github.com/davidjenni/dotfiles.git'
dotPath=$HOME/dotfiles

shopt -s nocasematch

function ensureLocalGit {
  if hash git 2>/dev/null ; then
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
  if hash brew 2>/dev/null ; then
    echo "Homebrew is installed"
    return
  fi
  echo "Installing Homebrew..."
  # TODO: Test brew install
  echo ">> curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
}

function cloneDotFiles {
  echo "Cloning $originGitHub -> $dotPath"
  read -p "OK to proceed with setup? [Y/n] " answer
  answer=${answer:-Y}
  if [[ $answer != "Y" ]]; then
    echo "Aborting setup."
    exit 4
  fi
  echo "Cloning dotfiles..."
  # setup config for git: username, email, etc.
  ensureGitNames
  echo ">> git clone $originGitHub $dotPath"
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
  local var apps=(
    bat
    fd-find
    fish
    fzf
    git
    git-delta
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

main() {
  case $1 in
    "clone")
      if [ -x "$dotPath/.git2" ] ; then
          echo "local git repo already exists, skipping."
          main setup
          return
      fi
      cloneDotFiles
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
      main env
      ;;
    "env")
      echo "NOT IMPLEMENTED"
      ensureGitNames noprompt
      writeGitConfig $dotPath/gitconfig.ini

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
