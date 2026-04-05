#!/bin/bash

# 改进的系统健康检查脚本 - macOS版本
# Improved System Health Check Script - macOS Version
# 作者: 孔明 - 基于 healthcheck-ready 技能改进

set -e

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
    echo "  改进系统健康检查 - macOS版本"
    echo "  Improved System Health Check - macOS"
    echo "=================================================="
    echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "系统: $(uname -s) $(uname -r)"
    echo "执行者: 孔明"
    echo "=================================================="
    echo
}

# 磁盘使用检查
check_disk_usage() {
    log_info "检查磁盘使用情况..."
    
    # 获取根目录磁盘使用情况
    if command -v df >/dev/null 2>&1; then
        disk_info=$(df -h / | tail -1)
        usage_percent=$(echo "$disk_info" | awk '{print $5}' | sed 's/%//')
        usage_size=$(echo "$disk_info" | awk '{print $3}')
        total_size=$(echo "$disk_info" | awk '{print $2}')
        mount_point=$(echo "$disk_info" | awk '{print $6}')
        
        echo "  磁盘使用: $usage_size / $total_size ($usage_percent%)"
        
        if [[ $usage_percent -lt 80 ]]; then
            log_success "  ✅ 磁盘使用正常"
        elif [[ $usage_percent -lt 90 ]]; then
            log_warning "  ⚠️ 磁盘使用偏高"
        else
            log_error "  ❌ 磁盘使用过高"
        fi
    else
        log_error "❌ 无法获取磁盘信息"
    fi
    echo
}

# CPU负载检查
check_cpu_load() {
    log_info "检查CPU负载..."
    
    if command -v ps >/dev/null 2>&1; then
        # 获取1分钟平均负载
        load_1min=$(sysctl -n vm.loadavg | awk '{print $1}')
        load_5min=$(sysctl -n vm.loadavg | awk '{print $2}')
        load_15min=$(sysctl -n vm.loadavg | awk '{print $3}')
        
        echo "  CPU负载 (1/5/15分钟): $load_1min, $load_5min, $load_15min"
        
        # 获取CPU核心数
        cpu_cores=$(sysctl -n hw.ncpu)
        threshold=$(echo "$cpu_cores * 0.8" | bc 2>/dev/null || echo "2.0")
        
        if (( $(echo "$load_1min < $threshold" | bc -l) )); then
            log_success "  ✅ CPU负载正常"
        else
            log_warning "  ⚠️ CPU负载偏高"
        fi
        
        # 显示CPU使用率
        if command -v top >/dev/null 2>&1; then
            cpu_usage=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
            echo "  CPU使用率: ${cpu_usage}%"
        fi
    else
        log_error "❌ 无法获取CPU信息"
    fi
    echo
}

# 内存使用检查
check_memory_usage() {
    log_info "检查内存使用情况..."
    
    if command -v vm_stat >/dev/null 2>&1; then
        # 使用vm_stat获取内存信息
        page_size=$(sysctl -n hw.pagesize)
        free_pages=$(vm_stat | grep "free:" | awk '{print $3}' | sed 's/\.//')
        active_pages=$(vm_stat | grep "active:" | awk '{print $3}' | sed 's/\.//')
        inactive_pages=$(vm_stat | grep "inactive:" | awk '{print $3}' | sed 's/\.//')
        wired_pages=$(vm_stat | grep "wired:" | awk '{print $3}' | sed 's/\.//')
        
        total_free=$((free_pages * page_size / 1024 / 1024))
        total_active=$((active_pages * page_size / 1024 / 1024))
        total_inactive=$((inactive_pages * page_size / 1024 / 1024))
        total_wired=$((wired_pages * page_size / 1024 / 1024))
        
        total_mem=$((total_free + total_active + total_inactive + total_wired))
        used_mem=$((total_active + total_inactive + total_wired))
        
        if [[ $total_mem -gt 0 ]]; then
            usage_percent=$((used_mem * 100 / total_mem))
            echo "  内存使用: ${used_mem}MB / ${total_mem}MB (${usage_percent}%)"
            
            if [[ $usage_percent -lt 80 ]]; then
                log_success "  ✅ 内存使用正常"
            elif [[ $usage_percent -lt 90 ]]; then
                log_warning "  ⚠️ 内存使用偏高"
            else
                log_error "  ❌ 内存使用过高"
            fi
        fi
    else
        log_error "❌ 无法获取内存信息"
    fi
    echo
}

# 网络连接检查
check_network_connectivity() {
    log_info "检查网络连接..."
    
    # 检查网络接口
    if command -v ifconfig >/dev/null 2>&1; then
        active_interfaces=$(ifconfig | grep "status: active" | wc -l)
        echo "  活跃网络接口: $active_interfaces"
        
        if [[ $active_interfaces -gt 0 ]]; then
            log_success "  ✅ 网络接口正常"
        else
            log_warning "  ⚠️ 无活跃网络接口"
        fi
    fi
    
    # 检查关键连接
    if command -v curl >/dev/null 2>&1; then
        echo "  HTTP连接测试:"
        for domain in "github.com" "google.com"; do
            if curl -s --head https://$domain >/dev/null; then
                log_success "    ✓ https://$domain"
            else
                log_warning "    ✗ https://$domain"
            fi
        done
    fi
    echo
}

# 关键进程检查
check_critical_processes() {
    log_info "检查关键进程..."
    
    processes=(
        "ssh:SSH守护进程"
        "sshd:SSH服务器"
        "cron:定时任务"
        "launchd:启动守护"
        "OpenClaw:OpenClaw服务"
    )
    
    for process_info in "${processes[@]}"; do
        process_name=$(echo "$process_info" | cut -d: -f1)
        process_desc=$(echo "$process_info" | cut -d: -f2)
        
        # 检查进程是否运行
        if pgrep -x "$process_name" >/dev/null 2>&1; then
            log_success "  ✅ $process_desc ($process_name): 运行中"
        else
            log_warning "  ⚠️ $process_desc ($process_name): 未运行"
        fi
    done
    echo
}

# 系统更新检查
check_system_updates() {
    log_info "检查系统更新..."
    
    # 检查macOS更新
    if command -v softwareupdate >/dev/null 2>&1; then
        echo "  macOS更新状态:"
        
        # 检查是否有可用更新
        if softwareupdate --list 2>/dev/null | grep -q "Label:"; then
            log_warning "  ⚠️ 有可用的macOS更新"
        else
            log_success "  ✅ 系统已更新"
        fi
    else
        log_warning "  ⚠️ 无法检查更新"
    fi
    
    # 检查Homebrew更新
    if command -v brew >/dev/null 2>&1; then
        echo "  Homebrew更新状态:"
        outdated_packages=$(brew outdated --quiet | wc -l)
        if [[ $outdated_packages -gt 0 ]]; then
            log_warning "  ⚠️ $outdated_packages个包需要更新"
        else
            log_success "  ✅ Homebrew已更新"
        fi
    fi
    echo
}

# 安全状态检查
check_security_status() {
    log_info "检查安全状态..."
    
    # 检查防火墙状态
    if command -v pfctl >/dev/null 2>&1; then
        firewall_status=$(pfctl -si 2>/dev/null | grep "Status:" | awk '{print $2}')
        echo "  防火墙状态: ${firewall_status:-未知}"
    fi
    
    # 检查Gatekeeper
    if command -v spctl >/dev/null 2>&1; then
        gatekeeper_status=$(spctl --status 2>/dev/null | grep "assessments" | cut -d: -f2 | xargs)
        echo "  Gatekeeper: ${gatekeeper_status:-启用}"
    fi
    
    # 检查文件完整性
    if [[ -f /usr/libexec/RemoteManagement/rmcfg ]];then
        log_success "  ✅ 远程管理服务可用"
    fi
    
    echo
}

# 生成健康报告
generate_health_report() {
    log_info "生成健康报告..."
    
    echo "=================================================="
    echo "              系统健康报告"
    echo "=================================================="
    
    # 计算健康分数
    health_score=100
    issues=()
    
    # 基于前面的检查调整分数
    if [[ "$disk_issue" == "high" ]]; then
        health_score=$((health_score - 20))
        issues+=("磁盘使用过高")
    elif [[ "$disk_issue" == "medium" ]]; then
        health_score=$((health_score - 10))
        issues+=("磁盘使用偏高")
    fi
    
    if [[ "$cpu_issue" == "high" ]]; then
        health_score=$((health_score - 15))
        issues+=("CPU负载过高")
    elif [[ "$cpu_issue" == "medium" ]]; then
        health_score=$((health_score - 5))
        issues+=("CPU负载偏高")
    fi
    
    if [[ "$memory_issue" == "high" ]]; then
        health_score=$((health_score - 20))
        issues+=("内存使用过高")
    elif [[ "$memory_issue" == "medium" ]]; then
        health_score=$((health_score - 10))
        issues+=("内存使用偏高")
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
        echo "状态: ${GREEN}良好${NC}"
    elif [[ $health_score -ge 60 ]]; then
        echo "状态: ${YELLOW}一般${NC}"
    else
        echo "状态: ${RED}较差${NC}"
    fi
    
    echo
    echo "建议行动:"
    if [[ $health_score -lt 80 ]]; then
        echo "  1. 清理不必要的文件"
        echo "  2. 检查资源使用情况"
        echo "  3. 考虑重启系统"
    fi
    echo "  2. 定期运行健康检查"
    echo "  3. 监控系统性能变化"
}

# 主函数
main() {
    show_title
    
    check_disk_usage
    check_cpu_load
    check_memory_usage
    check_network_connectivity
    check_critical_processes
    check_system_updates
    check_security_status
    generate_health_report
    
    log_success "系统健康检查完成!"
    echo "报告生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
}

# 如果脚本被直接执行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi