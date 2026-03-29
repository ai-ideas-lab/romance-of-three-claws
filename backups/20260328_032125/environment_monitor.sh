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
