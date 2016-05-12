" vim: set ft=vim ts=2 sts=2 sw=2 expandtab :

" standardize across OSes on one path for vim's local app data
if IsWindows()
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
  " echo "Installing NeoBundle..."
  if IsWindows()
    let s:oldPwd=getcwd()
    lcd $USERPROFILE
    silent !mkdir .vim\bundle
    silent !git clone https://github.com/Shougo/neobundle.vim .vim/bundle/neobundle.vim/
    exec ":lcd " . s:oldPwd
  else
    silent !mkdir -p ~/.vim/bundle
    silent !git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim/
  endif
endif

" Required:
filetype off
call neobundle#begin(expand(s:bundlePath))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

"" Color
NeoBundle 'vim-scripts/cmd.vim--Z'
NeoBundle 'tomasr/molokai'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'chriskempson/base16-vim'
NeoBundle 'sjl/badwolf'
NeoBundle 'morhetz/gruvbox'
NeoBundle 'jnurmine/Zenburn'
NeoBundle 'w0ng/vim-hybrid'

" essentials
NeoBundle 'bling/vim-airline'
let g:airline#extensions#tabline#enabled = 1
set noshowmode


if has("enable-CtrlSpace-later")
NeoBundle 'vim-ctrlspace/vim-ctrlspace'
  let g:airline_exclude_preview = 1
  if executable("ag")
      let g:CtrlSpaceGlobCommand = 'ag -l --nocolor -g ""'
  endif
  let g:CtrlSpaceIgnoredFiles = '\v(tmp|temp|Godeps)[\/]'
endif

" search with Ag and Sublime like contextual search results, editable
NeoBundle 'dyng/ctrlsf.vim'
  " let g:ctrlsf_default_root = 'project'
  let g:ctrlsf_default_root = 'cwd'
  vmap     <leader>* <Plug>CtrlSFVwordPath
  nmap     <leader>/ <Plug>CtrlSFCwordPath
  nmap     <leader>n <Plug>CtrlSFPwordPath
  " nnoremap <C-F>o :CtrlSFToggle<CR>

NeoBundle 'terryma/vim-multiple-cursors'

NeoBundle 'ctrlpvim/ctrlp.vim'
  let g:ctrlp_working_path_mode = 'ra'
  let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/]\.(git|hg|svn|node_modules)$',
    \ 'file': '\v\.(exe|so|dll)$',
    \ 'link': 'some_bad_symbolic_links',
    \ }
  if executable("ag")
    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  endif
  " ignore files in .gitignore
  "let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard'
  " NeoBundle 'spolu/dwm.vim'

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
if executable('ag')
  " ag from: https://github.com/ggreer/the_silver_searcher
  NeoBundle 'rking/ag.vim'
endif
NeoBundle 'mbbill/undotree'
nnoremap <F5> :UndotreeToggle<cr>
  " additional text objects for e.g. parameters:
NeoBundle 'wellle/targets.vim'

"" development, languages
NeoBundle 'scrooloose/syntastic'
  let g:airline#extensions#syntastic#enabled = 1

NeoBundle 'ressu/hexman.vim'
NeoBundle 'moll/vim-node'
NeoBundle 'elzr/vim-json'
  let g:vim_json_syntax_conceal = 1
  autocmd FileType json setlocal nofoldenable
" TypeScript autocomplete: TODO re-enable here once vimproc works on windows as well
" NeoBundle 'Quramy/tsuquyomi'

" any filetype specific plugins (like vim-json) need to be listed
" before vim-polyglot to avoid it dominating with its handlers
NeoBundle 'sheerun/vim-polyglot'
NeoBundle 'fatih/vim-go.git'

NeoBundle 'majutsushi/tagbar'
  nnoremap <leader>tb :TagbarToggle<CR>

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

" large file handling
NeoBundle 'mhinz/vim-hugefile'
let g:hugefile_trigger_size=2

NeoBundle 'Valloric/YouCompleteMe'

call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

" direct calls are only valid after plugins have been loaded by above NeoBundleCheck

if IsWindows()
  silent! colorscheme blue
  " silent! colorscheme cmd
else
  silent! colorscheme hybrid
endif

