#!/bin/bash

# 孔明智能助手 - 进度监控器
# 自动监控安装进程，提供实时状态更新

echo "🏯 孔明进度监控器启动"
echo "⏰ 时间: $(date)"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 监控函数
monitor_process() {
    local process_name=$1
    local check_command=$2
    
    echo -e "${BLUE}📡 监控 $process_name...${NC}"
    
    # 检查进程是否存在
    if pgrep -f "$process_name" > /dev/null; then
        echo -e "${YELLOW}🔄 $process_name 正在运行${NC}"
        
        # 检查命令是否可用
        if eval "$check_command" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ $process_name 安装成功${NC}"
            return 0
        else
            echo -e "${YELLOW}⏳ $process_name 安装中...${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ $process_name 进程未找到${NC}"
        return 2
    fi
}

# 检查GitHub CLI
echo "🔍 GitHub CLI 状态:"
if command -v gh >/dev/null 2>&1; then
    echo -e "${GREEN}✅ gh 已安装 - $(gh --version)${NC}"
else
    echo -e "${YELLOW}❌ gh 未安装${NC}"
    if pgrep -f "brew install gh" > /dev/null; then
        echo -e "${YELLOW}⏳ Homebrew 安装 gh 进程运行中...${NC}"
    else
        echo -e "${BLUE}📦 准备安装 gh...${NC}"
    fi
fi
echo ""

# 检查Rust
echo "🔍 Rust 状态:"
if command -v rustc >/dev/null 2>&1; then
    echo -e "${GREEN}✅ rustc 已安装 - $(rustc --version)${NC}"
    echo -e "${GREEN}✅ cargo 已安装 - $(cargo --version)${NC}"
else
    echo -e "${YELLOW}❌ Rust 未安装${NC}"
    if pgrep -f "rustup" > /dev/null; then
        echo -e "${YELLOW}⏳ Rust 安装进程运行中...${NC}"
    else
        echo -e "${BLUE}📦 准备安装 Rust...${NC}"
    fi
fi
echo ""

# 检查Docker
echo "🔍 Docker 状态:"
if command -v docker >/dev/null 2>&1; then
    echo -e "${GREEN}✅ docker 已安装 - $(docker --version)${NC}"
else
    echo -e "${YELLOW}❌ Docker 未安装${NC}"
    if ls -la "/Applications/Docker.app/" > /dev/null 2>&1; then
        echo -e "${YELLOW}⏳ Docker Desktop 已安装但未启动${NC}"
    else
        echo -e "${BLUE}📦 准备安装 Docker Desktop...${NC}"
    fi
fi
echo ""

# 检查Clawhub认证
echo "🔍 Clawhub 状态:"
if command -v clawhub >/dev/null 2>&1; then
    if clawhub whoami 2>/dev/null | grep -q "Not logged in"; then
        echo -e "${YELLOW}⚠️ clawhub 未登录${NC}"
        if pgrep -f "clawhub login" > /dev/null; then
            echo -e "${YELLOW}⏳ 认证进程运行中...${NC}"
        else
            echo -e "${BLUE}🔗 需要浏览器认证: https://clawhub.ai/cli/auth${NC}"
        fi
    else
        echo -e "${GREEN}✅ clawhub 已登录${NC}"
    fi
else
    echo -e "${RED}❌ clawhub 未安装${NC}"
fi
echo ""

# 总体进度
echo "📊 整体进度总结:"
echo "================"
tools_checked=0
tools_completed=0

tools=(
    "gh:GitHub CLI"
    "fzf:Fuzzy Finder"
    "ripgrep:ripgrep"
    "eza:eza"
    "bat:bat"
    "fd:fd"
    "dust:dust"
)

for tool_pair in "${tools[@]}"; do
    IFS=':' read -r tool_name tool_desc <<< "$tool_pair"
    ((tools_checked++))
    if command -v "$tool_name" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $tool_name: $tool_desc${NC}"
        ((tools_completed++))
    else
        echo -e "${YELLOW}❌ $tool_name: $tool_desc${NC}"
    fi
done

echo ""
echo "📈 CLI工具进度: $tools_completed/$tools_checked"

# 计算完成百分比
if [ $tools_checked -gt 0 ]; then
    completion_percentage=$(( tools_completed * 100 / tools_checked ))
    echo "完成率: $completion_percentage%"
    
    if [ $completion_percentage -eq 100 ]; then
        echo -e "${GREEN}🎉 所有CLI工具已安装完成！${NC}"
    elif [ $completion_percentage -ge 80 ]; then
        echo -e "${YELLOW}🚀 大部分工具已安装，接近完成！${NC}"
    else
        echo -e "${BLUE}🔧 继续安装剩余工具...${NC}"
    fi
fi

echo ""
echo "📋 建议下一步行动:"
if [ $completion_percentage -lt 100 ]; then
    echo "1. 等待当前安装进程完成"
    echo "2. 解决Homebrew锁定问题"
    echo "3. 完成Rust环境配置"
    echo "4. 安装Docker Desktop"
    echo "5. 完成clawhub认证"
fi

echo ""
echo "🔄 监控完成 - 下次检查建议: 5分钟后"