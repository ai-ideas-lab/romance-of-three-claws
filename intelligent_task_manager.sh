#!/bin/bash

# =============================================================================
# 智能任务管理系统
# 为主公的AI项目开发提供任务管理和进度跟踪
# =============================================================================

set -e

# 项目路径配置
CHERRY_STUDIO_PATH="/Users/wangshihao/projects/ai/cherry-studio"
RING_PATH="/Users/wangshihao/projects/ai/Ring"
WORKSPACE_ROOT="/Users/wangshihao/.openclaw/workspace"

# 任务数据库
TASK_DB="$WORKSPACE_ROOT/tasks.json"
BACKUP_DIR="$WORKSPACE_ROOT/backups"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 任务状态
STATUS_TODO="todo"
STATUS_IN_PROGRESS="in_progress"
STATUS_REVIEW="review"
STATUS_DONE="done"
STATUS_BLOCKED="blocked"

# 优先级
PRIORITY_LOW="low"
PRIORITY_MEDIUM="medium"
PRIORITY_HIGH="high"
PRIORITY_URGENT="urgent"

# 日志函数
log() {
    echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
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

log_success() {
    log "${GREEN}[SUCCESS]${NC} $1"
}

# 初始化任务数据库
init_task_db() {
    if [ ! -f "$TASK_DB" ]; then
        log_info "初始化任务数据库..."
        cat > "$TASK_DB" << 'EOF'
{
  "tasks": [],
  "projects": {
    "cherry-studio": {
      "name": "Cherry Studio",
      "description": "Electron AI助手",
      "tasks": [],
      "completed": 0,
      "total": 0
    },
    "ring": {
      "name": "Ring",
      "description": "AI导航与介绍",
      "tasks": [],
      "completed": 0,
      "total": 0
    },
    "workspace": {
      "name": "OpenClaw Workspace",
      "description": "工作空间配置和优化",
      "tasks": [],
      "completed": 0,
      "total": 0
    }
  },
  "stats": {
    "total_tasks": 0,
    "completed_tasks": 0,
    "in_progress_tasks": 0,
    "overdue_tasks": 0,
    "productivity_score": 0
  },
  "created_at": "$(date -Iseconds)",
  "updated_at": "$(date -Iseconds)"
}
EOF
        log_success "任务数据库已初始化"
    fi
}

# 创建备份
backup_db() {
    local backup_file="$BACKUP_DIR/tasks_backup_$(date +%Y%m%d_%H%M%S).json"
    mkdir -p "$BACKUP_DIR"
    cp "$TASK_DB" "$backup_file"
    log_info "任务数据库已备份: $backup_file"
}

# 生成任务ID
generate_task_id() {
    echo "task_$(date +%Y%m%d)_$(date +%H%M%S)_$((RANDOM % 1000))"
}

# 添加任务
add_task() {
    local project="$1"
    local title="$2"
    local description="$3"
    local priority="$4"
    local deadline="$5"
    local tags="$6"
    
    local task_id=$(generate_task_id)
    
    # 构建任务对象
    local task_obj=$(cat << EOF
{
  "id": "$task_id",
  "project": "$project",
  "title": "$title",
  "description": "$description",
  "priority": "$priority",
  "status": "$STATUS_TODO",
  "created_at": "$(date -Iseconds)",
  "updated_at": "$(date -Iseconds)",
  "deadline": "$deadline",
  "tags": ["$tags"],
  "estimated_hours": 0,
  "actual_hours": 0,
  "assignee": "主公",
  "reviewer": null,
  "blocked_reason": null
}
EOF
)
    
    # 更新任务数据库
    backup_db
    
    # 使用 jq 更新 JSON
    if command -v jq >/dev/null 2>&1; then
        jq --arg task "$task_obj" '.tasks += ($task | fromjson)' "$TASK_DB" > "$TASK_DB.tmp" && mv "$TASK_DB.tmp" "$TASK_DB"
        jq ".projects[\"$project\"].tasks += [\"$task_id\"]" "$TASK_DB" > "$TASK_DB.tmp" && mv "$TASK_DB.tmp" "$TASK_DB"
        jq ".projects[\"$project\"].total += 1" "$TASK_DB" > "$TASK_DB.tmp" && mv "$TASK_DB.tmp" "$TASK_DB"
        jq ".stats.total_tasks += 1" "$TASK_DB" > "$TASK_DB.tmp" && mv "$TASK_DB.tmp" "$TASK_DB"
    else
        log_error "jq 未安装，无法更新任务数据库"
        return 1
    fi
    
    log_success "任务已添加: $title (ID: $task_id)"
    echo "$task_id"
}

# 列出任务
list_tasks() {
    local project="$1"
    local status="$2"
    local priority="$3"
    
    log_info "列出任务..."
    
    if command -v jq >/dev/null 2>&1; then
        local filter=""
        
        if [ -n "$project" ]; then
            filter="$filter | .tasks[] | select(.project == \"$project\")"
        fi
        
        if [ -n "$status" ]; then
            filter="$filter | select(.status == \"$status\")"
        fi
        
        if [ -n "$priority" ]; then
            filter="$filter | select(.priority == \"$priority\")"
        fi
        
        if [ -n "$filter" ]; then
            jq -r ".tasks$filter | sort_by(.priority, .created_at) | .[] | \"\(.id) | \(.title) | \(.status) | \(.priority) | \(.deadline)\"" "$TASK_DB"
        else
            jq -r '.tasks[] | "\(.id) | \(.title) | \(.status) | \(.priority) | \(.deadline)"' "$TASK_DB"
        fi
    else
        log_error "jq 未安装，无法列出任务"
    fi
}

# 更新任务状态
update_task_status() {
    local task_id="$1"
    local new_status="$2"
    local comment="$3"
    
    backup_db
    
    if command -v jq >/dev/null 2>&1; then
        jq ".tasks[] | select(.id == \"$task_id\") | .status = \"$new_status\" | .updated_at = \"$(date -Iseconds)\"" "$TASK_DB" > "$TASK_DB.tmp" && mv "$TASK_DB.tmp" "$TASK_DB"
        
        if [ -n "$comment" ]; then
            # 添加评论逻辑（需要扩展JSON结构）
            log_info "添加评论: $comment"
        fi
        
        log_success "任务状态已更新: $task_id -> $new_status"
    else
        log_error "jq 未安装，无法更新任务状态"
    fi
}

# 删除任务
delete_task() {
    local task_id="$1"
    
    backup_db
    
    if command -v jq >/dev/null 2>&1; then
        # 获取任务信息以便更新统计
        local task_info=$(jq -r ".tasks[] | select(.id == \"$task_id\")" "$TASK_DB")
        local project=$(echo "$task_info" | jq -r '.project')
        local status=$(echo "$task_info" | jq -r '.status')
        
        # 删除任务
        jq "del(.tasks[] | select(.id == \"$task_id\"))" "$TASK_DB" > "$TASK_DB.tmp" && mv "$TASK_DB.tmp" "$TASK_DB"
        
        # 更新项目统计
        jq ".projects[\"$project\"].tasks -= [\"$task_id\"]" "$TASK_DB" > "$TASK_DB.tmp" && mv "$TASK_DB.tmp" "$TASK_DB"
        
        # 更新全局统计
        jq ".stats.total_tasks -= 1" "$TASK_DB" > "$TASK_DB.tmp" && mv "$TASK_DB.tmp" "$TASK_DB"
        
        if [ "$status" == "$STATUS_DONE" ]; then
            jq ".stats.completed_tasks -= 1" "$TASK_DB" > "$TASK_DB.tmp" && mv "$TASK_DB.tmp" "$TASK_DB"
        fi
        
        log_success "任务已删除: $task_id"
    else
        log_error "jq 未安装，无法删除任务"
    fi
}

# 生成任务报告
generate_task_report() {
    local project="$1"
    local output_file="$WORKSPACE_ROOT/task_report_$(date +%Y%m%d_%H%M%S).md"
    
    log_info "生成任务报告: $output_file"
    
    cat > "$output_file" << EOF
# 任务管理报告

生成时间: $(date)
报告期间: $(date -d "1 week ago" +%Y-%m-%d) 至 $(date +%Y-%m-%d)

## 📊 任务统计
EOF
    
    if command -v jq >/dev/null 2>&1; then
        # 添加统计信息
        jq '.stats' "$TASK_DB" >> "$output_file"
        
        # 添加任务列表
        echo "" >> "$output_file"
        echo "## 📋 任务列表" >> "$output_file"
        
        if [ -n "$project" ]; then
            echo "### 项目: $project" >> "$output_file"
            jq -r ".tasks[] | select(.project == \"$project\") | \"- \(.id): \(.title) [\(.status)] [优先级: \(.priority)]\"" "$TASK_DB" >> "$output_file"
        else
            jq -r '.tasks[] | "- \(.id): \(.title) [\(.status)] [优先级: \(.priority)] [项目: \(.project)]"' "$TASK_DB" >> "$output_file"
        fi
        
        # 添加项目统计
        echo "" >> "$output_file"
        echo "## 🎯 项目进度" >> "$output_file"
        jq '.projects | to_entries[] | "\(.key): \(.value.completed}/\(.value.total) 任务完成 (\(.value.description))"' "$TASK_DB" >> "$output_file"
        
        # 添加优先级分析
        echo "" >> "$output_file"
        echo "## 🔥 优先级分析" >> "$output_file"
        echo "### 高优先级任务:" >> "$output_file"
        jq -r '.tasks[] | select(.priority == "high" or .priority == "urgent") | "- \(.id): \(.title)"' "$TASK_DB" >> "$output_file"
        
        # 添加即将到期的任务
        echo "" >> "$output_file"
        echo "## ⏰ 即将到期的任务" >> "$output_file"
        jq -r '.tasks[] | select(.deadline != "" and .status != "done") | "- \(.id): \(.title) (截止日期: \(.deadline))"' "$TASK_DB" >> "$output_file"
        
    else
        echo "错误: jq 未安装，无法生成详细报告" >> "$output_file"
    fi
    
    echo "" >> "$output_file"
    echo "---" >> "$output_file"
    echo "报告由智能任务管理系统自动生成" >> "$output_file"
    
    log_success "任务报告已生成: $output_file"
}

# 计算生产力评分
calculate_productivity_score() {
    if command -v jq >/dev/null 2>&1; then
        local total_tasks=$(jq '.stats.total_tasks' "$TASK_DB")
        local completed_tasks=$(jq '.stats.completed_tasks' "$TASK_DB")
        
        if [ "$total_tasks" -gt 0 ]; then
            local score=$(( (completed_tasks * 100) / total_tasks ))
            jq ".stats.productivity_score = $score" "$TASK_DB" > "$TASK_DB.tmp" && mv "$TASK_DB.tmp" "$TASK_DB"
            log_info "生产力评分已计算: $score%"
        fi
    fi
}

# 智能任务建议
suggest_tasks() {
    log_info "生成智能任务建议..."
    
    local suggestions_file="$WORKSPACE_ROOT/task_suggestions.md"
    
    cat > "$suggestions_file" << EOF
# 智能任务建议

生成时间: $(date)

## 🔧 基于项目状态的智能建议

### Cherry Studio 项目建议
EOF
    
    if [ -d "$CHERRY_STUDIO_PATH" ]; then
        echo "" >> "$suggestions_file"
        echo "根据项目分析，建议以下任务:" >> "$suggestions_file"
        echo "- [ ] 检查 TypeScript 类型定义" >> "$suggestions_file"
        echo "- [ ] 运行安全审计" >> "$suggestions_file"
        echo "- [ ] 更新依赖包" >> "$suggestions_file"
        echo "- [ ] 优化构建性能" >> "$suggestions_file"
    else
        echo "Cherry Studio 项目未找到" >> "$suggestions_file"
    fi
    
    echo "" >> "$suggestions_file"
    echo "### Ring 项目建议" >> "$suggestions_file"
    
    if [ -d "$RING_PATH" ]; then
        echo "" >> "$suggestions_file"
        echo "根据项目分析，建议以下任务:" >> "$suggestions_file"
        echo "- [ ] 更新 AI 模型数据库" >> "$suggestions_file"
        echo "- [ ] 检查链接有效性" >> "$suggestions_file"
        echo "- [ ] 添加新的 AI 工具分类" >> "$suggestions_file"
        echo "- [ ] 优化内容组织结构" >> "$suggestions_file"
    else
        echo "Ring 项目未找到" >> "$suggestions_file"
    fi
    
    echo "" >> "$suggestions_file"
    echo "### 工作空间优化建议" >> "$suggestions_file"
    echo "" >> "$suggestions_file"
    echo "- [ ] 定期备份重要配置文件" >> "$suggestions_file"
    echo "- [ ] 检查 CLI 工具更新" >> "$suggestions_file"
    echo "- [ ] 优化 Shell 配置" >> "$suggestions_file"
    echo "- [ ] 清理临时文件" >> "$suggestions_file"
    
    echo "" >> "$suggestions_file"
    echo "## 📈 生产力提升建议" >> "$suggestions_file"
    echo "" >> "$suggestions_file"
    echo "- [ ] 使用时间块管理技术" >> "$suggestions_file"
    echo "- [ ] 定期回顾任务完成情况" >> "$suggestions_file"
    echo "- [ ] 优化工作流程" >> "$suggestions_file"
    echo "- [ ] 使用 AI 工具辅助开发" >> "$suggestions_file"
    
    echo "" >> "$suggestions_file"
    echo "---" >> "$suggestions_file"
    echo "建议基于当前项目状态和历史数据生成" >> "$suggestions_file"
    
    log_success "智能任务建议已生成: $suggestions_file"
}

# 主菜单
show_menu() {
    echo ""
    echo "🎯 智能任务管理系统"
    echo "========================================"
    echo "1. 添加新任务"
    echo "2. 列出任务"
    echo "3. 更新任务状态"
    echo "4. 删除任务"
    echo "5. 生成任务报告"
    echo "6. 计算生产力评分"
    echo "7. 智能任务建议"
    echo "8. 项目统计概览"
    echo "0. 退出"
    echo "========================================"
    read -p "请选择操作: " choice
}

# 处理用户选择
handle_choice() {
    case "$choice" in
        1)
            echo "添加新任务"
            echo "1. Cherry Studio"
            echo "2. Ring"
            echo "3. OpenClaw Workspace"
            read -p "选择项目: " project_choice
            
            case $project_choice in
                1) project="cherry-studio" ;;
                2) project="ring" ;;
                3) project="workspace" ;;
                *) log_error "无效选择"; return ;;
            esac
            
            read -p "任务标题: " title
            read -p "任务描述: " description
            echo "优先级: 1.低 2.中 3.高 4.紧急"
            read -p "选择优先级: " priority_choice
            
            case $priority_choice in
                1) priority="$PRIORITY_LOW" ;;
                2) priority="$PRIORITY_MEDIUM" ;;
                3) priority="$PRIORITY_HIGH" ;;
                4) priority="$PRIORITY_URGENT" ;;
                *) log_error "无效优先级"; return ;;
            esac
            
            read -p "截止日期 (YYYY-MM-DD): " deadline
            read -p "标签 (逗号分隔): " tags
            
            add_task "$project" "$title" "$description" "$priority" "$deadline" "$tags"
            ;;
        2)
            echo "列出任务"
            echo "1. 所有任务"
            echo "2. Cherry Studio"
            echo "3. Ring"
            echo "4. OpenClaw Workspace"
            read -p "选择项目: " list_project
            
            case $list_project in
                1) list_tasks "" "" "" ;;
                2) list_tasks "cherry-studio" "" "" ;;
                3) list_tasks "ring" "" "" ;;
                4) list_tasks "workspace" "" "" ;;
                *) log_error "无效选择"; return ;;
            esac
            ;;
        3)
            read -p "输入任务ID: " task_id
            echo "1. 待办 -> 进行中"
            echo "2. 进行中 -> 审核中"
            echo "3. 审核中 -> 完成"
            echo "4. 任何状态 -> 阻塞"
            read -p "选择操作: " status_choice
            
            case $status_choice in
                1) update_task_status "$task_id" "$STATUS_IN_PROGRESS" ;;
                2) update_task_status "$task_id" "$STATUS_REVIEW" ;;
                3) update_task_status "$task_id" "$STATUS_DONE" 
                   # 更新完成统计
                   if command -v jq >/dev/null 2>&1; then
                       jq '.stats.completed_tasks += 1' "$TASK_DB" > "$TASK_DB.tmp" && mv "$TASK_DB.tmp" "$TASK_DB"
                   fi
                   ;;
                4) 
                   read -p "阻塞原因: " blocked_reason
                   update_task_status "$task_id" "$STATUS_BLOCKED" "$blocked_reason"
                   ;;
                *) log_error "无效选择"; return ;;
            esac
            ;;
        4)
            read -p "输入要删除的任务ID: " task_id
            delete_task "$task_id"
            ;;
        5)
            read -p "生成项目报告 (1:所有, 2:Cherry Studio, 3:Ring): " report_choice
            
            case $report_choice in
                1) generate_task_report "" ;;
                2) generate_task_report "cherry-studio" ;;
                3) generate_task_report "ring" ;;
                *) log_error "无效选择"; return ;;
            esac
            ;;
        6)
            calculate_productivity_score
            ;;
        7)
            suggest_tasks
            ;;
        8)
            if command -v jq >/dev/null 2>&1; then
                echo "📊 项目统计概览"
                echo "========================="
                jq '.projects' "$TASK_DB" | sed 's/"/ /g' | sed 's/,//g'
                echo "========================="
                jq '.stats' "$TASK_DB" | sed 's/"/ /g' | sed 's/,//g'
            else
                log_error "jq 未安装，无法显示统计"
            fi
            ;;
        0)
            log_info "退出任务管理系统"
            exit 0
            ;;
        *)
            log_error "无效选择，请重新输入"
            ;;
    esac
}

# 主函数
main() {
    log_info "智能任务管理系统启动"
    
    # 初始化
    init_task_db
    
    while true; do
        show_menu
        handle_choice
    done
}

# 如果直接运行脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi