" vim config for Linux, OSX & Win32

set nocompatible

set runtimepath^=~/dotfiles/vimfiles

behave xterm
set title

" see also: http://items.sjbach.com/319/configuring-vim-right
runtime macros/matchit.vim

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
set writebackup
set history=500
set ruler
set showcmd
set shortmess=atI

set wildmenu
" set wildmode=longest,list
set wildmode=list:longest,list:full
set complete=.,w,t
" Ignore compiled files
set wildignore=*.o,*~,*.pyc,*.a
if has("win16") || has("win32")
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
    set wildignore+=*.obj,*.dll,*.exe
else
    set wildignore+=.git\*,.hg\*,.svn\*
endif


set nobackup
set noswapfile
set incsearch

" persist undo across sessions
if (v:version >= 703)
    silent !mkdir ~/.vim/backups > /dev/null 2>&1
    set undodir=~/.vim/backups
    set undofile
endif

set smartcase
set ignorecase
set cursorline
set cursorcolumn

" No sound on errors
set noerrorbells
set visualbell
set t_vb=
set timeoutlen=500

if (&term=="xterm-256color" || (&term=="screen" && exists("$TMUX")))
    set t_Co=256
endif

if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

if has ("autocmd")
  " Enable file type detection
  filetype plugin indent on
  augroup vimrxEx
      au!
      autocmd FileType text setlocal textwidth=78

      " Source the vimrc file after saving it
      " autocmd bufwritepost $MYVIMRC source $MYVIMRC

      " Auto change the directory to the current file I'm working on
      " autocmd BufEnter * lcd %:p:h

      autocmd filetype help set nonumber      " no line numbers when viewing help
      autocmd filetype help nnoremap <buffer><cr> <c-]>   " Enter selects subject
      autocmd filetype help nnoremap <buffer><bs> <c-T>   " Backspace to go back

      autocmd FileType make setlocal ts=8 sts=8 sw=8 noexpandtab

      " Treat files as XML
      autocmd BufNewFile,BufRead *.rss setfiletype xml
      autocmd BufNewFile,BufRead *.proj setfiletype xml
      autocmd BufNewFile,BufRead *.csproj setfiletype xml
      autocmd BufNewFile,BufRead *.targets setfiletype xml
      autocmd BufNewFile,BufRead *.settings setfiletype xml
  augroup END
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
set gdefault        " :s and :g goes global by default

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

"  treat both jump-to-mark the same (jump to line AND column)
nnoremap ' `
nnoremap ` '

nnoremap <esc> :nohlsearch<cr><esc>
map Q gq

" easy on my left pinky
imap jj <Esc>
imap jk <Esc> " easy on my left pinky
imap uu _
imap hh =>
imap aa @
" search for visually highlighted text
vmap // y/<C-R>"<CR>

noremap <C-Tab>         :bnext<CR>
inoremap <C-Tab>        :bnext<CR>
cnoremap <C-Tab>        :bnext<CR>
noremap <S-C-Tab>       :bprevious<CR>
inoremap <S-C-Tab>      :bprevious<CR>
cnoremap <S-C-Tab>      :bprevious<CR>

" buffer switching/management, might as well use those keys for something useful
map <Right> :bnext<CR>
imap <Right> <ESC>:bnext<CR>
map <Left> :bprev<CR>
imap <Left> <ESC>:bprev<CR>
map <Del> :bd<CR>
" switch upper/lower window:
nmap <Down> :wincmd j<cr>
nmap <Up> :wincmd k<cr>
" remap terminal codes for arrows
nnoremap <Esc>A :wincmd k<cr>
nnoremap <Esc>B :wincmd j<cr>
nnoremap <Esc>C :bnext<CR>
nnoremap <Esc>D :bprev<CR>

" use - and + to resize horizontal splits
map - <C-W>-
map + <C-W>+

" undo-tree panel:
nnoremap <F5> :UndotreeToggle<cr>

" src: http://files.werx.dk/wombat.vim
" http://dengmao.wordpress.com/2007/01/22/vim-color-scheme-wombat/
" http://ethanschoonover.com/solarized
" wget --no-check-certificate https://github.com/altercation/vim-colors-solarized/raw/master/colors/solarized.vim
if has('gui_running')
    " set background=dark
    " colorscheme solarized
    " set background=light
    " colorscheme molokai
    set background=dark
    colorscheme base16-ocean
    let g:molokai_original = 0
    set lines=50
    set columns=160
    if has("gui_win32")
        set guifont=Consolas:h10
    elseif has("mac")
        set guifont=Monaco:h13
        " <C-v>u21aa
        set showbreak=↪
    elseif has("unix")
        set guifont=Dejavu\ Sans\ Mono\ 10
    endif
else
    set background=dark
    if !has("unix")
        set background=dark
        " colorscheme wombat
        " colorscheme desert
        colorscheme blue
        set nocursorcolumn
    else
        " colorscheme moria
        " colorscheme ir_black
        " colorscheme solarized
        set background=light
        colorscheme molokai
    endif
endif

" 2 additional <CR>s to get past prompting
map <leader>m : call SaveAndMake()<CR><CR><CR>
map <leader>M : call SaveAndRebuild()<CR><CR><CR>

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

" shortcuts to open/close the quickfix window
nmap <leader>q :copen<CR>
nmap <leader>qq :cclose<CR>
" use he: unimpaired for quickfix navigation

nmap <leader>l :lopen<CR>
nmap <leader>ll :lclose<CR>

" fugitive mappings:
nmap <leader>gs :Gstatus<CR>
nmap <leader>gd :Gdiff<CR>
nmap <leader>gl :Glog<CR>

if has("win32")
    " TFS shortcuts: TODO: consider plugin similar to fugitive
    nmap <leader>ta :!tf add %<CR>
    nmap <leader>td :!tf diff /format:ss_unix %<CR>
    nmap <leader>te :!tf edit %<CR>
    nmap <leader>th :!tf hist /noprompt %<CR>
    nmap <leader>ti :!tf properties %<CR>
    nmap <leader>ts :!tf stat /format:brief<CR>
endif
" use Ack.vim for Ag:
" Ag from: https://github.com/ggreer/the_silver_searcher
let g:ackprg = 'ag --nogroup --nocolor --column'

" tagbar
nnoremap <silent> <F9> :TagbarToggle<CR>


