" vim: set ft=vim ts=2 sts=2 sw=2 expandtab :
" base vimrc without loading any external plugins
" this vimrc can be loaded by itself: vim -u base-vimrc
if &compatible
  set nocompatible
endif
" bail if not on a recent VIM version
if (v:version < 703)
  echoerr "Sorry, this vimrc requires a recent VIM version (>= 7.3)"
  finish
endif

if has('syntax') && !exists('g:syntax_on')
  syntax enable
endif
if has('autocmd')
  filetype plugin indent on
endif

" completion
set wildmenu
set wildmode=list:longest,list:full
set wildignorecase
set complete-=i
set smarttab
set ttimeout
set ttimeoutlen=100

" chrome and UI
set title
set shortmess=atI
set laststatus=2
set number
" set statusline=%n:%<%f%m%r%h%w%=%y\ (\%03.3b/0x\%02.2B)\ \ %5.l,%3(%c%V%)\ %P
set statusline=%<%f\                     " Filename
set statusline+=%w%h%m%r                 " Options
"set statusline+=%{fugitive#statusline()} " Git Hotness
set statusline+=\ [%{&ff}/%Y]            " Filetype
set statusline+=\ [%{getcwd()}]          " Current dir
set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
set ruler
set nowrap

set cursorline
augroup singleCursorline
    au!
    au WinLeave,InsertEnter * set nocursorline
    au WinEnter,InsertLeave * set cursorline
augroup END

set scrolloff=2
set sidescroll=1
set sidescrolloff=5
set display+=lastline

set mouse=a
set mousehide
behave xterm

" consider: https://github.com/ciaranm/securemodelines
set modeline
set modelines=2

" sounds counterintuitive: http://vim.wikia.com/wiki/Disable_beeping
set noerrorbells visualbell
set t_vb=
autocmd GUIEnter * set visualbell t_vb=

" GUI
if has("gui")
  set guioptions-=T   " no toolbar
  set guioptions-=t   " exclude tearoff menu
  set guioptions+=c   " use console for simple questions
  set guioptions-=m   " don't bother showing GUI menu
  set guioptions-=r   " no need for greyed menues
  set guioptions-=L   " don't show left hand scrollbar
  set lines=50
  set columns=160
  set guicursor=n:blinkon0
endif

" spaces, tabs & formatting
set expandtab
set tabstop=4
set shiftwidth=4
set autoindent
set cindent
set virtualedit=onemore
set nojoinspaces

set listchars=tab:>.,trail:#,extends:>,precedes:<
set list

set backspace=indent,eol,start

" http://vimdoc.sourceforge.net/htmldoc/syntax.html#:TOhtml
let g:html_use_css=1

" files, buffers
set encoding=utf-8
set writebackup
set autoread
set hidden
set cryptmethod=blowfish

" searching
set ignorecase
set smartcase
set incsearch
set hlsearch
set showmatch

" backups, swap file
set nobackup
set noswapfile
set noundofile

" sessions, history
set sessionoptions-=options
set history=1000
set viewoptions=folds,options,cursor,unix,slash

" leader
let mapleader="\<Space>"

" mappings
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
endif

" custom motions
" easy on my left pinky
imap jj <Esc>
imap jk <Esc>
" search for visually highlighted text
vmap // y/<C-R>"<CR>
" move cursor naturally through wrapped lines
nnoremap j  gj
nnoremap k  gk
" select last insertion
nnoremap gV `[v`]

" from Neil's VimDOJO class: repeat with visual
vnoremap . :normal . <CR>

" open file in same dir as current file:
" from: http://vimcasts.org/episodes/the-edit-command/
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

nnoremap <Leader>w :w<CR>

" copy/paste to system clipboard
" from: http://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
" jumpd to end of pasted text:
nnoremap <silent> p p`]

" autocmd

if has ("autocmd")
  augroup textFiles
    au!
    autocmd FileType text setlocal textwidth=78
  augroup END

  augroup helpFiles
    au!
    autocmd filetype help set nonumber
    autocmd filetype help nnoremap <buffer><cr> <c-]>   " Enter selects subject
    autocmd filetype help nnoremap <buffer><bs> <c-T>   " Backspace to go back
    autocmd FileType help wincmd K " show help in top hsplit
  augroup END

  augroup makeFiles
    au!
    autocmd FileType make setlocal ts=8 sts=8 sw=8 noexpandtab
  augroup END

  augroup xmlFiles
    au!
    autocmd BufNewFile,BufRead *.rss setfiletype xml
    autocmd BufNewFile,BufRead *.proj setfiletype xml
    autocmd BufNewFile,BufRead *.csproj setfiletype xml
    autocmd BufNewFile,BufRead *.targets setfiletype xml
    autocmd BufNewFile,BufRead *.settings setfiletype xml
  augroup END

  augroup jsFiles
    au!
    autocmd filetype javascript setlocal tabstop=2 shiftwidth=2
    autocmd filetype jade setlocal tabstop=2 shiftwidth=2
    autocmd BufNewFile,BufRead *.coffee setlocal tabstop=2 shiftwidth=2
  augroup END
endif

" OS specifics
silent function! OSX()
return has('macunix')
endfunction
silent function! LINUX()
return has('unix') && !has('macunix') && !has('win32unix')
endfunction
silent function! WINDOWS()
return  (has('win16') || has('win32') || has('win64'))
endfunction

if WINDOWS()
  set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
  set wildignore+=*.obj,*.dll,*.exe
else
  set wildignore+=.git\*,.hg\*,.svn\*
endif

if has('gui_running')
  set background=dark
  colorscheme evening

  if WINDOWS()
    set guifont=Consolas:h10
  elseif OSX()
    set guifont=Monaco:h12
    " <C-v>u21aa
    set showbreak=↪
  elseif LINUX()
    set guifont=Dejavu\ Sans\ Mono\ 10
  endif
else
  set background=dark
  colorscheme desert
  if (&term=="xterm-256color" || (&term=="screen" && exists("$TMUX")))
    set t_Co=256
  endif
endif

" plugins shipping with VIM
runtime macros/matchit.vim
" http://vimdoc.sourceforge.net/htmldoc/usr_12.html#find-manpage
runtime! ftplugin/man.vim

" macros

function! Preserve(command)
   " Preparation: save last search, and cursor position.
   let _s=@/
   let l = line(".")
   let c = col(".")
   " Do the business:
   execute a:command
   " Clean up: restore previous search history, and cursor position
   let @/=_s
   call cursor(l, c)
 endfunction

 function! StripTrailingWhitespace()
   call Preserve("%s/\\s\\+$//e")
 endfunction

 " autocmd BufWritePre *.py,*.js, *.json, *.cs, *.c, *.cpp, *.cxx, *.h, *.xml, *proj, *.props, *.targets :call StripTrailingWhitespace()
 nmap _$ :call StripTrailingWhitespace()<CR>
 nmap _= :call Preserve("normal gg=G")<CR>
