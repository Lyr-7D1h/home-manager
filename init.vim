call plug#begin()
Plug 'tpope/vim-commentary'
Plug 'rust-lang/rust.vim'
Plug 'lnl7/vim-nix'
Plug 'cespare/vim-toml'
Plug 'jiangmiao/auto-pairs'
Plug 'roxma/nvim-cm-racer'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
call plug#end()

" Wayland copy support
set clipboard+=unnamedplus

" Always use original yank when pasting
noremap <Leader>p "0p
noremap <Leader>P "oP
vnoremap <Leader>p "0p

