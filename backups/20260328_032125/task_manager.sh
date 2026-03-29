#!/bin/bash
# 任务管理器

TASKS_FILE="$HOME/.openclaw/workspace/tasks.txt"

if [ ! -f "$TASKS_FILE" ]; then
    touch "$TASKS_FILE"
fi

# 添加任务
add_task() {
    echo "$(date '+%Y-%m-%d %H:%M') - $1" >> "$TASKS_FILE"
    echo "✅ 任务已添加: $1"
}

# 列出任务
list_tasks() {
    echo "📋 待办任务:"
    echo "=========="
    if [ -s "$TASKS_FILE" ]; then
        cat -n "$TASKS_FILE"
    else
        echo "暂无任务"
    fi
}

# 完成任务
complete_task() {
    if [ -n "$1" ]; then
        sed -i "${1}d" "$TASKS_FILE"
        echo "✅ 任务 $1 已完成"
    fi
}

# 显示菜单
show_menu() {
    echo "任务管理器"
    echo "1. 添加任务"
    echo "2. 查看任务"
    echo "3. 完成任务"
    echo "4. 退出"
}

# 主循环
while true; do
    echo ""
    show_menu
    read -p "请选择操作 (1-4): " choice
    
    case $choice in
        1)
            read -p "请输入任务内容: " task_content
            add_task "$task_content"
            ;;
        2)
            list_tasks
            ;;
        3)
            list_tasks
            read -p "请输入要完成的任务编号: " task_num
            complete_task "$task_num"
            ;;
        4)
            echo "👋 再见!"
            break
            ;;
        *)
            echo "❌ 无效选择"
            ;;
    esac
done
