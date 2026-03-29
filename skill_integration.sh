#!/bin/bash
# skill_integration.sh - OpenClaw技能集成脚本
# 用于自动集成和管理OpenClaw技能

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# 检查clawhub是否已安装
check_clawhub() {
    if ! command -v clawhub &> /dev/null; then
        log_error "clawhub未安装"
        return 1
    fi
    log_success "clawhub已安装"
    return 0
}

# 检查clawhub登录状态
check_login_status() {
    log_info "检查clawhub登录状态..."
    if clawhub list --installed &> /dev/null; then
        log_success "clawhub已登录"
        return 0
    else
        log_warning "clawhub未登录，请先运行: clawhub login"
        return 1
    fi
}

# 列出已安装的技能
list_installed_skills() {
    log_info "已安装的技能列表:"
    if clawhub list --installed 2>/dev/null | grep -v "技能数量"; then
        local skill_count=$(clawhub list --installed 2>/dev/null | grep "技能数量" | awk '{print $3}' | tr -d '()')
        log_success "总共安装了 $skill_count 个技能"
    else
        log_warning "无法获取技能列表，可能未登录"
    fi
}

# 安装指定技能
install_skill() {
    local skill_name="$1"
    log_info "正在安装技能: $skill_name"
    
    if clawhub install "$skill_name"; then
        log_success "技能 $skill_name 安装成功"
        return 0
    else
        log_error "技能 $skill_name 安装失败"
        return 1
    fi
}

# 卸载指定技能
uninstall_skill() {
    local skill_name="$1"
    log_info "正在卸载技能: $skill_name"
    
    if clawhub uninstall "$skill_name"; then
        log_success "技能 $skill_name 卸载成功"
        return 0
    else
        log_error "技能 $skill_name 卸载失败"
        return 1
    fi
}

# 搜索可用技能
search_skills() {
    local search_term="$1"
    log_info "搜索技能: $search_term"
    
    if clawhub search "$search_term" | head -20; then
        return 0
    else
        log_error "搜索技能失败"
        return 1
    fi
}

# 测试技能功能
test_skill() {
    local skill_name="$1"
    log_info "测试技能功能: $skill_name"
    
    # 检查技能目录是否存在
    local skill_dir="./skills/$skill_name"
    if [ ! -d "$skill_dir" ]; then
        log_error "技能目录不存在: $skill_dir"
        return 1
    fi
    
    # 检查技能脚本
    local test_script="$skill_dir/test.sh"
    if [ -f "$test_script" ]; then
        log_info "运行技能测试脚本..."
        bash "$test_script"
        if [ $? -eq 0 ]; then
            log_success "技能 $skill_name 测试通过"
            return 0
        else
            log_error "技能 $skill_name 测试失败"
            return 1
        fi
    else
        log_warning "技能 $skill_name 没有测试脚本，跳过测试"
        return 0
    fi
}

# 技能健康检查
skill_health_check() {
    log_info "执行技能健康检查..."
    
    local skills_dir="./skills"
    if [ ! -d "$skills_dir" ]; then
        log_warning "技能目录不存在: $skills_dir"
        return 0
    fi
    
    local skill_count=0
    local healthy_count=0
    
    for skill_dir in "$skills_dir"/*/; do
        if [ -d "$skill_dir" ] && [ "$(basename "$skill_dir")" != "README.md" ]; then
            local skill_name=$(basename "$skill_dir")
            skill_count=$((skill_count + 1))
            
            log_info "检查技能: $skill_name"
            
            # 检查必要文件
            local has_script=false
            local has_readme=false
            
            if [ -f "$skill_dir/SKILL.md" ] || [ -f "$skill_dir/skill.sh" ]; then
                has_script=true
            fi
            
            if [ -f "$skill_dir/README.md" ]; then
                has_readme=true
            fi
            
            if [ "$has_script" = true ] && [ "$has_readme" = true ]; then
                log_success "技能 $skill_name 健康状态良好"
                healthy_count=$((healthy_count + 1))
            else
                log_warning "技能 $skill_name 缺少必要文件"
            fi
        fi
    done
    
    log_success "技能健康检查完成: $healthy_count/$skill_count 个技能健康"
}

# 生成技能报告
generate_skill_report() {
    local report_file="skill_report_$(date +%Y%m%d_%H%M%S).txt"
    log_info "生成技能报告: $report_file"
    
    {
        echo "OpenClaw技能集成报告"
        echo "生成时间: $(date)"
        echo "================================"
        echo ""
        echo "1. 已安装技能列表:"
        clawhub list --installed 2>/dev/null | grep -v "技能数量" || echo "无技能信息"
        echo ""
        echo "2. 技能目录状态:"
        ls -la skills/ 2>/dev/null || echo "技能目录不存在"
        echo ""
        echo "3. 技能健康检查:"
        skill_health_check
    } > "$report_file"
    
    log_success "技能报告已生成: $report_file"
}

# 主菜单
main_menu() {
    while true; do
        echo ""
        echo "OpenClaw技能集成管理系统"
        echo "============================"
        echo "1. 检查登录状态"
        echo "2. 列出已安装技能"
        echo "3. 安装新技能"
        echo "4. 卸载技能"
        echo "5. 搜索技能"
        echo "6. 测试技能功能"
        echo "7. 技能健康检查"
        echo "8. 生成技能报告"
        echo "9. 退出"
        echo ""
        
        read -p "请选择操作 (1-9): " choice
        
        case $choice in
            1)
                check_clawhub
                check_login_status
                ;;
            2)
                list_installed_skills
                ;;
            3)
                read -p "请输入要安装的技能名称: " skill_name
                install_skill "$skill_name"
                ;;
            4)
                read -p "请输入要卸载的技能名称: " skill_name
                uninstall_skill "$skill_name"
                ;;
            5)
                read -p "请输入搜索关键词: " search_term
                search_skills "$search_term"
                ;;
            6)
                read -p "请输入要测试的技能名称: " skill_name
                test_skill "$skill_name"
                ;;
            7)
                skill_health_check
                ;;
            8)
                generate_skill_report
                ;;
            9)
                log_info "退出技能集成管理系统"
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
    log_info "OpenClaw技能集成脚本启动"
    
    # 基础检查
    check_clawhub
    
    # 直接进入主菜单
    main_menu
}

# 如果直接运行脚本
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi