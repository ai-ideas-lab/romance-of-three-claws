#!/bin/bash
# workspace_optimizer.sh - OpenClaw工作空间优化脚本
# 集成所有优化功能，提供统一的管理界面

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

log_title() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}================================${NC}"
}

# 显示当前时间
show_time() {
    echo -e "${BLUE}当前时间:$(date '+%Y-%m-%d %H:%M:%S')${NC}"
}

# 进度条函数
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    
    local completed=$((current * width / total))
    local remaining=$((width - completed))
    
    printf "["
    printf "%*s" $completed | tr ' ' '='
    printf "%*s" $remaining | tr ' ' ' '
    printf "] %d%%\n" $percentage
}

# 环境检查函数
check_environment() {
    log_title "环境检查"
    
    echo "正在检查系统环境..."
    
    # 基础系统信息
    echo ""
    log_step "系统信息"
    echo "操作系统: $(uname -s)"
    echo "系统版本: $(uname -r)"
    echo "架构: $(uname -m)"
    echo "用户: $(whoami)"
    
    # 开发环境检查
    echo ""
    log_step "开发环境"
    
    local dev_tools=("node" "npm" "python" "git" "brew")
    local dev_tool_names=("Node.js" "npm" "Python" "Git" "Homebrew")
    local dev_count=0
    
    for i in "${!dev_tools[@]}"; do
        if command -v "${dev_tools[i]}" &> /dev/null; then
            log_success "${dev_tool_names[i]} ✓"
            dev_count=$((dev_count + 1))
        else
            log_warning "${dev_tool_names[i]} ✗"
        fi
    done
    
    echo "开发环境完整性: $dev_count/${#dev_tools[@]}"
    
    # 磁盘使用情况
    echo ""
    log_step "磁盘使用情况"
    df -h | grep -E "Filesystem|/$" | head -2
    
    return 0
}

# 技能管理函数
manage_skills() {
    log_title "OpenClaw技能管理"
    
    echo "OpenClaw技能管理系统"
    echo "===================="
    echo "1. 检查技能状态"
    echo "2. 安装新技能"
    echo "3. 技能健康检查"
    echo "4. 技能集成测试"
    echo "5. 返回主菜单"
    echo ""
    
    read -p "请选择操作 (1-5): " choice
    
    case $choice in
        1)
            log_info "检查OpenClaw技能状态..."
            bash skill_integration.sh
            ;;
        2)
            log_info "安装新技能..."
            bash skill_integration.sh
            ;;
        3)
            log_info "执行技能健康检查..."
            bash skill_integration.sh
            ;;
        4)
            log_info "技能集成测试..."
            bash skill_integration.sh
            ;;
        5)
            return 0
            ;;
        *)
            log_error "无效选择"
            ;;
    esac
}

# 工具安装函数
manage_tools() {
    log_title "现代CLI工具管理"
    
    echo "现代CLI工具安装管理"
    echo "===================="
    echo "1. 检查工具状态"
    echo "2. 批量安装工具"
    echo "3. 生成别名配置"
    echo "4. 测试工具功能"
    echo "5. 生成安装报告"
    echo "6. 返回主菜单"
    echo ""
    
    read -p "请选择操作 (1-6): " choice
    
    case $choice in
        1)
            log_info "检查工具状态..."
            bash cli_tools_installer.sh check
            ;;
        2)
            log_info "批量安装工具..."
            bash cli_tools_installer.sh install
            ;;
        3)
            log_info "生成别名配置..."
            bash cli_tools_installer.sh aliases
            ;;
        4)
            log_info "测试工具功能..."
            bash cli_tools_installer.sh test
            ;;
        5)
            log_info "生成安装报告..."
            bash cli_tools_installer.sh report
            ;;
        6)
            return 0
            ;;
        *)
            log_error "无效选择"
            ;;
    esac
}

# 配置优化函数
optimize_config() {
    log_title "配置文件优化"
    
    echo "配置文件优化"
    echo "============="
    echo "1. 检查Shell配置"
    echo "2. 检查Git配置"
    echo "3. 检查编辑器配置"
    echo "4. 验证所有配置"
    echo "5. 返回主菜单"
    echo ""
    
    read -p "请选择操作 (1-5): " choice
    
    case $choice in
        1)
            log_info "检查Shell配置..."
            if [ -f ~/.zshrc ]; then
                log_success "Shell配置文件存在"
                echo "Shell别名数量: $(grep -c '^alias' ~/.zshrc 2>/dev/null || echo 0)"
            else
                log_warning "Shell配置文件不存在"
            fi
            
            if [ -f .shell_aliases ]; then
                log_success "工作区Shell别名配置存在"
                echo "工作区别名数量: $(grep -c '^alias' .shell_aliases 2>/dev/null || echo 0)"
            else
                log_warning "工作区Shell别名配置不存在"
            fi
            ;;
        2)
            log_info "检查Git配置..."
            if [ -f ~/.gitconfig ]; then
                log_success "Git配置文件存在"
                echo "Git别名数量: $(grep -c '\[alias\]' ~/.gitconfig 2>/dev/null || echo 0)"
            else
                log_warning "Git配置文件不存在"
            fi
            
            if [ -f .git_aliases ]; then
                log_success "工作区Git别名配置存在"
                echo "工作区Git别名数量: $(grep -c '^alias' .git_aliases 2>/dev/null || echo 0)"
            else
                log_warning "工作区Git别名配置不存在"
            fi
            ;;
        3)
            log_info "检查编辑器配置..."
            if [ -f ~/.vimrc ]; then
                log_success "Vim配置文件存在"
                echo "Vim配置行数: $(wc -l < ~/.vimrc 2>/dev/null || echo 0)"
            else
                log_warning "Vim配置文件不存在"
            fi
            
            if command -v nvim &> /dev/null; then
                log_success "Neovim已安装"
                if [ -f ~/.config/nvim/init.vim ]; then
                    log_success "Neovim配置文件存在"
                else
                    log_warning "Neovim配置文件不存在"
                fi
            else
                log_warning "Neovim未安装"
            fi
            ;;
        4)
            log_info "验证所有配置..."
            
            # 检查配置文件完整性
            local config_files=(".shell_aliases" ".git_aliases" ".vimrc")
            local total_files=${#config_files[@]}
            local found_files=0
            
            for file in "${config_files[@]}"; do
                if [ -f "$file" ]; then
                    log_success "配置文件存在: $file"
                    found_files=$((found_files + 1))
                else
                    log_warning "配置文件不存在: $file"
                fi
            done
            
            echo ""
            log_step "配置完整性: $found_files/$total_files"
            
            if [ "$found_files" -eq "$total_files" ]; then
                log_success "所有配置文件完整"
            else
                log_warning "部分配置文件缺失"
            fi
            ;;
        5)
            return 0
            ;;
        *)
            log_error "无效选择"
            ;;
    esac
}

# 环境验证函数
verify_environment() {
    log_title "环境验证"
    
    echo "环境验证系统"
    echo "============="
    echo "1. 快速环境检查"
    echo "2. 详细环境分析"
    echo "3. 健康检查测试"
    echo "4. 性能分析报告"
    echo "5. 返回主菜单"
    echo ""
    
    read -p "请选择操作 (1-5): " choice
    
    case $choice in
        1)
            log_info "快速环境检查..."
            bash env_final_verification.sh
            ;;
        2)
            log_info "详细环境分析..."
            bash env_final_verification.sh --detailed
            ;;
        3)
            log_info "健康检查测试..."
            bash quick_health_check.sh
            ;;
        4)
            log_info "性能分析报告..."
            bash env_final_verification.sh --performance
            ;;
        5)
            return 0
            ;;
        *)
            log_error "无效选择"
            ;;
    esac
}

