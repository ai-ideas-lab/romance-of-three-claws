" 孔明智能助手 Neovim 配置
" 适用于现代Vim编辑器

" 基础设置
set nocompatible
filetype plugin indent on
syntax on

" 编码设置
set encoding=utf-8
set fileencoding=utf-8
set termencoding=utf-8

" 界面设置
set number relativenumber
set cursorline
set showmatch
set showmode
set showcmd
set laststatus=2

" 搜索设置
set hlsearch
set incsearch
set ignorecase
set smartcase

" 缩进设置
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set softtabstop=4

" 文件操作
set autowrite
set hidden
set backup
set backupdir=~/.vim/backup
set directory=~/.vim/swap
set undodir=~/.vim/undo

" 界面美化
set background=dark
colorscheme default

" 键盘映射
let mapleader = " "

" 快速保存和退出
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>wq :wq<CR>

" 分屏导航
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" 文件搜索
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Git 集成
nnoremap <leader>gs :Git<CR>
nnoremap <leader>ga :Git add %<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gp :Git push<CR>
nnoremap <leader>gl :Git log<CR>

" 代码格式化
nnoremap <leader>= :Format<CR>

" 插件配置 (如果安装了vim-plug)
" call plug#begin('~/.vim/plugged')

" 插件列表
" Plug 'tpope/vim-fugitive'
" Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
" Plug 'junegunn/fzf.vim'
" Plug 'preservim/nerdtree'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'airblade/vim-gitgutter'
" Plug 'tpope/vim-commentary'

" call plug#end()

" 自动命令
autocmd BufWritePre * %s/\s\+$//e  " 删除行尾空白
autocmd FileType gitcommit setlocal textwidth=72
autocmd FileType markdown setlocal textwidth=80
autocmd FileType javascript setlocal expandtab tabstop=2 shiftwidth=2
autocmd FileType typescript setlocal expandtab tabstop=2 shiftwidth=2
autocmd FileType jsx setlocal expandtab tabstop=2 shiftwidth=2
autocmd FileType tsx setlocal expandtab tabstop=2 shiftwidth=2

" 状态栏
set statusline=
set statusline+=%f\          " 文件名
set statusline+=%h          " 帮助文件标志
set statusline+=%m          " 修改标志
set statusline+=%r          " 只读标志
set statusline+=%=          " 右对齐
set statusline+=%{(&fileencoding?&fileencoding:&encoding)}
set statusline+=[%{&fileformat}]
set statusline+=%y          " 文件类型
set statusline+=%p%%        " 百分比
set statusline+=%L          " 行数

" 特殊文件类型支持
autocmd BufNewFile,BufRead *.md set filetype=markdown
autocmd BufNewFile,BufRead *.json set filetype=json
autocmd BufNewFile,BufRead *.yaml set filetype=yaml
autocmd BufNewFile,BufRead *.yml set filetype=yaml
autocmd BufNewFile,BufRead *.toml set filetype=toml
autocmd BufNewFile,BufRead *.sh set filetype=sh
autocmd BufNewFile,BufRead *.zsh set filetype=zsh
autocmd BufNewFile,BufRead *.bash set filetype=sh