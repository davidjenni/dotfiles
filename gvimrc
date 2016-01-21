" vim: set ft=vim ts=2 sts=2 sw=2 expandtab :

set visualbell t_vb=

set guioptions-=T   " no toolbar
set guioptions-=t   " exclude tearoff menu
set guioptions+=c   " use console for simple questions
set guioptions-=g   " no need for greyed menues
set guioptions-=m   " don't bother showing GUI menu
set guioptions-=r   " don't show right hand scrollbar
set guioptions-=R
set guioptions-=l   " don't show left hand scrollbar
set guioptions-=L
set lines=50
set columns=160
set guicursor=n:blinkon0

if IsWindows()
  set guifont=Consolas:h10
  set t_Co=256
elseif IsOSX()
  " set guifont=Monaco:h12
  set guifont=Hack:h12
  " <C-v>u21aa
  set showbreak=↪
elseif LINUX()
  set guifont=Dejavu\ Sans\ Mono\ 10
endif

set background=dark
colorscheme hybrid

