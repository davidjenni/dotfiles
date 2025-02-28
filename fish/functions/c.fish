# cd to directory with fuzzy search:
function c
    if test -n $argv
        set fzfSearchTerm "--query=$argv"
    end
    cd (fd --type d | fzf $fzfSearchTerm --height=40% --layout=reverse --border --margin=1 --select-1)
end
