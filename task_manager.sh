#!/usr/bin/env bash
# 孔明智能助手 - 任务管理脚本
# 简单的任务跟踪和提醒系统

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# 任务存储文件
TASK_FILE="$HOME/.kongming_tasks"
TODO_FILE="$HOME/.kongming_todo"
DONE_FILE="$HOME/.kongming_done"

# 确保任务文件存在
mkdir -p "$(dirname "$TASK_FILE")"
touch "$TASK_FILE" "$TODO_FILE" "$DONE_FILE"

# 显示帮助信息
show_help() {
    echo -e "${CYAN}孔明智能助手 - 任务管理脚本${NC}"
    echo "用法: $0 <命令> [选项]"
    echo
    echo "命令:"
    echo "  add <任务描述>     - 添加新任务"
    echo "  list              - 显示所有任务"
    echo "  today             - 显示今日任务"
    echo "  todo              - 显示待办任务"
    echo "  done              - 显示已完成任务"
    echo "  complete <编号>    - 完成指定任务"
    echo "  delete <编号>     - 删除指定任务"
    echo "  clear             - 清空所有任务"
    echo "  report            - 生成任务报告"
    echo "  remind            - 任务提醒"
    echo
    echo "示例:"
    echo "  $0 add '完成项目文档'"
    echo "  $0 list"
    echo "  $0 complete 1"
}

# 添加任务
add_task() {
    local task_description="$1"
    if [ -z "$task_description" ]; then
        echo -e "${RED}错误: 请提供任务描述${NC}"
        return 1
    fi
    
    local task_id
    task_id=$(date +%s%N)
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    echo "$task_id|$timestamp|$task_description" >> "$TASK_FILE"
    
    echo -e "${GREEN}✅ 任务已添加: $task_description${NC}"
    echo -e "${YELLOW}任务ID: $task_id${NC}"
    echo -e "${YELLOW}添加时间: $timestamp${NC}"
}

# 显示所有任务
list_tasks() {
    if [ ! -s "$TASK_FILE" ]; then
        echo -e "${YELLOW}📝 暂无任务${NC}"
        return 0
    fi
    
    echo -e "${CYAN}=== 所有任务 ===${NC}"
    echo -e "${BLUE}ID       | 时间                | 任务描述${NC}"
    echo -e "${BLUE}---------|---------------------|----------${NC}"
    
    sort "$TASK_FILE" | while IFS='|' read -r task_id timestamp description; do
        local status="📋"
        if grep -q "^$task_id" "$DONE_FILE"; then
            status="✅"
        elif grep -q "^$task_id" "$TODO_FILE"; then
            status="⏰"
        fi
        
        echo -e "${PURPLE}$task_id${NC} | $timestamp | ${status} $description"
    done
}

# 显示今日任务
today_tasks() {
    local today
    today=$(date "+%Y-%m-%d")
    
    echo -e "${CYAN}=== 今日任务 ($(date "+%Y年%m月%d日")) ===${NC}"
    
    local has_task=false
    sort "$TASK_FILE" | while IFS='|' read -r task_id timestamp description; do
        if [[ "$timestamp" == *"$today"* ]]; then
            echo -e "${PURPLE}[$task_id]${NC} $description (${BLUE}添加于 $timestamp${NC})"
            has_task=true
        fi
    done
    
    if [ "$has_task" = false ]; then
        echo -e "${YELLOW}🎉 今日暂无任务${NC}"
    fi
}

# 显示待办任务
todo_tasks() {
    echo -e "${CYAN}=== 待办任务 ===${NC}"
    
    local count=0
    while IFS='|' read -r task_id timestamp description; do
        if ! grep -q "^$task_id" "$DONE_FILE" && ! grep -q "^$task_id" "$TODO_FILE"; then
            echo -e "${PURPLE}[$((++count))]${NC} $description (${BLUE}添加于 $timestamp${NC})"
        fi
    done < <(sort "$TASK_FILE")
    
    if [ "$count" -eq 0 ]; then
        echo -e "${YELLOW}🎉 所有任务已完成或已标记${NC}"
    fi
}

# 显示已完成任务
completed_tasks() {
    echo -e "${CYAN}=== 已完成任务 ===${NC}"
    
    local count=0
    while IFS='|' read -r task_id timestamp description; do
        local done_timestamp
        done_timestamp=$(grep "^$task_id" "$DONE_FILE" | cut -d'|' -f2)
        echo -e "${GREEN}[$((++count))]${NC} $description (${BLUE}添加于 $timestamp${NC} | ${GREEN}完成于 $done_timestamp${NC})"
    done < <(sort "$TASK_FILE")
    
    if [ "$count" -eq 0 ]; then
        echo -e "${YELLOW}📝 尚未完成任务${NC}"
    fi
}

# 标记任务完成
complete_task() {
    local task_id="$1"
    if [ -z "$task_id" ]; then
        echo -e "${RED}错误: 请提供任务ID${NC}"
        return 1
    fi
    
    if ! grep -q "^$task_id" "$TASK_FILE"; then
        echo -e "${RED}错误: 任务ID $task_id 不存在${NC}"
        return 1
    fi
    
    local done_timestamp
    done_timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "$task_id|$done_timestamp" >> "$DONE_FILE"
    
    # 从待办中移除
    if grep -q "^$task_id" "$TODO_FILE"; then
        grep -v "^$task_id" "$TODO_FILE" > "$TODO_FILE.tmp"
        mv "$TODO_FILE.tmp" "$TODO_FILE"
    fi
    
    echo -e "${GREEN}✅ 任务已完成${NC}"
}

# 删除任务
delete_task() {
    local task_id="$1"
    if [ -z "$task_id" ]; then
        echo -e "${RED}错误: 请提供任务ID${NC}"
        return 1
    fi
    
    if ! grep -q "^$task_id" "$TASK_FILE"; then
        echo -e "${RED}错误: 任务ID $task_id 不存在${NC}"
        return 1
    fi
    
    # 从任务文件中删除
    grep -v "^$task_id|" "$TASK_FILE" > "$TASK_FILE.tmp"
    mv "$TASK_FILE.tmp" "$TASK_FILE"
    
    # 从完成文件中删除
    if grep -q "^$task_id" "$DONE_FILE"; then
        grep -v "^$task_id" "$DONE_FILE" > "$DONE_FILE.tmp"
        mv "$DONE_FILE.tmp" "$DONE_FILE"
    fi
    
    # 从待办文件中删除
    if grep -q "^$task_id" "$TODO_FILE"; then
        grep -v "^$task_id" "$TODO_FILE" > "$TODO_FILE.tmp"
        mv "$TODO_FILE.tmp" "$TODO_FILE"
    fi
    
    echo -e "${GREEN}🗑️  任务已删除${NC}"
}

# 清空所有任务
clear_all_tasks() {
    echo -e "${RED}⚠️  确定要清空所有任务吗？(y/N)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        > "$TASK_FILE"
        > "$TODO_FILE"
        > "$DONE_FILE"
        echo -e "${GREEN}✅ 所有任务已清空${NC}"
    else
        echo -e "${YELLOW}取消操作${NC}"
    fi
}

# 生成任务报告
generate_report() {
    echo -e "${CYAN}=== 任务报告 ===${NC}"
    echo -e "${BLUE}生成时间: $(date "+%Y-%m-%d %H:%M:%S")${NC}"
    echo
    
    local total_tasks
    total_tasks=$(wc -l < "$TASK_FILE")
    
    local completed_tasks
    completed_tasks=$(wc -l < "$DONE_FILE")
    
    local todo_tasks
    todo_tasks=$(wc -l < "$TODO_FILE")
    
    echo -e "${PURPLE}总任务数: $total_tasks${NC}"
    echo -e "${GREEN}已完成: $completed_tasks${NC}"
    echo -e "${YELLOW}待办: $todo_tasks${NC}"
    echo -e "${BLUE}进度: $((completed_tasks * 100 / total_tasks))%${NC}"
    echo
    
    echo -e "${CYAN}任务分布:${NC}"
    echo -e "${BLUE}今日任务:$(date "+%Y-%m-%d")${NC}"
    
    local today_count=0
    local today
    today=$(date "+%Y-%m-%d")
    while IFS='|' read -r task_id timestamp description; do
        if [[ "$timestamp" == *"$today"* ]]; then
            ((today_count++))
        fi
    done < <(sort "$TASK_FILE")
    
    echo -e "${PURPLE}今日任务数: $today_count${NC}"
    
    # 显示最近的任务
    echo -e "${CYAN}最近5个任务:${NC}"
    sort "$TASK_FILE" | tail -5 | while IFS='|' read -r task_id timestamp description; do
        local status="📋"
        if grep -q "^$task_id" "$DONE_FILE"; then
            status="✅"
        elif grep -q "^$task_id" "$TODO_FILE"; then
            status="⏰"
        fi
        echo -e "${PURlace}[$task_id]${NC} $status $description"
    done
}

# 任务提醒
remind_tasks() {
    echo -e "${CYAN}=== 任务提醒 ===${NC}"
    
    local today
    today=$(date "+%Y-%m-%d")
    
    echo -e "${YELLOW}今日任务提醒:${NC}"
    local has_today_task=false
    while IFS='|' read -r task_id timestamp description; do
        if [[ "$timestamp" == *"$today"* ]]; then
            echo -e "${PURPLE}[$task_id]${NC} ⏰ $description"
            has_today_task=true
        fi
    done < <(sort "$TASK_FILE")
    
    if [ "$has_today_task" = false ]; then
        echo -e "${GREEN}🎉 今日暂无任务${NC}"
    fi
    
    # 检查逾期任务
    echo -e "${YELLOW}逾期任务提醒:${NC}"
    local yesterday
    yesterday=$(date -v-1d "+%Y-%m-%d")
    local has_overdue=false
    
    while IFS='|' read -r task_id timestamp description; do
        local task_date="${timestamp:0:10}"
        if [[ "$task_date" < "$yesterday" ]] && ! grep -q "^$task_id" "$DONE_FILE"; then
            echo -e "${RED}[$task_id]${NC} ⚠️  $description (${RED}逾期${NC})"
            has_overdue=true
        fi
    done < <(sort "$TASK_FILE")
    
    if [ "$has_overdue" = false ]; then
        echo -e "${GREEN}✅ 无逾期任务${NC}"
    fi
}

# 标记任务为待办
mark_todo() {
    local task_id="$1"
    if [ -z "$task_id" ]; then
        echo -e "${RED}错误: 请提供任务ID${NC}"
        return 1
    fi
    
    if ! grep -q "^$task_id" "$TASK_FILE"; then
        echo -e "${RED}错误: 任务ID $task_id 不存在${NC}"
        return 1
    fi
    
    local todo_timestamp
    todo_timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "$task_id|$todo_timestamp" >> "$TODO_FILE"
    
    # 从完成中移除
    if grep -q "^$task_id" "$DONE_FILE"; then
        grep -v "^$task_id" "$DONE_FILE" > "$DONE_FILE.tmp"
        mv "$DONE_FILE.tmp" "$DONE_FILE"
    fi
    
    echo -e "${YELLOW}⏰ 任务已标记为待办${NC}"
}

# 主函数
main() {
    local command="$1"
    shift
    
    case "$command" in
        "add")
            add_task "$@"
            ;;
        "list")
            list_tasks
            ;;
        "today")
            today_tasks
            ;;
        "todo")
            todo_tasks
            ;;
        "done")
            completed_tasks
            ;;
        "complete")
            complete_task "$@"
            ;;
        "delete")
            delete_task "$@"
            ;;
        "clear")
            clear_all_tasks
            ;;
        "report")
            generate_report
            ;;
        "remind")
            remind_tasks
            ;;
        "mark-todo")
            mark_todo "$@"
            ;;
        "help"|"--help"|"-h"|"")
            show_help
            ;;
        *)
            echo -e "${RED}错误: 未知命令 '$command'${NC}"
            echo
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"