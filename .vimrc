" vim config for Linux, OSX & Win32

set nocompatible

set runtimepath^=~/dotfiles/vimfiles

behave xterm
set title

" wget --no-check-certificate https://github.com/tpope/vim-pathogen/raw/master/autoload/pathogen.vim
" to refresh pathogen and plugins:
" cd ~/dotfiles
" git submodule foreach git pull origin master
runtime bundle/pathogen/autoload/pathogen.vim
call pathogen#infect()
call pathogen#helptags()

let mapleader = ","

set backspace=indent,eol,start

" Allow switching edited buffers without saving
set hidden
"set nobackup
"set noswapfile
set writebackup
set history=500
set ruler
set showcmd
set shortmess=atI

set wildmenu
set wildmode=longest,list

 " Auto-backup files and .swp files don't go to pwd
if has("unix") || has("mac")
    set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
    set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
else
    set directory=$HOMEPATH/.vim-tmp,$HOMEPATH/tmp,$TEMP
    set backupdir=$HOMEPATH/.vim-tmp,$HOMEPATH/tmp,$TEMP
endif
set incsearch
set smartcase
set ignorecase
set cursorline

" No sound on errors
set noerrorbells
set visualbell
set t_vb=
set tm=500

if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

if has ("autocmd")
  " Enable file type detection
  filetype plugin indent on
  " augroup vimrxEx
  " au!
  " autocmd FileType text setlocal textwidth=78
  " augroup END
else
  set autoindent
endif

" code editing settings
set autoindent
set shiftwidth=4
set tabstop=4
set expandtab
set cindent
set showmatch
set number
set scrolloff=5
" set selectmode=cmd
set autoread
set virtualedit=all
set nowrap
set sidescroll=1
set sidescrolloff=4
set listchars=tab:>.,trail:#,extends:>,precedes:<
set list

"set statusline=%<%f\ %h%m%r=%-14.(%l,%c%V%)\ %P
set statusline=%n:%<%f%m%r%h%w%=%y\ (\%03.3b/0x\%02.2B)\ \ %5.l,%3(%c%V%)\ %P
set laststatus=2

if has("gui")
    set guioptions-=T   " no toolbar
    set guioptions-=t   " exclude tearoff menu
    set guioptions-=c   " use console for simple questions
    set lines=50
    set columns=160
endif

nnoremap <esc> :nohlsearch<cr><esc>
map Q gq

imap jj <Esc> " easy on my left pinky
imap uu _
imap hh =>
imap aa @
vmap // y/<C-R>"<CR>       : search for visually highlighted text

noremap <C-Tab>         :bnext<CR>
inoremap <C-Tab>        :bnext<CR>
cnoremap <C-Tab>        :bnext<CR>
noremap <S-C-Tab>       :bprevious<CR>
inoremap <S-C-Tab>      :bprevious<CR>
cnoremap <S-C-Tab>      :bprevious<CR>

" src: http://files.werx.dk/wombat.vim
" http://dengmao.wordpress.com/2007/01/22/vim-color-scheme-wombat/
"colorscheme wombat

" src:
" wget --no-check-certificate https://github.com/altercation/vim-colors-solarized/raw/master/colors/solarized.vim
" http://ethanschoonover.com/solarized
if has('gui_running')
    set background=dark
    colorscheme solarized
    set lines=50
    set columns=160
    if has("gui-win32")
        set guifont=Consolas:h10
    elseif has("mac")
        set guifont=Monaco:h13
    elseif has("unix")
        set guifont=Dejavu\ Sans\ Mono\ 10
    endif
else
    set background=dark
    if !has("unix")
        colorscheme wombat
    else
        "colorscheme darkblue
        colorscheme ir_black
"        colorscheme solarized
    endif
endif

" 2 additional <CR>s to get past prompting
map <F6> : call SaveAndMake()<CR><CR><CR>
map <S-F6> : call SaveAndRebuild()<CR><CR><CR>

func! SaveAndMake()
    exec "w"
    exec ":make"
    exec "copen"
endfunc

func! SaveAndRebuild()
    exec "w"
    exec ":make rebuild"
    exec "copen"
endfunc

function! OpenURL(url)
    if has("win32")
        exe "!start cmd /cstart /b ".a:url.""
    elseif $DISPLAY !~ '^\w'
        exe "silent !sensible-browser \"".a:url."\""
    else
        exe "silent !sensible-browser -T \"".a:url."\""
    endif
    redraw!
endfunction
command! -nargs=1 OpenURL :call OpenURL(<q-args>)
" open URL under cursor in browser
nnoremap gb :OpenURL <cfile><CR>
nnoremap gA :OpenURL http://www.answers.com/<cword><CR>
nnoremap gG :OpenURL http://www.google.com/search?q=<cword><CR>
nnoremap gW :OpenURL http://en.wikipedia.org/wiki/Special:Search?search=<cword><CR>

" Show syntax highlighting groups for word under cursor
nmap <C-S-P> :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" Source the vimrc file after saving it
if has("autocmd")
  autocmd bufwritepost $MYVIMRC source $MYVIMRC
endif

nmap <leader>v :split $MYVIMRC<CR>

cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%

" shortcuts for copying to/from clipboard
if has("win32")
    nmap <leader>y "+y
    nmap <leader>Y "+yy
    nmap <leader>p "+p
    nmap <leader>P "+P
else
    nmap <leader>y "*y
    nmap <leader>Y "*yy
    nmap <leader>p "*p
    nmap <leader>P "+P
endif

" shortcut to toggle spelling
nmap <leader>s :setlocal spell! spelllang=en_us<CR>

" Auto change the directory to the current file I'm working on
" conflicts with Command-T
" autocmd BufEnter * lcd %:p:h

autocmd filetype help set nonumber      " no line numbers when viewing help
autocmd filetype help nnoremap <buffer><cr> <c-]>   " Enter selects subject
autocmd filetype help nnoremap <buffer><bs> <c-T>   " Backspace to go back

" shortcuts to open/close the quickfix window
nmap <leader>c :copen<CR>
nmap <leader>cc :cclose<CR>

nmap <leader>l :lopen<CR>
nmap <leader>ll :lclose<CR>
nmap <leader>ln :lN<CR>
nmap <leader>lp :lN<CR>

" use - and + to resize horizontal splits
map - <C-W>-
map + <C-W>+
