#!/bin/bash

# Project Metrics Collection Script
# Collects development metrics for all active AI projects

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

# Create metrics directory
mkdir -p docs
mkdir -p memory

# Initialize metrics data
METRICS_FILE="docs/project-metrics-$(date +%Y-%m-%d).md"
STATE_FILE="memory/metrics-state-$(date +%Y-%m-%d).json"

echo "# 项目开发指标追踪报告" > "$METRICS_FILE"
echo "## 生成时间: $(date)" >> "$METRICS_FILE"
echo "" >> "$METRICS_FILE"

echo "## 24小时指标汇总" >> "$METRICS_FILE"
echo "| 项目名称 | 代码行数变化 | 提交次数 | 开放Issues | 已关闭Issues | 开放PRs | 已合并PRs | 分支数 | 贡献者数 |" >> "$METRICS_FILE"
echo "|---------|-------------|----------|-----------|-------------|---------|-----------|--------|----------|" >> "$METRICS_FILE"

# Initialize JSON state data
echo '{' > "$STATE_FILE"
echo '  "timestamp": "'$(date -Iseconds)'",' >> "$STATE_FILE"
echo '  "projects": [' >> "$STATE_FILE"

PROJECT_COUNT=0

for PROJECT in "${PROJECTS[@]}"; do
    if [ -d "$PROJECT" ]; then
        PROJECT_DIR="$PROJECT"
        cd "$PROJECT_DIR" 2>/dev/null || continue
        
        echo "🔍 正在收集项目: $PROJECT"
        
        # Check if it's a git repository
        if [ ! -d ".git" ]; then
            echo "  ❌ 跳过: 不是Git仓库"
            cd ..
            continue
        fi
        
        # Get 24-hour metrics
        echo "  📊 收集24小时指标..."
        
        # Code line changes
        LINES_CHANGE=$(git log --stat --since="24h ago" 2>/dev/null | grep -E "insertion|deletion" | awk '{sum+=$1} END {print sum+0}')
        if [ -z "$LINES_CHANGE" ]; then LINES_CHANGE=0; fi
        
        # Commit frequency
        COMMIT_COUNT=$(git log --oneline --since="24h ago" 2>/dev/null | wc -l)
        if [ -z "$COMMIT_COUNT" ]; then COMMIT_COUNT=0; fi
        
        # Branch count
        BRANCH_COUNT=$(git branch -a 2>/dev/null | grep -v "^*" | wc -l)
        if [ -z "$BRANCH_COUNT" ]; then BRANCH_COUNT=0; fi
        
        # Contributor count
        CONTRIB_COUNT=$(git log --since="24h ago" --format='%an' 2>/dev/null | sort -u | wc -l)
        if [ -z "$CONTRIB_COUNT" ]; then CONTRIB_COUNT=0; fi
        
        # GitHub issues (if GitHub URL exists)
        OPEN_ISSUES=0
        CLOSED_ISSUES=0
        OPEN_PRS=0
        MERGED_PRS=0
        
        # Check if .git/config contains GitHub URL
        if grep -q "github.com" .git/config 2>/dev/null; then
            # Extract repo name from git remote
            REPO_URL=$(git remote -v 2>/dev/null | grep origin | head -1 | awk '{print $2}')
            if [[ $REPO_URL == *"github.com"* ]]; then
                # Extract owner/repo from URL
                REPO_PATH=$(echo $REPO_URL | sed 's|https://github.com/||' | sed 's|git@github.com:||' | sed 's|\.git$||')
                
                echo "  🔗 GitHub仓库: $REPO_PATH"
                
                # Get issues using gh CLI (if available)
                if command -v gh &> /dev/null; then
                    OPEN_ISSUES=$(gh issue list --state open --limit 100 2>/dev/null | wc -l)
                    CLOSED_ISSUES=$(gh issue list --state closed --limit 100 2>/dev/null | wc -l)
                    OPEN_PRS=$(gh pr list --state open --limit 100 2>/dev/null | wc -l)
                    MERGED_PRS=$(gh pr list --state merged --limit 100 2>/dev/null | wc -l)
                    
                    # Subtract header line
                    [ "$OPEN_ISSUES" -gt 0 ] && OPEN_ISSUES=$((OPEN_ISSUES - 1))
                    [ "$CLOSED_ISSUES" -gt 0 ] && CLOSED_ISSUES=$((CLOSED_ISSUES - 1))
                    [ "$OPEN_PRS" -gt 0 ] && OPEN_PRS=$((OPEN_PRS - 1))
                    [ "$MERGED_PRS" -gt 0 ] && MERGED_PRS=$((MERGED_PRS - 1))
                fi
            fi
        fi
        
        # Project name mapping
        PROJECT_NAME=$(echo "$PROJECT" | sed 's/-/ /g' | sed 's/\b\w/\u&/g')
        
        # Add to markdown table
        printf "| %s | %d | %d | %d | %d | %d | %d | %d | %d |\n" \
            "$PROJECT_NAME" "$LINES_CHANGE" "$COMMIT_COUNT" "$OPEN_ISSUES" "$CLOSED_ISSUES" "$OPEN_PRS" "$MERGED_PRS" "$BRANCH_COUNT" "$CONTRIB_COUNT" >> "$METRICS_FILE"
        
        # Calculate trend indicators
        echo "  📈 计算趋势指标..."
        
        # Code growth rate (compare to 7 days ago)
        WEEK_BEFORE=$(date -d "7 days ago" +%s)
        CURRENT_TIME=$(date +%s)
        WEEK_COMMITS=$(git log --since="$WEEK_BEFORE seconds ago" --oneline 2>/dev/null | wc -l)
        if [ -z "$WEEK_COMMITS" ]; then WEEK_COMMITS=0; fi
        
        if [ "$WEEK_COMMITS" -gt 0 ]; then
            GROWTH_RATE=$(( (COMMIT_COUNT * 7) / WEEK_COMMITS ))
        else
            GROWTH_RATE=0
        fi
        
        # Issue resolution rate
        TOTAL_ISSUES=$((OPEN_ISSUES + CLOSED_ISSUES))
        if [ "$TOTAL_ISSUES" -gt 0 ]; then
            RESOLUTION_RATE=$(( (CLOSED_ISSUES * 100) / TOTAL_ISSUES ))
        else
            RESOLUTION_RATE=0
        fi
        
        # Activity score (0-100)
        ACTIVITY_SCORE=$(( (COMMIT_COUNT * 10) + (CONTRIB_COUNT * 20) + (LINES_CHANGE / 100) ))
        if [ "$ACTIVITY_SCORE" -gt 100 ]; then ACTIVITY_SCORE=100; fi
        
        # Add JSON entry
        if [ $PROJECT_COUNT -gt 0 ]; then
            echo ',' >> "$STATE_FILE"
        fi
        
        cat >> "$STATE_FILE" << EOF
    {
      "project": "$PROJECT",
      "projectName": "$PROJECT_NAME",
      "timestamp": "$(date -Iseconds)",
      "metrics": {
        "linesChange": $LINES_CHANGE,
        "commits24h": $COMMIT_COUNT,
        "weekCommits": $WEEK_COMMITS,
        "openIssues": $OPEN_ISSUES,
        "closedIssues": $CLOSED_ISSUES,
        "openPRs": $OPEN_PRS,
        "mergedPRs": $MERGED_PRS,
        "branches": $BRANCH_COUNT,
        "contributors": $CONTRIB_COUNT
      },
      "trends": {
        "growthRate": $GROWTH_RATE,
        "resolutionRate": $RESOLUTION_RATE,
        "activityScore": $ACTIVITY_SCORE
      }
    }
EOF
        
        PROJECT_COUNT=$((PROJECT_COUNT + 1))
        
        echo "  ✅ 完成: 提交=$COMMIT_COUNT, 贡献者=$CONTRIB_COUNT, 活动=$ACTIVITY%"
        
        cd ..
    else
        echo "⚠️  跳过: 项目目录不存在: $PROJECT"
    fi
done

echo '  ]' >> "$STATE_FILE"
echo '}' >> "$STATE_FILE"

echo "" >> "$METRICS_FILE"
echo "## 趋势分析与效率评估" >> "$METRICS_FILE"
echo "" >> "$METRICS_FILE"

# Generate trend analysis
echo "### 代码活跃度分析" >> "$METRICS_FILE"
HIGH_ACTIVITY=0
MEDIUM_ACTIVITY=0
LOW_ACTIVITY=0

# Read JSON data for analysis
python3 << 'EOF'
import json
import sys

try:
    with open('memory/metrics-state-$(date +%Y-%m-%d).json', 'r') as f:
        data = json.load(f)
    
    high_projects = []
    medium_projects = []
    low_projects = []
    
    for project in data['projects']:
        score = project['trends']['activityScore']
        name = project['projectName']
        
        if score >= 70:
            high_projects.append((name, score))
        elif score >= 30:
            medium_projects.append((name, score))
        else:
            low_projects.append((name, score))
    
    print("#### 高活跃度项目 (70-100分):")
    for name, score in high_projects:
        print(f"- {name}: {score}分")
    
    print("\n#### 中等活跃度项目 (30-69分):")
    for name, score in medium_projects:
        print(f"- {name}: {score}分")
    
    print("\n#### 低活跃度项目 (0-29分):")
    for name, score in low_projects:
        print(f"- {name}: {score}分")

