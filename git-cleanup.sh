#!/bin/bash

# Git整理脚本 - 孔明
# 遍历指定目录，检查并整理git仓库

# 仓库根目录列表
REPOS=(
    "/Users/wangshihao/.openclaw/workspace"
    "/Users/wangshihao/projects/openclaws"
)

# 整理的仓库列表
CLEANED_REPOS=()

# 遍历每个目录
for repo_dir in "${REPOS[@]}"; do
    echo "检查目录: $repo_dir"
    
    # 查找所有git仓库
    while IFS= read -r -d '' git_dir; do
        repo_path=$(dirname "$git_dir")
        repo_name=$(basename "$repo_path")
        
        echo "处理仓库: $repo_name"
        
        # 进入仓库目录
        cd "$repo_path" || continue
        
        # 检查是否有未暂存的改动（排除代码文件）
        if ! git diff --quiet; then
            echo "  发现未暂存改动..."
            
            # 添加相关文档文件
            git add memory/ docs/ 2>/dev/null || true
            git add *.md 2>/dev/null || true
            git add *.json 2>/dev/null || true
            
            # 检查是否有实际添加的文件
            if ! git diff --cached --quiet; then
                # 简要描述改动
                brief_desc=$(git diff --cached --name-only | head -3 | tr '\n' ' ' | sed 's/ $//')
                commit_msg="chore: auto-commit $brief_desc"
                
                # 提交
                if git commit -m "$commit_msg" 2>/dev/null; then
                    echo "  ✓ 已提交: $commit_msg"
                    CLEANED_REPOS+=("$repo_name")
                else
                    echo "  ⚠ 提交失败"
                fi
            fi
        fi
        
        # 检查是否有未推送的提交
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        if git log --oneline "origin/$current_branch..$current_branch" --quiet; then
            echo "  发现未推送提交..."
            
            # 推送（最多重试2次）
            push_attempts=0
            while [ $push_attempts -lt 2 ]; do
                if git push origin "$current_branch"; then
                    echo "  ✓ 推送成功"
                    break
                else
                    push_attempts=$((push_attempts + 1))
                    echo "  推送失败，尝试 $push_attempts/2"
                    sleep 2
                fi
            done
        else
            echo "  ✓ 已同步，无需推送"
        fi
        
        # 返回原目录
        cd - > /dev/null || exit 1
        
    done < <(find "$repo_dir" -type d -name ".git" -print0 2>/dev/null)
done

# 报告结果
echo ""
echo "=== 整理完成 ==="
if [ ${#CLEANED_REPOS[@]} -gt 0 ]; then
    echo "整理的仓库: ${CLEANED_REPOS[*]}"
else
    echo "所有仓库已整理完毕，无需额外操作"
fi