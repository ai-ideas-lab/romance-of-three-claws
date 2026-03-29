#!/bin/bash

# 环境验证脚本 - 检查所有开发工具和配置
# 作者: 孔明
# 日期: 2026-03-28

echo "🔍 环境验证检查开始..."
echo "⏰ 当前时间: $(date)"
echo "📍 工作目录: $(pwd)"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的文本
print_status() {
    local status=$1
    local message=$2
    case $status in
        "✅") echo -e "${GREEN}${status} ${message}${NC}" ;;
        "❌") echo -e "${RED}${status} ${message}${NC}" ;;
        "⏳") echo -e "${YELLOW}${status} ${message}${NC}" ;;
        "🔍") echo -e "${BLUE}${status} ${message}${NC}" ;;
    esac
}

print_section() {
    echo ""
    echo "============================================"
    echo "$1"
    echo "============================================"
    echo ""
}

# 系统信息检查
print_section "🖥️ 系统信息"
print_status "✅" "操作系统: $(uname -s)"
print_status "✅" "系统版本: $(uname -r)"
print_status "✅" "架构: $(uname -m)"
print_status "✅" "主机名: $(hostname)"
print_status "✅" "时区: $(date +%Z)"
print_status "✅" "当前时间: $(date)"
echo ""

# 核心开发环境检查
print_section "🛠️ 核心开发环境"
# Node.js
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    print_status "✅" "Node.js: $NODE_VERSION"
else
    print_status "❌" "Node.js: 未安装"
fi

# npm
if command -v npm >/dev/null 2>&1; then
    NPM_VERSION=$(npm --version)
    print_status "✅" "npm: $NPM_VERSION"
else
    print_status "❌" "npm: 未安装"
fi

# Python
if command -v python3 >/dev/null 2>&1; then
    PYTHON_VERSION=$(python3 --version)
    print_status "✅" "Python: $PYTHON_VERSION"
else
    print_status "❌" "Python: 未安装"
fi

# Git
if command -v git >/dev/null 2>&1; then
    GIT_VERSION=$(git --version)
    print_status "✅" "Git: $GIT_VERSION"
else
    print_status "❌" "Git: 未安装"
fi

# Docker
if command -v docker >/dev/null 2>&1; then
    DOCKER_VERSION=$(docker --version)
    print_status "✅" "Docker: $DOCKER_VERSION"
else
    print_status "❌" "Docker: 未安装"
fi

# Kubernetes
if command -v kubectl >/dev/null 2>&1; then
    KUBECTL_VERSION=$(kubectl version --client --short)
    print_status "✅" "Kubernetes: $KUBECTL_VERSION"
else
    print_status "❌" "Kubernetes: 未安装"
fi

# Helm
if command -v helm >/dev/null 2>&1; then
    HELM_VERSION=$(helm version --short)
    print_status "✅" "Helm: $HELM_VERSION"
else
    print_status "❌" "Helm: 未安装"
fi
echo ""

# 现代CLI工具检查
print_section "🚀 现代CLI工具"
tools=("gh" "fzf" "ripgrep" "eza" "bat" "fd" "dust" "rustc")

for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        case $tool in
            "rustc") version=$(rustc --version) ;;
            "gh") version=$(gh --version) ;;
            "fzf") version=$(fzf --version) ;;
            "ripgrep") version=$(rg --version) ;;
            "eza") version=$(eza --version) ;;
            "bat") version=$(bat --version) ;;
            "fd") version=$(fd --version) ;;
            "dust") version=$(dust --version) ;;
            *) version=$(command -v "$tool") ;;
        esac
        print_status "✅" "$tool: $version"
    else
        print_status "❌" "$tool: 未安装"
    fi
done
echo ""

# 包管理器检查
print_section "📦 包管理器"
if command -v yarn >/dev/null 2>&1; then
    YARN_VERSION=$(yarn --version)
    print_status "✅" "Yarn: $YARN_VERSION"
else
    print_status "❌" "Yarn: 未安装"
