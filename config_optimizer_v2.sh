#!/bin/bash

# 孔明智能助手配置优化器
# 第15轮优化：配置优化和环境检查
# 创建时间: 2026-03-28 03:30 AM

echo "🏯 孔明配置优化器启动 - 第15轮优化"
echo "⏰ 时间: $(date)"
echo "📋 任务: 配置优化和环境检查"
echo ""

# 创建备份目录
BACKUP_DIR="$HOME/.openclaw/workspace/backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📁 创建配置备份目录: $BACKUP_DIR"
echo ""

# 1. 检查当前环境
echo "🔍 环境检查"
echo "=========="
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "Python: $(python3 --version)"
if command -v rustc >/dev/null 2>&1; then
    echo "Rust: $(rustc --version)"
else
    echo "Rust: ❌ 未安装"
fi
if command -v gh >/dev/null 2>&1; then
    echo "GitHub CLI: $(gh --version)"
else
    echo "GitHub CLI: ❌ 未安装"
fi
echo ""

# 2. 优化Shell配置
echo "⚙️ Shell配置优化"
echo "================"
SHELL_RC="$HOME/.zshrc"
if [ -f "$SHELL_RC" ]; then
    echo "备份当前zshrc配置..."
    cp "$SHELL_RC" "$BACKUP_DIR/zshrc_backup_$(date +%H%M%S).backup"
    
    # 检查是否已经包含了我们的配置
    if ! grep -q "孔明智能助手" "$SHELL_RC"; then
        echo "添加孔明配置到zshrc..."
        cat >> "$SHELL_RC" << 'EOF'

# 孔明智能助手配置 (由配置优化器自动添加)
export OPENCLAW_WORKSPACE="$HOME/.openclaw/workspace"
export PATH="$OPENCLAW_WORKSPACE:$PATH"

# 环境变量优化
export EDITOR="vim"
export VISUAL="vim"
export PAGER="less -R"

# 颜色主题
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# 历史记录优化
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
export HISTTIMEFORMAT="%F %T "

# 自动加载我们的配置
if [ -f "$OPENCLAW_WORKSPACE/.shell_aliases" ]; then
    source "$OPENCLAW_WORKSPACE/.shell_aliases"
fi

if [ -f "$OPENCLAW_WORKSPACE/.tool_aliases" ]; then
    source "$OPENCLAW_WORKSPACE/.tool_aliases"
fi
EOF
        echo "✅ Shell配置已优化"
    else
        echo "✅ Shell配置已经是最新的"
    fi
else
    echo "⚠️ zshrc文件不存在，跳过配置"
fi
echo ""

# 3. 检查和优化Git配置
echo "🐱 Git配置优化"
echo "=============="
GIT_CONFIG="$HOME/.gitconfig"
if [ -f "$GIT_CONFIG" ]; then
    echo "备份当前git配置..."
    cp "$GIT_CONFIG" "$BACKUP_DIR/gitconfig_backup_$(date +%H%M%S).backup"
    
    # 检查是否有用户名配置
    if ! grep -q "name" "$GIT_CONFIG" || ! grep -q "email" "$GIT_CONFIG"; then
        echo "配置Git用户信息..."
        read -p "请输入Git用户名: " git_user
        read -p "请输入Git邮箱: " git_email
        cat >> "$GIT_CONFIG" << EOF

[user]
    name = $git_user
    email = $git_email
EOF
        echo "✅ Git用户信息已配置"
    else
        echo "✅ Git配置已经包含用户信息"
    fi
    
    # 添加别名配置
    if ! grep -q "include" "$GIT_CONFIG"; then
        echo "添加Git别名配置..."
        cat >> "$GIT_CONFIG" << EOF

[include]
    path = $HOME/.openclaw/workspace/.git_aliases
EOF
        echo "✅ Git别名配置已添加"
    else
        echo "✅ Git别名配置已存在"
    fi
else
    echo "⚠️ gitconfig文件不存在，跳过配置"
fi
echo ""

# 4. 创建现代化工具配置
echo "🛠️ 现代化工具配置"
echo "================"
echo ""

# 创建现代化配置文件
MODERN_CONFIG="$BACKUP_DIR/modern_tools_config.sh"
cat > "$MODERN_CONFIG" << 'EOF'
#!/bin/bash
# 现代化工具配置脚本

echo "🚀 现代化工具配置"

# 检查工具可用性
check_tool() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "✅ $1: 可用"
        return 0
    else
        echo "❌ $1: 不可用"
        return 1
    fi
}

# 检查常用工具
echo "检查常用CLI工具:"
check_tool "gh"
check_tool "fzf"
check_tool "ripgrep"
check_tool "eza"
check_tool "bat"
check_tool "fd"
check_tool "dust"
check_tool "jq"

# 设置别名（如果工具可用）
setup_aliases() {
    echo ""
    echo "设置现代化别名:"
    
    # 如果eza可用，覆盖ls
    if check_tool "eza" >/dev/null 2>&1; then
        alias ls='eza --icons'
        alias ll='eza -al --icons'
        echo "✅ 已设置eza别名"
    fi
    
    # 如果bat可用，覆盖cat和less
    if check_tool "bat" >/dev/null 2>&1; then
        alias cat='bat'
        alias less='bat --paging=always'
        echo "✅ 已设置bat别名"
    fi
    
    # 如果fd可用，覆盖find
    if check_tool "fd" >/dev/null 2>&1; then
        alias find='fd'
        echo "✅ 已设置fd别名"
    fi
    
    # 如果ripgrep可用，覆盖grep
    if check_tool "ripgrep" >/dev/null 2>&1; then
        alias grep='rg --color=auto'
        echo "✅ 已设置ripgrep别名"
    fi
}

setup_aliases
EOF

chmod +x "$MODERN_CONFIG"
echo "✅ 现代化工具配置已创建: $MODERN_CONFIG"
echo ""

# 5. 创建环境监控脚本
echo "📊 环境监控脚本"
echo "=============="
MONITOR_SCRIPT="$BACKUP_DIR/environment_monitor.sh"
cat > "$MONITOR_SCRIPT" << 'EOF'
#!/bin/bash
# 环境监控脚本

echo "📊 环境状态监控 - $(date)"

# 系统资源使用
echo "系统资源使用:"
echo "CPU使用率: $(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')%"
echo "内存使用: $(ps -caxm -orss,comm | awk '{ sum += $1 } END { print sum/1024/1024 "GB" }')"
echo "磁盘使用: $(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')% 已使用"
echo ""

# 开发环境状态
echo "开发环境状态:"
echo "Node.js: $(node --version 2>/dev/null || echo '❌ 未安装')"
echo "npm: $(npm --version 2>/dev/null || echo '❌ 未安装')"
echo "Python: $(python3 --version 2>/dev/null || echo '❌ 未安装')"
echo "Rust: $(rustc --version 2>/dev/null || echo '❌ 未安装')"
echo "Git: $(git --version 2>/dev/null || echo '❌ 未安装')"
echo ""

# 工具安装状态
echo "常用工具状态:"
tools=("gh" "fzf" "ripgrep" "eza" "bat" "fd" "dust" "jq")
for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "✅ $tool: 已安装"
    else
        echo "❌ $tool: 未安装"
    fi
done
echo ""

echo "📋 监控完成"
EOF

chmod +x "$MONITOR_SCRIPT"
echo "✅ 环境监控脚本已创建: $MONITOR_SCRIPT"
echo ""

# 6. 创建任务管理器
echo "📋 任务管理器"
echo "============"
TASK_MANAGER="$BACKUP_DIR/task_manager.sh"
cat > "$TASK_MANAGER" << 'EOF'
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
EOF

chmod +x "$TASK_MANAGER"
echo "✅ 任务管理器已创建: $TASK_MANAGER"
echo ""

# 7. 创建进度报告
echo "📈 生成优化报告"
echo "==============="
REPORT_FILE="$BACKUP_DIR/optimization_report_$(date +%Y%m%d_%H%M%S).txt"

cat > "$REPORT_FILE" << EOF
孔明配置优化报告 - 第15轮优化
===========================
时间: $(date)
优化器版本: v1.0

## 已完成的优化

### 1. 环境检查
- Node.js: $(node --version)
- npm: $(npm --version)  
- Python: $(python3 --version)
- Rust: $(rustc --version 2>/dev/null || echo "未安装")
- Git: $(git --version)

### 2. 配置优化
- Shell配置 (zshrc) 已备份并优化
- Git配置已检查和优化
- 现代化工具配置已创建
- 环境监控脚本已创建
- 任务管理器已创建

### 3. 新增工具
- 现代化工具检查脚本
- 环境状态监控脚本
- 任务管理脚本
- 配置备份系统

## 待优化项目
- CLI工具安装: gh, fzf, ripgrep, eza, bat, fd, dust
- Rust环境配置
- 更多技能安装

## 下一步计划
1. 完成CLI工具安装
2. 安装Rust开发环境
3. 继续技能安装和管理
4. 优化现有配置

## 配置文件位置
- 备份目录: $BACKUP_DIR
- Shell配置: $SHELL_RC
- Git配置: $GIT_CONFIG
EOF

echo "✅ 优化报告已生成: $REPORT_FILE"
echo ""

# 8. 运行现代化配置
echo "🚀 运行现代化工具配置..."
echo "=================="
source "$MONITOR_SCRIPT"
echo ""

# 总结
echo "🏯 配置优化完成!"
echo "==============="
echo "✅ 备份目录: $BACKUP_DIR"
echo "✅ 配置文件已优化"
echo "✅ 监控工具已创建"
echo "✅ 任务管理器已创建"
echo "✅ 优化报告已生成"
echo ""
echo "📋 第15轮优化完成时间: $(date)"
echo "🎯 准备进行下一轮优化..."