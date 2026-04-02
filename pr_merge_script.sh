#!/bin/bash

# PR自动化合并脚本 - 孔明执行
# 用于合并 ava-agent/awesome-ai-ideas 仓库中经过充分讨论的PR

set -e

REPO="ava-agent/awesome-ai-ideas"
MAX_MERGE=10
MIN_COMMENTS=5
TEMP_FILE="/tmp/pr_merge_candidates.txt"

echo "🔥 开始PR合并任务..."
echo "📊 最少需要 $MIN_COMMENTS 条评论才能合并"
echo "🎯 最多合并 $MAX_MERGE 个PR"

# 获取所有开放PR
echo "📋 获取开放PR列表..."
gh api "repos/$REPO/pulls?state=open&per_page=100" --template '{{range .}}{{.number}}{{"\n"}}{{end}}' > "$TEMP_FILE"

pr_count=$(wc -l < "$TEMP_FILE")
echo "📈 发现 $pr_count 个开放PR"

# 分析每个PR
merged_count=0
skipped_count=0
failed_count=0
merge_results=()

while IFS= read -r pr_number; do
    if [ -z "$pr_number" ]; then
        continue
    fi

    echo "🔍 分析 PR #$pr_number..."
    
    # 获取PR标题
    title=$(gh api "repos/$REPO/pulls/$pr_number" --template '{{.title}}')
    echo "   标题: $title"
    
    # 获取评论数
    comment_count=$(gh api "repos/$REPO/issues/$pr_number/comments" --template '{{len .}}')
    echo "   评论数: $comment_count"
    
    # 检查是否满足合并条件
    if [ "$comment_count" -ge "$MIN_COMMENTS" ]; then
        echo "   ✅ 符合合并条件 (评论数 ≥ $MIN_COMMENTS)"
        
        # 尝试合并
        if gh pr merge "$pr_number" --repo "$REPO" --merge --auto >/dev/null 2>&1; then
            echo "   ✅ 合并成功"
            merged_count=$((merged_count + 1))
            merge_results+=("$pr_number:成功")
        else
            echo "   ❌ 合并失败，记录原因..."
            error_msg=$(gh pr merge "$pr_number" --repo "$REPO" --merge --auto 2>&1)
            echo "   错误信息: $error_msg"
            failed_count=$((failed_count + 1))
            merge_results+=("$pr_number:失败-$error_msg")
        fi
    else
        echo "   ⏭️  跳过 (评论数不足)"
        skipped_count=$((skipped_count + 1))
        merge_results+=("$pr_number:跳过-评论数不足")
    fi
    
    echo ""
    
    # 检查是否达到最大合并数量
    if [ "$merged_count" -ge "$MAX_MERGE" ]; then
        echo "🎯 已达到最大合并数量 $MAX_MERGE，停止处理"
        break
    fi
done < "$TEMP_FILE"

# 输出总结
echo "===================="
echo "📊 合并任务完成"
echo "===================="
echo "✅ 成功合并: $merged_count 个PR"
echo "⏭️  跳过: $skipped_count 个PR"
echo "❌ 失败: $failed_count 个PR"

# 显示详细结果
echo ""
echo "📋 详细结果:"
for result in "${merge_results[@]}"; do
    echo "   $result"
done

# 清理临时文件
rm -f "$TEMP_FILE"

echo ""
echo "🔥 任务完成！"