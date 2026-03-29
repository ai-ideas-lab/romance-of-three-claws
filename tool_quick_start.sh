# 工具快速启动脚本 - 自动生成于 Sat Mar 28 01:52:33 CST 2026
#!/bin/bash

# 检查并集成工具
source "/Users/wangshihao/.openclaw/workspace/.tool_aliases"

# 显示工具状态
check_all_tools

# 使用说明
echo ""
echo "📖 使用说明:"
echo "  source /Users/wangshihao/.openclaw/workspace/.tool_aliases  - 加载工具配置"
echo "  check_all_tools      - 检查所有工具状态"
echo 
echo "🔧 可用工具命令:"

# 设置执行权限
chmod +x "/Users/wangshihao/.openclaw/workspace/.tool_aliases"
