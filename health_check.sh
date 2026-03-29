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
