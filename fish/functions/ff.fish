function ff --description 'find files with fzf' --argument-names 'query'
    # terniary operator in fish; similar to bash's '${*:-}
    set -l _Q (test -n "$argv"; and echo "$argv"; or echo '')
    fzf --ansi --disabled --query=$_Q \
        --height=50% --layout=reverse-list --border --margin=1 --padding=1 \
        --bind 'start:reload:fd --type f {q}' \
        --bind 'change:reload:sleep 0.2 && fd --type f {q}' \
        --color 'hl:-1:underline,hl+:-1:underline:reverse' \
        --preview 'bat --color=always {1} --theme base16-256' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
        --bind 'enter:become(vim {1} +{2})'
end
