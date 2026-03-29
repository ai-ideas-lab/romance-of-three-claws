#!/bin/bash
# cli_tools_installer.sh - 现代CLI工具安装脚本
# 自动检测和安装常用的现代CLI工具

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
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
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# 工具定义
declare -A TOOLS=(
    ["gh"]="GitHub CLI"
    ["fzf"]="Fuzzy Finder"
    ["ripgrep"]="ripgrep - faster grep"
    ["eza"]="eza - a better ls"
    ["bat"]="bat - a cat with wings"
    ["fd"]="fd - find alternative"
    ["dust"]="dust - du alternative"
    ["rustc"]="Rust Compiler"
)

# 检查工具是否已安装
check_tool() {
    local tool_name="$1"
    if command -v "$tool_name" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# 检查Homebrew是否安装
check_homebrew() {
    if command -v brew &> /dev/null; then
        log_success "Homebrew已安装"
        return 0
    else
        log_error "Homebrew未安装，请先安装Homebrew"
        return 1
    fi
}

# 安装单个工具
install_tool() {
    local tool_name="$1"
    local tool_desc="${TOOLS[$tool_name]}"
    
    log_step "正在安装 $tool_name ($tool_desc)..."
    
    if check_tool "$tool_name"; then
        log_success "$tool_name 已经安装"
        return 0
    fi
    
    log_info "通过Homebrew安装 $tool_name..."
    if brew install "$tool_name"; then
        log_success "$tool_name 安装成功"
        return 0
    else
        log_error "$tool_name 安装失败"
        return 1
    fi
}

# 批量安装工具
batch_install_tools() {
    log_step "开始批量安装现代CLI工具..."
    
    local failed_tools=()
    local success_count=0
    
    for tool_name in "${!TOOLS[@]}"; do
        if check_tool "$tool_name"; then
            log_info "$tool_name 已安装，跳过"
            success_count=$((success_count + 1))
        else
            log_info "安装 $tool_name..."
            if install_tool "$tool_name"; then
                success_count=$((success_count + 1))
            else
                failed_tools+=("$tool_name")
            fi
        fi
    done
    
    # 显示结果
    echo ""
    log_step "批量安装完成"
    log_success "成功安装 $success_count 个工具"
    
    if [ ${#failed_tools[@]} -gt 0 ]; then
        log_error "以下工具安装失败:"
        for tool in "${failed_tools[@]}"; do
            log_error "  - $tool"
        done
    fi
}

# 检查工具版本
check_tool_versions() {
    log_step "检查已安装工具版本..."
    
    for tool_name in "${!TOOLS[@]}"; do
        if check_tool "$tool_name"; then
            local version=$("$tool_name" --version 2>/dev/null || "$tool_name" -v 2>/dev/null || echo "未知")
            log_success "$tool_name: $version"
        else
            log_warning "$tool_name: 未安装"
        fi
    done
}

# 生成工具别名配置
generate_aliases() {
    local alias_file="cli_tool_aliases.sh"
    log_step "生成工具别名配置: $alias_file"
    
    cat > "$alias_file" << 'EOF'
#!/bin/bash
# 现代CLI工具别名配置

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 智能别名函数
smart_alias() {
    local original="$1"
    local modern="$2"
    local description="$3"
    
    if command -v "$modern" &> /dev/null; then
        alias "$original"="$modern"
        echo -e "${GREEN}✓${NC} $original -> $modern ($description)"
    else
        echo -e "${YELLOW}✗${NC} $original -> $modern (未安装)"
    fi
}

# 文件操作别名
smart_alias ls eza "现代文件列表"
smart_alias cat bat "现代文件查看"
smart_alias find fd "现代文件搜索"
smart_alias grep rg "现代文本搜索"

# 系统工具别名
smart_alias du dust "磁盘使用分析"
smart_alias ps procs "现代进程查看"

# 其他实用别名
smart_alias git hub "Git Hub CLI"  # 如果安装了gh alias
smart_alias zz fzf "模糊查找"

# 显示可用工具
echo "可用现代CLI工具:"
echo "-----------------"

if command -v eza &> /dev/null; then echo "✓ eza (现代ls)"; fi
if command -v bat &> /dev/null; then echo "✓ bat (现代cat)"; fi
if command -v fd &> /dev/null; then echo "✓ fd (现代find)"; fi
if command -v rg &> /dev/null; then echo "✓ rg (现代grep)"; fi
if command -v dust &> /dev/null; then echo "✓ dust (现代du)"; fi
if command -v fzf &> /dev/null; then echo "✓ fzf (模糊查找)"; fi
if command -v gh &> /dev/null; then echo "✓ gh (GitHub CLI)"; fi
if command -v rustc &> /dev/null; then echo "✓ rustc (Rust编译器)"; fi

echo ""
echo "提示: 重新运行 'source cli_tool_aliases.sh' 来重新加载别名"
EOF
    
    chmod +x "$alias_file"
    log_success "工具别名配置已生成: $alias_file"
}

# 测试工具功能
test_tools() {
    log_step "测试已安装工具功能..."
    
    # 创建测试文件
    echo "测试内容" > test_file.txt
    
    local test_results=()
    
    # 测试文件列表
    if command -v eza &> /dev/null; then
        log_info "测试eza..."
        ela --version &> /dev/null && test_results+=("eza: 正常") || test_results+=("eza: 异常")
    fi
    
    # 测试文件查看
    if command -v bat &> /dev/null; then
        log_info "测试bat..."
        bat test_file.txt --color=always --style=plain &> /dev/null && test_results+=("bat: 正常") || test_results+=("bat: 异常")
    fi
    
    # 测试文本搜索
    if command -v rg &> /dev/null; then
        log_info "测试ripgrep..."
        rg "测试" test_file.txt &> /dev/null && test_results+=("rg: 正常") || test_results+=("rg: 异常")
    fi
    
    # 测试文件搜索
    if command -v fd &> /dev/null; then
        log_info "测试fd..."
        fd "test" . &> /dev/null && test_results+=("fd: 正常") || test_results+=("fd: 异常")
    fi
    
    # 清理测试文件
    rm -f test_file.txt
    
    # 显示测试结果
    echo ""
    log_step "工具功能测试结果:"
    for result in "${test_results[@]}"; do
        if [[ "$result" == *": 正常"* ]]; then
            log_success "$result"
        else
            log_error "$result"
        fi
    done
}

# 生成安装报告
generate_report() {
    local report_file="cli_tools_report_$(date +%Y%m%d_%H%M%S).txt"
    log_step "生成工具安装报告: $report_file"
    
    {
        echo "现代CLI工具安装报告"
        echo "生成时间: $(date)"
        echo "================================"
        echo ""
        echo "1. 工具安装状态:"
        echo ""
        
        local installed_count=0
        for tool_name in "${!TOOLS[@]}"; do
            if check_tool "$tool_name"; then
                echo "✓ $tool_name (${TOOLS[$tool_name]}) - 已安装"
                installed_count=$((installed_count + 1))
            else
                echo "✗ $tool_name (${TOOLS[$tool_name]}) - 未安装"
            fi
        done
        
        echo ""
        echo "2. 统计信息:"
        echo "   已安装工具: $installed_count/${#TOOLS[@]}"
        echo "   安装成功率: $((installed_count * 100 / ${#TOOLS[@]}))%"
        echo ""
        echo "3. 工具版本信息:"
        check_tool_versions
        echo ""
        echo "4. 建议操作:"
        if [ "$installed_count" -lt "${#TOOLS[@]}" ]; then
            echo "   - 运行 'bash cli_tools_installer.sh' 继续安装"
        fi
        if [ "$installed_count" -gt 0 ]; then
            echo "   - 运行 'source cli_tool_aliases.sh' 加载别名"
        fi
        echo "   - 运行 'bash cli_tools_installer.sh test' 测试工具功能"
    } > "$report_file"
    
    log_success "安装报告已生成: $report_file"
}

# 主菜单
main_menu() {
    while true; do
        echo ""
        echo "现代CLI工具安装管理"
        echo "===================="
        echo "1. 检查工具状态"
        echo "2. 批量安装工具"
        echo "3. 检查工具版本"
        echo "4. 生成别名配置"
        echo "5. 测试工具功能"
        echo "6. 生成安装报告"
        echo "7. 退出"
        echo ""
        
        read -p "请选择操作 (1-7): " choice
        
        case $choice in
            1)
                log_step "检查工具状态..."
                for tool_name in "${!TOOLS[@]}"; do
                    if check_tool "$tool_name"; then
                        log_success "$tool_name ✓"
                    else
                        log_warning "$tool_name ✗"
                    fi
                done
                ;;
            2)
                check_homebrew
                batch_install_tools
                ;;
            3)
                check_tool_versions
                ;;
            4)
                generate_aliases
                ;;
            5)
                test_tools
                ;;
            6)
                generate_report
                ;;
            7)
                log_info "退出工具安装管理"
                exit 0
                ;;
            *)
                log_error "无效选择，请重新输入"
                ;;
        esac
    done
}

# 脚本入口
main() {
    log_info "现代CLI工具安装脚本启动"
    
    # 检查参数
    case "${1:-menu}" in
        "install")
            check_homebrew
            batch_install_tools
            ;;
        "test")
            test_tools
            ;;
        "aliases")
            generate_aliases
            ;;
        "report")
            generate_report
            ;;
        *)
            check_homebrew
            main_menu
            ;;
    esac
}

# 如果直接运行脚本
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi