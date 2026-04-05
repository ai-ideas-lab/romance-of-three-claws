#!/bin/bash

# 孔明智能助手 - 简化CLI工具安装器
# 解决兼容性问题，支持多种shell环境

echo "🏯 孔明CLI工具安装器启动"
echo "⏰ 时间: $(date)"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 工具列表
tools=(
    "gh:GitHub CLI"
    "fzf:Fuzzy Finder" 
    "ripgrep:ripgrep - faster grep"
    "eza:eza - a better ls"
    "bat:bat - a cat with wings"
    "fd:fd - find alternative"
    "dust:dust - du alternative"
)

# 工具状态
declare -i total_tools=${#tools[@]}
declare -i installed_tools=0
declare -i failed_tools=0

# 检查工具函数
check_tool() {
    local tool_name=$1
    if command -v "$tool_name" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $tool_name: 已安装${NC}"
        return 0
    else
        echo -e "${YELLOW}❌ $tool_name: 未安装${NC}"
        return 1
    fi
}

# 安装工具函数
install_tool() {
    local tool_name=$1
    local tool_desc=$2
    
    echo -e "${BLUE}📦 安装 $tool_name ($tool_desc)${NC}"
    
    case "$tool_name" in
        "gh")
            if command -v brew >/dev/null 2>&1; then
                brew install gh --quiet
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ $tool_name 安装成功${NC}"
                    return 0
                fi
            fi
            ;;
        "fzf")
            if command -v brew >/dev/null 2>&1; then
                brew install fzf --quiet
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ $tool_name 安装成功${NC}"
                    return 0
                fi
            fi
            ;;
        "ripgrep")
            if command -v brew >/dev/null 2>&1; then
                brew install ripgrep --quiet
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ $tool_name 安装成功${NC}"
                    return 0
                fi
            fi
            ;;
        "eza")
            if command -v brew >/dev/null 2>&1; then
                brew install eza --quiet
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ $tool_name 安装成功${NC}"
                    return 0
                fi
            fi
            ;;
        "bat")
            if command -v brew >/dev/null 2>&1; then
                brew install bat --quiet
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ $tool_name 安装成功${NC}"
                    return 0
                fi
            fi
            ;;
        "fd")
            if command -v brew >/dev/null 2>&1; then
                brew install fd --quiet
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ $tool_name 安装成功${NC}"
                    return 0
                fi
            fi
            ;;
        "dust")
            if command -v brew >/dev/null 2>&1; then
                brew install dust --quiet
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ $tool_name 安装成功${NC}"
                    return 0
                fi
            fi
            ;;
        *)
            echo -e "${RED}❌ 不支持的工具: $tool_name${NC}"
            return 1
            ;;
    esac
    
    echo -e "${RED}❌ $tool_name 安装失败${NC}"
    return 1
}

# 主安装流程
echo "🔍 检查当前工具状态"
echo "=================="

# 检查所有工具
for tool_pair in "${tools[@]}"; do
    IFS=':' read -r tool_name tool_desc <<< "$tool_pair"
    if check_tool "$tool_name"; then
        ((installed_tools++))
    else
        ((failed_tools++))
    fi
    echo ""
done

echo "📊 工具统计:"
echo "- 总工具数: $total_tools"
echo "- 已安装: $installed_tools" 
echo "- 未安装: $failed_tools"
echo ""

# 安装缺失的工具
if [ $failed_tools -gt 0 ]; then
    echo "🚀 开始安装缺失的工具"
    echo "==================="
    
    for tool_pair in "${tools[@]}"; do
        IFS=':' read -r tool_name tool_desc <<< "$tool_pair"
        if ! check_tool "$tool_name" >/dev/null 2>&1; then
            install_tool "$tool_name" "$tool_desc"
            echo ""
            
            # 重新检查是否安装成功
            if check_tool "$tool_name" >/dev/null 2>&1; then
                ((installed_tools++))
            else
                ((failed_tools++))
            fi
        fi
    done
else
    echo "🎉 所有工具都已安装!"
fi

# 最终检查
echo ""
echo "🔍 最终检查"
echo "==========="

final_installed=0
final_failed=0

for tool_pair in "${tools[@]}"; do
    IFS=':' read -r tool_name tool_desc <<< "$tool_pair"
    if check_tool "$tool_name" >/dev/null 2>&1; then
        ((final_installed++))
    else
        ((final_failed++))
    fi
done

echo ""
echo "📋 安装完成统计:"
echo "- 总工具数: $total_tools"
echo "- 最终安装: $final_installed"
echo "- 最终失败: $final_failed"

if [ $final_failed -eq 0 ]; then
    echo -e "${GREEN}🎉 所有工具安装成功!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️ 部分工具安装失败${NC}"
    exit 1
fi