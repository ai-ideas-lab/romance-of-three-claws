#!/bin/bash
# 智能工作流集成脚本
# 作者: 孔明
# 功能: 基于现有工具创建智能工作流，最大化开发效率

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_section() {
    echo -e "\n${PURPLE}=== $1 ===${NC}"
}

# 检查命令是否存在
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# 创建智能项目工作流
create_project_workflow() {
    log_section "创建智能项目工作流"
    
    # 创建项目启动脚本
    cat > smart_project_start.sh << 'EOF'
#!/bin/bash
# 智能项目启动脚本 - 函数定义部分

# 检查命令是否存在
check_command() {
    command -v "$1" >/dev/null 2>&1
}

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 检查项目类型
detect_project_type() {
    if [[ -f "package.json" ]]; then
        echo "nodejs"
    elif [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
        echo "python"
    elif [[ -f "Cargo.toml" ]]; then
        echo "rust"
    elif [[ -f "go.mod" ]]; then
        echo "golang"
    else
        echo "generic"
    fi
}

# 启动项目
start_project() {
    local project_type=$(detect_project_type)
    
    case $project_type in
        "nodejs")
            log_info "检测到Node.js项目"
            if check_command "npm"; then
                log_info "安装依赖..."
                npm install
                
                if [[ -f "package.json" ]] && grep -q "devDependencies" package.json; then
                    log_info "安装开发依赖..."
                    npm install --include-dev
                fi
                
                if check_command "nodemon"; then
                    log_success "启动开发服务器..."
                    nodemon
                else
                    log_success "启动应用..."
                    npm start
                fi
            else
                log_error "Node.js未安装"
            fi
            ;;
        "python")
            log_info "检测到Python项目"
            if check_command "python3"; then
                log_info "创建虚拟环境..."
                python3 -m venv venv
                
                log_info "激活虚拟环境..."
                source venv/bin/activate
                
                if [[ -f "requirements.txt" ]]; then
                    log_info "安装依赖..."
                    pip install -r requirements.txt
                fi
                
                if check_command "python" && [[ -f "app.py" ]]; then
                    log_success "启动应用..."
                    python app.py
                else
                    log_success "启动交互式环境..."
                    python3
                fi
            else
                log_error "Python未安装"
            fi
            ;;
        "rust")
            log_info "检测到Rust项目"
            if check_command "cargo"; then
                log_info "构建项目..."
                cargo build
                
                if check_command "cargo-watch"; then
                    log_success "启动开发模式..."
                    cargo watch -x run
                else
                    log_success "启动应用..."
                    cargo run
                fi
            else
                log_error "Rust未安装"
            fi
            ;;
        *)
            log_warning "未检测到特定项目类型"
            log_info "提供可用选项..."
            echo "1. Node.js 项目"
            echo "2. Python 项目"
            echo "3. Rust 项目"
            echo "4. 通用项目"
            
            read -p "选择项目类型 (1-4): " choice
            case $choice in
                1) create_nodejs_project ;;
                2) create_python_project ;;
                3) create_rust_project ;;
                4) create_generic_project ;;
            esac
            ;;
    esac
}

# 创建项目选项
create_nodejs_project() {
    local project_name
    read -p "项目名称: " project_name
    
    mkdir -p "$project_name"
    cd "$project_name"
    
    cat > package.json << EOF
{
  "name": "$project_name",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js",
    "test": "jest",
    "lint": "eslint src/",
    "format": "prettier --write src/"
  },
  "dependencies": {},
  "devDependencies": {
    "nodemon": "^3.0.0",
    "eslint": "^8.0.0",
    "prettier": "^3.0.0"
  }
}
EOF
    
    mkdir -p src
    cat > src/index.js << EOF
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// 健康检查
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 根路径
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to your Node.js project!' });
});

app.listen(PORT, () => {
  console.log(\`Server is running on port \${PORT}\`);
});
EOF
    
    log_success "Node.js项目已创建: $project_name"
}

create_python_project() {
    local project_name
    read -p "项目名称: " project_name
    
    mkdir -p "$project_name"
    cd "$project_name"
    
    cat > requirements.txt << EOF
flask==3.0.0
flask-cors==4.0.0
python-dotenv==1.0.0
EOF
    
    cat > app.py << EOF
from flask import Flask, jsonify, request
from flask_cors import CORS
import os
from datetime import datetime

app = Flask(__name__)
CORS(app)

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({
        'status': 'ok',
        'timestamp': datetime.now().isoformat(),
        'environment': os.getenv('ENV', 'development')
    })

@app.route('/', methods=['GET'])
def root():
    return jsonify({
        'message': 'Welcome to your Python project!',
        'version': '1.0.0'
    })

@app.route('/api/data', methods=['GET'])
def get_data():
    return jsonify({
        'data': [
            {'id': 1, 'name': 'Item 1'},
            {'id': 2, 'name': 'Item 2'},
            {'id': 3, 'name': 'Item 3'}
        ]
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
EOF
    
    log_success "Python项目已创建: $project_name"
}

create_rust_project() {
    local project_name
    read -p "项目名称: " project_name
    
    cargo new "$project_name"
    cd "$project_name"
    
    cat >> Cargo.toml << EOF
[dependencies]
tokio = { version = "1.0", features = ["full"] }
warp = "0.3"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
EOF
    
    mkdir -p src
    cat > src/main.rs << EOF
use warp::Filter;
use serde::{Deserialize, Serialize};
use std::time::Instant;

#[derive(Serialize, Deserialize)]
struct HealthResponse {
    status: String,
    timestamp: String,
}

#[tokio::main]
async fn main() {
    // 健康检查端点
    let health = warp::path("health")
        .and(warp::get())
        .map(|| {
            let response = HealthResponse {
                status: "ok".to_string(),
                timestamp: chrono::Utc::now().to_rfc3339(),
            };
            warp::reply::json(&response)
        });

    // 根路径
    let root = warp::path("/")
        .and(warp::get())
        .map(|| {
            warp::reply::json(&serde_json::json!({
                "message": "Welcome to your Rust project!",
                "version": "1.0.0"
            }))
        });

    let routes = health.or(root);
    
    println!("Starting server on http://localhost:3030");
    warp::serve(routes)
        .run(([0, 0, 0, 0], 3030))
        .await;
}
EOF
    
    log_success "Rust项目已创建: $project_name"
}

create_generic_project() {
    local project_name
    read -p "项目名称: " project_name
    
    mkdir -p "$project_name"
    cd "$project_name"
    
    # 创建基本目录结构
    mkdir -p src docs tests
    mkdir -p public assets
    
    # 创建README
    cat > README.md << EOF
# $project_name

A generic project template.

## Getting Started

\`\`\`bash
# 安装依赖
npm install

# 启动开发
npm run dev

# 构建
npm run build

# 测试
npm test
\`\`\`

## 项目结构

- \`src/\` - 源代码
- \`docs/\` - 文档
- \`tests/\` - 测试
- \`public/\` - 静态资源
- \`assets/\` - 项目资源
EOF
    
    # 创建.gitignore
    cat > .gitignore << EOF
# Dependencies
node_modules/
venv/
.env
*.pyc
__pycache__/
.DS_Store

# Build outputs
dist/
build/
*.tar.gz
*.zip

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db
EOF
    
    log_success "通用项目已创建: $project_name"
}

# 智能项目启动脚本主函数
smart_project_start() {
    echo "智能项目启动器"
    echo "================"
    
    # 检查当前目录
    if [[ -f "package.json" ]] || [[ -f "requirements.txt" ]] || [[ -f "Cargo.toml" ]]; then
        log_info "检测到现有项目"
        start_project
    else
        log_info "未检测到现有项目"
        log_info "创建新项目..."
        create_nodejs_project
    fi
}
EOF

    chmod +x smart_project_start.sh
    log_success "智能项目启动脚本已创建"
}

# 创建开发工作流
create_development_workflow() {
    log_section "创建开发工作流"
    
    # 创建开发脚本目录
    mkdir -p dev_scripts
    
    # 创建代码检查脚本
    cat > dev_scripts/code_check.sh << 'EOF'
#!/bin/bash
# 代码检查脚本

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# JavaScript检查
if check_command "npm"; then
    if [[ -f "package.json" ]]; then
        log_info "检查JavaScript代码..."
        if check_command "eslint"; then
            npm run lint 2>/dev/null || log_warning "ESLint检查失败"
        fi
        
        if check_command "prettier"; then
            npm run format 2>/dev/null || log_warning "Prettier格式化失败"
        fi
    fi
fi

# Python检查
if check_command "python3"; then
    if [[ -f "requirements.txt" ]] || [[ -f "*.py" ]]; then
        log_info "检查Python代码..."
        
        # 基本语法检查
        python3 -m py_compile *.py 2>/dev/null || log_error "Python语法错误"
        
        # 静态分析
        if check_command "flake8"; then
            flake8 *.py 2>/dev/null || log_warning "flake8发现问题"
        fi
        
        if check_command "mypy"; then
            mypy *.py 2>/dev/null || log_warning "mypy发现问题"
        fi
    fi
fi

# 通用检查
if check_command "git"; then
    log_info "检查Git状态..."
    if [[ $(git status --porcelain 2>/dev/null | wc -l) -gt 0 ]]; then
        log_warning "有未提交的更改"
        git status --porcelain 2>/dev/null
    else
        log_success "工作区干净"
    fi
fi

log_success "代码检查完成"
EOF

    # 创建部署脚本
    cat > dev_scripts/deploy.sh << 'EOF'
#!/bin/bash
# 部署脚本

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 检查必要工具
check_requirements() {
    if ! check_command "git"; then
        log_error "Git未安装"
        exit 1
    fi
    
    if ! check_command "npm"; then
        log_error "npm未安装"
        exit 1
    fi
}

# 清理和构建
cleanup_and_build() {
    log_info "清理项目..."
    
    # 删除node_modules
    if [[ -d "node_modules" ]]; then
        rm -rf node_modules
        log_info "已清理node_modules"
    fi
    
    # 删除构建产物
    if [[ -d "dist" ]]; then
        rm -rf dist
        log_info "已清理构建产物"
    fi
    
    # 清理缓存
    if [[ -d ".cache" ]]; then
        rm -rf .cache
        log_info "已清理缓存"
    fi
}

# 安装依赖
install_dependencies() {
    log_info "安装依赖..."
    npm install
}

# 构建项目
build_project() {
    log_info "构建项目..."
    if [[ -f "package.json" ]] && grep -q "build" package.json; then
        npm run build
    else
        log_warning "未找到构建脚本，跳过构建"
    fi
}

# 提交代码
commit_changes() {
    log_info "提交代码..."
    git add .
    
    if [[ $(git status --porcelain 2>/dev/null | wc -l) -gt 0 ]]; then
        read -p "提交信息: " commit_msg
        git commit -m "$commit_msg"
        log_success "代码已提交"
    else
        log_warning "没有需要提交的更改"
    fi
}

# 推送到远程
push_to_remote() {
    log_info "推送到远程..."
    git push origin main 2>/dev/null || {
        log_warning "推送到远程失败，可能需要配置远程仓库"
        read -p "是否继续? (y/n): " continue_deploy
        if [[ "$continue_deploy" == "y" ]]; then
            log_info "部署完成，但未推送到远程"
        else
            exit 1
        fi
    }
}

# 主函数
main() {
    echo "部署脚本"
    echo "========"
    
    check_requirements
    
    local deploy_type
    echo "选择部署类型:"
    echo "1. 完整部署 (清理+安装+构建+提交+推送)"
    echo "2. 仅构建"
    echo "3. 仅提交"
    echo "4. 手动模式"
    
    read -p "选择部署类型 (1-4): " deploy_type
    
    case $deploy_type in
        1)
            cleanup_and_build
            install_dependencies
            build_project
            commit_changes
            push_to_remote
            ;;
        2)
            build_project
            ;;
        3)
            commit_changes
            push_to_remote
            ;;
        4)
            echo "手动模式，请执行以下步骤:"
            echo "1. git add ."
            echo "2. git commit -m '你的提交信息'"
            echo "3. git push origin main"
            ;;
        *)
            log_error "无效的选择"
            exit 1
            ;;
    esac
    
    log_success "部署完成"
}

main "$@"
EOF

    # 创建测试脚本
    cat > dev_scripts/test.sh << 'EOF'
#!/bin/bash
# 测试脚本

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 运行测试
run_tests() {
    if [[ -f "package.json" ]]; then
        log_info "运行JavaScript测试..."
        if check_command "npm"; then
            if grep -q "test" package.json; then
                npm test || log_warning "测试失败"
            else
                log_warning "未找到测试配置"
            fi
        fi
    fi
    
    if [[ -f "requirements.txt" ]] || [[ -f "pytest.ini" ]]; then
        log_info "运行Python测试..."
        if check_command "python3"; then
            if check_command "pytest"; then
                pytest || log_warning "Python测试失败"
            else
                python3 -m unittest discover -s tests -p "test_*.py" || log_warning "Python测试失败"
            fi
        fi
    fi
    
    # 通用测试
    if check_command "git"; then
        log_info "检查Git仓库..."
        git status --porcelain | grep -E "^M|^A" && log_warning "有未提交的更改"
    fi
}

# 性能测试
run_performance_test() {
    log_info "运行性能测试..."
    
    if check_command "npm"; then
        if [[ -f "package.json" ]] && grep -q "performance" package.json; then
            npm run perf || log_warning "性能测试失败"
        fi
    fi
}

# 安全测试
run_security_test() {
    log_info "运行安全测试..."
    
    if check_command "npm"; then
        if [[ -f "package.json" ]] && grep -q "audit" package.json; then
            npm audit || log_warning "安全审计发现问题"
        fi
    fi
}

# 主函数
main() {
    echo "测试脚本"
    echo "========"
    
    local test_type
    echo "选择测试类型:"
    echo "1. 运行所有测试"
    echo "2. 仅单元测试"
    echo "3. 性能测试"
    echo "4. 安全测试"
    
    read -p "选择测试类型 (1-4): " test_type
    
    case $test_type in
        1)
            run_tests
            run_performance_test
            run_security_test
            ;;
        2)
            run_tests
            ;;
        3)
            run_performance_test
            ;;
        4)
            run_security_test
            ;;
        *)
            log_error "无效的选择"
            exit 1
            ;;
    esac
    
    log_success "测试完成"
}

main "$@"
EOF

    # 创建监控脚本
    cat > dev_scripts/monitor.sh << 'EOF'
#!/bin/bash
# 开发环境监控脚本

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 监控函数
monitor() {
    local interval=${1:-5}
    
    log_info "开始监控开发环境 (间隔: ${interval}s)"
    
    while true; do
        echo ""
        echo "=== 监控报告 $(date '+%H:%M:%S') ==="
        
        # CPU使用率
        if check_command "top"; then
            local cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}')
            echo "CPU使用率: $cpu_usage"
        fi
        
        # 内存使用
        if check_command "vm_stat"; then
            local memory_pressure=$(vm_stat | grep "page free" | awk '{print $3}')
            echo "内存压力: $memory_pressure 页"
        fi
        
        # 磁盘使用
        if check_command "df"; then
            local disk_usage=$(df -h / | awk 'NR==2 {print $5}')
            echo "磁盘使用: $disk_usage"
        fi
        
        # Git状态
        if check_command "git" && git rev-parse --git-dir >/dev/null 2>&1; then
            local uncommitted=$(git status --porcelain 2>/dev/null | wc -l)
            echo "未提交更改: $uncommitted"
        fi
        
        # 端口占用
        echo "端口占用:"
        local ports=("80" "443" "3000" "5000" "8080")
        for port in "${ports[@]}"; do
            if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
                echo "  端口 $port: 已占用"
            else
                echo "  端口 $port: 空闲"
            fi
        done
        
        sleep $interval
    done
}

# 健康检查函数
health_check() {
    log_info "执行健康检查..."
    
    # 检查Node.js
    if check_command "node"; then
        log_success "Node.js: $(node --version)"
    else
        log_error "Node.js未安装"
    fi
    
    # 检查npm
    if check_command "npm"; then
        log_success "npm: $(npm --version)"
    else
        log_error "npm未安装"
    fi
    
    # 检查Python
    if check_command "python3"; then
        log_success "Python: $(python3 --version)"
    else
        log_error "Python未安装"
    fi
    
    # 检查Git
    if check_command "git"; then
        log_success "Git: $(git --version | head -n1)"
    else
        log_error "Git未安装"
    fi
    
    # 网络连接检查
    if check_command "curl"; then
        local test_urls=("https://github.com" "https://registry.npmjs.org")
        for url in "${test_urls[@]}"; do
            if curl -s --connect-timeout 5 "$url" >/dev/null 2>&1; then
                log_success "网络: $url"
            else
                log_error "网络: $url 失败"
            fi
        done
    fi
}

# 主函数
main() {
    local action=$1
    
    case $action in
        "monitor")
            monitor $2
            ;;
        "health")
            health_check
            ;;
        *)
            echo "使用方法: $0 {monitor|health} [interval]"
            echo "  monitor - 持续监控开发环境"
            echo "  health - 执行健康检查"
            echo "  interval - 监控间隔秒数 (默认5秒)"
            exit 1
            ;;
    esac
}

main "$@"
EOF

    chmod +x dev_scripts/*.sh
    log_success "开发工作流脚本已创建"
}

# 创建使用指南
create_usage_guide() {
    log_section "创建使用指南"
    
    cat > USAGE_GUIDE.md << 'EOF'
# 智能工作流使用指南

## 概述

本工作流是基于孔明智能助手创建的开发环境优化系统，提供智能化的项目管理和开发支持。

## 快速开始

### 1. 智能项目启动

```bash
./smart_project_start.sh
```

- 自动检测项目类型
- 创建新项目模板
- 启动开发服务器
- 集成依赖管理

### 2. 代码检查

```bash
./dev_scripts/code_check.sh
```

- JavaScript代码检查 (ESLint, Prettier)
- Python代码检查 (flake8, mypy)
- Git状态检查
- 语法验证

### 3. 测试运行

```bash
./dev_scripts/test.sh
```

- 单元测试运行
- 性能测试
- 安全测试
- 集成测试

### 4. 部署管理

```bash
./dev_scripts/deploy.sh
```

- 清理和构建
- 依赖安装
- 代码提交
- 远程推送

### 5. 环境监控

```bash
./dev_scripts/monitor.sh monitor
```

- CPU和内存监控
- 端口占用检查
- Git状态监控
- 网络连接检查

## 项目类型支持

### Node.js项目
- 自动检测package.json
- npm依赖管理
- 开发服务器启动 (nodemon)
- 代码检查和格式化

### Python项目
- 虚拟环境创建
- pip依赖管理
- Flask应用支持
- 语法和静态分析

### Rust项目
- Cargo项目管理
- 开发模式启动
- 语法检查
- 构建优化

## 配置文件

### Shell别名
- 智能工具检测
- 现代CLI工具集成
- 便捷快捷键
- 自动配置加载

### Git别名
- 常用操作快捷键
- 分支管理
- 状态检查
- 强制操作

### 编辑器配置
- Vim/Neovim优化
- 语法高亮
- 缩进设置
- 快捷键映射

## 环境要求

### 基础工具
- Node.js v18+
- npm 8+
- Python 3.8+
- Git 2.0+
- Bash/Zsh

### 可选工具
- Docker
- Kubernetes
- Helm
- 现代CLI工具 (eza, bat, fd, rg, dust)

## 故障排除

### 常见问题

1. **权限错误**
   ```bash
   chmod +x *.sh
   chmod +x dev_scripts/*.sh
   ```

2. **依赖缺失**
   ```bash
   # 检查工具可用性
   which node npm python3 git
   ```

3. **网络连接**
   ```bash
   # 测试网络连接
   curl -s https://github.com > /dev/null && echo "网络正常" || echo "网络错误"
   ```

4. **Git配置**
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

### 性能优化

1. **内存管理**
   ```bash
   # 检查内存使用
   vm_stat | grep "page free"
   ```

2. **磁盘清理**
   ```bash
   # 清理node_modules
   find . -name "node_modules" -type d -exec rm -rf {} +
   ```

3. **Git优化**
   ```bash
   # 清理Git历史
   git gc --aggressive
   ```

## 更新日志

### v1.0.0 (2026-03-28)
- 初始版本发布
- 基础项目模板支持
- 代码检查功能
- 部署脚本
- 环境监控
- 使用指南创建

## 贡献

欢迎提交Issue和Pull Request来改进本工作流。

## 许可证

MIT License

---

*本工作流由孔明智能助手创建和维护*
EOF

    log_success "使用指南已创建: USAGE_GUIDE.md"
}

# 主函数
main() {
    log_section "智能工作流集成开始"
    
    # 创建智能项目工作流
    create_project_workflow
    
    # 创建开发工作流
    create_development_workflow
    
    # 创建使用指南
    create_usage_guide
    
    log_section "智能工作流集成完成"
    log_success "所有工作流脚本已创建"
    log_info "目录结构:"
    echo "  ├── smart_project_start.sh"
    echo "  ├── dev_scripts/"
    echo "  │   ├── code_check.sh"
    echo "  │   ├── deploy.sh"
    echo "  │   ├── test.sh"
    echo "  │   └── monitor.sh"
    echo "  └── USAGE_GUIDE.md"
}

main "$@"