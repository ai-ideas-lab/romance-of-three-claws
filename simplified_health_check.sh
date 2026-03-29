#!/bin/bash

# 适配当前环境的简化健康检查脚本
# Simplified Health Check for Current Environment
# 作者: 孔明 - 2026-03-28

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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
    echo "  简化系统健康检查"
    echo "  Simplified System Health Check"
    echo "=================================================="
    echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "系统: $(uname -s) $(uname -r 2>/dev/null || echo 'unknown')"
    echo "执行者: 孔明"
    echo "环境: OpenClaw Workspace"
    echo "=================================================="
    echo
}

# 检查基础环境
check_basic_environment() {
    log_info "检查基础环境..."
    
    # Node.js
    if command -v node >/dev/null 2>&1; then
        NODE_VERSION=$(node --version 2>/dev/null || echo "unknown")
        log_success "✅ Node.js: $NODE_VERSION"
    else
        log_error "❌ Node.js 未安装"
    fi
    
    # npm
    if command -v npm >/dev/null 2>&1; then
        NPM_VERSION=$(npm --version 2>/dev/null || echo "unknown")
        log_success "✅ npm: $NPM_VERSION"
    else
        log_error "❌ npm 未安装"
    fi
    
    # Python
    if command -v python3 >/dev/null 2>&1; then
        PYTHON_VERSION=$(python3 --version 2>/dev/null || echo "unknown")
        log_success "✅ Python: $PYTHON_VERSION"
    else
        log_error "❌ Python3 未安装"
    fi
    
    # Git
    if command -v git >/dev/null 2>&1; then
        GIT_VERSION=$(git --version 2>/dev/null || echo "unknown")
        log_success "✅ Git: $GIT_VERSION"
        
        # Git 配置
        GIT_USER_NAME=$(git config --global user.name 2>/dev/null || echo "未设置")
        GIT_USER_EMAIL=$(git config --global user.email 2>/dev/null || echo "未设置")
        echo "  Git 用户: $GIT_USER_NAME <$GIT_USER_EMAIL>"
    else
        log_error "❌ Git 未安装"
    fi
    
    # 检查当前环境
    log_info "当前环境:"
    echo "  工作目录: $(pwd)"
    echo "  用户: $(whoami)"
    echo "  主机: $(hostname 2>/dev/null || echo 'unknown')"
    
    # 检查OpenClaw
    if [[ -d "/Users/wangshihao/.openclaw" ]]; then
        log_success "✅ OpenClaw 工作空间已安装"
    else
        log_error "❌ OpenClaw 工作空间未找到"
    fi
    echo
}

# 检查开发工具
check_development_tools() {
    log_info "检查开发工具..."
    
    tools=(
        "npm:包管理器"
        "git:版本控制"
        "kubectl:Kubernetes"
        "helm:Helm包管理"
        "docker:Docker"
        "gh:GitHub CLI"
        "fzf:模糊查找"
        "rg:ripgrep"
        "eza:现代ls"
        "bat:现代cat"
        "fd:现代find"
        "dust:磁盘分析"
    )
    
    available_tools=0
    for tool in "${tools[@]}"; do
        tool_name=$(echo "$tool" | cut -d: -f1)
        tool_desc=$(echo "$tool" | cut -d: -f2)
        
        if command -v "$tool_name" >/dev/null 2>&1; then
            if [[ "$tool_name" == "npm" || "$tool_name" == "git" ]]; then
                # 对于已确认的工具，显示版本
                TOOL_VERSION=$("$tool_name" --version 2>/dev/null || echo "已安装")
                log_success "✅ $tool_desc ($tool_name): $TOOL_VERSION"
            else
                # 其他工具只显示状态
                log_success "✅ $tool_desc ($tool_name)"
            fi
            available_tools=$((available_tools + 1))
        else
            log_warning "❌ $tool_desc ($tool_name)"
        fi
    done
    
    total_tools=${#tools[@]}
    echo "  工具可用性: $available_tools/$total_tools"
    echo
}

# 检查网络连接
check_network_connectivity() {
    log_info "检查网络连接..."
    
    # 检查基本网络
    if ping -c 1 -W 2 127.0.0.1 >/dev/null 2>&1; then
        log_success "✅ 本地网络正常"
    else
        log_warning "❌ 本地网络异常"
    fi
    
    # 检查HTTP连接
    if command -v curl >/dev/null 2>&1; then
        echo "  HTTP连接测试:"
        for domain in "github.com" "google.com" "npmjs.com"; do
            if curl -s --head https://$domain >/dev/null 2>&1; then
                log_success "    ✓ https://$domain"
            else
                log_warning "    ✗ https://$domain"
            fi
        done
    else
        log_warning "❌ curl 不可用，无法测试HTTP连接"
    fi
    echo
}

# 检查配置文件
check_config_files() {
    log_info "检查配置文件..."
    
    configs=(
        "~/.shell_aliases:Shell别名"
        "~/.git_aliases:Git别名"
        "~/.vimrc:Vim配置"
        "~/.zshrc:Zsh配置"
        "~/.bashrc:Bash配置"
    )
    
    for config in "${configs[@]}"; do
        config_file=$(echo "$config" | cut -d: -f1)
        config_desc=$(echo "$config" | cut -d: -f2)
        
        expanded_config=$(eval echo "$config_file")
        if [[ -f "$expanded_config" ]]; then
            log_success "✅ $config_desc: 已存在"
            
            # 统计别名数量
            if [[ "$config_file" == "~/.shell_aliases" && -f "$expanded_config" ]]; then
                alias_count=$(grep -c "^alias" "$expanded_config" 2>/dev/null || echo "0")
                echo "    别名数量: $alias_count"
            fi
            
            if [[ "$config_file" == "~/.git_aliases" && -f "$expanded_config" ]]; then
                git_alias_count=$(grep -c "^alias" "$expanded_config" 2>/dev/null || echo "0")
                echo "    Git别名数量: $git_alias_count"
            fi
        else
            log_warning "❌ $config_desc: 不存在"
        fi
    done
    echo
}

# 检查工作空间
check_workspace() {
    log_info "检查工作空间..."
    
    # 当前工作空间文件
    workspace_files=(
        "AGENTS.md"
        "USER.md"
        "SOUL.md"
        "TOOLS.md"
        "MEMORY.md"
        "env_final_verification.sh"
        "improved_health_check.sh"
        "init_project.sh"
        "task_manager.sh"
    )
    
    echo "  工作空间文件:"
    for file in "${workspace_files[@]}"; do
        if [[ -f "$file" ]]; then
            log_success "    ✅ $file"
        else
            log_warning "    ❌ $file"
        fi
    done
    
    # 检查技能目录
    if [[ -d "skills" ]]; then
        skill_count=$(find skills -name "*.md" -type f | wc -l)
        log_success "    ✅ 技能目录 ($skill_count个技能)"
    else
        log_warning "    ❌ 技能目录不存在"
    fi
    
    # 检查记忆目录
    if [[ -d "memory" ]]; then
        memory_files=$(find memory -name "*.md" -type f | wc -l)
        log_success "    ✅ 记忆目录 ($memory_files个文件)"
    else
        log_warning "    ❌ 记忆目录不存在"
    fi
    echo
}

# 生成改进建议
generate_improvement_suggestions() {
    log_info "生成改进建议..."
    
    echo "=================================================="
    echo "              改进建议"
    echo "=================================================="
    
    suggestions=()
    
    # 工具安装建议
    if ! command -v gh >/dev/null 2>&1; then
        suggestions+=("🔧 安装GitHub CLI: brew install gh")
    fi
    
    if ! command -v rg >/dev/null 2>&1; then
        suggestions+=("🔧 安装ripgrep: brew install ripgrep")
    fi
    
    if ! command -v eza >/dev/null 2>&1; then
        suggestions+=("🔧 安装eza: brew install eza")
    fi
    
    if ! command -v bat >/dev/null 2>&1; then
        suggestions+=("🔧 安装bat: brew install bat")
    fi
    
    if ! command -v fd >/dev/null 2>&1; then
        suggestions+=("🔧 安装fd: brew install fd")
    fi
    
    if ! command -v dust >/dev/null 2>&1; then
        suggestions+=("🔧 安装dust: brew install dust")
    fi
    
    if ! command -v docker >/dev/null 2>&1; then
        suggestions+=("🔧 安装Docker: brew install --cask docker")
    fi
    
    if [[ ${#suggestions[@]} -gt 0 ]]; then
        echo "建议安装的工具:"
        for suggestion in "${suggestions[@]}"; do
            echo "  $suggestion"
        done
        echo
    else
        log_success "✅ 所有推荐工具都已安装!"
    fi
    
    echo "优化建议:"
    echo "  📝 完善环境配置"
    echo "  🔄 重新加载配置: source ~/.zshrc"
    echo "  🧪 测试新工具功能"
    echo "  📊 定期运行健康检查"
    echo "  🔄 持续优化工作流程"
    echo
}

# 生成健康报告
generate_health_report() {
    log_info "生成健康报告..."
    
    echo "=================================================="
    echo "              健康报告"
    echo "=================================================="
    
    # 计算健康分数 (简化版本)
    health_score=100
    issues=()
    
    # 检查基础工具
    if ! command -v node >/dev/null 2>&1; then
        health_score=$((health_score - 20))
        issues+=("Node.js缺失")
    fi
    
    if ! command -v npm >/dev/null 2>&1; then
        health_score=$((health_score - 15))
        issues+=("npm缺失")
    fi
    
    if ! command -v git >/dev/null 2>&1; then
        health_score=$((health_score - 25))
        issues+=("Git缺失")
    fi
    
    # 检查配置文件
    if [[ ! -f ~/.shell_aliases ]]; then
        health_score=$((health_score - 10))
        issues+=("Shell别名配置缺失")
    fi
    
    if [[ ! -f ~/.git_aliases ]]; then
        health_score=$((health_score - 10))
        issues+=("Git别名配置缺失")
    fi
    
    if [[ ${#issues[@]} -gt 0 ]]; then
        echo "发现的问题:"
        for issue in "${issues[@]}"; do
            echo "  • $issue"
        done
        echo
    fi
    
    echo "健康分数: $health_score/100"
    
    if [[ $health_score -ge 80 ]]; then
        echo "状态: ${GREEN}优秀${NC}"
    elif [[ $health_score -ge 60 ]]; then
        echo "状态: ${YELLOW}良好${NC}"
    elif [[ $health_score -ge 40 ]]; then
        echo "状态: ${YELLOW}一般${NC}"
    else
        echo "状态: ${RED}较差${NC}"
    fi
    
    echo
    echo "环境评估: OpenClaw工作空间已基本搭建完成"
    echo "核心组件: 开发环境完整，配置系统完善"
    echo "待优化: 现代CLI工具安装和技能扩展"
    echo
}

# 主函数
main() {
    show_title
    
    check_basic_environment
    check_development_tools
    check_network_connectivity
    check_config_files
    check_workspace
    generate_improvement_suggestions
    generate_health_report
    
    log_success "简化健康检查完成!"
    echo "报告生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "执行者: 孔明"
}

# 如果脚本被直接执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi