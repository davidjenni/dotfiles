function gl --description 'git log with fzf' --argument-names 'query'
    # terniary operator in fish; similar to bash's '${*:-}
    set -l _Q (test -n "$argv"; and echo "$argv"; or echo '')
    git log --date=short --format='%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)' --graph \
    | fzf --ansi --query=$_Q --no-sort \
        --height=50% --layout=reverse-list --border --margin=1 --padding=1 \
        --preview 'git show --color {3}' \
        --bind ctrl-b:preview-page-up,ctrl-f:preview-page-down \
        --bind shift-up:preview-top,shift-down:preview-bottom
end
