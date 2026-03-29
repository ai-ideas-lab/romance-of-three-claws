#!/bin/bash

# 智能监控预警系统 - 第59轮优化
# 功能：多维度系统监控、智能预警、自动修复建议

echo "🔍 智能监控系统启动 - $(date)"
echo "================================"

# 颜色定义
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 监控结果变量
HEALTH_SCORE=100
ISSUES_FOUND=0
WARNINGS_FOUND=0

# 1. 系统资源监控
echo -e "${BLUE}📊 系统资源监控${NC}"
echo "--------------------------------"

# CPU使用率
CPU_USAGE=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}' | sed 's/%//')
if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
    echo -e "${RED}⚠️  CPU使用率过高: ${CPU_USAGE}%${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    HEALTH_SCORE=$((HEALTH_SCORE - 10))
elif (( $(echo "$CPU_USAGE > 60" | bc -l) )); then
    echo -e "${YELLOW}⚠️  CPU使用率较高: ${CPU_USAGE}%${NC}"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
    HEALTH_SCORE=$((HEALTH_SCORE - 5))
else
    echo -e "${GREEN}✅ CPU使用率正常: ${CPU_USAGE}%${NC}"
fi

# 内存使用率
MEMORY_INFO=$(vm_stat | grep "Pages free" | awk '{print $3}')
MEMORY_TOTAL=$(sysctl -n hw.memsize)
MEMORY_FREE=$((MEMORY_INFO * 4096)) # macOS页面大小为4KB，转换为字节
MEMORY_USED=$((MEMORY_TOTAL - MEMORY_FREE))
MEMORY_USAGE=$(echo "scale=1; $MEMORY_USED * 100 / $MEMORY_TOTAL" | bc -l)

if (( $(echo "$MEMORY_USAGE > 85" | bc -l) )); then
    echo -e "${RED}⚠️  内存使用率过高: ${MEMORY_USAGE}%${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    HEALTH_SCORE=$((HEALTH_SCORE - 15))
elif (( $(echo "$MEMORY_USAGE > 70" | bc -l) )); then
    echo -e "${YELLOW}⚠️  内存使用率较高: ${MEMORY_USAGE}%${NC}"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
    HEALTH_SCORE=$((HEALTH_SCORE - 8))
else
    echo -e "${GREEN}✅ 内存使用率正常: ${MEMORY_USAGE}%${NC}"
fi

# 磁盘使用率
DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 90 ]; then
    echo -e "${RED}⚠️  磁盘使用率过高: ${DISK_USAGE}%${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    HEALTH_SCORE=$((HEALTH_SCORE - 20))
elif [ "$DISK_USAGE" -gt 80 ]; then
    echo -e "${YELLOW}⚠️  磁盘使用率较高: ${DISK_USAGE}%${NC}"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
    HEALTH_SCORE=$((HEALTH_SCORE - 10))
else
    echo -e "${GREEN}✅ 磁盘使用率正常: ${DISK_USAGE}%${NC}"
fi

# 2. 服务状态监控
echo -e "\n${BLUE}🔧 服务状态监控${NC}"
echo "--------------------------------"

# OpenClaw服务状态
if pgrep -f "openclaw-gateway" > /dev/null; then
    echo -e "${GREEN}✅ OpenClaw Gateway 运行正常${NC}"
else
    echo -e "${RED}⚠️  OpenClaw Gateway 未运行${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    HEALTH_SCORE=$((HEALTH_SCORE - 15))
fi

# Node.js环境检查
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✅ Node.js ${NODE_VERSION} 可用${NC}"
else
    echo -e "${RED}⚠️  Node.js 未安装${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    HEALTH_SCORE=$((HEALTH_SCORE - 10))
fi

# Python环境检查
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✅ Python ${PYTHON_VERSION} 可用${NC}"
else
    echo -e "${RED}⚠️  Python 未安装${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    HEALTH_SCORE=$((HEALTH_SCORE - 10))
fi

# 3. 进程状态监控
echo -e "\n${BLUE}📈 进程状态监控${NC}"
echo "--------------------------------"

# 高CPU进程
echo "高CPU使用进程:"
top -l 1 -n 5 | grep -E "wangshihao" | while read -r line; do
    CPU=$(echo $line | awk '{print $3}')
    if (( $(echo "$CPU > 10" | bc -l) )); then
        echo "  - $(echo $line | awk '{print $11}'): ${CPU}%"
    fi
