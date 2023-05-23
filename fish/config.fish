# fish configuration:
#
set -x CLICOLOR "yes"
set -x LESS "-c -i -x4 -J -w -M -r"
set -x VISUAL "nvim"
set -x EDITOR "nvim"

set fish_greeting ""

switch (uname)
    case Linux
        if test -x /usr/bin/lesspipe.sh
            set -x LESSOPEN "|lesspipe.sh %s"
        end
    case Darwin
        set -g fish_user_paths "/opt/homebrew/bin" $fish_user_paths
        if test -x (brew --prefix)/bin/lesspipe.sh
            set -x LESSOPEN "|lesspipe.sh %s"
        end
        # ensure openssl installed via brew is found before the system version (which is outdated)
        set -g fish_user_paths "/usr/local/opt/openssl/bin" $fish_user_paths
end

if test -d "$HOME/node_modules/.bin"
    set -x PATH $HOME/node_modules/.bin $PATH
end

if test -d "$HOME/go/bin"
    set -x GOPATH ~/go
    set PATH $HOME/go/bin $PATH
end

if test -d "$HOME/.cargo/bin"
    set PATH $HOME/.cargo/bin $PATH
end

fish_vi_key_bindings
# fish_ssh_agent
fish_add_path /opt/homebrew/sbin

zoxide init fish | source

# https://starship.rs/advanced-config/#transientprompt-and-transientrightprompt-in-fish
function starship_transient_prompt_func
    starship module character
end
function starship_transient_rprompt_func
    starship module time
end
starship init fish | source
# contents of enable_trancience function, which is not callable yet after above source
bind --user \r transient_execute
bind --user -M insert \r transient_execute
