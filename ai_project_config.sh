#!/bin/bash

# =============================================================================
# AI项目开发环境配置脚本
# 为主公的AI项目提供专属的开发环境配置和优化
# =============================================================================

set -e

# AI项目路径
CHERRY_STUDIO_PATH="/Users/wangshihao/projects/ai/cherry-studio"
RING_PATH="/Users/wangshihao/projects/ai/Ring"
WORKSPACE_ROOT="/Users/wangshihao/.openclaw/workspace"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 日志函数
log() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"
}

log_info() {
    log "${CYAN}[INFO]${NC} $1"
}

log_warn() {
    log "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    log "${RED}[ERROR]${NC} $1"
}

log_success() {
    log "${GREEN}[SUCCESS]${NC} $1"
}

# 检查项目是否存在
check_project() {
    local project_path="$1"
    local project_name="$2"
    
    if [ ! -d "$project_path" ]; then
        log_error "$project_name 项目不存在: $project_path"
        return 1
    fi
    log_info "$project_name 项目存在: $project_path"
    return 0
}

# Cherry Studio 环境配置
configure_cherry_studio() {
    log_info "开始配置 Cherry Studio 开发环境"
    
    if ! check_project "$CHERRY_STUDIO_PATH" "Cherry Studio"; then
        return 1
    fi
    
    cd "$CHERRY_STUDIO_PATH"
    
    # 创建开发环境配置文件
    cat > ".env.development" << EOF
# Cherry Studio 开发环境配置
NODE_ENV=development
ELECTRON_SKIP_APP_UPDATE=true
ELECTRON_ENABLE_LOGGING=true
ELECTRON_DISABLE_SECURITY_WARNINGS=true
VITE_INLINE_SOURCEMAP=true
VITE_BUILD_MODE=development
EOF
    
    log_success "Cherry Studio 开发环境配置已创建"
    
    # 检查是否需要安装依赖
    if [ ! -d "node_modules" ]; then
        log_info "安装 Cherry Studio 依赖..."
        npm install || yarn install
        log_success "依赖安装完成"
    fi
    
    # 创建开发脚本
    cat > "dev.sh" << 'EOF'
#!/bin/bash
# Cherry Studio 开发启动脚本

set -e

log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

log_info "启动 Cherry Studio 开发环境..."

# 检查依赖
if [ ! -d "node_modules" ]; then
    log_info "安装依赖..."
    npm install
fi

# 设置环境变量
export NODE_ENV=development
export ELECTRON_SKIP_APP_UPDATE=true
export ELECTRON_ENABLE_LOGGING=true

# 启动开发服务器
log_info "启动开发服务器..."
npm run dev &

# 等待开发服务器启动
sleep 5

log_info "Cherry Studio 开发环境已启动"
log_info "开发服务器: http://localhost:5173"
log_info "按 Ctrl+C 停止开发服务器"

# 清理函数
cleanup() {
    log_info "停止开发服务器..."
    kill $(pgrep -f "npm run dev") 2>/dev/null || true
    exit 0
}

# 设置信号处理
trap cleanup INT TERM

# 保持脚本运行
while true; do
    sleep 1
done
EOF
    
    chmod +x dev.sh
    log_success "Cherry Studio 开发脚本已创建"
    
    # 创建 lint 配置优化
    if [ -f ".eslintrc.js" ]; then
        log_info "优化 ESLint 配置..."
        # 添加AI相关的规则
        cat >> ".eslintrc.js" << EOF

// AI 开发相关规则
module.exports = {
  overrides: [
    {
      files: ['src/**/*.ts', 'src/**/*.tsx'],
      rules: {
        '@typescript-eslint/no-unused-vars': 'warn',
        'no-console': 'warn',
        'prefer-const': 'error',
      },
    },
  ],
};
EOF
    fi
    
    log_success "Cherry Studio 开发环境配置完成"
}

