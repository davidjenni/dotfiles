-- neovim init file
-- github.com/davidjenni/dotfiles
--
local api, cmd, fn, g = vim.api, vim.cmd, vim.fn, vim.g
local opt, wo = vim.opt, vim.wo
local fmt = string.format

-- bootstrap paq-nvim:
local must_run_paq_install = false
local paq_path = fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
if fn.empty(fn.glob(paq_path)) > 0 then
  opt.cmdheight = 10    -- ensure bootstrap messages are better visible
  print('Bootstrapping paq_nvim into: ' .. paq_path .. '...')
  fn.system({'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', paq_path})
  must_run_paq_install = true
end

-- opt.wildmode = { 'list:longest', 'list:full' }
opt.wildmode = { 'list', 'full' }
-- opt.wildmode = { 'list:full' }
opt.wildignorecase = true
opt.wildoptions = "pum"
opt.pumheight = 12

opt.showmode = true
opt.showcmd = true
opt.showmatch = true

opt.number = true
opt.signcolumn = 'yes'
opt.shortmess = 'atToOFc'
opt.splitright = true
opt.splitbelow = true

opt.smarttab = true
opt.expandtab = true
local indent = 4
opt.tabstop = indent
opt.softtabstop = indent
opt.shiftwidth = indent
opt.autoindent = true
opt.smartindent = true
opt.shiftround = true
opt.cindent = true
opt.virtualedit = "onemore"
opt.joinspaces = false
opt.formatoptions = 'crqnj'

opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true
opt.scrolloff = 2
opt.sidescrolloff = 2

opt.listchars = { tab = '>.', trail = '#', extends = '>', precedes = '<' }
opt.list = true

opt.mouse = "a"
opt.belloff = "all"
opt.clipboard = 'unnamed'
opt.writebackup = false
opt.swapfile = false
opt.hidden = true
opt.switchbuf = 'useopen'
if not must_run_paq_install then
    if not fn.has('mac') then
        -- terminal on macOS has awful colors with termguicolors on
        opt.termguicolors = true
    end
    cmd[[colorscheme gruvbox]]
end

-- Don't show status line on vim terminals
cmd [[ au TermOpen term://* setlocal nonumber laststatus=0 ]]
cmd [[ au TermClose term://* setlocal number laststatus=2 ]]

cmd 'au TextYankPost * lua vim.highlight.on_yank {on_visual = false}'

-- Remember last position in file
cmd[[autocmd BufReadPost * lua goto_last_pos()]]
function goto_last_pos()
  local last_pos = vim.fn.line("'\"")
  if last_pos > 0 and last_pos <= vim.fn.line("$") then
    api.nvim_win_set_cursor(0, {last_pos, 0})
  end
end


g.mapleader = ' '


require "paq" {
    "savq/paq-nvim";                  -- Let Paq manage itself
    'tomasr/molokai';
    'dracula/vim';
    'altercation/vim-colors-solarized';
    'chriskempson/base16-vim';
    'sjl/badwolf';
    'morhetz/gruvbox';
    'jnurmine/Zenburn';
    'w0ng/vim-hybrid';

    "neovim/nvim-lspconfig";
    'tpope/vim-unimpaired';
    'tpope/vim-surround';
    'tpope/vim-commentary';
    'tpope/vim-repeat';
    'tpope/vim-abolish';
    'tpope/vim-vinegar';
    'tpope/vim-dispatch';
    'tpope/vim-fugitive';
    'ojroques/nvim-bufbar';

    'sgur/vim-editorconfig';
    'lukas-reineke/indent-blankline.nvim';

    'nvim-lua/plenary.nvim';
    'lewis6991/gitsigns.nvim';
    'vim-airline/vim-airline';
    'vim-airline/vim-airline-themes';
    -- 'hoob3rt/lualine.nvim';
    -- requires nerd-fonts:
    -- brew tap homebrew/cask-fonts
    -- brew install --cask font-hack-nerd-font
    'kyazdani42/nvim-web-devicons';

    'rking/ag.vim';
    'mbbill/undotree';
    'wellle/targets.vim';
    'mhinz/vim-hugefile';

    {'junegunn/fzf', run = fn['fzf#install']};
    'junegunn/fzf.vim';

-- development, languages
--NeoBundle 'scrooloose/syntastic'
--let g:airline#extensions#syntastic#enabled = 1

    'dag/vim-fish';
    'moll/vim-node';
    'elzr/vim-json';
}
if must_run_paq_install then
    print('calling :PaqInstall to initialize plugins...')
    cmd[[PaqInstall]]
    print('Please restart nvim once :PaqInstall has finished.')
end

local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  api.nvim_set_keymap(mode, lhs, rhs, options)
end

map('n', '<C-l>', '<cmd>noh<CR>')    -- Clear highlights
map('i', 'jk', '<ESC>')
map('n', '<leader>t', '<cmd>terminal<CR>')
map('t', '<ESC>', '&filetype == "fzf" ? "\\<ESC>" : "\\<C-\\>\\<C-n>"' , {expr = true})

-- <Tab> to navigate the completion menu
map('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', {expr = true})
map('i', '<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true})

-- airline
g['airline#extensions#tabline#enabled'] = 1

-- git/fugitive
local log = [[\%C(yellow)\%h\%Cred\%d \%Creset\%s \%Cgreen(\%ar) \%Cblue\%an\%Creset]]
map('n', '<leader>g<space>', ':Git ')
map('n', '<leader>gd', '<cmd>Gvdiffsplit<CR>')
map('n', '<leader>gg', '<cmd>Git<CR>')
map('n', '<leader>gl', fmt('<cmd>term git log --graph --all --format="%s"<CR><cmd>start<CR>', log))

-- fzf
g['fzf_action'] = {['ctrl-s'] = 'split', ['ctrl-v'] = 'vsplit'}
map('n', '<leader>/', '<cmd>BLines<CR>')
map('n', '<leader>f', '<cmd>Files<CR>')
map('n', '<leader>;', '<cmd>History:<CR>')
map('n', '<leader>r', '<cmd>Rg<CR>')
map('n', '<leader>b', '<cmd>Buffers<CR>')

-- hugefile
g['hugefile_trigger_size'] = 2

-- requiring plugins that haven't been loaded will fail, skip until :PaqInstall could finish
if not must_run_paq_install then
    -- require('lualine').setup({theme = 'gruvbox'})
    require('gitsigns').setup {
    signs = {
        add = {text = '+'},
        change = {text = '~'},
        delete = {text = '-'}, topdelete = {text = '-'}, changedelete = {text = '≃'},
    },
    }
    require("indent_blankline").setup {
        -- char = "|",
        buftype_exclude = {"terminal"}
    }
    require('bufbar').setup {show_bufname = 'visible', show_flags = false}
end