# 报告生成函数
generate_reports() {
    log_title "报告生成"
    
    echo "报告生成系统"
    echo "============="
    echo "1. 环境状态报告"
    echo "2. 技能集成报告"
    echo "3. 工具安装报告"
    echo "4. 完整工作空间报告"
    echo "5. 返回主菜单"
    echo ""
    
    read -p "请选择操作 (1-5): " choice
    
    case $choice in
        1)
            log_info "生成环境状态报告..."
            bash env_final_verification.sh --report
            ;;
        2)
            log_info "生成技能集成报告..."
            bash skill_integration.sh --report
            ;;
        3)
            log_info "生成工具安装报告..."
            bash cli_tools_installer.sh report
            ;;
        4)
            log_info "生成完整工作空间报告..."
            
            # 生成综合报告
            local report_file="workspace_report_$(date +%Y%m%d_%H%M%S).txt"
            
            {
                echo "OpenClaw工作空间完整报告"
                echo "生成时间: $(date)"
                echo "================================"
                echo ""
                
                # 环境状态
                echo "1. 环境状态:"
                echo "------------"
                bash env_final_verification.sh --quick
                
                echo ""
                echo "2. 技能状态:"
                echo "------------"
                if command -v clawhub &> /dev/null; then
                    clawhub list --installed 2>/dev/null | head -10
                else
                    echo "clawhub未安装"
                fi
                
                echo ""
                echo "3. 工具状态:"
                echo "------------"
                bash cli_tools_installer.sh check
                
                echo ""
                echo "4. 配置状态:"
                echo "------------"
                optimize_config
                
            } > "$report_file"
            
            log_success "完整工作空间报告已生成: $report_file"
            ;;
        5)
            return 0
            ;;
        *)
            log_error "无效选择"
            ;;
    esac
}

# 自动优化函数
auto_optimize() {
    log_title "自动优化"
    
    echo "自动优化模式"
    echo "============="
    echo "1. 智能优化推荐"
    echo "2. 一键完整优化"
    echo "3. 针对性优化"
    echo "4. 返回主菜单"
    echo ""
    
    read -p "请选择操作 (1-4): " choice
    
    case $choice in
        1)
            log_info "智能优化推荐..."
            
            echo "基于当前环境的优化建议:"
            echo ""
            
            # 检查Homebrew
            if ! command -v brew &> /dev/null; then
                log_warning "建议: 安装Homebrew包管理器"
            else
                log_success "Homebrew已安装"
            fi
            
            # 检查现代CLI工具
            local modern_tools=("gh" "fzf" "rg" "eza" "bat" "fd" "dust")
            local installed_tools=0
            
            for tool in "${modern_tools[@]}"; do
                if command -v "$tool" &> /dev/null; then
                    installed_tools=$((installed_tools + 1))
                fi
            done
            
            if [ "$installed_tools" -lt 5 ]; then
                log_warning "建议: 安装现代CLI工具 (已安装: $installed_tools/${#modern_tools[@]})"
            else
                log_success "现代CLI工具基本完整"
            fi
            
            # 检查OpenClaw技能
            if command -v clawhub &> /dev/null; then
                local skill_count=$(clawhub list --installed 2>/dev/null | grep "技能数量" | awk '{print $3}' | tr -d '()' || echo "未知")
                if [ "$skill_count" -lt 5 ]; then
                    log_warning "建议: 安装更多OpenClaw技能 (当前: $skill_count)"
                else
                    log_success "OpenClaw技能数量充足"
                fi
            else
                log_warning "建议: 安装clawhub CLI工具"
            fi
            
            # 检查配置文件
            local config_files=(".shell_aliases" ".git_aliases" ".vimrc")
            local config_count=0
            
            for file in "${config_files[@]}"; do
                if [ -f "$file" ]; then
                    config_count=$((config_count + 1))
                fi
            done
            
            if [ "$config_count" -lt 3 ]; then
                log_warning "建议: 完善配置文件 (已配置: $config_count/${#config_files[@]})"
            else
                log_success "配置文件完整"
            fi
            ;;
        2)
            log_info "开始一键完整优化..."
            
            echo "开始完整优化流程..."
            echo "这可能需要一些时间，请耐心等待..."
            echo ""
            
            # 环境检查
            log_step "1. 环境检查"
            check_environment
            
            # 安装现代CLI工具
            log_step "2. 安装现代CLI工具"
            bash cli_tools_installer.sh install
            
            # 安装OpenClaw技能
            log_step "3. 安装OpenClaw技能"
            bash skill_integration.sh --install-healthcheck
            
            # 配置优化
            log_step "4. 配置优化"
            optimize_config
            
            # 生成报告
            log_step "5. 生成最终报告"
            generate_reports
            
            echo ""
            log_success "完整优化完成!"
            ;;
        3)
            log_info "针对性优化..."
            
            echo "选择需要优化的方面:"
            echo "1. 仅工具安装"
            echo "2. 仅技能安装"
            echo "3. 仅配置优化"
            echo "4. 仅环境验证"
            echo ""
            
            read -p "请选择优化方向 (1-4): " direction
            
            case $direction in
                1)
                    bash cli_tools_installer.sh install
                    ;;
                2)
                    bash skill_integration.sh --install-healthcheck
                    ;;
                3)
                    optimize_config
                    ;;
                4)
                    verify_environment
                    ;;
                *)
                    log_error "无效选择"
                    ;;
            esac
            ;;
        4)
            return 0
            ;;
        *)
            log_error "无效选择"
            ;;
    esac
}

