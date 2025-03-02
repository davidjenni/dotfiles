function ff
  set RG_PREFIX "rg --column --line-number --no-heading --color=always --smart-case "
  fzf --ansi --disabled \
    --bind "start:reload:$RG_PREFIX {q}" \
    --bind "change:reload:sleep 0.2;$RG_PREFIX {q} || true" \
    --color "hl:-1:underline,hl+:-1:underline:reverse" \
    --delimiter : \
    --preview 'bat --color=always {1} --highlight-line {2} --theme Nord' \
    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
    --bind 'enter:become(vim {1} +{2})'
end
