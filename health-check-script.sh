#!/bin/bash

# Daily Project Health Check Script
# Author: Kongming (AI Assistant)
# Date: 2026-04-07

PROJECT_DIR="/Users/wangshihao/projects/openclaws"
REPORT_DIR="$PROJECT_DIR/docs"
TODAY=$(date +%Y-%m-%d)
REPORT_FILE="$REPORT_DIR/health-check-$TODAY.md"

# Create docs directory if it doesn't exist
mkdir -p "$REPORT_DIR"

# Initialize report
cat > "$REPORT_FILE" << EOF
# 项目健康巡检报告
**日期:** $TODAY  
**巡检时间:** $(date)  
**巡检项目:** AI Ideas Lab 项目列表

---

## 项目健康状态概览

| 状态 | 数量 | 项目 |
|------|------|------|
| 🟢 健康 | 0 | - |
| 🟡 警告 | 0 | - |
| 🔴 异常 | 0 | - |

---

## 详细检查结果

EOF

# List of AI projects to check
PROJECTS=(
    "ai-appointment-manager"
    "ai-carbon-footprint-tracker"
    "ai-career-soft-skills-coach-bak"
    "ai-contract-reader"
    "ai-email-manager"
    "ai-error-diagnostician"
    "ai-family-health-guardian"
    "ai-gardening-designer"
    "ai-interview-coach"
    "ai-rental-detective"
    "ai-voice-notes-organizer"
    "ai-workspace-orchestrator"
)

RED_ISSUES=()

# Function to check a project
check_project() {
    local project_name="$1"
    local project_path="$PROJECT_DIR/$project_name"
    
    echo "检查项目: $project_name"
    
    # Check if directory exists
    if [ ! -d "$project_path" ]; then
        echo "❌ $project_name - 目录不存在"
        return
    fi
    
    cd "$project_path"
    
    # Initialize status variables
    has_uncommitted=false
    has_readme=false
    has_tests=false
    has_security_issues=false
    recent_commits_count=0
    last_commit_date=""
    days_since_last_commit=0
    
    # Check git status
    if git status --porcelain | grep -q "^."; then
        has_uncommitted=true
    fi
    
    # Check recent commits
    if git log --oneline -3 >/dev/null 2>&1; then
        recent_commits_count=$(git log --oneline -3 | wc -l | tr -d ' ')
        last_commit_date=$(git log -1 --format=%ci | awk '{print $1}')
        last_commit_timestamp=$(date -d "$last_commit_date" +%s 2>/dev/null || echo "0")
        current_timestamp=$(date +%s)
        days_since_last_commit=$(( (current_timestamp - last_commit_timestamp) / 86400 ))
    fi
    
    # Check for README
    if [ -f "README.md" ] || [ -f "readme.md" ] || [ -f "README" ]; then
        has_readme=true
    fi
    
    # Check for test files
    if find . -name "*test*" -type f | grep -q . || find . -name "*spec*" -type f | grep -q .; then
        has_tests=true
    fi
    
    # Check for package.json and run npm audit
    if [ -f "package.json" ]; then
        if npm audit --json 2>/dev/null | grep -q "vulnerabilities"; then
            has_security_issues=true
        fi
    fi
    
    # Determine project status
    status="🟢"
    status_text="健康"
    issues=()
    
    if [ "$has_uncommitted" = true ]; then
        status="🟡"
        status_text="警告"
        issues+=("有未提交的更改")
    fi
    
    if [ "$has_readme" = false ]; then
        status="🟡"
        status_text="警告"
        issues+=("缺少README")
    fi
    
    if [ "$has_tests" = false ]; then
        status="🟡"
        status_text="警告"
        issues+=("缺少测试文件")
    fi
    
    if [ "$days_since_last_commit" -gt 30 ]; then
        status="🔴"
        status_text="异常"
        issues+=("长时间无提交 ($days_since_last_commit天)")
    fi
    
    if [ "$has_security_issues" = true ]; then
        status="🔴"
        status_text="异常"
        issues+=("存在安全漏洞")
    fi
    
    # Add to RED_ISSUES if status is 🔴
    if [ "$status" = "🔴" ]; then
        RED_ISSUES+=("$project_name")
    fi
    
    # Format project info for report
    project_info="| $status | $project_name | $recent_commits_count | $last_commit_date | $days_since_last_commit天 |"
    
    # Add issues column if any
    if [ ${#issues[@]} -gt 0 ]; then
        issues_str=$(IFS="; "; echo "${issues[*]}")
        project_info+=" $issues_str |"
    else
        project_info+=" - |"
    fi
    
    echo "$project_info" >> "$REPORT_FILE"
}

# Create table header
cat >> "$REPORT_FILE" << EOF
| 状态 | 项目名称 | 最近提交数 | 最后提交日期 | 距离今天 | 问题描述 |
|------|----------|------------|--------------|----------|----------|
EOF

# Check each project
for project in "${PROJECTS[@]}"; do
    check_project "$project"
done

# Add summary to report
echo "" >> "$REPORT_FILE"
echo "## 统计信息" >> "$REPORT_FILE"

# Count statuses
healthy_count=$(grep -c "🟢" "$REPORT_FILE")
warning_count=$(grep -c "🟡" "$REPORT_FILE")  
red_count=$(grep -c "🔴" "$REPORT_FILE")

# Update summary table
sed -i '' "s/| 🟢 健康 | 0 | - |/| 🟢 健康 | $healthy_count | $(grep "🟢" "$REPORT_FILE" | cut -d'|' -f2 | tr -d ' ' | grep -v "项目名称" | tr '\n' ',' | sed 's/,$//') |/" "$REPORT_FILE"
sed -i '' "s/| 🟡 警告 | 0 | - |/| 🟡 警告 | $warning_count | $(grep "🟡" "$REPORT_FILE" | cut -d'|' -f2 | tr -d ' ' | grep -v "项目名称" | tr '\n' ',' | sed 's/,$//') |/" "$REPORT_FILE"
sed -i '' "s/| 🔴 异常 | 0 | - |/| 🔴 异常 | $red_count | $(grep "🔴" "$REPORT_FILE" | cut -d'|' -f2 | tr -d ' ' | grep -v "项目名称" | tr '\n' ',' | sed 's/,$//') |/" "$REPORT_FILE"

echo ""
echo "健康巡检完成！报告已保存到: $REPORT_FILE"
echo "异常项目数量: $red_count"

# Exit with error code if there are red issues
if [ ${#RED_ISSUES[@]} -gt 0 ]; then
    echo "发现异常项目，需要创建GitHub Issues: ${RED_ISSUES[*]}"
    exit 1
fi

exit 0