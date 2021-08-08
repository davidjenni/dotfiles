# fish configuration:
#
set -x CLICOLOR "yes"
set -x LESS "-c -i -x4 -J -w -M -r"
set -x VISUAL "vim"

switch (uname)
    case Linux
        if test -x /usr/bin/lesspipe.sh
            set -x LESSOPEN "|lesspipe.sh %s"
        end
         [ -f /usr/share/autojump/autojump.fish ]; and source /usr/share/autojump/autojump.fish
    case Darwin
        set -g fish_user_paths "/opt/homebrew/bin" $fish_user_paths
        if test -x (brew --prefix)/bin/lesspipe.sh
            set -x LESSOPEN "|lesspipe.sh %s"
        end
        # ensure openssl installed via brew is found before the system version (which is outdated)
        set -g fish_user_paths "/usr/local/opt/openssl/bin" $fish_user_paths
         [ -f (brew --prefix)/share/autojump/autojump.fish ]; and source (brew --prefix)/share/autojump/autojump.fish
end

if test -f ~/.gitSecrets.sh
    # fish uses different export variable syntax than sh
    cat ~/.gitSecrets.sh | sed 's/export/set -x/' | sed 's/=/ /' | source -
end

if test -d "$HOME/node_modules/.bin"
    set -x PATH $HOME/node_modules/.bin $PATH
end

if test -d "/usr/local/opt/node@12/bin"
    set -x PATH /usr/local/opt/node@12/bin $PATH
end

if test -d "$HOME/go/bin"
    set -x GOPATH ~/go
    set PATH $HOME/go/bin $PATH
end

set condaLoc $HOME/miniconda3
if test -d "$condaLoc"
    set PATH $condaLoc/bin $PATH
    source $condaLoc/etc/fish/conf.d/conda.fish
end

if test -d "$HOME/.cargo/bin"
    set PATH $HOME/.cargo/bin $PATH
end

# brew install autojump
[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish

fish_vi_key_bindings
fish_ssh_agent

