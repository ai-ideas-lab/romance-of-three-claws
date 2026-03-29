#!/bin/bash
# 孔明智能助手 - 工具别名配置
# 在安装新工具时自动加载相应的别名

# 颜色输出函数
color_print() {
    case $1 in
        "green") echo -e "\033[0;32m$2\033[0m" ;;
        "yellow") echo -e "\033[1;33m$2\033[0m" ;;
        "blue") echo -e "\033[0;34m$2\033[0m" ;;
        *) echo "$2" ;;
    esac
}

# eza 配置
if command -v eza &> /dev/null; then
    case eza in
        eza)
            alias ls='eza --color=auto --icons=auto'
            alias l='eza -l --color=auto --icons=auto'
            alias ll='eza -la --color=auto --icons=auto'
            color_print "green" "✅ eza 别名已加载"
            ;;
        bat)
            alias cat='bat --paging=never --style=plain'
            alias more='bat --paging=always'
            color_print "green" "✅ bat 别名已加载"
            ;;
        fd)
            alias find='fd --hidden --exclude .git'
            alias fdd='fd --type d --hidden --exclude .git'
            color_print "green" "✅ fd 别名已加载"
            ;;
        rg)
            alias grep='rg --hidden --glob "!.git"'
            alias rgi='rg --hidden --glob "!.git" -i'
            color_print "green" "✅ ripgrep 别名已加载"
            ;;
        dust)
            alias du='dust -r'
            color_print "green" "✅ dust 别名已加载"
            ;;
        gh)
            alias gitpr='gh pr'
            alias gitissue='gh issue'
            color_print "green" "✅ gh 别名已加载"
            ;;
        fzf)
            alias f='fzf'
            alias ff='fzf --filter'
            # 搜索函数
            search_history() { history | fzf; }
            search_files() { fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'; }
            color_print "green" "✅ fzf 别名已加载"
            ;;
        rustc)
            alias cb='cargo build'
            alias cr='cargo run'
            alias ct='cargo test'
            color_print "green" "✅ Rust 别名已加载"
            ;;
    esac
fi

# bat 配置
if command -v bat &> /dev/null; then
    case bat in
        eza)
            alias ls='eza --color=auto --icons=auto'
            alias l='eza -l --color=auto --icons=auto'
            alias ll='eza -la --color=auto --icons=auto'
            color_print "green" "✅ eza 别名已加载"
            ;;
        bat)
            alias cat='bat --paging=never --style=plain'
            alias more='bat --paging=always'
            color_print "green" "✅ bat 别名已加载"
            ;;
        fd)
            alias find='fd --hidden --exclude .git'
            alias fdd='fd --type d --hidden --exclude .git'
            color_print "green" "✅ fd 别名已加载"
            ;;
        rg)
            alias grep='rg --hidden --glob "!.git"'
            alias rgi='rg --hidden --glob "!.git" -i'
            color_print "green" "✅ ripgrep 别名已加载"
            ;;
        dust)
            alias du='dust -r'
            color_print "green" "✅ dust 别名已加载"
            ;;
        gh)
            alias gitpr='gh pr'
            alias gitissue='gh issue'
            color_print "green" "✅ gh 别名已加载"
            ;;
        fzf)
            alias f='fzf'
            alias ff='fzf --filter'
            # 搜索函数
            search_history() { history | fzf; }
            search_files() { fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'; }
            color_print "green" "✅ fzf 别名已加载"
            ;;
        rustc)
            alias cb='cargo build'
            alias cr='cargo run'
            alias ct='cargo test'
            color_print "green" "✅ Rust 别名已加载"
            ;;
    esac
fi

# fd 配置
if command -v fd &> /dev/null; then
    case fd in
        eza)
            alias ls='eza --color=auto --icons=auto'
            alias l='eza -l --color=auto --icons=auto'
            alias ll='eza -la --color=auto --icons=auto'
            color_print "green" "✅ eza 别名已加载"
            ;;
        bat)
            alias cat='bat --paging=never --style=plain'
            alias more='bat --paging=always'
            color_print "green" "✅ bat 别名已加载"
            ;;
        fd)
            alias find='fd --hidden --exclude .git'
            alias fdd='fd --type d --hidden --exclude .git'
            color_print "green" "✅ fd 别名已加载"
            ;;
        rg)
            alias grep='rg --hidden --glob "!.git"'
            alias rgi='rg --hidden --glob "!.git" -i'
            color_print "green" "✅ ripgrep 别名已加载"
            ;;
        dust)
            alias du='dust -r'
            color_print "green" "✅ dust 别名已加载"
            ;;
        gh)
            alias gitpr='gh pr'
            alias gitissue='gh issue'
            color_print "green" "✅ gh 别名已加载"
            ;;
        fzf)
            alias f='fzf'
            alias ff='fzf --filter'
            # 搜索函数
            search_history() { history | fzf; }
            search_files() { fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'; }
            color_print "green" "✅ fzf 别名已加载"
            ;;
        rustc)
            alias cb='cargo build'
            alias cr='cargo run'
            alias ct='cargo test'
            color_print "green" "✅ Rust 别名已加载"
            ;;
    esac
fi

# rg 配置
if command -v rg &> /dev/null; then
    case rg in
        eza)
            alias ls='eza --color=auto --icons=auto'
            alias l='eza -l --color=auto --icons=auto'
            alias ll='eza -la --color=auto --icons=auto'
            color_print "green" "✅ eza 别名已加载"
            ;;
        bat)
            alias cat='bat --paging=never --style=plain'
            alias more='bat --paging=always'
            color_print "green" "✅ bat 别名已加载"
            ;;
        fd)
            alias find='fd --hidden --exclude .git'
            alias fdd='fd --type d --hidden --exclude .git'
            color_print "green" "✅ fd 别名已加载"
            ;;
        rg)
            alias grep='rg --hidden --glob "!.git"'
            alias rgi='rg --hidden --glob "!.git" -i'
            color_print "green" "✅ ripgrep 别名已加载"
            ;;
        dust)
            alias du='dust -r'
            color_print "green" "✅ dust 别名已加载"
            ;;
        gh)
            alias gitpr='gh pr'
            alias gitissue='gh issue'
            color_print "green" "✅ gh 别名已加载"
            ;;
        fzf)
            alias f='fzf'
            alias ff='fzf --filter'
            # 搜索函数
            search_history() { history | fzf; }
            search_files() { fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'; }
            color_print "green" "✅ fzf 别名已加载"
            ;;
        rustc)
            alias cb='cargo build'
            alias cr='cargo run'
            alias ct='cargo test'
            color_print "green" "✅ Rust 别名已加载"
            ;;
    esac
fi

# dust 配置
if command -v dust &> /dev/null; then
    case dust in
        eza)
            alias ls='eza --color=auto --icons=auto'
            alias l='eza -l --color=auto --icons=auto'
            alias ll='eza -la --color=auto --icons=auto'
            color_print "green" "✅ eza 别名已加载"
            ;;
        bat)
            alias cat='bat --paging=never --style=plain'
            alias more='bat --paging=always'
            color_print "green" "✅ bat 别名已加载"
            ;;
        fd)
            alias find='fd --hidden --exclude .git'
            alias fdd='fd --type d --hidden --exclude .git'
            color_print "green" "✅ fd 别名已加载"
            ;;
        rg)
            alias grep='rg --hidden --glob "!.git"'
            alias rgi='rg --hidden --glob "!.git" -i'
            color_print "green" "✅ ripgrep 别名已加载"
            ;;
        dust)
            alias du='dust -r'
            color_print "green" "✅ dust 别名已加载"
            ;;
        gh)
            alias gitpr='gh pr'
            alias gitissue='gh issue'
            color_print "green" "✅ gh 别名已加载"
            ;;
        fzf)
            alias f='fzf'
            alias ff='fzf --filter'
            # 搜索函数
            search_history() { history | fzf; }
            search_files() { fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'; }
            color_print "green" "✅ fzf 别名已加载"
            ;;
        rustc)
            alias cb='cargo build'
            alias cr='cargo run'
            alias ct='cargo test'
            color_print "green" "✅ Rust 别名已加载"
            ;;
    esac
fi

