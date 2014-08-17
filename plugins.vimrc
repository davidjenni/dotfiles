" vim: set ft=vim ts=2 sts=2 sw=2 expandtab :

" standardize across OSes on one path for vim's local app data
if WINDOWS()
  set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
  let s:bundlePath='$USERPROFILE/.vim/bundle'
else
  let s:bundlePath='~/.vim/bundle'
endif

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

if !executable('git')
  echom "Cannot find 'git' on path."
  echom "NeoBundle will not be able install or update any packages, but local plugins will get loaded."
endif

let s:pluginMgr_readme=expand('~/.vim/bundle/neobundle.vim/README.md')
if !filereadable(s:pluginMgr_readme)
  echo "Installing NeoBundle..."
  echo ""
  if WINDOWS()
    let s:oldPwd=getcwd()
    lcd $USERPROFILE
    silent !mkdir .vim/bundle
    silent !git clone https://github.com/Shougo/neobundle.vim .vim/bundle/neobundle.vim/
    exec ":lcd " . s:oldPwd
  else
    silent !mkdir -p ~/.vim/bundle
    silent !git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim/
  endif
endif

" Required:
call neobundle#begin(expand(s:bundlePath))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

"" Color
NeoBundle 'tomasr/molokai'

" essentials
NeoBundle 'bling/vim-airline'
let g:airline#extensions#tabline#enabled = 1
set noshowmode

NeoBundle 'tpope/vim-unimpaired'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-commentary'
NeoBundle 'tpope/vim-repeat'
NeoBundle 'tpope/vim-abolish'
NeoBundle 'tpope/vim-vinegar'
NeoBundle 'tpope/vim-unimpaired'
NeoBundle 'tpope/vim-fugitive'
let g:airline#extensions#branch#enabled = 1
NeoBundle 'tpope/vim-dispatch'
NeoBundle 'rking/ag.vim'

"" development, languages
NeoBundle 'scrooloose/syntastic'
let g:airline#extensions#syntastic#enabled = 1

NeoBundle 'sheerun/vim-polyglot'
NeoBundle 'moll/vim-node'

"" writing
NeoBundle 'junegunn/limelight.vim'
NeoBundle 'junegunn/goyo.vim'
function! GoyoBefore()
   if exists('$TMUX')
     silent !tmux set status off
   endif
   set noshowcmd
   Limelight
 endfunction

function! GoyoAfter()
   if exists('$TMUX')
     silent !tmux set status on
   endif
   set showcmd
   Limelight!
 endfunction
let g:goyo_callbacks = [function('GoyoBefore'), function('GoyoAfter')]
nnoremap <Leader>G :Goyo<CR>

call neobundle#end()

colorscheme molokai

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

