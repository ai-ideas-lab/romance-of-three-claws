#!/bin/bash
# 智能配置检查与优化脚本
# 作者: 孔明
# 功能: 全面检查并优化开发环境配置

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "\n${PURPLE}=== $1 ===${NC}"
}

# 检查命令是否存在
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 获取命令版本
get_version() {
    if check_command "$1"; then
        $1 --version 2>/dev/null | head -n1 | cut -d' ' -f1-3 || echo "Unknown"
    else
        echo "Not installed"
    fi
}

# 检查并生成智能别名
setup_smart_aliases() {
    log_step "智能别名配置检查"
    
    local alias_file="$HOME/.shell_aliases"
    local backup_file="$alias_file.backup.$(date +%Y%m%d_%H%M%S)"
    
    # 备份现有配置
    if [[ -f "$alias_file" ]]; then
        cp "$alias_file" "$backup_file"
        log_info "已备份现有配置到 $backup_file"
    fi
    
    cat > "$alias_file" << 'EOF'
# 孔明智能Shell别名配置 - 自动生成于 $(date)
# 基于可用工具的智能配置

# 基础工具别名
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# 智能工具检测和别名
if check_command eza; then
    alias ls='eza --color=auto --icons'
    alias ll='eza -al --icons'
    alias la='eza -a --icons'
    alias tree='eza --tree --icons'
    log_info "使用eza替代ls"
elif check_command ls; then
    alias ls='ls -F --color=auto'
fi

if check_command bat; then
    alias cat='bat --style=plain --color=always'
    alias less='bat --style=plain --paging=always'
    log_info "使用bat替代cat"
fi

if check_command fd; then
    alias find='fd --color=auto'
    log_info "使用fd替代find"
fi

if check_command rg; then
    alias grep='rg --color=auto'
    log_info "使用ripgrep替代grep"
elif check_command grep; then
    alias grep='grep --color=auto'
fi

if check_command dust; then
    alias du='dust -c'
    alias df='df -h'
    log_info "使用dust替代du"
fi

if check_command gh; then
    alias pr='gh pr view --json title,body,author,state,mergeable,reviews'
    alias issue='gh issue view --json title,body,state,assignees'
    log_info "GitHub CLI别名已配置"
fi

if check_command fzf; then
    alias ff='fzf --height=40% --border'
    alias fdv='fzf --height=40% --border --reverse'
    log_info "fzf别名已配置"
fi

# 开发工具别名
alias npm outdated='npm outdated --depth=0'
alias npm update='npm update && npm outdated'
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gds='git diff --staged'

# 系统工具别名
alias sysinfo='system_profiler SPHardwareDataType | grep -E "(Chip|Memory|Processor)"'
alias diskusage='df -h | grep -E "Filesystem|/$"'
alias psaux='ps aux | grep -v grep | fzf --height=40% --border'
alias psgrep='ps aux | grep'

# 文件操作别名
alias mkdir='mkdir -pv'
alias rm='rm -iv'
alias cp='cp -iv'
alias mv='mv -iv'

# 网络工具别名
alias ping='ping -c 4'
alias wget='wget -c'
alias curl='curl -L -O'
alias myip='curl ifconfig.me'

# 查看函数定义
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# 加载额外配置（如果存在）
if [[ -f "$HOME/.custom_aliases" ]]; then
    log_info "加载自定义别名配置"
    source "$HOME/.custom_aliases"
fi

EOF

    log_success "智能别名配置已生成: $alias_file"
    
    # 检查shell配置
    local shell_rc="$HOME/.zshrc"
    if [[ ! -f "$shell_rc" ]]; then
        shell_rc="$HOME/.bashrc"
    fi
    
    if ! grep -q "source.*shell_aliases" "$shell_rc" 2>/dev/null; then
        echo "# 加载孔明智能别名配置" >> "$shell_rc"
        echo "source $alias_file" >> "$shell_rc"
        log_success "已在 $shell_rc 中添加别名配置"
    fi
}

# 检查并优化Git配置
setup_git_config() {
    log_step "Git配置检查与优化"
    
    local git_dir="$HOME/.git_aliases"
    local backup_git="$git_dir.backup.$(date +%Y%m%d_%H%M%S)"
    
    # 备份现有配置
    if [[ -f "$git_dir" ]]; then
        cp "$git_dir" "$backup_git"
        log_info "已备份Git配置到 $backup_git"
    fi
    
    cat > "$git_dir" << 'EOF'
# 孔明智能Git别名配置
# 基于最佳实践的Git工作流

# 基础别名
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add -p'
alias gr='git reset'
alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'

# 提交别名
alias gc='git commit -m'
alias gca='git commit -am'
alias gcm='git commit -m'
alias gcam='git commit -am'
alias gcS='git commit -S -m'

# 查看别名
alias gl='git log --oneline --graph --decorate --all'
alias gla='git log --oneline --graph --decorate --all --stat'
alias glg='git log --oneline --graph --decorate --all --grep'
alias gls='git log --oneline --graph --decorate --all --since'
alias glu='git log --oneline --graph --decorate --all --until'

# 分支别名
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gbl='git branch --list'
alias gbm='git branch --merged'
alias gbn='git branch --no-merged'

# 远程别名
alias gr='git remote'
alias gra='git remote add'
alias grr='git remote remove'
alias grv='git remote -v'
alias grs='git remote show'
alias grb='git remote branch'

# 合并别名
alias gm='git merge'
alias gmm='git merge main'
alias gmd='git merge --no-ff'
alias gma='git merge --abort'

# 标签别名
alias gt='git tag'
alias gtl='git tag -l'
gta='git tag -a'
gtd='git tag -d'
gtp='git push --tags'
gtd='git push origin --delete'

# 暂存别名
alias gst='git stash'
alias gsta='git stash apply'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'

# 补丁别名
alias gcp='git cherry-pick'
alias gcpc='git cherry-pick --continue'
alias gcpa='git cherry-pick --abort'

# 子模块别名
alias gsm='git submodule'
alias gsma='git submodule add'
alias gsu='git submodule update'
alias gsd='git submodule deinit -f'
alias gss='git submodule status'

# 重置别名
alias grc='git rebase --continue'
alias gra='git rebase --abort'
alias gri='git rebase -i'

# 统计别名
alias gstat='git diff --stat'
alias gstats='git diff --stat --cached'
alias gstatb='git branch -v --merged'
alias gstatl='git log --oneline --stat'

# 其他有用别名
alias gurl='git config --get remote.origin.url'
alias gwho='git shortlog -s -n'
alias gignore='git update-index --assume-unchanged'
alias gunignore='git update-index --no-assume-unchanged'
alias gignored='git ls-files -v | grep "^[[:lower:]]"'

# 清理别名
alias gclean='git clean -fd'
alias gprune='git remote prune origin'
alias gcleanup='git remote prune origin && git branch --merged | grep -v "^\*" | xargs git branch -d'

# 强制推送别名 (谨慎使用)
alias gpf='git push --force-with-lease'
alias gpff='git push --force'
alias gpf='git push --force-with-lease'

EOF

    log_success "Git别名配置已生成: $git_dir"
}

# 检查并优化编辑器配置
setup_editor_config() {
    log_step "编辑器配置检查与优化"
    
    local neovimrc="$HOME/.vimrc"
    if check_command nvim; then
        neovimrc="$HOME/.config/nvim/init.vim"
    fi
    
    local backup_nvim="$neovimrc.backup.$(date +%Y%m%d_%H%M%S)"
    
    # 备份现有配置
    if [[ -f "$neovimrc" ]]; then
        cp "$neovimrc" "$backup_nvim"
        log_info "已备份编辑器配置到 $backup_nvim"
    fi
    
    cat > "$neovimrc" << 'EOF'
" 孔明智能编辑器配置 - 基于最佳实践的Neovim/Vim配置
" 自动生成于 $(date)

" 基础设置
set nocompatible              " 使用vim的改进模式
filetype plugin indent on     " 开启文件类型检测
syntax on                     " 语法高亮
set encoding=utf-8            " UTF-8编码
set fileencoding=utf-8        " 文件编码

" 界面设置
set number                    " 显示行号
set relativenumber            " 显示相对行号
set cursorline                " 高亮当前行
set showmatch                 " 显示匹配括号
set matchtime=2               " 匹配括号高亮时间

" 编辑设置
set tabstop=4                 " Tab宽度为4
set shiftwidth=4              " 自动缩进宽度
set expandtab                 " 用空格替代Tab
set smarttab                  " 智能Tab
set autoindent                " 自动缩进
set smartindent               " 智能缩进
set cindent                   " C风格缩进

" 搜索设置
set hlsearch                  " 高亮搜索结果
set incsearch                 " 增量搜索
set ignorecase                " 搜索时忽略大小写
set smartcase                 " 搜索时智能大小写

" 文件操作
set hidden                    " 允许在缓冲区中有未保存的文件
set confirm                   " 操作文件时确认
set autoread                  " 自动读取文件变化
set autowrite                 " 自动保存文件

" 界面设置
set laststatus=2              " 显示状态行
set showcmd                   " 显示命令
set showmode                  " 显示模式
set wildmenu                  " 命令行补全菜单
set wildmode=longest,list,full " 命令行补全模式

" 性能优化
set lazyredraw                " 执行命令时不重绘
 ttyfast                     " 快速终端响应

" 键盘映射
let mapleader = ' '          " 空格键作为leader键

" 基础快捷键
nnoremap <leader>w :w<CR>    " 保存
nnoremap <leader>q :q<CR>    " 退出
nnoremap <leader>wq :wq<CR>  " 保存并退出
nnoremap <leader>bd :bd<CR>  " 关闭缓冲区

" 窗口操作
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>
nnoremap <leader>vs :vsplit<CR>
nnoremap <leader>sp :split<CR>

" 缓冲区操作
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprevious<CR>
nnoremap <leader>bc :bdelete<CR>

" 文件类型特定配置
autocmd BufRead,BufNewFile *.json set ft=json
autocmd BufRead,BufNewFile *.yaml set ft=yaml
autocmd BufRead,BufNewFile *.yml set ft=yaml
autocmd BufRead,BufNewFile *.md set ft=markdown
autocmd BufRead,BufNewFile *.sh set ft=sh
autocmd BufRead,BufNewFile *.py set ft=python
autocmd BufRead,BufNewFile *.js set ft=javascript
autocmd BufRead,BufNewFile *.ts set ft=typescript
autocmd BufRead,BufNewFile *.tsx set ft=typescriptreact
autocmd BufRead,BufNewFile *.jsx set ft=javascriptreact

" 插件配置 (如果有)
if has('nvim')
    " Neovim特定设置
    set inccommand=split       " 实时搜索替换
    set termguicolors          " 真彩色支持
endif

" 状态栏配置
set statusline=%f\ %m%r%h%w\ [%{&ff}]\ [%{&fileencoding}]\ [%Y]\ %P\ [%l,%c]\ [%p%%]

" 备份设置
set nobackup                  " 不创建备份文件
set noswapfile               " 不创建交换文件
set undofile                 " 持久化撤销历史
set undodir=~/.vim/undo      " 撤销文件目录
if !isdirectory($HOME . '/.vim/undo')
    call mkdir($HOME . '/.vim/undo', 'p', 0700)
endif

" 自动命令
augroup AutoCommands
    autocmd!
    " 保存时自动去除尾部空白
    autocmd BufWritePre * %s/\s\+$//e
    " 保存时自动格式化
    autocmd BufWritePre * %s/\n\{3,}/\r\r/e
augroup END

" 键盘映射优化
nnoremap ; :
nnoremap : ;
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" 搜索优化
vnoremap // y/<C-R>"<CR>
nnoremap <leader>/ :nohlsearch<CR>
nnoremap <leader>hl :nohlsearch<CR>

EOF

    log_success "编辑器配置已生成: $neovimrc"
}

# 主函数
main() {
    log_step "智能配置检查与优化开始"
    log_info "开始时间: $(date)"
    
    # 显示系统信息
    log_step "系统信息"
    echo "操作系统: $(uname -s)"
    echo "架构: $(uname -m)"
    echo "Shell: $SHELL"
    echo "当前目录: $(pwd)"
    
    # 检查关键工具
    log_step "关键工具检查"
    local tools=("node" "npm" "git" "python" "brew")
    for tool in "${tools[@]}"; do
        if check_command "$tool"; then
            log_success "$tool: $(get_version $tool)"
        else
            log_warning "$tool: 未安装"
        fi
    done
    
    # 执行配置优化
    setup_smart_aliases
    setup_git_config
    setup_editor_config
    
    # 显示完成信息
    log_step "配置优化完成"
    log_success "智能配置检查与优化已完成"
    log_info "完成时间: $(date)"
    
    # 提示重新加载shell
    log_warning "请重新加载shell或重启终端以使配置生效"
    log_info "运行: source ~/.zshrc 或 source ~/.bashrc"
}

# 执行主函数
main "$@"