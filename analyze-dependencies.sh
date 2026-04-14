#!/bin/bash

# 依赖关系分析脚本
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
echo "|" 项目名称 | 技术栈 | 主要依赖 | 内部共享包 | API调用关系 "|" >> "$REPORT_FILE"
echo "|---------|--------|---------|-----------|----------|" >> "$REPORT_FILE"

# 存储所有依赖信息用于后续分析
declare -A ALL_DEPS
declare -A PROJECT_STACKS
declare -A SHARED_DEPS

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
            deps=$(grep -A 100 '"dependencies"' "$package_file" | grep -E '"[^"]+":' | head -10)
            dev_deps=$(grep -A 100 '"devDependencies"' "$package_file" | grep -E '"[^"]+":' | head -5)
            
            # 提取技术栈（基于主要依赖推测）
            stack=""
            if [[ "$deps" =~ "react" ]] || [[ "$dev_deps" =~ "react" ]]; then
                stack="$stack React"
            fi
            if [[ "$deps" =~ "node" ]] || [[ "$deps" =~ "express" ]]; then
                stack="$stack Node.js"
            fi
            if [[ "$deps" =~ "typescript" ]]; then
                stack="$stack TypeScript"
            fi
            if [[ "$deps" =~ "openai" ]] || [[ "$deps" =~ "ai" ]]; then
                stack="$stack AI/ML"
            fi
            if [[ "$deps" =~ "sqlite" ]] || [[ "$deps" =~ "mongodb" ]]; then
                stack="$stack Database"
            fi
            if [[ "$deps" =~ "tailwind" ]]; then
                stack="$stack Tailwind"
            fi
            
            # 收集所有依赖用于分析
            if [[ -n "$deps" ]]; then
                while read -r line; do
                    if [[ $line =~ \"([^\"]+)\": ]]; then
                        dep_name="${BASH_REMATCH[1]}"
                        if [[ "$dep_name" != "*" ]] && [[ "$dep_name" != "npm" ]]; then
                            ALL_DEPS["$dep_name"]="${ALL_DEPS["$dep_name"]:-$project_name}"
                            # 检查是否为内部共享包
                            if [[ "$dep_name" =~ ^@ai- ]]; then
                                SHARED_DEPS["$dep_name"]="${SHARED_DEPS["$dep_name"]:-$project_name}"
                            fi
                        fi
                    fi
                done <<< "$deps"
            fi
            
            # 生成项目信息行
            main_deps=$(echo "$deps" | head -3 | sed 's/^[[:space:]]*//' | sed 's/,//')
            shared_pkgs=$(echo "$deps" | grep -E "@ai-" | head -3 | sed 's/^[[:space:]]*//' | sed 's/,//')
            
            echo "| $project_name | $stack | $main_deps | $shared_pkgs | 待分析 |" >> "$REPORT_FILE"
            
            PROJECT_STACKS["$project_name"]="$stack"
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

for dep in "${!ALL_DEPS[@]}"; do
    projects=(${ALL_DEPS[$dep]})
    project_count=${#projects[@]}
    if [[ $project_count -gt 1 ]]; then
        project_list=$(IFS=,; echo "${projects[*]}")
        echo "| $dep | $project_count | $project_list |" >> "$REPORT_FILE"
    fi
done

# 分析内部共享包
echo "" >> "$REPORT_FILE"
echo "### 内部共享包分析：" >> "$REPORT_FILE"
echo "| 内部包 | 使用项目 |" >> "$REPORT_FILE"
echo "|--------|---------|" >> "$REPORT_FILE"

for shared in "${!SHARED_DEPS[@]}"; do
    projects=(${SHARED_DEPS[$shared]})
    project_list=$(IFS=,; echo "${projects[*]}")
    echo "| $shared | $project_list |" >> "$REPORT_FILE"
done

# 生成依赖关系图（Mermaid）
echo "" >> "$REPORT_FILE"
echo "## 依赖关系图" >> "$REPORT_FILE"
echo "```mermaid" >> "$REPORT_FILE"
echo "graph TD" >> "$REPORT_FILE"
echo "    A[AI Ideas Lab] --> B{项目集合}" >> "$REPORT_FILE"

# 添加主要项目节点
for project in "${!PROJECT_STACKS[@]}"; do
    echo "    B --> $project[$project]" >> "$REPORT_FILE"
done

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

echo "报告已生成: $REPORT_FILE"
echo "开始提交到 Git..."
cd "$PROJECTS_DIR" && git add docs/dependency-map-"$DATE".md && git commit -m "Add dependency analysis report for $DATE" && git push origin main