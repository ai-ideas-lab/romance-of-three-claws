#!/bin/bash

# 环境验证和工具集成脚本
# Environment Verification and Tool Integration Script
# 作者: 孔明 - 2026-03-28

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
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

# 显示标题
show_title() {
    echo "=================================================="
    echo "  环境验证和工具集成系统"
    echo "  Environment Verification & Tool Integration"
    echo "=================================================="
    echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "执行者: 孔明"
    echo "=================================================="
    echo
}

# 系统信息检查
check_system_info() {
    log_info "检查系统信息..."
    
    echo "操作系统: $(uname -s)"
    echo "系统版本: $(uname -r)"
    echo "架构: $(uname -m)"
    echo "主机名: $(hostname)"
    echo "用户: $(whoami)"
    echo "工作目录: $(pwd)"
    echo
    
    # 内存使用情况
    if command -v free >/dev/null 2>&1; then
        echo "内存使用:"
        free -h | head -2
        echo
    fi
    
    # 磁盘使用情况
    if command -v df >/dev/null 2>&1; then
        echo "磁盘使用 (根目录):"
        df -h / | tail -1
        echo
    fi
}

# 开发环境检查
check_development_env() {
    log_info "检查开发环境..."
    
    # Node.js
    if command -v node >/dev/null 2>&1; then
        NODE_VERSION=$(node --version)
        log_success "Node.js: $NODE_VERSION"
    else
        log_error "Node.js 未安装"
    fi
    
    # npm
    if command -v npm >/dev/null 2>&1; then
        NPM_VERSION=$(npm --version)
        log_success "npm: $NPM_VERSION"
    else
        log_error "npm 未安装"
    fi
    
    # Python
    if command -v python3 >/dev/null 2>&1; then
        PYTHON_VERSION=$(python3 --version)
        log_success "Python: $PYTHON_VERSION"
    else
        log_error "Python3 未安装"
    fi
    
    # Git
    if command -v git >/dev/null 2>&1; then
        GIT_VERSION=$(git --version)
        log_success "Git: $GIT_VERSION"
        
        # Git 配置检查
        echo "Git 用户配置:"
        git config --global user.name 2>/dev/null || echo "  用户名: 未设置"
        git config --global user.email 2>/dev/null || echo "  邮箱: 未设置"
    else
        log_error "Git 未安装"
    fi
    echo
}

# 现代CLI工具检查
check_modern_cli_tools() {
    log_info "检查现代CLI工具..."
    
    tools=(
        "gh:GitHub CLI"
        "fzf:Fuzzy finder"
        "rg:ripgrep"
        "eza:Modern ls"
        "bat:Cat alternative"
        "fd:Find alternative"
        "dust:Disk usage"
        "rustc:Rust compiler"
        "docker:Docker"
        "kubectl:Kubernetes"
        "helm:Helm"
    )
    
    for tool in "${tools[@]}"; do
        tool_name=$(echo "$tool" | cut -d: -f1)
        tool_desc=$(echo "$tool" | cut -d: -f2)
        
        if command -v "$tool_name" >/dev/null 2>&1; then
            TOOL_VERSION=$("$tool_name" --version 2>/dev/null || echo "已安装")
            log_success "$tool_desc ($tool_name): $TOOL_VERSION"
        else
            log_warning "$tool_desc ($tool_name): 未安装"
        fi
    done
    echo
}

# 网络连接检查
check_network_connectivity() {
    log_info "检查网络连接..."
    
    # 检查关键域名
    domains=(
        "github.com"
        "npmjs.com"
        "pypi.org"
        "hub.docker.com"
        "clawhub.com"
    )
    
    for domain in "${domains[@]}"; do
        if ping -c 1 -W 3 "$domain" >/dev/null 2>&1; then
            log_success "✓ $domain: 连接正常"
        else
            log_warning "✗ $domain: 连接失败"
        fi
    done
    
    # 检查HTTP请求
    if command -v curl >/dev/null 2>&1; then
        log_info "检查HTTP请求..."
        if curl -s --head https://github.com >/dev/null; then
            log_success "GitHub HTTP: 正常"
        else
            log_warning "GitHub HTTP: 异常"
        fi
    fi
    echo
}

# 配置文件检查
check_config_files() {
    log_info "检查配置文件..."
    
    config_files=(
        "~/.shell_aliases"
        "~/.git_aliases" 
        "~/.vimrc"
        "~/.zshrc"
        "~/.bashrc"
    )
    
    for config in "${config_files[@]}"; 
    do
        expanded_config=$(eval echo "$config")
        if [[ -f "$expanded_config" ]]; then
            log_success "✓ $config: 已存在"
        else
            log_warning "✗ $config: 不存在"
        fi
    done
    echo
}

# 工具集成检查
check_tool_integration() {
    log_info "检查工具集成状态..."
    
    # 检查别名文件
    if [[ -f ~/.shell_aliases ]]; then
        log_info "Shell 别名状态:"
        alias_count=$(grep -c "^alias" ~/.shell_aliases 2>/dev/null || echo "0")
        log_success "  已定义别名数量: $alias_count"
        
        # 检查现代工具别名
        modern_aliases=("eza" "bat" "fd" "rg" "dust")
        for alias in "${modern_aliases[@]}"; do
            if grep -q "^alias.*$alias" ~/.shell_aliases 2>/dev/null; then
                log_success "  $alias 别名: 已配置"
            else
                log_warning "  $alias 别名: 未配置"
            fi
        done
    fi
    
    # 检查Git别名
    if [[ -f ~/.git_aliases ]] && command -v git >/dev/null 2>&1; then
        log_info "Git 别名状态:"
        git_alias_count=$(grep -c "^alias" ~/.git_aliases 2>/dev/null || echo "0")
        log_success "  已定义Git别名数量: $git_alias_count"
    fi
    echo
}

# 生成建议报告
generate_suggestions() {
    log_info "生成优化建议..."
    
    echo "=================================================="
    echo "               优化建议报告"
    echo "=================================================="
    
    suggestions=()
    
    # 检查缺失的工具
    if ! command -v gh >/dev/null 2>&1; then
        suggestions+=("安装GitHub CLI (gh): brew install gh")
    fi
    
    if ! command -v rg >/dev/null 2>&1; then
        suggestions+=("安装ripgrep: brew install ripgrep")
    fi
    
    if ! command -v eza >/dev/null 2>&1; then
        suggestions+=("安装eza: brew install eza")
    fi
    
    if ! command -v bat >/dev/null 2>&1; then
        suggestions+=("安装bat: brew install bat")
    fi
    
    if ! command -v fd >/dev/null 2>&1; then
        suggestions+=("安装fd: brew install fd")
    fi
    
    if ! command -v dust >/dev/null 2>&1; then
        suggestions+=("安装dust: brew install dust")
    fi
    
    if ! command -v docker >/dev/null 2>&1; then
        suggestions+=("安装Docker: brew install --cask docker")
    fi
    
    if [[ ${#suggestions[@]} -gt 0 ]]; then
        echo "建议安装的工具:"
        for suggestion in "${suggestions[@]}"; do
            echo "  • $suggestion"
        done
    else
        log_success "所有推荐工具都已安装!"
    fi
    
    echo
    echo "下一步行动建议:"
    echo "  1. 完成当前正在进行的安装任务"
    echo "  2. 安装缺失的工具"
    echo "  3. 重新加载配置文件: source ~/.zshrc"
    echo "  4. 测试新安装的工具功能"
    echo
}

# 主函数
main() {
    show_title
    
    check_system_info
    check_development_env
    check_modern_cli_tools
    check_network_connectivity
    check_config_files
    check_tool_integration
    generate_suggestions
    
    log_success "环境验证完成!"
    echo "报告生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
}

# 如果脚本被直接执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi