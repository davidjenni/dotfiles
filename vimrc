" vim: set ft=vim ts=2 sts=2 sw=2 expandtab :
set nocompatible

let s:thisDir=expand("<sfile>:p:h")

exec ":source " . s:thisDir . "/base.vimrc"
exec ":source " . s:thisDir . "/plugins.vimrc"

" Include user's local vim config
if filereadable(expand("~/.vimrc.local"))
  source ~/.vimrc.local
endif