fi

if command -v pip3 >/dev/null 2>&1; then
    PIP_VERSION=$(pip3 --version)
    print_status "✅" "pip3: $PIP_VERSION"
else
    print_status "❌" "pip3: 未安装"
fi

if command -v jq >/dev/null 2>&1; then
    JQ_VERSION=$(jq --version)
    print_status "✅" "jq: $JQ_VERSION"
else
    print_status "❌" "jq: 未安装"
fi
echo ""

# 配置文件检查
print_section "⚙️ 配置文件"
config_files=(".shell_aliases" ".git_aliases" ".vimrc" ".zshrc" ".bashrc")

for config in "${config_files[@]}"; do
    if [[ -f "$HOME/$config" ]]; then
        print_status "✅" "$config: 已配置"
    else
        print_status "❌" "$config: 未配置"
    fi
done
echo ""

# Shell配置检查
print_section "🐚 Shell配置"
SHELL_NAME=$(basename "$SHELL")
print_status "✅" "当前Shell: $SHELL_NAME"

if [[ "$SHELL_NAME" == "zsh" ]] && [[ -f "$HOME/.zshrc" ]]; then
    if grep -q "source.*shell_aliases" "$HOME/.zshrc"; then
        print_status "✅" "ZSH别名已集成"
    else
        print_status "⚠️" "ZSH别名未集成"
    fi
elif [[ "$SHELL_NAME" == "bash" ]] && [[ -f "$HOME/.bashrc" ]]; then
    if grep -q "source.*shell_aliases" "$HOME/.bashrc"; then
        print_status "✅" "Bash别名已集成"
    else
        print_status "⚠️" "Bash别名未集成"
    fi
fi
echo ""

# OpenClaw环境检查
print_section "🎯 OpenClaw环境"
if command -v openclaw >/dev/null 2>&1; then
    OPENCLAW_VERSION=$(openclaw --version)
    print_status "✅" "OpenClaw: $OPENCLAW_VERSION"
else
    print_status "❌" "OpenClaw: 未安装"
fi

# 检查技能目录
if [[ -d "$HOME/.nvm/versions/node/v22.22.1/lib/node_modules/openclaw/skills" ]]; then
    SKILL_COUNT=$(find "$HOME/.nvm/versions/node/v22.22.1/lib/node_modules/openclaw/skills" -name "*.md" -type f | wc -l)
    print_status "✅" "已安装技能: $SKILL_COUNT 个"
else
    print_status "❌" "技能目录不存在"
fi
echo ""

# 磁盘空间检查
print_section "💾 磁盘空间"
disk_info=$(df -h . | tail -1)
print_status "🔍" "当前磁盘使用情况:"
echo "   $disk_info"
echo ""

# 内存使用检查
if command -v top >/dev/null 2>&1; then
    mem_info=$(top -l 1 -n 0 | grep "PhysMem")
    print_status "🔍" "内存使用情况:"
    echo "   $mem_info"
fi
echo ""

# 网络连接检查
print_section "🌐 网络连接"
if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    print_status "✅" "网络连接正常"
else
    print_status "❌" "网络连接异常"
fi

# 检查GitHub连接
if command -v gh >/dev/null 2>&1; then
    if gh auth status >/dev/null 2>&1; then
        print_status "✅" "GitHub认证成功"
    else
        print_status "❌" "GitHub认证失败"
    fi
else
    print_status "⏳" "GitHub CLI未安装"
fi
echo ""

print_section "📊 总结"
echo "环境验证完成！"
echo ""
echo "建议操作:"
echo "1. 安装缺失的现代化CLI工具"
echo "2. 配置Shell别名集成"
echo "3. 检查和更新认证状态"
echo "4. 清理不需要的文件"
echo ""

echo "🎯 优化建议:"
echo "- 检查Homebrew包管理器状态"
echo "- 确认所有开发工具都可用"
echo "- 验证配置文件正确加载"
echo "- 检查网络连接和认证状态"