done

# 内存使用进程
echo "高内存使用进程:"
ps aux | sort -rk 4 | head -5 | while read -r line; do
    USER=$(echo $line | awk '{print $1}')
    if [ "$USER" = "wangshihao" ]; then
        MEM=$(echo $line | awk '{print $4}')
        CMD=$(echo $line | awk '{print $11}')
        echo "  - ${CMD}: ${MEM}%"
    fi
done

# 4. 网络状态监控
echo -e "\n${BLUE}🌐 网络状态监控${NC}"
echo "--------------------------------"

if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 网络连接正常${NC}"
else
    echo -e "${RED}⚠️  网络连接失败${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    HEALTH_SCORE=$((HEALTH_SCORE - 10))
    echo "   🔹 网络连接问题，建议:"
    echo "      - 检查网络连接"
    echo "      - 重启网络服务"
    echo "      - 检查代理设置"
fi

# 5. 智能修复建议
echo -e "\n${BLUE}💡 智能修复建议${NC}"
echo "================================"

if [ $ISSUES_FOUND -gt 0 ]; then
    echo -e "${RED}🚨 发现 ${ISSUES_FOUND} 个严重问题${NC}"
    
    if [ "$CPU_USAGE" -gt 80 ]; then
        echo "   🔹 CPU使用率过高，建议:"
        echo "      - 检查并结束不必要的进程"
        echo "      - 考虑优化高CPU使用率的程序"
    fi
    
    if [ "$DISK_USAGE" -gt 90 ]; then
        echo "   🔹 磁盘空间不足，建议:"
        echo "      - 清理临时文件和缓存"
        echo "      - 删除不需要的大型文件"
        echo "      - 考虑扩展磁盘容量"
    fi
    
    if ! pgrep -f "openclaw-gateway" > /dev/null; then
        echo "   🔹 OpenClaw Gateway未运行，建议:"
        echo "      - 启动OpenClaw服务: openclaw gateway start"
        echo "      - 检查服务配置文件"
    fi
fi

if [ $WARNINGS_FOUND -gt 0 ]; then
    echo -e "${YELLOW}⚠️  发现 ${WARNINGS_FOUND} 个警告${NC}"
    
    if [ "$MEMORY_USAGE" -gt 70 ]; then
        echo "   🔸 内存使用率较高，建议:"
        echo "      - 重启大型应用程序"
        echo "      - 检查内存泄漏问题"
    fi
fi

# 6. 健康评分
echo -e "\n${BLUE}📊 健康评分报告${NC}"
echo "================================"

if [ "$HEALTH_SCORE" -ge 90 ]; then
    echo -e "${GREEN}🏆 系统健康度: ${HEALTH_SCORE}/100 (优秀)${NC}"
elif [ "$HEALTH_SCORE" -ge 70 ]; then
    echo -e "${YELLOW}📈 系统健康度: ${HEALTH_SCORE}/100 (良好)${NC}"
elif [ "$HEALTH_SCORE" -ge 50 ]; then
    echo -e "${YELLOW}⚠️  系统健康度: ${HEALTH_SCORE}/100 (一般)${NC}"
else
    echo -e "${RED}🚨 系统健康度: ${HEALTH_SCORE}/100 (需要立即处理)${NC}"
fi

# 7. 系统信息汇总
echo -e "\n${BLUE}📋 系统信息汇总${NC}"
echo "================================"
echo "运行时间: $(uptime)"
echo "负载平均值: $(uptime | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//')"
echo "活跃用户: $(who | wc -l)"
echo "系统版本: $(sw_vers -productVersion)"

# 8. 优化建议
echo -e "\n${BLUE}🔮 优化建议${NC}"
echo "================================"

echo "基于当前系统状态，建议:"
echo "1. 🔄 定期清理系统缓存和临时文件"
echo "2. 📊 监控高CPU和内存使用进程"
echo "3. 🔧 保持OpenClaw服务正常运行"
echo "4. 💾 定期检查磁盘空间使用情况"
echo "5. 🌐 监控网络连接稳定性"

echo -e "\n${BLUE}✅ 监控完成 - $(date)${NC}"
echo "================================"