# Ring 项目环境配置
configure_ring_project() {
    log_info "开始配置 Ring AI 导航项目开发环境"
    
    if ! check_project "$RING_PATH" "Ring"; then
        return 1
    fi
    
    cd "$RING_PATH"
    
    # 创建 AI 内容管理脚本
    cat > "ai-content-manager.sh" << 'EOF'
#!/bin/bash
# Ring AI 内容管理脚本

set -e

# AI 模型目录
LLM_DIR="LLM"
TOOL_DIR="TOOL"

log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

# 创建 AI 模型卡片模板
create_model_card() {
    local model_name="$1"
    local provider="$2"
    local description="$3"
    
    local card_path="$LLM_DIR/${model_name}/card.md"
    
    mkdir -p "$LLM_DIR/$model_name"
    
    cat > "$card_path" << EOF
# $model_name

**提供商**: $provider

## 描述
$description

## 特点
- 特色功能1
- 特色功能2
- 特色功能3

## 使用场景
- 场景1
- 场景2
- 场景3

## 定价
- 基础版: 免费
- 专业版: \$X/月
- 企业版: \$X/月

## 链接
- 官网: [链接]
- 文档: [链接]
- API: [链接]

## 评价
- 优点: 
- 缺点: 
- 适用人群: 

## 更新日志
- $(date '+%Y-%m-%d'): 初始版本
EOF
    
    log_success "AI模型卡片已创建: $card_path"
}

# 创建 AI 工具卡片模板
create_tool_card() {
    local tool_name="$1"
    local category="$2"
    local description="$3"
    
    local tool_path="$TOOL_DIR/${tool_name}/card.md"
    
    mkdir -p "$TOOL_DIR/$tool_name"
    
    cat > "$tool_path" << EOF
# $tool_name

**类别**: $category

## 描述
$description

## 功能
- 功能1
- 功能2
- 功能3

## 支持
- 平台: 
- 语言: 
- 部署方式: 

## 定价
- 免费: ✅/❌
- 付费: ✅/❌
- 开源: ✅/❌

## 链接
- 官网: [链接]
- GitHub: [链接]
- 文档: [链接]

## 评价
- 优点: 
- 缺点: 
- 适用场景: 

## 使用方法
\`\`\`
// 使用示例
\`\`\`

## 更新日志
- $(date '+%Y-%m-%d'): 初始版本
EOF
    
    log_success "AI工具卡片已创建: $tool_path"
}

# 主菜单
show_menu() {
    echo ""
    echo "🤖 Ring AI 内容管理器"
    echo "=============================="
    echo "1. 创建 AI 模型卡片"
    echo "2. 创建 AI 工具卡片"
    echo "3. 列出所有模型"
    echo "4. 列出所有工具"
    echo "5. 生成项目报告"
    echo "0. 退出"
    echo "=============================="
    read -p "请选择操作: " choice
}

case "$1" in
    "create-model")
        read -p "模型名称: " model_name
        read -p "提供商: " provider
        read -p "描述: " description
        create_model_card "$model_name" "$provider" "$description"
        ;;
    "create-tool")
        read -p "工具名称: " tool_name
        read -p "类别: " category
        read -p "描述: " description
        create_tool_card "$tool_name" "$category" "$description"
        ;;
    "list-models")
        echo "可用的AI模型:"
        ls -1 "$LLM_DIR" 2>/dev/null || echo "未找到AI模型"
        ;;
    "list-tools")
        echo "可用的AI工具:"
        ls -1 "$TOOL_DIR" 2>/dev/null || echo "未找到AI工具"
        ;;
    "report")
        echo "生成Ring项目报告..."
        # 这里可以添加报告生成逻辑
        ;;
    *)
        echo "使用方法: $0 (create-model|create-tool|list-models|list-tools|report)"
        ;;
esac
EOF
    
    chmod +x ai-content-manager.sh
    
    # 创建内容同步脚本
    cat > "sync-content.sh" << 'EOF'
#!/bin/bash
# Ring 项目内容同步脚本

set -e

LOG_FILE="content_sync.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_info "开始同步 Ring 项目内容..."

# 检查Git状态
cd "$(git rev-parse --show-toplevel)"
git add .
git status --porcelain > /tmp/git_status.txt

if [ -s /tmp/git_status.txt ]; then
    log_info "发现未提交的更改:"
    cat /tmp/git_status.txt
    
    read -p "是否提交这些更改? (y/n): " should_commit
    if [[ "$should_commit" =~ ^[Yy]$ ]]; then
        read -p "提交信息: " commit_msg
        git commit -m "$commit_msg"
        log_success "更改已提交"
    fi
else
    log_info "没有未提交的更改"
fi

# 清理临时文件
rm -f /tmp/git_status.txt

log_success "内容同步完成"
EOF
    
    chmod +x sync-content.sh
    
    log_success "Ring 项目开发环境配置完成"
}

# AI 开发工具集成
setup_ai_tools() {
    log_info "设置 AI 开发工具集成"
    
    # 创建 AI 辅助开发脚本
    cat > "ai-dev-helper.sh" << 'EOF'
#!/bin/bash
# AI 开发助手脚本

set -e

# 配置
OPENAI_API_KEY="${OPENAI_API_KEY:-}"
CLAUDE_API_KEY="${CLAUDE_API_KEY:-}"
GIT_COMMIT_PROMPT="请为以下代码更改生成一个合适的Git提交信息："

log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

# 生成 Git 提交信息
generate_commit_message() {
    local git_diff=$(git diff --staged)
    
    if [ -z "$git_diff" ]; then
        log_warn "没有暂存的更改"
        return 1
    fi
    
    log_info "生成 Git 提交信息..."
    
    # 使用 OpenAI 或 Claude
    if [ -n "$OPENAI_API_KEY" ]; then
        local response=$(curl -s -X POST \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $OPENAI_API_KEY" \
            -d "{
                \"model\": \"gpt-3.5-turbo\",
                \"messages\": [
                    {
                        \"role\": \"system\",
                        \"content\": \"你是一个专业的软件开发者，专门为代码更改生成清晰、简洁的Git提交信息。\" 
                    },
                    {
                        \"role\": \"user\", 
                        \"content\": \"$GIT_COMMIT_PROMPT\\n\\n$git_diff\"
                    }
                ],
                \"max_tokens\": 150
            }" \
            https://api.openai.com/v1/chat/completions)
        
        echo "$response" | grep -o '"content":"[^"]*"' | sed 's/"content":"//;s/"$//' | head -1
    elif [ -n "$CLAUDE_API_KEY" ]; then
        log_info "使用 Claude API..."
        # 这里需要 Claude API 调用逻辑
        echo "基于代码更改的提交信息"
    else
        log_warn "未配置 AI API 密钥，使用默认提交信息"
        echo "代码更新"
    fi
}

# 代码审查
review_code() {
    local file_path="$1"
    
    if [ ! -f "$file_path" ]; then
        log_error "文件不存在: $file_path"
        return 1
    fi
    
    log_info "开始代码审查: $file_path"
    
    local file_content=$(cat "$file_path")
    
    # 这里可以添加代码审查逻辑
    echo "代码审查功能待实现"
}

# 性能分析
analyze_performance() {
    local project_path="$1"
    
    if [ ! -d "$project_path" ]; then
        log_error "项目路径不存在: $project_path"
        return 1
    fi
    
    cd "$project_path"
    
    log_info "开始性能分析..."
    
    # 分析构建时间
    if [ -f "package.json" ] && grep -q "build" package.json; then
        log_info "分析构建性能..."
        time npm run build 2>&1 | grep -E "(Time|real|user|sys)" || true
    fi
    
    # 分析包大小
    if [ -d "dist" ]; then
        log_info "分析构建产物大小..."
        du -sh dist/ 2>/dev/null || log_warn "无法分析构建产物大小"
    fi
    
    # 依赖分析
    if command -v npm >/dev/null 2>&1 && [ -f "package.json" ]; then
        log_info "分析依赖项..."
        npm audit --audit-level moderate 2>/dev/null || true
    fi
}

# 主菜单
show_menu() {
    echo ""
    echo "🤖 AI 开发助手"
    echo "=============================="
    echo "1. 生成 Git 提交信息"
    echo "2. 代码审查"
    echo "3. 性能分析"
    echo "4. AI 模型信息"
    echo "0. 退出"
    echo "=============================="
    read -p "请选择操作: " choice
}

case "$1" in
    "commit")
        generate_commit_message
        ;;
    "review")
        read -p "请输入要审查的文件路径: " file_path
        review_code "$file_path"
        ;;
    "analyze")
        read -p "请输入项目路径: " project_path
        analyze_performance "$project_path"
        ;;
    "models")
        echo "可用的 AI 模型:"
        echo "- OpenAI GPT-3.5/GPT-4"
        echo "- Claude 3"
        echo "- Gemini"
        echo "- 通义千问"
        ;;
    *)
        echo "使用方法: $0 (commit|review|analyze|models)"
        ;;
esac
EOF
    
    chmod +x ai-dev-helper.sh
    
    log_success "AI 开发工具集成完成"
}

# 项目模板生成器
generate_project_template() {
    log_info "生成 AI 项目开发模板"
    
    # 创建项目模板目录
    local template_dir="$WORKSPACE_ROOT/templates"
    mkdir -p "$template_dir"
    
    # Cherry Studio 模板
    cat > "$template_dir/cherry-studio-template.md" << EOF
# Cherry Studio 项目开发模板

## 技术栈
- Electron + React + TypeScript
- Vite 构建工具
- Redux 状态管理
- 现代化 CLI 工具链

## 开发环境配置
1. Node.js v22.22.1
2. npm 或 yarn 包管理器
3. 现代化 CLI 工具 (gh, fzf, rg, eza, bat, fd, dust, jq, tree, htop, ack, nvim, delta, tmux, zoxide, procs, sd)

## 开发工作流
1. **启动开发环境**
   \`\`\`bash
   cd cherry-studio
   ./dev.sh
   \`\`\`

2. **代码检查**
   \`\`\`bash
   npm run lint
   npm run type-check
   \`\`\`

3. **构建项目**
   \`\`\`bash
   npm run build
   \`\`\`

4. **测试**
   \`\`\`bash
   npm test
   \`\`\`

## 特色功能
- AI 助手集成
- 多语言支持
- 跨平台兼容
- 实时协作

## 最佳实践
- 使用 TypeScript 进行类型安全
- 遵循 ESLint 规范
- 定期运行安全审计
- 维护清晰的文档
EOF
    
    # Ring 项目模板
    cat > "$template_dir/ring-template.md" << EOF
# Ring AI 项目开发模板

## 项目概述
Ring 是一个 AI 导航和介绍项目，收集和整理主流 AI 模型和工具信息。

## 技术栈
- 纯静态网站
- Markdown 内容管理
- Git 版本控制
- 现代化 CLI 工具链

## 目录结构
\`\`\`
Ring/
├── LLM/              # 大语言模型目录
│   ├── chatgpt/      # OpenAI ChatGPT
│   ├── claude/       # Anthropic Claude
│   ├── gemini/       # Google Gemini
│   └── ...
├── TOOL/             # AI工具目录
│   ├── cursor/       # AI编程工具
│   └── ...
├── FUTURE/           # 未来规划
├── TECH/             # 技术文档
└── Traval/           # 旅行相关
\`\`\`

## 开发工作流
1. **内容管理**
   \`\`\`bash
   ./ai-content-manager.sh create-model
   ./ai-content-manager.sh create-tool
   \`\`\`

2. **内容同步**
   \`\`\`bash
   ./sync-content.sh
   \`\`\`

3. **代码审查**
   \`\`\`bash
   ./ai-dev-helper.sh review
   \`\`\`

## 内容标准
- 每个模型/工具都有独立的 card.md 文件
- 包含完整的描述、特点、使用场景等信息
- 定期更新评价和定价信息
- 维护清晰的项目结构

## 特色功能
- AI 模型比较
- 工具推荐系统
- 实时更新机制
- 用户评价整合
EOF
    
    log_success "项目模板生成完成"
}

# 主菜单
show_main_menu() {
    echo ""
    echo "🚀 AI 项目开发环境配置"
    echo "=================================="
    echo "1. 配置 Cherry Studio 开发环境"
    echo "2. 配置 Ring AI 导航项目环境"
    echo "3. 设置 AI 开发工具集成"
    echo "4. 生成项目开发模板"
    echo "5. 运行所有配置"
    echo "0. 退出"
    echo "=================================="
    read -p "请选择配置项目: " choice
}

# 主函数
main() {
    log_info "AI 项目开发环境配置开始"
    
    while true; do
        show_main_menu
        
        case "$choice" in
            1)
                configure_cherry_studio
                ;;
            2)
                configure_ring_project
                ;;
            3)
                setup_ai_tools
                ;;
            4)
                generate_project_template
                ;;
            5)
                log_info "运行所有配置..."
                configure_cherry_studio
                configure_ring_project
                setup_ai_tools
                generate_project_template
                log_success "所有配置完成"
                ;;
            0)
                log_info "退出配置程序"
                exit 0
                ;;
            *)
                log_error "无效选择，请重新输入"
                ;;
        esac
    done
}

# 如果直接运行脚本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi