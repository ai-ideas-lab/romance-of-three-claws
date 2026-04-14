#!/bin/bash

# Project Metrics Collection Script
echo "📊 Starting Project Metrics Collection"
echo "Time: $(date)"
echo "=========================================="

# Define projects to track
PROJECTS=(
    "ai-appointment-manager"
    "ai-carbon-footprint-tracker"
    "ai-contract-reader"
    "ai-email-manager"
    "ai-error-diagnostician"
    "ai-gardening-designer"
    "ai-interview-coach"
    "ai-rental-detective"
    "ai-voice-notes-organizer"
    "ai-workspace-orchestrator"
    "code-knowledge-map-generator"
)

# Create directories
mkdir -p docs
mkdir -p memory

# Initialize metrics file
METRICS_FILE="docs/project-metrics-$(date +%Y-%m-%d).md"
echo "# 项目开发指标追踪报告" > "$METRICS_FILE"
echo "## 生成时间: $(date)" >> "$METRICS_FILE"
echo "" >> "$METRICS_FILE"

echo "## 24小时指标汇总" >> "$METRICS_FILE"
echo "| 项目名称 | 代码行数变化 | 提交次数 | 开放Issues | 已关闭Issues | 开放PRs | 已合并PRs | 分支数 | 贡献者数 |" >> "$METRICS_FILE"
echo "|---------|-------------|----------|-----------|-------------|---------|-----------|--------|----------|" >> "$METRICS_FILE"

PROJECT_COUNT=0

for PROJECT in "${PROJECTS[@]}"; do
    if [ -d "$PROJECT" ]; then
        echo "🔍 正在收集项目: $PROJECT"
        cd "$PROJECT" 2>/dev/null || continue
        
        # Check if git repo
        if [ ! -d ".git" ]; then
            echo "  ❌ 跳过: 不是Git仓库"
            cd ..
            continue
        fi
        
        # Get metrics
        LINES_CHANGE=$(git log --stat --since="24h ago" 2>/dev/null | grep -E "insertion|deletion" | awk '{sum+=$1} END {print sum+0}' || echo "0")
        COMMIT_COUNT=$(git log --oneline --since="24h ago" 2>/dev/null | wc -l || echo "0")
        BRANCH_COUNT=$(git branch -a 2>/dev/null | grep -v "^*" | wc -l || echo "0")
        CONTRIB_COUNT=$(git log --since="24h ago" --format='%an' 2>/dev/null | sort -u | wc -l || echo "0")
        
        # GitHub metrics
        OPEN_ISSUES=0
        CLOSED_ISSUES=0
        OPEN_PRS=0
        MERGED_PRS=0
        
        if grep -q "github.com" .git/config 2>/dev/null && command -v gh &> /dev/null; then
            REPO_URL=$(git remote -v 2>/dev/null | grep origin | head -1 | awk '{print $2}')
            if [[ $REPO_URL == *"github.com"* ]]; then
                OPEN_ISSUES=$(gh issue list --state open --limit 100 2>/dev/null | wc -l || echo "0")
                CLOSED_ISSUES=$(gh issue list --state closed --limit 100 2>/dev/null | wc -l || echo "0")
                OPEN_PRS=$(gh pr list --state open --limit 100 2>/dev/null | wc -l || echo "0")
                MERGED_PRS=$(gh pr list --state merged --limit 100 2>/dev/null | wc -l || echo "0")
                
                [ "$OPEN_ISSUES" -gt 0 ] && OPEN_ISSUES=$((OPEN_ISSUES - 1))
                [ "$CLOSED_ISSUES" -gt 0 ] && CLOSED_ISSUES=$((CLOSED_ISSUES - 1))
                [ "$OPEN_PRS" -gt 0 ] && OPEN_PRS=$((OPEN_PRS - 1))
                [ "$MERGED_PRS" -gt 0 ] && MERGED_PRS=$((MERGED_PRS - 1))
            fi
        fi
        
        # Format project name
        PROJECT_NAME=$(echo "$PROJECT" | sed 's/-/ /g' | sed 's/\b\w/\u&/g')
        
        # Add to table
        printf "| %s | %d | %d | %d | %d | %d | %d | %d | %d |\n" \
            "$PROJECT_NAME" "$LINES_CHANGE" "$COMMIT_COUNT" "$OPEN_ISSUES" "$CLOSED_ISSUES" "$OPEN_PRS" "$MERGED_PRS" "$BRANCH_COUNT" "$CONTRIB_COUNT" >> "$METRICS_FILE"
        
        echo "  ✅ 完成: 提交=$COMMIT_COUNT, 贡献者=$CONTRIB_COUNT"
        
        cd ..
        PROJECT_COUNT=$((PROJECT_COUNT + 1))
    else
        echo "⚠️  跳过: 项目目录不存在: $PROJECT"
    fi
done

echo "" >> "$METRICS_FILE"
echo "## 监控项目总数: $PROJECT_COUNT" >> "$METRICS_FILE"
echo "*报告生成时间: $(date)*" >> "$METRICS_FILE"

echo ""
echo "✅ Metrics collection completed!"
echo "📄 Report saved to: $METRICS_FILE"
echo "🔍 监控项目总数: $PROJECT_COUNT"