# fish configuration:
#
set -x CLICOLOR "yes"
set -x LESS "-c -i -x4 -J -w -M -r"
set -x VISUAL "vim"

if test -x (brew --prefix)/bin/lesspipe.sh
    set -x LESSOPEN "|lesspipe.sh %s"
end

if test -f ~/.gitSecrets.sh
    # fish uses different export variable syntax than sh
    cat ~/.gitSecrets.sh | sed 's/export/set -x/' | sed 's/=/ /' | source -
end

if test -d "$HOME/node_modules/.bin"
    set PATH $HOME/node_modules/.bin $PATH
end


fish_vi_key_bindings

