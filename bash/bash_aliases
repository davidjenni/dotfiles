function have {
  hash "$1" >&/dev/null
}

alias cls='clear'
if have lsd; then
  alias la='lsd -a --group-directories-first'
  alias ls='lsd --group-directories-first'
  alias ll='lsd -l --group-directories-first'
else
  alias la='ls -aGF'
  alias ls='ls -GF'
  alias ll='ls -lGF'
fi

if have bat; then
  alias l='bat'
else
  alias l='less'
fi

export LESS="-c -i -x4 -J -w -M -r"
export VISUAL='nvim'
alias v='nvim'
alias vv='nvim'

alias ff='fd'
#alias '-'='popd'
alias ..='cd ../'
alias ...='cd ../../'

# vi mode; can be switched on temp with: set -o vi
set editing-mode vi

myip() { wget -q -O - checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//'; }

if uname -r | grep -q "WSL"; then
  alias ssh='ssh.exe'
  alias ssh-add='ssh-add.exe'
fi

case `uname` in
  'Darwin')
    if [ -d "/opt/homebrew/bin" ] ; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    ;;
  'Linux')
    if [ -d "/home/linuxbrew/.linuxbrew/bin" ] ; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    ;;
esac

if have starship; then
  eval "$(starship init bash)"
fi
if have zoxide; then
  eval "$(zoxide init bash)"
fi

case $- in
  *i*)  # interactive
    if `shopt -q login_shell`; then
      if have neofetch; then
        neofetch
      else
        echo " $(uname -a)"
        uptime
      fi
    fi
  ;;
esac
