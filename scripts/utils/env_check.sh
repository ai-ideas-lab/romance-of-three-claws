#!/usr/bin/env bash
# 孔明智能助手 - 环境检查脚本
# 自动检查开发环境和工具状态

echo "=== 孔明智能助手 - 开发环境检查 ==="
echo "检查时间: $(date)"
echo "检查用户: $(whoami)"
echo "当前路径: $(pwd)"
echo

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查函数
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $1${NC} $(command -v "$1")"
        return 0
    else
        echo -e "${RED}❌ $1${NC} 未安装"
        return 1
    fi
}

check_version() {
    if command -v "$1" >/dev/null 2>&1; then
        version=$($1 --version 2>/dev/null | head -n1)
        if [ -n "$version" ]; then
            echo -e "${GREEN}✅ $1${NC} $version"
        else
            echo -e "${YELLOW}⚠️  $1${NC} 版本信息不可用"
        fi
        return 0
    else
        echo -e "${RED}❌ $1${NC} 未安装"
        return 1
    fi
}

echo -e "${BLUE}=== 系统基础信息 ===${NC}"
echo "操作系统: $(uname -s)"
echo "系统版本: $(uname -r)"
echo "机器架构: $(uname -m)"
echo "主机名: $(hostname)"
echo

echo -e "${BLUE}=== 开发环境检查 ===${NC}"
check_command "node"
check_command "npm"
check_command "python3"
check_command "python"
check_command "git"
check_command "docker"
echo

echo -e "${BLUE}=== CLI工具检查 ===${NC}"
check_command "gh"
check_command "fzf"
check_command "rg"
check_command "eza"
check_command "bat"
check_command "fd"
check_command "dust"
check_command "rustc"
echo

echo -e "${BLUE}=== 包管理器检查 ===${NC}"
check_command "yarn"
check_command "pip"
check_command "pip3"
echo

echo -e "${BLUE}=== Shell和编辑器检查 ===${NC}"
check_command "zsh"
check_command "bash"
check_command "vim"
check_command "nvim"
echo

echo -e "${BLUE}=== OpenClaw相关检查 ===${NC}"
check_command "openclaw"
echo

echo -e "${BLUE}=== 工作区配置文件检查 ===${NC}"
if [ -f ".shell_aliases" ]; then
    echo -e "${GREEN}✅ .shell_aliases${NC} 存在"
else
    echo -e "${RED}❌ .shell_aliases${NC} 不存在"
fi

if [ -f ".git_aliases" ]; then
    echo -e "${GREEN}✅ .git_aliases${NC} 存在"
else
    echo -e "${RED}❌ .git_aliases${NC} 不存在"
fi

if [ -f ".vimrc" ]; then
    echo -e "${GREEN}✅ .vimrc${NC} 存在"
else
    echo -e "${RED}❌ .vimrc${NC} 不存在"
fi

echo
echo -e "${BLUE}=== 环境总结 ===${NC}"
echo -e "${YELLOW}提示: 使用 'source .shell_aliases' 加载shell别名${NC}"
echo -e "${YELLOW}提示: 使用 'source .git_aliases' 加载git别名${NC}"
echo -e "${YELLOW}提示: Neovim配置已就绪，可直接使用 'nvim'${NC}"
echo

echo "=== 检查完成 ==="