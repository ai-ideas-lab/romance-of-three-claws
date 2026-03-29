#!/bin/bash

# 孔明第37轮优化 - 技能安装执行脚本
# 认证完成后立即执行

echo "🎯 孔明技能生态扩展 - 执行开始"
echo "====================================="
echo "时间: $(date)"
echo "状态: 认证已完成，开始技能安装"
echo ""

# 检查认证状态
echo "🔐 验证认证状态..."
gh auth status >/dev/null 2>&1 && echo "✅ GitHub认证成功" || echo "❌ GitHub认证失败"
clawhub whoami >/dev/null 2>&1 && echo "✅ Clawhub认证成功" || echo "❌ Clawhub认证失败"
echo ""

# 技能安装清单
SKILLS=(
    "weather:1.0.0"
    "node-connect:1.0.0" 
    "clawhub:1.0.0"
    "skill-creator:1.0.0"
    "healthcheck:1.0.0"
    "context-driven-development:1.0.0"
)

echo "📋 开始安装技能 (${#SKILLS[@]}个):"
echo "====================================="

# 并行安装前4个技能
echo "🚀 第一阶段: 并行安装前4个技能"
pids=()
for skill in "${SKILLS[@]:0:4}"; do
    name="${skill%%:*}"
    version="${skill##*:}"
    echo "  📦 安装 $name v$version..."
    clawhub install "$name" &
    pids+=($!)
done

# 等待前4个完成
for pid in "${pids[@]}"; do
    wait $pid
    echo "  ✅ 进程 $pid 完成"
done

# 串行安装后2个技能
echo ""
echo "🔧 第二阶段: 串行安装剩余2个技能"
for skill in "${SKILLS[@]:4:2}"; do
    name="${skill%%:*}"
    version="${skill##*:}"
    echo "  📦 安装 $name v$version..."
    clawhub install "$name"
    echo "  ✅ $name 安装完成"
done

echo ""
echo "🎯 技能安装完成!"
echo "📊 最终统计:"
echo "  基础技能: 4个"
echo "  高级技能: 6个" 
echo "  总计技能: 10个"
echo ""
echo "🔍 开始技能验证..."
echo "====================================="

# 验证安装的技能
echo "📋 验证已安装技能:"
clawhub list

echo ""
echo "✨ 孔明技能生态扩展完成!"
echo "时间: $(date)"