# gh 配置
if command -v gh &> /dev/null; then
    case gh in
        eza)
            alias ls='eza --color=auto --icons=auto'
            alias l='eza -l --color=auto --icons=auto'
            alias ll='eza -la --color=auto --icons=auto'
            color_print "green" "✅ eza 别名已加载"
            ;;
        bat)
            alias cat='bat --paging=never --style=plain'
            alias more='bat --paging=always'
            color_print "green" "✅ bat 别名已加载"
            ;;
        fd)
            alias find='fd --hidden --exclude .git'
            alias fdd='fd --type d --hidden --exclude .git'
            color_print "green" "✅ fd 别名已加载"
            ;;
        rg)
            alias grep='rg --hidden --glob "!.git"'
            alias rgi='rg --hidden --glob "!.git" -i'
            color_print "green" "✅ ripgrep 别名已加载"
            ;;
        dust)
            alias du='dust -r'
            color_print "green" "✅ dust 别名已加载"
            ;;
        gh)
            alias gitpr='gh pr'
            alias gitissue='gh issue'
            color_print "green" "✅ gh 别名已加载"
            ;;
        fzf)
            alias f='fzf'
            alias ff='fzf --filter'
            # 搜索函数
            search_history() { history | fzf; }
            search_files() { fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'; }
            color_print "green" "✅ fzf 别名已加载"
            ;;
        rustc)
            alias cb='cargo build'
            alias cr='cargo run'
            alias ct='cargo test'
            color_print "green" "✅ Rust 别名已加载"
            ;;
    esac
fi

# fzf 配置
if command -v fzf &> /dev/null; then
    case fzf in
        eza)
            alias ls='eza --color=auto --icons=auto'
            alias l='eza -l --color=auto --icons=auto'
            alias ll='eza -la --color=auto --icons=auto'
            color_print "green" "✅ eza 别名已加载"
            ;;
        bat)
            alias cat='bat --paging=never --style=plain'
            alias more='bat --paging=always'
            color_print "green" "✅ bat 别名已加载"
            ;;
        fd)
            alias find='fd --hidden --exclude .git'
            alias fdd='fd --type d --hidden --exclude .git'
            color_print "green" "✅ fd 别名已加载"
            ;;
        rg)
            alias grep='rg --hidden --glob "!.git"'
            alias rgi='rg --hidden --glob "!.git" -i'
            color_print "green" "✅ ripgrep 别名已加载"
            ;;
        dust)
            alias du='dust -r'
            color_print "green" "✅ dust 别名已加载"
            ;;
        gh)
            alias gitpr='gh pr'
            alias gitissue='gh issue'
            color_print "green" "✅ gh 别名已加载"
            ;;
        fzf)
            alias f='fzf'
            alias ff='fzf --filter'
            # 搜索函数
            search_history() { history | fzf; }
            search_files() { fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'; }
            color_print "green" "✅ fzf 别名已加载"
            ;;
        rustc)
            alias cb='cargo build'
            alias cr='cargo run'
            alias ct='cargo test'
            color_print "green" "✅ Rust 别名已加载"
            ;;
    esac
fi

# rustc 配置
if command -v rustc &> /dev/null; then
    case rustc in
        eza)
            alias ls='eza --color=auto --icons=auto'
            alias l='eza -l --color=auto --icons=auto'
            alias ll='eza -la --color=auto --icons=auto'
            color_print "green" "✅ eza 别名已加载"
            ;;
        bat)
            alias cat='bat --paging=never --style=plain'
            alias more='bat --paging=always'
            color_print "green" "✅ bat 别名已加载"
            ;;
        fd)
            alias find='fd --hidden --exclude .git'
            alias fdd='fd --type d --hidden --exclude .git'
            color_print "green" "✅ fd 别名已加载"
            ;;
        rg)
            alias grep='rg --hidden --glob "!.git"'
            alias rgi='rg --hidden --glob "!.git" -i'
            color_print "green" "✅ ripgrep 别名已加载"
            ;;
        dust)
            alias du='dust -r'
            color_print "green" "✅ dust 别名已加载"
            ;;
        gh)
            alias gitpr='gh pr'
            alias gitissue='gh issue'
            color_print "green" "✅ gh 别名已加载"
            ;;
        fzf)
            alias f='fzf'
            alias ff='fzf --filter'
            # 搜索函数
            search_history() { history | fzf; }
            search_files() { fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'; }
            color_print "green" "✅ fzf 别名已加载"
            ;;
        rustc)
            alias cb='cargo build'
            alias cr='cargo run'
            alias ct='cargo test'
            color_print "green" "✅ Rust 别名已加载"
            ;;
    esac
fi


# 配置完成
color_print "blue" "=== 工具配置完成 ==="
color_print "green" "已配置工具数量: $(grep -c "alias" $0)"
color_print "yellow" "使用 'source tool_aliases.sh' 加载配置"

