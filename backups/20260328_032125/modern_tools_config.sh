#!/bin/bash
# 现代化工具配置脚本

echo "🚀 现代化工具配置"

# 检查工具可用性
check_tool() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "✅ $1: 可用"
        return 0
    else
        echo "❌ $1: 不可用"
        return 1
    fi
}

# 检查常用工具
echo "检查常用CLI工具:"
check_tool "gh"
check_tool "fzf"
check_tool "ripgrep"
check_tool "eza"
check_tool "bat"
check_tool "fd"
check_tool "dust"
check_tool "jq"

# 设置别名（如果工具可用）
setup_aliases() {
    echo ""
    echo "设置现代化别名:"
    
    # 如果eza可用，覆盖ls
    if check_tool "eza" >/dev/null 2>&1; then
        alias ls='eza --icons'
        alias ll='eza -al --icons'
        echo "✅ 已设置eza别名"
    fi
    
    # 如果bat可用，覆盖cat和less
    if check_tool "bat" >/dev/null 2>&1; then
        alias cat='bat'
        alias less='bat --paging=always'
        echo "✅ 已设置bat别名"
    fi
    
    # 如果fd可用，覆盖find
    if check_tool "fd" >/dev/null 2>&1; then
        alias find='fd'
        echo "✅ 已设置fd别名"
    fi
    
    # 如果ripgrep可用，覆盖grep
    if check_tool "ripgrep" >/dev/null 2>&1; then
        alias grep='rg --color=auto'
        echo "✅ 已设置ripgrep别名"
    fi
}

setup_aliases
