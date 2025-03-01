function c --description 'cd to directory with fuzzy search' --argument-names 'query'
    # terniary operator in fish; similar to bash's '${*:-}
    set -l _Q (test -n "$argv"; and echo "$argv"; or echo '')
    cd (fzf --ansi --disabled --query=$_Q \
        --height=20% --layout=reverse-list --border --margin=1 --padding=1 --info=inline \
        --bind 'start:reload:fd --type d {q}' \
        --bind 'change:reload:sleep 0.2 && fd --type d {q}' \
        --color 'hl:-1:underline,hl+:-1:underline:reverse' \
        --preview 'eza --sort ext --group-directories-first --classify --color=auto --icons=always {1}' \
        --select-1 --exit-0 \
        --preview-window '60%,border-bottom,+{2}+3/3,~3')
end
