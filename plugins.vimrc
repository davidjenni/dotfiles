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
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'chriskempson/base16-vim'

" essentials
NeoBundle 'bling/vim-airline'
let g:airline#extensions#tabline#enabled = 1
set noshowmode

NeoBundle 'Shougo/unite.vim'
let g:unite_source_history_yank_enable = 1
nnoremap <leader>p :<C-u>Unite -no-split -buffer-name=files   -start-insert file_rec/async:!<cr>
nnoremap <leader>t :<C-u>Unite -no-split -buffer-name=files   -start-insert file_rec<cr>
nnoremap <leader>b :<C-u>Unite -no-split -buffer-name=buffer  -start-insert buffer bookmark<cr>
nnoremap <leader>g :<C-u>Unite -no-split -buffer-name=files   -start-insert file_rec/git:--cached:--others:--exclude-standard<cr>
nnoremap <leader>f :<C-u>Unite -no-split -buffer-name=files   -start-insert file<cr>
" nnoremap <leader>r :<C-u>Unite -no-split -buffer-name=mru     -start-insert file_mru<cr>
nnoremap <leader>h :<C-u>Unite -no-split -buffer-name=yank    history/yank<cr>

autocmd FileType unite call s:unite_mappings()
function! s:unite_mappings()
  " Play nice with supertab
  let b:SuperTabDisabled=1
  imap <buffer> <C-j>   <Plug>(unite_select_next_line)
  imap <buffer> <C-k>   <Plug>(unite_select_previous_line)
endfunction

NeoBundle 'Shougo/vimproc.vim', {
      \ 'build' : {
      \     'windows' : 'nmake -f make_msvc.mak',
      \     'cygwin' : 'make -f make_cygwin.mak',
      \     'mac' : 'make -f make_mac.mak',
      \     'unix' : 'make -f make_unix.mak',
      \    },
      \ }

NeoBundle 'tpope/vim-unimpaired'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-commentary'
NeoBundle 'tpope/vim-repeat'
NeoBundle 'tpope/vim-abolish'
NeoBundle 'tpope/vim-vinegar'
NeoBundle 'tpope/vim-unimpaired'
NeoBundle 'tpope/vim-fugitive'
  nmap <leader>gs :Gstatus<CR>
  nmap <leader>gd :Gdiff<CR>
  nmap <leader>gl :Glog<CR>
  nmap <leader>ci :Gcommit<CR>
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

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

" direct calls are only valid after plugins have been loaded by above NeoBundleCheck
call unite#filters#matcher_default#use(['matcher_fuzzy'])
colorscheme molokai

