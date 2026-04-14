#!/bin/bash

# 依赖关系分析脚本 - macOS 兼容版本
# 遍历所有 ai-ideas-lab 项目，收集依赖信息

PROJECTS_DIR="/Users/wangshihao/projects/openclaws"
REPORT_DIR="${PROJECTS_DIR}/docs"
DATE=$(date +%Y-%m-%d)
REPORT_FILE="${REPORT_DIR}/dependency-map-${DATE}.md"

# 确保 docs 目录存在
mkdir -p "$REPORT_DIR"

# 初始化报告
echo "# AI Ideas Lab 项目依赖关系分析报告 - $(date)" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "## 项目信息收集" >> "$REPORT_FILE"
echo "| 项目名称 | 技术栈 | 主要依赖 | 内部共享包 | API调用关系 |" >> "$REPORT_FILE"
echo "|---------|--------|---------|-----------|----------|" >> "$REPORT_FILE"

# 临时文件用于存储数据
TEMP_DEPS_FILE="/tmp/all_deps_${DATE}.txt"
TEMP_STACKS_FILE="/tmp/project_stacks_${DATE}.txt"
TEMP_SHARED_FILE="/tmp/shared_deps_${DATE}.txt"

# 清空临时文件
> "$TEMP_DEPS_FILE"
> "$TEMP_STACKS_FILE"
> "$TEMP_SHARED_FILE"

# 遍历所有 ai- 项目
for project in ai-*; do
    if [[ -d "$project" && $project =~ ^ai- ]]; then
        project_path="${PROJECTS_DIR}/${project}"
        package_file="${project_path}/package.json"
        
        if [[ -f "$package_file" ]]; then
            echo "分析项目: $project"
            
            # 提取项目基本信息
            project_name=$(basename "$project")
            description=$(grep -o '"description": "[^"]*"' "$package_file" | cut -d'"' -f4 | head -1)
            
            # 提取依赖信息
            deps_section=$(sed -n '/"dependencies": {/,/}/p' "$package_file" | head -20)
            dev_deps_section=$(sed -n '/"devDependencies": {/,/}/p' "$package_file" | head -15)
            
            # 提取技术栈（基于主要依赖推测）
            stack=""
            if [[ "$deps_section" =~ "react" ]] || [[ "$dev_deps_section" =~ "react" ]]; then
                stack="$stack React"
            fi
            if [[ "$deps_section" =~ "node" ]] || [[ "$deps_section" =~ "express" ]]; then
                stack="$stack Node.js"
            fi
            if [[ "$deps_section" =~ "typescript" ]]; then
                stack="$stack TypeScript"
            fi
            if [[ "$deps_section" =~ "openai" ]] || [[ "$deps_section" =~ "ai" ]] || [[ "$dev_deps_section" =~ "ai" ]]; then
                stack="$stack AI/ML"
            fi
            if [[ "$deps_section" =~ "sqlite" ]] || [[ "$deps_section" =~ "mongodb" ]] || [[ "$deps_section" =~ "prisma" ]]; then
                stack="$stack Database"
            fi
            if [[ "$deps_section" =~ "tailwind" ]]; then
                stack="$stack Tailwind"
            fi
            
            # 收集所有依赖
            current_deps=""
            current_dev_deps=""
            
            # 提取 dependencies
            echo "$deps_section" | grep -E '"[^"]+":' | while read -r line; do
                if [[ $line =~ \"([^\"]+)\": ]]; then
                    dep_name="${BASH_REMATCH[1]}"
                    if [[ "$dep_name" != "*" ]] && [[ "$dep_name" != "npm" ]]; then
                        current_deps="$current_deps $dep_name"
                        # 保存到全局依赖文件
                        echo "$dep_name|$project_name" >> "$TEMP_DEPS_FILE"
                        
                        # 检查是否为内部共享包
                        if [[ "$dep_name" =~ ^@ai- ]]; then
                            echo "$dep_name|$project_name" >> "$TEMP_SHARED_FILE"
                        fi
                    fi
                fi
            done
            
            # 提取 devDependencies
            echo "$dev_deps_section" | grep -E '"[^"]+":' | while read -r line; do
                if [[ $line =~ \"([^\"]+)\": ]]; then
                    dev_name="${BASH_REMATCH[1]}"
                    if [[ "$dev_name" != "*" ]] && [[ "$dev_name" != "npm" ]]; then
                        current_dev_deps="$current_dev_deps $dev_name"
                    fi
                fi
            done
            
            # 提取主要依赖（前5个）
            main_deps=$(echo "$deps_section" | grep -E '"[^"]+":' | head -5 | sed 's/"\([^"]*\)":.*/\1/' | tr '\n' ',' | sed 's/,$//')
            
            # 提取内部共享包
            shared_pkgs=$(echo "$deps_section" | grep -E '"@ai-[^"]*":' | head -3 | sed 's/"\([^"]*\)":.*/\1/' | tr '\n' ',' | sed 's/,$//')
            
            # 保存项目栈信息
            echo "$project_name|$stack" >> "$TEMP_STACKS_FILE"
            
            # 生成项目信息行
            echo "| $project_name | $stack | $main_deps | $shared_pkgs | 待分析 |" >> "$REPORT_FILE"
            
        else
            echo "| $project | 未找到 package.json | - | - | - |" >> "$REPORT_FILE"
        fi
    fi
done

echo "" >> "$REPORT_FILE"

# 分析共享依赖
echo "## 共享依赖分析" >> "$REPORT_FILE"
echo "### 多个项目共用的依赖包：" >> "$REPORT_FILE"
echo "| 依赖包 | 使用项目数 | 使用项目 |" >> "$REPORT_FILE"
echo "|--------|------------|---------|" >> "$REPORT_FILE"

# 统计共用依赖
while IFS='|' read -r dep project; do
    if [[ -n "$dep" ]]; then
        # 查找使用这个依赖的所有项目
        using_projects=$(grep "$dep|" "$TEMP_DEPS_FILE" | cut -d'|' -f2 | sort | uniq | tr '\n' ',' | sed 's/,$//')
        project_count=$(echo "$using_projects" | tr ',' '\n' | wc -l | tr -d ' ')
        
        if [[ $project_count -gt 1 ]]; then
            echo "| $dep | $project_count | $using_projects |" >> "$REPORT_FILE"
        fi
    fi
done < "$TEMP_DEPS_FILE"

# 分析内部共享包
echo "" >> "$REPORT_FILE"
echo "### 内部共享包分析：" >> "$REPORT_FILE"
echo "| 内部包 | 使用项目 |" >> "$REPORT_FILE"
echo "|--------|---------|" >> "$REPORT_FILE"

while IFS='|' read -r shared project; do
    if [[ -n "$shared" && $shared =~ ^@ai- ]]; then
        using_projects=$(grep "$shared|" "$TEMP_SHARED_FILE" | cut -d'|' -f2 | sort | uniq | tr '\n' ',' | sed 's/,$//')
        echo "| $shared | $using_projects |" >> "$REPORT_FILE"
    fi
done < "$TEMP_SHARED_FILE"

# 生成依赖关系图（Mermaid）
echo "" >> "$REPORT_FILE"
echo "## 依赖关系图" >> "$REPORT_FILE"
echo "```mermaid" >> "$REPORT_FILE"
echo "graph TD" >> "$REPORT_FILE"
echo "    A[AI Ideas Lab] --> B[项目集合]" >> "$REPORT_FILE"

# 添加主要项目节点
while IFS='|' read -r project_name stack; do
    if [[ -n "$project_name" ]]; then
        echo "    B --> $project_name[$project_name]" >> "$REPORT_FILE"
    fi
done < "$TEMP_STACKS_FILE"

# 添加共享依赖
echo "    B --> C[共享依赖库]" >> "$REPORT_FILE"
echo "    C --> D[React/Node.js]" >> "$REPORT_FILE"
echo "    C --> E[TypeScript]" >> "$REPORT_FILE"
echo "    C --> F[AI框架]" >> "$REPORT_FILE"
echo "    C --> G[数据库]" >> "$REPORT_FILE"

echo "```" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"

# 优化建议
echo "## 优化建议" >> "$REPORT_FILE"
echo "### Monorepo 策略建议：" >> "$REPORT_FILE"
echo "1. **共享包提取**：将重复依赖提取到 monorepo 根目录的 packages/ 目录" >> "$REPORT_FILE"
echo "2. **版本统一**：制定统一的依赖版本管理策略，避免版本冲突" >> "$REPORT_FILE"
echo "3. **CI/CD 优化**：使用 monorepo 构建工具（如 Turbo、Nx）优化构建流程" >> "$REPORT_FILE"
echo "4. **依赖监控**：建立依赖安全监控，及时更新废弃包" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "### 具体行动项：" >> "$REPORT_FILE"
echo "- [ ] 创建 monorepo 根目录的 package.json 和工作区配置" >> "$REPORT_FILE"
echo "- [ ] 识别并提取 3-5 个最常用的共享依赖" >> "$REPORT_FILE"
echo "- [ ] 统一 TypeScript 配置和 ESLint 规则" >> "$REPORT_FILE"
echo "- [ ] 建立依赖版本升级流程" >> "$REPORT_FILE"
echo "- [ ] 设置定期的依赖安全检查" >> "$REPORT_FILE"

# 清理临时文件
rm -f "$TEMP_DEPS_FILE" "$TEMP_STACKS_FILE" "$TEMP_SHARED_FILE"

echo "报告已生成: $REPORT_FILE"
echo "开始提交到 Git..."
cd "$PROJECTS_DIR" && git add docs/dependency-map-"$DATE".md && git commit -m "Add dependency analysis report for $DATE" && git push origin main