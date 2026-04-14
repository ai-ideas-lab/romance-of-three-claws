#!/bin/bash

# 项目健康巡检脚本
PROJECTS_DIR="/Users/wangshihao/projects/openclaws"
REPORT_FILE="$PROJECTS_DIR/docs/health-check-2026-04-14.md"
DATE=$(date '+%Y-%m-%d')

echo "# AI Ideas Lab 项目健康巡检报告 - $DATE" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| 项目名称 | 状态 | Git状态 | README | 测试 | 安全漏洞 | 最近提交 |" >> "$REPORT_FILE"
echo "|---------|------|---------|--------|------|----------|-----------|" >> "$REPORT_FILE"

# 获取所有ai-ideas-lab项目
PROJECTS=$(find "$PROJECTS_DIR" -maxdepth 1 -name "ai-*" -type d | sort)

for project in $PROJECTS; do
    project_name=$(basename "$project")
    
    # 切换到项目目录
    cd "$project" || continue
    
    # 检查git状态
    git_status_output=$(git status --porcelain 2>/dev/null)
    if [ $? -eq 0 ]; then
        if [ -z "$git_status_output" ]; then
            git_status="✅ 干净"
            has_uncommitted_changes=false
        else
            git_status="⚠️ 有未提交更改"
            has_uncommitted_changes=true
        fi
    else
        git_status="❌ Git错误"
        has_uncommitted_changes=true
    fi
    
    # 检查最近提交
    recent_commits=$(git log --oneline -3 2>/dev/null | head -1)
    if [ $? -ne 0 ]; then
        recent_commits="无提交记录"
    else
        # 检查提交时间
        commit_date=$(git log -1 --format="%cd" --date=short 2>/dev/null)
        current_date=$(date '+%Y-%m-%d')
        
        # 如果是今天或昨天，显示为正常
        if [ "$commit_date" = "$current_date" ]; then
            recent_commits="🟢 今天: $recent_commits"
        elif [ "$commit_date" = "$(date -d 'yesterday' '+%Y-%m-%d')" ]; then
            recent_commits="🟡 昨天: $recent_commits"
        else
            # 检查是否超过7天
            commit_timestamp=$(date -d "$commit_date" +%s 2>/dev/null)
            current_timestamp=$(date +%s)
            days_diff=$(( (current_timestamp - commit_timestamp) / 86400 ))
            
            if [ $days_diff -gt 7 ]; then
                recent_commits="🔴 $days_diff天前: $recent_commits"
            else
                recent_commits="🟡 $days_diff天前: $recent_commits"
            fi
        fi
    fi
    
    # 检查README.md
    if [ -f "README.md" ]; then
        has_readme="✅ 有"
    else
        has_readme="❌ 无"
    fi
    
    # 检查测试文件
    test_files=$(find . -name "*test*" -o -name "*spec*" | grep -v node_modules | grep -v dist | head -1)
    if [ -n "$test_files" ]; then
        has_tests="✅ 有"
    else
        has_tests="❌ 无"
    fi
    
    # 检查安全漏洞
    npm_audit_output=$(npm audit --json 2>/dev/null)
    if [ $? -eq 0 ]; then
        if echo "$npm_audit_output" | grep -q "vulnerabilities"; then
            vuln_count=$(echo "$npm_audit_output" | grep -o '"total": [0-9]*' | cut -d: -f2 | tr -d ' ')
            if echo "$npm_audit_output" | grep -q '"critical": [1-9]'; then
                security_issues="🔴 Critical: $vuln_count"
            elif echo "$npm_audit_output" | grep -q '"high": [1-9]'; then
                security_issues="🟡 High: $vuln_count"
            else
                security_issues="🟡 Moderate: $vuln_count"
            fi
        else
            security_issues="✅ 无"
        fi
    else
        security_issues="❌ 检查失败"
    fi
    
    # 确定项目状态
    if [ "$has_uncommitted_changes" = true ] || [ "$has_readme" = "❌ 无" ] || [ "$has_tests" = "❌ 无" ] || [ "$security_issues" = "🔴 Critical:"* ] || [ "$recent_commits" = "🔴"* ]; then
        if [ "$security_issues" = "🔴 Critical:"* ] || [ "$recent_commits" = "🔴"* ]; then
            project_status="🔴 异常"
        else
            project_status="🟡 警告"
        fi
    else
        project_status="🟢 健康"
    fi
    
    # 添加到报告
    echo "| $project_name | $project_status | $git_status | $has_readme | $has_tests | $security_issues | $recent_commits |" >> "$REPORT_FILE"
    
    echo "检查完成: $project_name"
done

echo "" >> "$REPORT_FILE"
echo "## 生成时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_FILE"
echo "## 总计项目数: $(echo "$PROJECTS" | wc -l | tr -d ' ')" >> "$REPORT_FILE"

# 统计状态
total_projects=$(echo "$PROJECTS" | wc -l | tr -d ' ')
healthy_projects=$(grep "🟢 健康" "$REPORT_FILE" | wc -l | tr -d ' ')
warning_projects=$(grep "🟡 警告" "$REPORT_FILE" | wc -l | tr -d ' ')
error_projects=$(grep "🔴 异常" "$REPORT_FILE" | wc -l | tr -d ' ')

echo "" >> "$REPORT_FILE"
echo "## 状态统计:" >> "$REPORT_FILE"
echo "- 🟢 健康: $healthy_projects 个项目" >> "$REPORT_FILE"
echo "- 🟡 警告: $warning_projects 个项目" >> "$REPORT_FILE"
echo "- 🔴 异常: $error_projects 个项目" >> "$REPORT_FILE"

echo "健康巡检报告已生成: $REPORT_FILE"