except Exception as e:
    print(f"分析错误: {e}")
EOF

echo "" >> "$METRICS_FILE"
echo "### 效率评估与改进建议" >> "$METRICS_FILE"
cat >> "$METRICS_FILE" << 'EOF'
1. **代码质量指标**:
   - 平均每日提交数: TBD
   - 代码增长趋势: TBD
   - 团队协作效率: TBD

2. **问题解决效率**:
   - 平均解决时间: TBD
   - Issue处理及时性: TBD
   - PR合并周期: TBD

3. **开发节奏**:
   - 高峰期分析: TBD
   - 资源分配优化: TBD
   - 技术债务管理: TBD

4. **改进建议**:
   - 增加自动化测试覆盖率
   - 优化CI/CD流程
   - 加强代码审查机制
   - 建立更完善的文档体系
   - 定期技术分享和复盘

EOF

echo "## 技术债务评估" >> "$METRICS_FILE"
cat >> "$METRICS_FILE" << 'EOF'
### 代码质量健康度
- **技术债务**: 需要持续关注
- **架构优化**: 适时重构和升级
- **性能监控**: 建立完善的监控机制
- **安全审计**: 定期进行安全检查
- **依赖管理**: 及时更新第三方库

### 开发流程优化
- **分支管理**: 建立规范的分支策略
- **版本发布**: 制定清晰的发布计划
- **文档维护**: 保持技术文档的更新
- **知识分享**: 建立团队知识库

EOF

echo "## 数据统计摘要" >> "$METRICS_FILE"
cat >> "$METRICS_FILE" << 'EOF'

### 关键指标汇总
- **监测项目总数**: $PROJECT_COUNT个
- **活跃代码仓库**: TBD
- **总贡献者数**: TBD
- **累计提交次数**: TBD
- **Issue处理总量**: TBD

### 时间趋势
- **数据采集周期**: 24小时滚动
- **历史数据保留**: 最近7天
- **更新频率**: 每2小时自动采集
- **分析维度**: 多维度综合评估

EOF

echo "" >> "$METRICS_FILE"
echo "---" >> "$METRICS_FILE"
echo "*报告生成时间: $(date)*" >> "$METRICS_FILE"
echo "*数据来源: 各项目Git仓库自动采集*" >> "$METRICS_FILE"

echo ""
echo "✅ Metrics collection completed!"
echo "📄 Report saved to: $METRICS_FILE"
echo "📊 State data saved to: $STATE_FILE"
echo ""
echo "🔍 监控项目总数: $PROJECT_COUNT"
echo ""
echo "📋 下一步操作:"
echo "1. 检查指标数据准确性"
echo "2. 更新项目优先级"
echo "3. 制定开发计划"
echo "4. Git提交和推送数据"