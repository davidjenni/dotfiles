function gb --description 'git branches with fzf' --argument-names 'query'
    # terniary operator in fish; similar to bash's '${*:-}
    set -l _Q (test -n "$argv"; and echo "$argv"; or echo '')
    git branch -r \
        | fzf --query=$_Q --no-sort \
            --height=50% --layout=reverse-list --border --margin=1 --padding=1 \
            --preview 'git log {1} --no-source --color' \
            --bind ctrl-b:preview-page-up,ctrl-f:preview-page-down \
            --bind shift-up:preview-top,shift-down:preview-bottom
end
