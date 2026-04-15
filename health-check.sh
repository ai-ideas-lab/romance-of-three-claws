#!/bin/bash

# 项目健康巡检脚本 - 2026-04-15
# 遍历所有 ai-ideas-lab 项目并生成健康报告

PROJECT_DIR="/Users/wangshihao/projects/openclaws"
REPORT_FILE="$PROJECT_DIR/docs/health-check-2026-04-15.md"
DATE=$(date +'%Y-%m-%d %H:%M:%S')

echo "# 项目健康巡检报告 - $DATE" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| 项目名称 | Git状态 | 最近提交 | README | 测试 | 安全漏洞 | 健康状态 |" >> "$REPORT_FILE"
echo "|---------|---------|----------|-------|------|----------|----------|" >> "$REPORT_FILE"

# 项目列表
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

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

critical_projects=()

for project in "${PROJECTS[@]}"; do
    project_path="$PROJECT_DIR/$project"
    
    if [ ! -d "$project_path" ]; then
        echo "项目 $project 不存在，跳过"
        continue
    fi
    
    cd "$project_path" || continue
    
    # 初始化变量
    git_status="❌"
    recent_commit="无"
    readme="❌"
    tests="❌"
    security="❌"
    health_status="🔴 异常"
    status_details="无提交更改，无法检查"
    
    # 检查是否为git仓库
    if [ -d ".git" ]; then
        # Git状态检查
        if git status --porcelain | grep -q "^"; then
            git_status="⚠️"
            status_details="有未提交的更改"
        else
            git_status="✅"
            status_details="无未提交更改"
        fi
        
        # 最近提交检查
        recent_commit=$(git log --oneline -3 2>/dev/null | head -1 | cut -d' ' -f2-3 || echo "无提交记录")
        
        # 检查提交时间
        last_commit_date=$(git log -1 --format="%ct" 2>/dev/null)
        if [ -n "$last_commit_date" ]; then
            days_since_commit=$(( ( $(date +%s) - last_commit_date ) / 86400 ))
            if [ $days_since_commit -gt 30 ]; then
                health_status="🔴 异常"
                status_details="长时间无提交 ($days_since_commit天)"
            fi
        fi
    else
        status_details="非Git仓库"
        git_status="❌"
    fi
    
    # README检查
    if [ -f "README.md" ]; then
        readme="✅"
    fi
    
    # 测试文件检查
    if [ -d "tests" ] || [ -d "test" ] || [ -f "*.test.js" ] || [ -f "*.test.ts" ] || [ -f "*.spec.js" ] || [ -f "*.spec.ts" ]; then
        tests="✅"
    fi
    
    # 安全漏洞检查
    if [ -f "package.json" ]; then
        if npm audit --json 2>/dev/null | grep -q '"vulnerabilities"'; then
            security="⚠️"
            if [ "$health_status" != "🔴 异常" ]; then
                health_status="🟡 警告"
            fi
            status_details="$status_details，有安全漏洞"
        else
            security="✅"
        fi
    else
        security="❌"
        if [ "$health_status" != "🔴 异常" ]; then
            health_status="🟡 警告"
        fi
    fi
    
    # 综合健康状态判断
    if [ "$git_status" = "✅" ] && [ "$readme" = "✅" ] && [ "$tests" = "✅" ] && [ "$security" = "✅" ]; then
        health_status="🟢 健康"
    elif [ "$git_status" = "⚠️" ] || [ "$readme" = "❌" ] || [ "$tests" = "❌" ] || [ "$security" = "⚠️" ]; then
        if [ "$health_status" != "🔴 异常" ]; then
            health_status="🟡 警告"
        fi
    fi
    
    # 记录到报告
    echo "| $project | $git_status | $recent_commit | $readme | $tests | $security | $health_status |" >> "$REPORT_FILE"
    
    # 输出到控制台
    echo -e "${GREEN}项目: $project${NC}"
    echo -e "  Git状态: $git_status"
    echo -e "  最近提交: $recent_commit"
    echo -e "  README: $readme"
    echo -e "  测试: $tests"
    echo -e "  安全: $security"
    echo -e "  健康状态: ${health_status} $status_details"
    echo ""
    
    # 记录异常项目
    if [ "$health_status" = "🔴 异常" ]; then
        critical_projects+=("$project")
    fi
done

echo "" >> "$REPORT_FILE"
echo "## 健康状态统计" >> "$REPORT_FILE"
echo "- 🟢 健康: $(grep '| 🟢 健康 |' "$REPORT_FILE" | wc -l) 个项目" >> "$REPORT_FILE"
echo "- 🟡 警告: $(grep '| 🟡 警告 |' "$REPORT_FILE" | wc -l) 个项目" >> "$REPORT_FILE"
echo "- 🔴 异常: $(grep '| 🔴 异常 |' "$REPORT_FILE" | wc -l) 个项目" >> "$REPORT_FILE"

# 为异常项目创建GitHub Issues
if [ ${#critical_projects[@]} -gt 0 ]; then
    echo "" >> "$REPORT_FILE"
    echo "## 🔴 异常项目处理建议" >> "$REPORT_FILE"
    for project in "${critical_projects[@]}"; do
        echo "- $project: 需要紧急处理" >> "$REPORT_FILE"
        echo "  建议创建GitHub Issue进行跟踪" >> "$REPORT_FILE"
    done
    
    echo ""
    echo "${RED}发现 ${#critical_projects[@]} 个异常项目，建议创建GitHub Issues进行跟踪${NC}"
    
    # 这里可以添加创建GitHub Issue的逻辑
    # gh issue create --title "健康巡检发现异常项目: $project" --body "项目 $project 在健康巡检中发现问题，需要处理。"
else
    echo "${GREEN}所有项目健康状态正常${NC}"
fi

echo ""
echo "健康报告已保存到: $REPORT_FILE"