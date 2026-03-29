#!/bin/bash

# =============================================================================
# 智能项目工作流管理器
# 为主公的AI项目提供智能化的开发环境和工作流
# =============================================================================

set -e

# 配置
PROJECT_ROOT="/Users/wangshihao/projects/ai"
WORKSPACE_ROOT="/Users/wangshihao/.openclaw/workspace"
LOG_FILE="$WORKSPACE_ROOT/project_workflow.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_info() {
    log "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    log "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    log "${RED}[ERROR]${NC} $1"
}

log_debug() {
    log "${BLUE}[DEBUG]${NC} $1"
}

# 检查项目状态
check_project_status() {
    local project_path="$1"
    local project_name="$2"
    
    log_info "检查 $project_name 项目状态"
    
    if [ ! -d "$project_path" ]; then
        log_error "项目路径不存在: $project_path"
        return 1
    fi
    
    cd "$project_path"
    
    # 检查Git状态
    if [ -d ".git" ]; then
        local git_status=$(git status --porcelain)
        if [ -z "$git_status" ]; then
            log_info "$project_name - Git状态: 干净"
        else
            log_warn "$project_name - Git状态: 有未提交的更改"
            echo "$git_status" | tee -a "$LOG_FILE"
        fi
    else
        log_warn "$project_name - 不是Git仓库"
    fi
    
    # 检查Node.js项目
    if [ -f "package.json" ]; then
        log_info "$project_name - Node.js项目检测到"
        if [ -d "node_modules" ]; then
            log_info "$project_name - 依赖已安装"
        else
            log_warn "$project_name - 依赖未安装"
        fi
    fi
    
    # 检查TypeScript项目
    if [ -f "tsconfig.json" ] || [ -f "tsconfig.node.json" ]; then
        log_info "$project_name - TypeScript项目检测到"
    fi
    
    # 检查Electron项目
    if grep -q "electron" package.json 2>/dev/null; then
        log_info "$project_name - Electron应用检测到"
    fi
}

# 智能项目选择
select_project() {
    local projects=(
        "cherry-studio|Electron AI助手"
        "Ring|AI导航与介绍"
        "workspace|OpenClaw工作空间"
    )
    
    log_info "可用项目列表:"
    for i in "${!projects[@]}"; do
        IFS='|' read -r name desc <<< "${projects[$i]}"
        echo "  $((i+1)). $name - $desc"
    done
    
    read -p "请选择项目编号 (1-${#projects[@]}): " choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#projects[@]}" ]; then
        local selected="${projects[$((choice-1))]}"
        IFS='|' read -r project_name project_desc <<< "$selected"
        echo "$project_desc"
        return 0
    else
        log_error "无效选择"
        return 1
    fi
}

# 快速开发启动
quick_dev() {
    local project_name="$1"
    local project_path="$PROJECT_ROOT/$project_name"
    
    log_info "启动快速开发模式: $project_name"
    
    check_project_status "$project_path" "$project_name"
    
    cd "$project_path"
    
    # 依赖检查和安装
    if [ -f "package.json" ] && [ ! -d "node_modules" ]; then
        log_info "安装项目依赖..."
        npm install || yarn install
    fi
    
    # 代码检查
    if command -v npm >/dev/null 2>&1 && [ -f "package.json" ]; then
        log_info "运行代码检查..."
        npm run lint 2>/dev/null || log_warn "代码检查失败或未配置"
    fi
    
    # 启动开发服务器
    if command -v npm >/dev/null 2>&1 && [ -f "package.json" ]; then
        log_info "启动开发服务器..."
        if grep -q "dev" package.json; then
            npm run dev &
            DEV_PID=$!
            log_info "开发服务器已启动 (PID: $DEV_PID)"
        fi
    fi
    
    log_info "$project_name 开发环境已准备就绪"
}

# 代码质量检查
code_quality_check() {
    local project_name="$1"
    local project_path="$PROJECT_ROOT/$project_name"
    
    log_info "开始代码质量检查: $project_name"
    
    cd "$project_path"
    
    # TypeScript检查
    if command -v tsc >/dev/null 2>&1; then
        log_info "TypeScript类型检查..."
        tsc --noEmit 2>&1 | tee -a "$LOG_FILE" || log_warn "TypeScript类型检查发现问题"
    fi
    
    # ESLint检查
    if command -v eslint >/dev/null 2>&1; then
        log_info "ESLint代码检查..."
        eslint . 2>&1 | tee -a "$LOG_FILE" || log_warn "ESLint检查发现问题"
    fi
    
    # 安全检查
    if command -v npm >/dev/null 2>&1; then
        log_info "npm安全审计..."
        npm audit --audit-level moderate 2>&1 | tee -a "$LOG_FILE" || log_warn "发现安全漏洞"
    fi
    
    log_info "代码质量检查完成"
}

# 项目构建
build_project() {
    local project_name="$1"
    local project_path="$PROJECT_ROOT/$project_name"
    
    log_info "开始构建项目: $project_name"
    
    cd "$project_path"
    
    # 清理构建目录
    if [ -d "dist" ] || [ -d "build" ]; then
        log_info "清理构建目录..."
        rm -rf dist build
    fi
    
    # 构建项目
    if command -v npm >/dev/null 2>&1; then
        log_info "运行构建脚本..."
        npm run build 2>&1 | tee -a "$LOG_FILE" || {
            log_error "构建失败"
            return 1
        }
    fi
    
    log_info "项目构建完成"
}

# Git操作
git_operation() {
    local project_name="$1"
    local project_path="$PROJECT_ROOT/$project_name"
    local operation="$2"
    
    log_info "执行Git操作: $operation"
    
    cd "$project_path"
    
    case "$operation" in
        "status")
            git status
            ;;
        "add")
            git add .
            log_info "所有更改已暂存"
            ;;
        "commit")
            read -p "请输入提交信息: " commit_msg
            git commit -m "$commit_msg"
            log_info "提交完成"
            ;;
        "push")
            git push
            log_info "推送完成"
            ;;
        "pull")
            git pull
            log_info "拉取完成"
            ;;
        *)
            log_error "不支持的Git操作: $operation"
            return 1
            ;;
    esac
}

# 主菜单
show_menu() {
    echo ""
    echo "🚀 智能项目工作流管理器"
    echo "============================"
    echo "1. 检查项目状态"
    echo "2. 快速开发启动"
    echo "3. 代码质量检查"
    echo "4. 构建项目"
    echo "5. Git操作"
    echo "6. 运行测试"
    echo "7. 生成项目报告"
    echo "0. 退出"
    echo "============================"
    read -p "请选择操作: " choice
}

# 主函数
main() {
    log_info "智能项目工作流管理器启动"
    
    while true; do
        show_menu
        
        case "$choice" in
            1)
                select_project
                check_project_status "$PROJECT_ROOT/$project_name" "$project_name"
                ;;
            2)
                select_project
                quick_dev "$project_name"
                ;;
            3)
                select_project
                code_quality_check "$project_name"
                ;;
            4)
                select_project
                build_project "$project_name"
                ;;
            5)
                select_project
                echo "Git操作选项: status, add, commit, push, pull"
                read -p "请选择操作: " git_op
                git_operation "$project_name" "$git_op"
                ;;
            6)
                select_project
                cd "$PROJECT_ROOT/$project_name"
                if command -v npm >/dev/null 2>&1; then
                    log_info "运行测试..."
                    npm test 2>&1 | tee -a "$LOG_FILE" || log_warn "测试失败"
                fi
                ;;
            7)
                select_project
                generate_project_report "$project_name"
                ;;
            0)
                log_info "退出项目工作流管理器"
                exit 0
                ;;
            *)
                log_error "无效选择，请重新输入"
                ;;
        esac
    done
}

# 项目报告生成
generate_project_report() {
    local project_name="$1"
    local project_path="$PROJECT_ROOT/$project_name"
    local report_file="$WORKSPACE_ROOT/${project_name}_report_$(date +%Y%m%d_%H%M%S).md"
    
    log_info "生成项目报告: $project_name"
    
    echo "# 项目报告: $project_name" > "$report_file"
    echo "生成时间: $(date)" >> "$report_file"
    echo "" >> "$report_file"
    
    cd "$project_path"
    
    # 基本信息
    echo "## 基本信息" >> "$report_file"
    echo "- 项目路径: $project_path" >> "$report_file"
    echo "- Git状态: $(git status --porcelain 2>/dev/null | wc -l | sed 's/ //g') 个文件有更改" >> "$report_file"
    echo "- 最后提交: $(git log -1 --format='%ci' 2>/dev/null || echo '无Git历史')" >> "$report_file"
    echo "" >> "$report_file"
    
    # 依赖信息
    if [ -f "package.json" ]; then
        echo "## 依赖信息" >> "$report_file"
        echo "- Node.js版本: $(node --version 2>/dev/null || echo '未知')" >> "$report_file"
        echo "- npm版本: $(npm --version 2>/dev/null || echo '未知')" >> "$report_file"
        
        local dependencies=$(npm ls --depth=0 2>/dev/null | tail -n +2 | head -n -1 | wc -l | sed 's/ //g')
        local dev_dependencies=$(npm ls --depth=0 --dev 2>/dev/null | tail -n +2 | head -n -1 | wc -l | sed 's/ //g')
        
        echo "- 生产依赖数量: $dependencies" >> "$report_file"
        echo "- 开发依赖数量: $dev_dependencies" >> "$report_file"
        echo "" >> "$report_file"
    fi
    
    # 文件统计
    echo "## 文件统计" >> "$report_file"
    local total_files=$(find . -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" | wc -l | sed 's/ //g')
    local ts_files=$(find . -name "*.ts" -o -name "*.tsx" | wc -l | sed 's/ //g')
    local js_files=$(find . -name "*.js" -o -name "*.jsx" | wc -l | sed 's/ //g')
    
    echo "- 总文件数: $total_files" >> "$report_file"
    echo "- TypeScript文件: $ts_files" >> "$report_file"
    echo "- JavaScript文件: $js_files" >> "$report_file"
    echo "" >> "$report_file"
    
    # 项目类型检测
    echo "## 项目类型" >> "$report_file"
    if grep -q "electron" package.json 2>/dev/null; then
        echo "- 📱 Electron应用" >> "$report_file"
    fi
    if grep -q "react" package.json 2>/dev/null; then
        echo "- ⚛️ React项目" >> "$report_file"
    fi
    if grep -q "typescript" package.json 2>/dev/null || [ -f "tsconfig.json" ]; then
        echo "- 📝 TypeScript项目" >> "$report_file"
    fi
    echo "" >> "$report_file"
    
    log_info "项目报告已生成: $report_file"
}

# 如果直接运行脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi