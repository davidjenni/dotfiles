function fff --description 'find in files with fzf & rg' --argument-names 'query'
  set -l _RG "rg --column --line-number --no-heading --color=always --smart-case "
  # terniary operator in fish; similar to bash's '${*:-}
  set -l _Q (test -n "$argv"; and echo "$argv"; or echo '')

  fzf --ansi --disabled --query $_Q \
    --height=50% --layout=reverse --border --margin=1 --padding=1 \
    --bind "start:reload:$_RG {q}" \
    --bind "change:reload:sleep 0.2;$_RG {q} || true" \
    --color "hl:-1:underline,hl+:-1:underline:reverse" \
    --delimiter : \
    --preview 'bat --color=always {1} --highlight-line {2} --theme base16-256' \
    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
    --bind 'enter:become(vim {1} +{2})'
end
