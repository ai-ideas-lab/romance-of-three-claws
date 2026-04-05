#!/bin/bash

# 孔明智能助手 - 最终环境验证脚本
# 用途：在所有工具安装完成后进行全面环境验证

echo "=== 孔明智能助手 - 最终环境验证 ==="
echo "检查时间: $(date)"
echo "检查用户: $(whoami)"
echo "当前路径: $(pwd)"
echo

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== 系统信息 ===${NC}"
echo "操作系统: $(uname -s)"
echo "系统版本: $(uname -r)"
echo "机器架构: $(uname -m)"
echo "主机名: $(hostname)"
echo

# 检查所有关键工具
echo -e "${BLUE}=== 开发环境检查 ===${NC}"
tools=("node" "npm" "python3" "git" "gh" "fzf" "rg" "eza" "bat" "fd" "dust" "rustc" "docker")
for tool in "${tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        path=$(command -v "$tool")
        echo -e "${GREEN}✅ $${NC} $path"
    else
        echo -e "${RED}❌ $${NC} 未安装"
    fi
done
echo

# 检查包管理器
echo -e "${BLUE}=== 包管理器检查 ===${NC}"
package_managers=("yarn" "pip" "pip3")
for pm in "${package_managers[@]}"; do
    if command -v "$pm" &> /dev/null; then
        path=$(command -v "$pm")
        echo -e "${GREEN}✅ $${NC} $path"
    else
        echo -e "${RED}❌ $${NC} 未安装"
    fi
done
echo

# 检查编辑器
echo -e "${BLUE}=== 编辑器检查 ===${NC}"
editors=("vim" "nvim")
for editor in "${editors[@]}"; do
    if command -v "$editor" &> /dev/null; then
        path=$(command -v "$editor")
        echo -e "${GREEN}✅ $${NC} $path"
    else
        echo -e "${RED}❌ $${NC} 未安装"
    fi
done
echo

# 检查OpenClaw相关
echo -e "${BLUE}=== OpenClaw相关检查 ===${NC}"
if command -v openclaw &> /dev/null; then
    path=$(command -v openclaw)
    echo -e "${GREEN}✅ openclaw${NC} $path"
    
    # 检查技能数量
    if command -v clawhub &> /dev/null; then
        skills=$(clawhub list 2>/dev/null | wc -l)
        echo -e "${GREEN}✅ clawhub技能${NC} 已安装 $skills 个技能"
    fi
else
    echo -e "${RED}❌ openclaw${NC} 未安装"
fi
echo

# 检查配置文件
echo -e "${BLUE}=== 配置文件检查 ===${NC}"
configs=(".shell_aliases" ".git_aliases" ".vimrc" ".tool_aliases")
for config in "${configs[@]}"; do
    if [[ -f "$HOME/$config" ]]; then
        echo -e "${GREEN}✅ $config${NC} 存在"
    else
        echo -e "${RED}❌ $config${NC} 不存在"
    fi
done
echo

# 检查工具集成状态
echo -e "${BLUE}=== 智能工具集成检查 ===${NC}"
echo -e "${YELLOW}工具别名集成:${NC}"
if [[ -f "$HOME/.shell_aliases" ]]; then
    echo "Shell别名配置已存在"
    echo -e "${YELLOW}可用工具检查:${NC}"
    
    # 检查各工具是否可用并显示别名
    tools_check=("eza|ls|现代文件列表" "bat|cat|现代文件查看" "fd|find|现代文件搜索" "rg|grep|现代文本搜索" "dust|du|磁盘使用分析")
    for tool_check in "${tools_check[@]}"; do
        tool_name=$(echo "$tool_check" | cut -d'|' -f1)
        alias_name=$(echo "$tool_check" | cut -d'|' -f2)
        desc=$(echo "$tool_check" | cut -d'|' -f3)
        
        if command -v "$tool_name" &> /dev/null; then
            echo -e "${GREEN}✅ $alias_name${NC} ($desc) - 可用"
        else
            echo -e "${YELLOW}⚠️ $alias_name${NC} ($desc) - 待安装"
        fi
    done
fi
echo

# 网络连接检查
echo -e "${BLUE}=== 网络连接检查 ===${NC}"
if ping -c 1 github.com &> /dev/null; then
    echo -e "${GREEN}✅ GitHub连接${NC} 正常"
else
    echo -e "${RED}❌ GitHub连接${NC} 失败"
fi

if ping -c 1 npmjs.com &> /dev/null; then
    echo -e "${GREEN}✅ NPM连接${NC} 正常"
else
    echo -e "${RED}❌ NPM连接${NC} 失败"
fi
echo

# 磁盘和内存使用
echo -e "${BLUE}=== 系统资源检查 ===${NC}"
disk_usage=$(df -h . | tail -1 | awk '{print $5}' | sed 's/%//')
memory_info=$(top -l 1 -n 0 | grep "PhysMem" | sed 's/.*PhysMem: *\([^,]*\).*/\1/')

echo -e "${YELLOW}磁盘使用: ${disk_usage}%${NC}"
echo -e "${YELLOW}内存信息: $memory_info${NC}"

# 磁盘空间警告
if [[ $disk_usage -gt 80 ]]; then
    echo -e "${RED}⚠️ 磁盘空间不足！${NC}"
fi
echo

# 环境总结
echo -e "${BLUE}=== 环境总结 ===${NC}"
missing_tools=()
for tool in "${tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        missing_tools+=("$tool")
    fi
done

if [[ ${#missing_tools[@]} -eq 0 ]]; then
    echo -e "${GREEN}🎉 所有开发工具已安装完成！${NC}"
    echo "环境已完全配置，可以开始开发工作。"
else
    echo -e "${YELLOW}⚠️ 仍需安装的工具:${NC}"
    for tool in "${missing_tools[@]}"; do
        echo -e "  - $tool"
    done
    echo
    echo -e "${YELLOW}建议使用以下命令安装缺失工具:${NC}"
    echo "  brew install ${missing_tools[*]}"
    echo "  或者运行: ./env_check.sh"
fi

# 配置加载提示
echo
echo -e "${YELLOW}配置加载建议:${NC}"
echo "- 运行 'source ~/.shell_aliases' 加载Shell别名"
echo "- 运行 'source ~/.git_aliases' 加载Git别名"
echo "- 使用 'nvim' 启动Neovim编辑器"
echo "- 运行 './tool_integration.sh' 自动检测和配置新工具"

echo
echo "=== 验证完成 ==="