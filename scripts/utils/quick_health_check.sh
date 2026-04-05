#!/bin/bash

# 快速健康检查脚本 - 立即可用版本
# Quick Health Check - Immediate Version
# 作者: 孔明 - 2026-03-28

echo "=================================================="
echo "  快速健康检查 - 立即可用"
echo "  Quick Health Check - Immediate"
echo "=================================================="
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "执行者: 孔明"
echo "=================================================="
echo

# 基础环境检查
echo "🔍 基础环境检查:"
if command -v node >/dev/null 2>&1; then
    echo "  ✅ Node.js: $(node --version)"
else
    echo "  ❌ Node.js 未安装"
fi

if command -v npm >/dev/null 2>&1; then
    echo "  ✅ npm: $(npm --version)"
else
    echo "  ❌ npm 未安装"
fi

if command -v git >/dev/null 2>&1; then
    echo "  ✅ Git: $(git --version)"
else
    echo "  ❌ Git 未安装"
fi

if command -v python3 >/dev/null 2>&1; then
    echo "  ✅ Python: $(python3 --version)"
else
    echo "  ❌ Python3 未安装"
fi

# 开发工具检查
echo
echo "🔧 开发工具检查:"
tools_available=0
total_tools=8

if command -v kubectl >/dev/null 2>&1; then echo "  ✅ Kubernetes"; tools_available=$((tools_available + 1)); else echo "  ❌ Kubernetes"; fi
if command -v helm >/dev/null 2>&1; then echo "  ✅ Helm"; tools_available=$((tools_available + 1)); else echo "  ❌ Helm"; fi
if command -v gh >/dev/null 2>&1; then echo "  ✅ GitHub CLI"; tools_available=$((tools_available + 1)); else echo "  ❌ GitHub CLI"; fi
if command -v docker >/dev/null 2>&1; then echo "  ✅ Docker"; tools_available=$((tools_available + 1)); else echo "  ❌ Docker"; fi
if command -v rg >/dev/null 2>&1; then echo "  ✅ ripgrep"; tools_available=$((tools_available + 1)); else echo "  ❌ ripgrep"; fi
if command -v eza >/dev/null 2>&1; then echo "  ✅ eza"; tools_available=$((tools_available + 1)); else echo "  ❌ eza"; fi
if command -v bat >/dev/null 2>&1; then echo "  ✅ bat"; tools_available=$((tools_available + 1)); else echo "  ❌ bat"; fi
if command -v fd >/dev/null 2>&1; then echo "  ✅ fd"; tools_available=$((tools_available + 1)); else echo "  ❌ fd"; fi

echo
echo "工具可用性: $tools_available/$total_tools"

# 配置文件检查
echo
echo "📁 配置文件检查:"
if [[ -f ~/.shell_aliases ]]; then 
    alias_count=$(grep -c "^alias" ~/.shell_aliases 2>/dev/null || echo "0")
    echo "  ✅ Shell别名 ($alias_count个)"
else
    echo "  ❌ Shell别名"
fi

if [[ -f ~/.git_aliases ]]; then 
    git_alias_count=$(grep -c "^alias" ~/.git_aliases 2>/dev/null || echo "0")
    echo "  ✅ Git别名 ($git_alias_count个)"
else
    echo "  ❌ Git别名"
fi

if [[ -f ~/.vimrc ]]; then echo "  ✅ Vim配置"; else echo "  ❌ Vim配置"; fi

# 工作空间检查
echo
echo "📂 工作空间检查:"
if [[ -f AGENTS.md ]]; then echo "  ✅ AGENTS.md"; else echo "  ❌ AGENTS.md"; fi
if [[ -f USER.md ]]; then echo "  ✅ USER.md"; else echo "  ❌ USER.md"; fi
if [[ -f SOUL.md ]]; then echo "  ✅ SOUL.md"; else echo "  ❌ SOUL.md"; fi
if [[ -f MEMORY.md ]]; then echo "  ✅ MEMORY.md"; else echo "  ❌ MEMORY.md"; fi
if [[ -d skills ]]; then 
    skill_count=$(find skills -name "*.md" -type f | wc -l)
    echo "  ✅ 技能目录 ($skill_count个技能)"
else
    echo "  ❌ 技能目录"
fi

echo
echo "=================================================="
echo "              快速总结"
echo "=================================================="

# 健康评分
health_score=100
if ! command -v node >/dev/null 2>&1; then health_score=$((health_score - 20)); fi
if ! command -v npm >/dev/null 2>&1; then health_score=$((health_score - 15)); fi
if ! command -v git >/dev/null 2>&1; then health_score=$((health_score - 25)); fi
if [[ ! -f ~/.shell_aliases ]]; then health_score=$((health_score - 10)); fi
if [[ ! -f ~/.git_aliases ]]; then health_score=$((health_score - 10)); fi

echo "健康分数: $health_score/100"

if [[ $health_score -ge 80 ]]; then
    echo "状态: ✅ 优秀"
elif [[ $health_score -ge 60 ]]; then
    echo "状态: ✅ 良好"
else
    echo "状态: ⚠️ 需要改进"
fi

echo
echo "🎯 下一步行动:"
echo "  1. 安装现代CLI工具: brew install gh fzf ripgrep eza bat fd dust"
echo "  2. 安装Docker: brew install --cask docker"
echo "  3. 安装更多OpenClaw技能"
echo "  4. 重新加载配置: source ~/.zshrc"
echo "  5. 测试新工具功能"

echo
echo "报告生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "执行者: 孔明"
echo "=================================================="