# 主菜单
main_menu() {
    while true; do
        clear
        show_time
        
        echo "OpenClaw工作空间优化系统"
        echo "========================="
        echo ""
        echo "主要功能:"
        echo "1. 📊 环境检查"
        echo "2. 🛠️  技能管理"
        echo "3. 🔧 工具安装"
        echo "4. ⚙️  配置优化"
        echo "5. ✅ 环境验证"
        echo "6. 📈 报告生成"
        echo "7. 🤖 自动优化"
        echo "8. 🚪 退出"
        echo ""
        
        read -p "请选择操作 (1-8): " choice
        
        case $choice in
            1)
                check_environment
                read -p "按Enter键继续..."
                ;;
            2)
                manage_skills
                read -p "按Enter键继续..."
                ;;
            3)
                manage_tools
                read -p "按Enter键继续..."
                ;;
            4)
                optimize_config
                read -p "按Enter键继续..."
                ;;
            5)
                verify_environment
                read -p "按Enter键继续..."
                ;;
            6)
                generate_reports
                read -p "按Enter键继续..."
                ;;
            7)
                auto_optimize
                read -p "按Enter键继续..."
                ;;
            8)
                log_info "感谢使用OpenClaw工作空间优化系统"
                exit 0
                ;;
            *)
                log_error "无效选择，请重新输入"
                read -p "按Enter键继续..."
                ;;
        esac
    done
}

# 脚本入口
main() {
    log_title "OpenClaw工作空间优化系统"
    log_info "开始工作空间优化..."
    
    # 检查必要的文件
    if [ ! -f "skill_integration.sh" ]; then
        log_error "缺少技能集成脚本"
        exit 1
    fi
    
    if [ ! -f "cli_tools_installer.sh" ]; then
        log_error "缺少工具安装脚本"
        exit 1
    fi
    
    if [ ! -f "env_final_verification.sh" ]; then
        log_error "缺少环境验证脚本"
        exit 1
    fi
    
    # 给脚本添加执行权限
    chmod +x skill_integration.sh
    chmod +x cli_tools_installer.sh
    chmod +x env_final_verification.sh
    
    log_success "所有依赖脚本已准备就绪"
    
    # 进入主菜单
    main_menu
}

# 如果直接运行脚本
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi