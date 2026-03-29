#!/bin/bash

# 工具集成脚本 - 自动检测并集成现代化CLI工具
# 作者: 孔明
# 日期: 2026-03-28

echo "🔧 工具集成脚本启动..."
echo "⏰ 当前时间: $(date)"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 打印带颜色的文本
print_status() {
    local status=$1
    local message=$2
    case $status in
        "✅") echo -e "${GREEN}${status} ${message}${NC}" ;;
        "❌") echo -e "${RED}${status} ${message}${NC}" ;;
        "⏳") echo -e "${YELLOW}${status} ${message}${NC}" ;;
        "🔧") echo -e "${BLUE}${status} ${message}${NC}" ;;
        "🚀") echo -e "${PURPLE}${status} ${message}${NC}" ;;
    esac
}

print_section() {
    echo ""
    echo "============================================"
    echo "$1"
    echo "============================================"
    echo ""
}

print_section "🔍 检测可用工具"

# 工具检测和配置映射
tool_configs=(
    "eza:alias ls='eza --color=auto --group-directories-first'"
    "eza-l:alias ll='eza --color=auto --group-directories-first -l'"
    "eza-la:alias la='eza --color=auto --group-directories-first -la'"
    "bat:alias cat='bat --style=plain'"
    "bat-p:alias preview='bat --style=grid --paging=always'"
    "fd:alias find='fd'"
    "fd-i:alias fdi='fd --ignore-case'"
    "dust:alias du='dust'"
    "dust-h:alias duh='dust -H'"
    "ripgrep:alias grep='rg'"
    "rg-i:alias rgi='rg -i'"
    "gh:alias gh='gh --help'"
    "cargo:alias cargo='cargo --help'"
)

# 检测每个工具并显示状态
for config_pair in "${tool_configs[@]}"; do
    tool="${config_pair%%:*}"
    if command -v "$tool" >/dev/null 2>&1; then
        print_status "✅" "$tool: 已安装"
    else
        print_status "❌" "$tool: 未安装"
    fi
done
echo ""

print_section "🔧 智能工具检测"

# 实际工具检测
available_tools=()
unavailable_tools=()

for config_pair in "${tool_configs[@]}"; do
    tool="${config_pair%%:*}"
    if command -v "$tool" >/dev/null 2>&1; then
        available_tools+=("$tool")
        print_status "✅" "$tool: 可用"
    else
        unavailable_tools+=("$tool")
        print_status "❌" "$tool: 不可用"
    fi
done

echo ""
echo "📊 统计信息:"
echo "✅ 可用工具: ${#available_tools[@]} 个"
echo "❌ 不可用工具: ${#unavailable_tools[@]} 个"
echo ""

if [ ${#available_tools[@]} -gt 0 ]; then
    print_section "🚀 可用工具配置"
    for tool in "${available_tools[@]}"; do
        config="${tool_configs[$tool]}"
        print_status "🔧" "$tool: $config"
        
        # 询问是否要添加到配置文件
        if [ -n "$config" ]; then
            echo -e "${BLUE}  建议: 将配置添加到 ~/.shell_aliases${NC}"
        fi
    done
fi

echo ""
if [ ${#unavailable_tools[@]} -gt 0 ]; then
    print_section "❌ 缺失工具建议"
    for tool in "${unavailable_tools[@]}"; do
        case $tool in
            "eza") echo "📦 安装: brew install eza" ;;
            "bat") echo "📦 安装: brew install bat" ;;
            "fd") echo "📦 安装: brew install fd" ;;
            "dust") echo "📦 安装: brew install dust" ;;
            "ripgrep") echo "📦 安装: brew install ripgrep" ;;
            "gh") echo "📦 安装: brew install gh" ;;
            "cargo") echo "📦 安装: brew install rust" ;;
            *) echo "📦 安装: brew install $tool" ;;
        esac
    done
fi

print_section "⚙️ 智能配置生成"

# 生成智能配置文件
config_file="/Users/wangshihao/.openclaw/workspace/.tool_aliases"
echo "# 工具智能配置 - 自动生成于 $(date)" > "$config_file"
echo "" >> "$config_file"

# 生成工具别名
for tool in "${available_tools[@]}"; do
    for config_pair in "${tool_configs[@]}"; do
        if [[ "$config_pair" == "$tool:"* ]]; then
            config="${config_pair#*:}"
            if [ -n "$config" ]; then
                echo "$config" >> "$config_file"
            fi
            break
        fi
    done
done

echo "" >> "$config_file"
echo "# 工具检测函数" >> "$config_file"
echo "check_tool() {" >> "$config_file"
echo "    local tool=\$1" >> "$config_file"
echo "    if command -v \"\$tool\" >/dev/null 2>&1; then" >> "$config_file"
echo "        echo \"✅ \$tool: 可用\"" >> "$config_file"
echo "        return 0" >> "$config_file"
echo "    else" >> "$config_file"
echo "        echo \"❌ \$tool: 不可用\"" >> "$config_file"
echo "        return 1" >> "$config_file"
echo "    fi" >> "$config_file"
echo "}" >> "$config_file"

echo "" >> "$config_file"
echo "# 快速工具检查" >> "$config_file"
echo "check_all_tools() {" >> "$config_file"
echo "    echo \"🔍 检查所有可用工具:\"" >> "$config_file"
echo "    for tool in eza bat fd dust ripgrep gh cargo; do" >> "$config_file"
echo "        check_tool \"\$tool\"" >> "$config_file"
echo "    done" >> "$config_file"
echo "}" >> "$config_file"

echo ""
print_status "✅" "智能配置文件已生成: $config_file"

print_section "🎯 集成建议"

# 检查是否需要更新shell配置
shell_config=""
if [ -f "$HOME/.zshrc" ]; then
    shell_config="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    shell_config="$HOME/.bashrc"
fi

if [ -n "$shell_config" ]; then
    print_status "✅" "Shell配置文件: $shell_config"
    
    # 检查是否已经包含工具配置
    if grep -q "tool_aliases" "$shell_config"; then
        print_status "⚠️" "工具配置已包含在shell配置中"
    else
        print_status "🔧" "建议在shell配置中添加工具集成"
        echo ""
        echo "添加以下行到 $shell_config:"
        echo "source \"$config_file\""
        echo ""
        echo "或者运行:"
        echo "echo \"source \\\"$config_file\\\"\" >> \"$shell_config\""
    fi
else
    print_status "❌" "未找到shell配置文件"
fi

print_section "🚀 快速启动脚本"

# 生成快速启动脚本
quick_script="/Users/wangshihao/.openclaw/workspace/tool_quick_start.sh"
echo "# 工具快速启动脚本 - 自动生成于 $(date)" > "$quick_script"
echo "#!/bin/bash" >> "$quick_script"
echo "" >> "$quick_script"
echo "# 检查并集成工具" >> "$quick_script"
echo "source \"$config_file\"" >> "$quick_script"
echo "" >> "$quick_script"
echo "# 显示工具状态" >> "$quick_script"
echo "echo \"🔍 工具状态:\""
echo "check_all_tools" >> "$quick_script"
echo "" >> "$quick_script"
echo "# 使用说明" >> "$quick_script"
echo "echo \"\"" >> "$quick_script"
echo "echo \"📖 使用说明:\"" >> "$quick_script"
echo "echo \"  source $config_file  - 加载工具配置\"" >> "$quick_script"
echo "echo \"  check_all_tools      - 检查所有工具状态\"" >> "$quick_script"
echo "echo " >> "$quick_script"
echo "echo \"🔧 可用工具命令:\"" >> "$quick_script"

# 添加可用工具命令说明
for tool in "${available_tools[@]}"; do
    case $tool in
        "eza") echo "echo \"  eza          - 现代化ls替代品\"" >> "$quick_script" ;;
        "bat") echo "echo \"  bat          - 语法高亮的cat替代品\"" >> "$quick_script" ;;
        "fd") echo "echo \"  fd           - 更快的find替代品\"" >> "$quick_script" ;;
        "dust") echo "echo \"  dust         - 更好的du替代品\"" >> "$quick_script" ;;
        "ripgrep") echo "echo \"  rg           - 更快的grep替代品\"" >> "$quick_script" ;;
        "gh") echo "echo \"  gh           - GitHub CLI\"" >> "$quick_script" ;;
        "cargo") echo "echo \"  cargo         - Rust包管理器\"" >> "$quick_script" ;;
    esac
done

echo "" >> "$quick_script"
echo "# 设置执行权限" >> "$quick_script"
echo "chmod +x \"$config_file\"" >> "$quick_script"

# 设置执行权限
chmod +x "$quick_script"

print_status "✅" "快速启动脚本已生成: $quick_script"

print_section "🎉 集成完成"

echo ""
echo "📋 完成项目:"
echo "✅ 检测了 ${#available_tools[@]} 个可用工具"
echo "✅ 生成了智能配置文件: $config_file"
echo "✅ 创建了快速启动脚本: $quick_script"
echo ""

if [ ${#available_tools[@]} -gt 0 ]; then
    echo "🚀 可用工具已准备就绪:"
    for tool in "${available_tools[@]}"; do
        case $tool in
            "eza") echo "  • eza - 现代化文件列表工具" ;;
            "bat") echo "  • bat - 语法高亮文件查看器" ;;
            "fd") echo "  • fd - 更快的文件查找工具" ;;
            "dust") echo "  • dust - 直观的磁盘使用分析" ;;
            "ripgrep") echo "  • ripgrep - 快速文本搜索工具" ;;
            "gh") echo "  • gh - GitHub命令行工具" ;;
            "cargo") echo "  • cargo - Rust包管理器" ;;
        esac
    done
    echo ""
    echo "💡 使用方法:"
    echo "  source $quick_script  # 加载所有工具配置"
    echo "  check_all_tools       # 检查工具状态"
    echo ""
fi

if [ ${#unavailable_tools[@]} -gt 0 ]; then
    echo "📦 待安装工具:"
    for tool in "${unavailable_tools[@]}"; do
        case $tool in
            "eza") echo "  • eza - brew install eza" ;;
            "bat") echo "  • bat - brew install bat" ;;
            "fd") echo "  • fd - brew install fd" ;;
            "dust") echo "  • dust - brew install dust" ;;
            "ripgrep") echo "  • ripgrep - brew install ripgrep" ;;
            "gh") echo "  • gh - brew install gh" ;;
            "cargo") echo "  • cargo - brew install rust" ;;
        esac
    done
    echo ""
fi

echo "🎯 下一步建议:"
echo "1. 运行 $quick_script 加载工具配置"
echo "2. 安装缺失的工具 (使用brew install)"
echo "3. 将配置集成到shell配置文件"
echo "4. 测试新工具的可用性和功能"