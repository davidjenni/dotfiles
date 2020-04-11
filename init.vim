" neovim configuration
if !has("nvim-0.4")
    echo("A recent neovim version >= 0.4 is required!")
    exe '!nvim -u NONE -version'
    sleep 4
    cquit
endif

" OS specifics
silent function! IsOSX()
  return has('macunix')
endfunction
silent function! IsLinux()
  return has('unix') && !has('macunix') && !has('win32unix')
endfunction
silent function! IsWindows()
  return  (has('win16') || has('win32') || has('win64'))
endfunction


" bootstrap plugin manager:
if IsWindows()
    let s:autoLoadDir = $LOCALAPPDATA . "\\nvim\\autoload"
else
    let s:autoLoadDir = "~/.vim/nvim/autoload"
endif
let s:plugVimFile = s:autoLoadDir . "/plug.vim"
if !filereadable(s:plugVimFile)
    echo "Bootstrapping vim-plug..."
    silent execute '!curl -fLo ' . s:plugVimFile . ' --create-dirs
        \ "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"'
    echo "Installing plugins..."
    autocmd VimEnter * PlugInstall
endif

" install plugins:
call plug#begin(stdpath('data') . '/plugged')
Plug 'editorconfig/editorconfig-vim'

Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-fugitive'
  nmap <leader>gs :Gstatus<CR>
  nmap <leader>gd :Gdiff<CR>
  nmap <leader>gl :Glog<CR>
  nmap <leader>ci :Gcommit<CR>
  let g:airline#extensions#branch#enabled = 1

Plug 'bling/vim-airline'

" Language support:
Plug 'HerringtonDarkholme/yats.vim'
" Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
" Plug 'rust-lang/rust.vim'

call plug#end()
