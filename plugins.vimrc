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
  echo "Installing NeoBundle..."
  echo ""
  if IsWindows()
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

NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/unite-outline'
let g:unite_source_history_yank_enable = 1
let g:unite_enable_ignore_case  = 1
let g:unite_enable_smart_case   = 1
if IsWindows()
  " TODO: vimproc seems to have issues under Win and VS2012; don't use async yet
  nnoremap <leader>p :<C-u>Unite -no-split -buffer-name=files     -start-insert file_rec<cr>
else
  nnoremap <leader>p :<C-u>Unite -no-split -buffer-name=files     -start-insert file_rec/async:!<cr>
  nnoremap <leader>g :<C-u>Unite -no-split -buffer-name=gitfiles  -start-insert file_rec/git:--cached:--others:--exclude-standard<cr>
endif
nnoremap <leader>b :<C-u>Unite -no-split -buffer-name=buffer    -quick-match buffer bookmark<cr>
" nnoremap <leader>f :<C-u>Unite -no-split -buffer-name=localfiles  -start-insert file<cr>
nnoremap <leader>o :<C-u>Unite -no-split -buffer-name=outline   outline<cr>
" nnoremap <leader>r :<C-u>Unite -no-split -buffer-name=mru     -start-insert file_mru<cr>
nnoremap <leader>r :<C-u>Unite -no-split -buffer-name=register  register<cr>
nnoremap <leader>ma :<C-u>Unite -no-split -buffer-name=mappings mapping<cr>
nnoremap <leader>y :<C-u>Unite -no-split -buffer-name=yank      history/yank<cr>
" nnoremap <space>/ :Unite grep:.<cr>
" if executable('ag')
"   let g:unite_source_grep_command = 'ag'
"   let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
"   let g:unite_source_grep_recursive_opt = ''
" endif

autocmd FileType unite call s:unite_mappings()
function! s:unite_mappings()
  " Play nice with supertab
  let b:SuperTabDisabled=1
  imap <buffer> <C-j>   <Plug>(unite_select_next_line)
  imap <buffer> <C-k>   <Plug>(unite_select_previous_line)
endfunction

if !IsWindows()
  NeoBundle 'Shougo/vimproc.vim', {
        \ 'build' : {
        \     'windows' : 'nmake -f make_msvc.mak',
        \     'cygwin' : 'make -f make_cygwin.mak',
        \     'mac' : 'make -f make_mac.mak',
        \     'unix' : 'make -f make_unix.mak',
        \    },
        \ }
  NeoBundle 'Shougo/unite-help'
  nnoremap <leader>h :<C-u>Unite -no-split -buffer-name=help help<cr>
  " TypeScript autocomplete
  NeoBundle 'Quramy/tsuquyomi'
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

NeoBundle 'kien/ctrlp.vim'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }
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
" git clone --recursive and install script not really working in OSX or Win
" NeoBundle 'Valloric/YouCompleteMe', {
"           \ 'build' : {
"           \   'mac' : './install.sh --clang-completer',
"           \   'unix' : './install.sh --clang-completer'
"           \   }
"           \ }

" if has("lua")
if has("never")
NeoBundle 'Shougo/neocomplete.vim'
  let g:acp_enableAtStartup = 0
  let g:neocomplete#enable_at_startup = 1
  let g:neocomplete#enable_smart_case = 1
  inoremap <expr><C-g>     neocomplete#undo_completion()
  inoremap <expr><C-l>     neocomplete#complete_common_string()
  " Recommended key-mappings.
  " <CR>: close popup and save indent.
  inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
  function! s:my_cr_function()
    return neocomplete#close_popup() . "\<CR>"
    " For no inserting <CR> key.
    "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
  endfunction
  " <TAB>: completion.
  inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
  " <C-h>, <BS>: close popup and delete backword char.
  inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr><C-y>  neocomplete#close_popup()
  inoremap <expr><C-e>  neocomplete#cancel_popup()
  " Close popup by <Space>.
  inoremap <expr><Space> pumvisible() ? neocomplete#close_popup() : "\<Space>"
  " Enable omni completion.
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

NeoBundleLazy 'osyo-manga/vim-marching', {
      \  'autoload' : { 'filetypes' : [ 'c ' , 'cpp', 'cxx' ] }
      \ }
  let g:marching_enable_neocomplete=1
endif

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

call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

" direct calls are only valid after plugins have been loaded by above NeoBundleCheck
silent! call unite#filters#matcher_default#use(['matcher_fuzzy'])
if IsWindows()
  silent! colorscheme blue
  " silent! colorscheme cmd
else
  silent! colorscheme hybrid
endif


