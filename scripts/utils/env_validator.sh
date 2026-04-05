#!/bin/bash
# 环境验证与诊断脚本
# 作者: 孔明
# 功能: 全面检查开发环境状态，提供详细的诊断报告和建议

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

log_section() {
    echo -e "\n${PURPLE}=== $1 ===${NC}"
}

# 检查命令是否存在
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# 获取命令版本
get_version() {
    if check_command "$1"; then
        $1 --version 2>/dev/null | head -n1 || echo "Available"
    else
        echo "Not installed"
    fi
}

# 检查端口是否被占用
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 检查网络连接
check_network() {
    local url="$1"
    local timeout="${2:-5}"
    
    if curl -s --connect-timeout "$timeout" --head "$url" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# 生成环境报告
generate_report() {
    local report_file="environment_report_$(date +%Y%m%d_%H%M%S).txt"
    
    log_section "生成环境报告"
    
    {
        echo "=== 环境验证报告 ==="
        echo "生成时间: $(date)"
        echo "生成者: 孔明智能助手"
        echo ""
        
        # 系统信息
        echo "=== 系统信息 ==="
        echo "操作系统: $(uname -s) $(uname -r)"
        echo "架构: $(uname -m)"
        echo "主机名: $(hostname)"
        echo "当前用户: $(whoami)"
        echo "Shell: $SHELL"
        echo "工作目录: $(pwd)"
        echo ""
        
        # 硬件信息
        echo "=== 硬件信息 ==="
        echo "CPU信息: $(sysctl -n hw.ncpu) 核心"
        echo "内存信息: $(sysctl -n hw.memsize | numfmt --to=iec) 总内存"
        echo "可用内存: $(vm_stat | grep "free" | awk '{print $3 * 4096}')"
        echo "磁盘使用:"
        df -h | grep -E "Filesystem|/$"
        echo ""
        
        # 开发环境
        echo "=== 开发环境 ==="
        
        # Node.js环境
        echo "Node.js环境:"
        echo "  版本: $(node --version 2>/dev/null || echo 'Not installed')"
        echo "  npm版本: $(npm --version 2>/dev/null || echo 'Not installed')"
        echo "  全局包数量: $(npm list -g --depth=0 2>/dev/null | grep -v '└──' | wc -l || echo 'Unknown')"
        echo ""
        
        # Python环境
        echo "Python环境:"
        echo "  Python版本: $(python3 --version 2>/dev/null || python --version 2>/dev/null || echo 'Not installed')"
        echo "  pip版本: $(pip3 --version 2>/dev/null || pip --version 2>/dev/null || echo 'Not installed')"
        echo "  虚拟环境: $(which virtualenv 2>/dev/null || echo 'Not installed')"
        echo ""
        
        # Git环境
        echo "Git环境:"
        echo "  Git版本: $(git --version 2>/dev/null || echo 'Not installed')"
        echo "  用户名: $(git config user.name 2>/dev/null || echo 'Not configured')"
        echo "  邮箱: $(git config user.email 2>/dev/null || echo 'Not configured')"
        echo "  配置文件位置: $(git config --list 2>/dev/null | grep -E '^core\.editor|^user\.' | head -5)"
        echo ""
        
        # 工具检查
        echo "=== 工具检查 ==="
        
        # 现代CLI工具
        local modern_tools=("gh" "fzf" "rg" "eza" "bat" "fd" "dust" "cargo")
        echo "现代CLI工具:"
        for tool in "${modern_tools[@]}"; do
            if check_command "$tool"; then
                echo "  ✅ $tool: $(get_version $tool)"
            else
                echo "  ❌ $tool: Not installed"
            fi
        done
        echo ""
        
        # 容器和编排工具
        local container_tools=("docker" "kubectl" "helm" "minikube" "kind")
        echo "容器和编排工具:"
        for tool in "${container_tools[@]}"; do
            if check_command "$tool"; then
                echo "  ✅ $tool: $(get_version $tool)"
            else
                echo "  ❌ $tool: Not installed"
            fi
        done
        echo ""
        
        # 开发工具
        local dev_tools=("vim" "neovim" "yarn" "pnpm" "tsc" "eslint" "prettier")
        echo "开发工具:"
        for tool in "${dev_tools[@]}"; do
            if check_command "$tool"; then
                echo "  ✅ $tool: $(get_version $tool)"
            else
                echo "  ❌ $tool: Not installed"
            fi
        done
        echo ""
        
        # 网络连接检查
        echo "=== 网络连接检查 ==="
        local test_urls=("https://github.com" "https://registry.npmjs.org" "https://pypi.org")
        for url in "${test_urls[@]}"; do
            if check_network "$url"; then
                echo "  ✅ $url: Connected"
            else
                echo "  ❌ $url: Connection failed"
            fi
        done
        echo ""
        
        # 端口检查
        echo "=== 端口检查 ==="
        local ports=("80" "443" "3000" "8000" "8080" "5432" "3306")
        for port in "${ports[@]}"; do
            if check_port "$port"; then
                echo "  🔌 端口 $port: 已占用"
            else
                echo "  🔌 端口 $port: 空闲"
            fi
        done
        echo ""
        
        # 配置文件检查
        echo "=== 配置文件检查 ==="
        local config_files=("$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.gitconfig" "$HOME/.vimrc" "$HOME/.shell_aliases")
        for config in "${config_files[@]}"; do
            if [[ -f "$config" ]]; then
                echo "  📄 $config: 存在 ($(wc -l < "$config") 行)"
            else
                echo "  📄 $config: 不存在"
            fi
        done
        echo ""
        
        # 环境变量检查
        echo "=== 环境变量检查 ==="
        echo "重要环境变量:"
        env | grep -E "PATH|HOME|USER|SHELL|NODE_|PYTHON_|JAVA_|GOPATH|RBENV|RUBY|GOROOT" | sort
        echo ""
        
        # 项目检查
        echo "=== 项目检查 ==="
        local current_dir=$(pwd)
        echo "当前目录: $current_dir"
        echo "子目录数量: $(find "$current_dir" -maxdepth 1 -type d | grep -v "^.$" | wc -l)"
        echo "文件数量: $(find "$current_dir" -maxdepth 1 -type f | wc -l)"
        
        # 检查是否为git仓库
        if git rev-parse --git-dir >/dev/null 2>&1; then
            echo "Git仓库: 是"
            echo "当前分支: $(git branch --show-current)"
            echo "未提交的更改: $(git status --porcelain | wc -l)"
        else
            echo "Git仓库: 否"
        fi
        
    } > "$report_file"
    
    log_success "环境报告已生成: $report_file"
    echo "报告内容:"
    cat "$report_file"
}

# 修复建议
provide_fixes() {
    log_section "修复建议"
    
    echo "=== 环境修复建议 ==="
    
    # 检查并提供建议
    if ! check_command "node"; then
        echo "❌ Node.js未安装"
        echo "  建议: brew install node"
    fi
    
    if ! check_command "npm"; then
        echo "❌ npm未安装"
        echo "  建议: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
    fi
    
    if ! check_command "git"; then
        echo "❌ Git未安装"
        echo "  建议: brew install git"
    fi
    
    if ! check_command "python"; then
        echo "❌ Python未安装"
        echo "  建议: brew install python3"
    fi
    
    # 现代CLI工具建议
    local modern_tools=("gh" "fzf" "rg" "eza" "bat" "fd" "dust")
    echo ""
    echo "=== 现代CLI工具建议 ==="
    for tool in "${modern_tools[@]}"; do
        if ! check_command "$tool"; then
            echo "📦 $tool: brew install $tool"
        else
            echo "✅ $tool: 已安装"
        fi
    done
    
    echo ""
    echo "=== 配置建议 ==="
    if [[ ! -f "$HOME/.shell_aliases" ]]; then
        echo "📜 建议配置智能别名: source $HOME/.shell_aliases"
    fi
    
    if [[ ! -f "$HOME/.git_aliases" ]]; then
        echo "📜 建议配置Git别名: source $HOME/.git_aliases"
    fi
    
    if [[ ! -f "$HOME/.vimrc" ]]; then
        echo "📜 建议配置编辑器: cp $HOME/.vimrc ~/.config/nvim/init.vim"
    fi
}

# 性能分析
analyze_performance() {
    log_section "性能分析"
    
    echo "=== 系统性能分析 ==="
    
    # CPU使用率
    echo "CPU使用率:"
    top -l 1 | grep "CPU usage"
    
    # 内存使用
    echo ""
    echo "内存使用:"
    vm_stat | grep -E "free|active|inactive|wired"
    
    # 磁盘使用
    echo ""
    echo "磁盘使用:"
    df -h | grep -E "Filesystem|/$"
    
    # 网络连接
    echo ""
    echo "网络连接:"
    netstat -an | grep ESTABLISHED | wc -l
    netstat -an | grep LISTEN | wc -l
}

# 生成健康检查脚本
generate_health_script() {
    log_section "生成健康检查脚本"
    
    cat > health_check.sh << 'EOF'
#!/bin/bash
# 开发环境健康检查脚本
# 作者: 孔明

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# 检查必要工具
check_tools() {
    echo "=== 检查开发工具 ==="
    
    tools=("node" "npm" "git")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            log_success "$tool: $($tool --version | head -n1)"
        else
            log_error "$tool: 未安装"
        fi
    done
}

# 检查网络连接
check_network() {
    echo -e "\n=== 检查网络连接 ==="
    
    if curl -s --connect-timeout 5 https://github.com >/dev/null; then
        log_success "GitHub连接正常"
    else
        log_error "GitHub连接失败"
    fi
    
    if curl -s --connect-timeout 5 https://registry.npmjs.org >/dev/null; then
        log_success "npm registry连接正常"
    else
        log_error "npm registry连接失败"
    fi
}

# 检查系统资源
check_resources() {
    echo -e "\n=== 检查系统资源 ==="
    
    # 内存
    local memory_pressure=$(vm_stat | grep "page free" | awk '{print $3}')
    if [[ $memory_pressure -gt 1000 ]]; then
        log_success "内存充足"
    else
        log_warning "内存不足"
    fi
    
    # 磁盘
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | cut -d'%' -f1)
    if [[ $disk_usage -lt 80 ]]; then
        log_success "磁盘空间充足 ($disk_usage%)"
    else
        log_error "磁盘空间不足 ($disk_usage%)"
    fi
}

# 主检查函数
main() {
    echo "开发环境健康检查"
    echo "开始时间: $(date)"
    
    check_tools
    check_network
    check_resources
    
    echo -e "\n健康检查完成: $(date)"
}

main "$@"
EOF

    chmod +x health_check.sh
    log_success "健康检查脚本已生成: health_check.sh"
}

# 主函数
main() {
    log_section "环境验证与诊断开始"
    log_info "开始时间: $(date)"
    
    # 执行各种检查
    generate_report
    provide_fixes
    analyze_performance
    generate_health_script
    
    # 检查shell配置
    if [[ -f "$HOME/.zshrc" ]]; then
        log_info "Shell配置文件存在"
        if grep -q "source.*shell_aliases" "$HOME/.zshrc"; then
            log_success "别名配置已集成"
        else
            log_warning "别名配置未集成"
        fi
    fi
    
    log_section "环境验证完成"
    log_success "所有检查已完成"
    log_info "完整报告已生成"
    log_info "运行 ./health_check.sh 执行快速健康检查"
}

# 执行主函数
main "$@"