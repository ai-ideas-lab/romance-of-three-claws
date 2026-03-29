#!/bin/bash

# 孔明智能助手 - 智能项目初始化模板
# 用途：为主公快速创建不同类型的项目模板

echo "=== 孔明智能助手 - 智能项目初始化 ==="
echo "初始化时间: $(date)"
echo

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# 检查必要工具
check_tools() {
    local missing=()
    local tools=("git" "node" "npm")
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing+=("$tool")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}❌ 缺少必要工具: ${missing[*]}${NC}"
        return 1
    fi
    return 0
}

# 创建Node.js项目
create_node_project() {
    local project_name=$1
    local template_type=$2
    
    echo -e "${BLUE}创建Node.js项目: $project_name ($template_type)${NC}"
    
    # 创建项目目录
    mkdir -p "$project_name"
    cd "$project_name" || exit 1
    
    # 初始化package.json
    npm init -y
    
    # 根据类型添加依赖
    case $template_type in
        "web")
            npm install express helmet cors morgan
            npm install -D nodemon eslint prettier
            ;;
        "api")
            npm install express helmet cors morgan dotenv
            npm install -D nodemon eslint prettier @types/node
            ;;
        "cli")
            npm install commander inquirer chalk
            npm install -D eslint prettier @types/node
            ;;
        "fullstack")
            npm install express helmet cors morgan dotenv
            npm install -D nodemon eslint prettier @types/node
            # 添加前端框架
            npm install react react-dom
            npm install -D @types/react @types/react-dom
            ;;
    esac
    
    # 创建基础文件结构
    mkdir -p src/{routes,controllers,middleware,utils}
    mkdir -p tests
    mkdir -p docs
    
    # 创建.gitignore
    cat > .gitignore << EOF
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# nyc test coverage
.nyc_output

# Grunt intermediate storage
.grunt

# Bower dependency directory
bower_components

# node-waf configuration
.lock-wscript

# Compiled binary addons
build/Release

# Dependency directories
jspm_packages/

# TypeScript v1 declaration files
typings/

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# parcel-bundler cache
.cache
.parcel-cache

# next.js build output
.next

# nuxt.js build output
.nuxt

# vuepress build output
.vuepress/dist

# Serverless directories
.serverless

# FuseBox cache
.fusebox/

# DynamoDB Local files
.dynamodb/

# TernJS port file
.tern-port

# Stores VSCode versions used for testing VSCode extensions
.vscode-test

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
EOF

    # 创建基础代码文件
    cat > src/app.js << EOF
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');

const app = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Basic route
app.get('/', (req, res) => {
    res.json({ message: 'Welcome to $project_name API' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(\`\$project_name running on port \${PORT}\`);
});

module.exports = app;
EOF

    # 创建测试文件
    cat > tests/app.test.js << EOF
const request = require('supertest');
const app = require('../src/app');

describe('$project_name API', () => {
    test('GET / should return welcome message', async () => {
        const response = await request(app).get('/');
        expect(response.status).toBe(200);
        expect(response.body.message).toBe('Welcome to $project_name API');
    });

    test('GET /health should return status ok', async () => {
        const response = await request(app).get('/health');
        expect(response.status).toBe(200);
        expect(response.body.status).toBe('ok');
    });
});
EOF

    # 创建配置文件
    cat > .eslintrc.json << EOF
{
    "extends": ["eslint:recommended"],
    "env": {
        "node": true,
        "es2021": true
    },
    "parserOptions": {
        "ecmaVersion": 12
    },
    "rules": {
        "indent": ["error", 4],
        "linebreak-style": ["error", "unix"],
        "quotes": ["error", "single"],
        "semi": ["error", "always"]
    }
}
EOF

    cat > .prettierrc << EOF
{
    "semi": true,
    "singleQuote": true,
    "tabWidth": 4,
    "trailingComma": "es5"
}
EOF

    echo -e "${GREEN}✅ Node.js项目 $project_name 创建完成${NC}"
    cd ..
}

# 创建Python项目
create_python_project() {
    local project_name=$1
    local template_type=$2
    
    echo -e "${BLUE}创建Python项目: $project_name ($template_type)${NC}"
    
    mkdir -p "$project_name"
    cd "$project_name" || exit 1
    
    # 创建虚拟环境
    python3 -m venv venv
    source venv/bin/activate
    
    # 根据类型安装依赖
    case $template_type in
        "web")
            pip install flask requests gunicorn pytest
            ;;
        "api")
            pip install fastapi uvicorn requests pytest
            ;;
        "data")
            pip install pandas numpy matplotlib seaborn jupyter pytest
            ;;
        "ml")
            pip install scikit-learn tensorflow torch pandas numpy pytest
            ;;
    esac
    
    # 创建项目结构
    mkdir -p src/{models,services,utils}
    mkdir -p tests
    mkdir -p docs
    
    # 创建.gitignore
    cat > .gitignore << EOF
# Virtual environments
venv/
env/
ENV/
env.bak/
venv.bak/

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# PyInstaller
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/
.pytest_cache/

# Jupyter Notebook
.ipynb_checkpoints

# IPython
profile_default/
ipython_config.py

# pyenv
.python-version

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/
.dmypy.json
dmypy.json
EOF

    # 创建requirements.txt
    cat > requirements.txt << EOF
# Core dependencies
flask==2.3.3
requests==2.31.0
gunicorn==21.2.0
pytest==7.4.3

# Development dependencies
black==23.11.0
flake8==6.1.0
mypy==1.7.1
EOF

    # 创建基础应用
    cat > src/main.py << EOF
"""
$project_name - Main application
"""

from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        "message": "Welcome to $project_name",
        "status": "running"
    })

@app.route('/health')
def health():
    return jsonify({
        "status": "ok",
        "timestamp": str(datetime.datetime.now())
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=True, host='0.0.0.0', port=port)
EOF

    echo -e "${GREEN}✅ Python项目 $project_name 创建完成${NC}"
    cd ..
}

# 显示菜单
show_menu() {
    echo -e "${BLUE}=== 项目类型选择 ===${NC}"
    echo "1. Node.js Web应用"
    echo "2. Node.js API服务"
    echo "3. Node.js CLI工具"
    echo "4. Node.js 全栈应用"
    echo "5. Python Web应用"
    echo "6. Python API服务"
    echo "7. Python 数据分析"
    echo "8. Python 机器学习"
    echo "9. 自定义项目"
    echo "q. 退出"
    echo
}

# 主程序
main() {
    echo -e "${BLUE}=== 孔明智能助手 - 项目初始化模板 ===${NC}"
    echo
    
    if ! check_tools; then
        echo -e "${RED}请先安装必要的开发工具${NC}"
        return 1
    fi
    
    while true; do
        show_menu
        
        read -p "请选择项目类型 (1-9, q): " choice
        
        case $choice in
            1)
                read -p "输入项目名称: " project_name
                create_node_project "$project_name" "web"
                ;;
            2)
                read -p "输入项目名称: " project_name
                create_node_project "$project_name" "api"
                ;;
            3)
                read -p "输入项目名称: " project_name
                create_node_project "$project_name" "cli"
                ;;
            4)
                read -p "输入项目名称: " project_name
                create_node_project "$project_name" "fullstack"
                ;;
            5)
                read -p "输入项目名称: " project_name
                create_python_project "$project_name" "web"
                ;;
            6)
                read -p "输入项目名称: " project_name
                create_python_project "$project_name" "api"
                ;;
            7)
                read -p "输入项目名称: " project_name
                create_python_project "$project_name" "data"
                ;;
            8)
                read -p "输入项目名称: " project_name
                create_python_project "$project_name" "ml"
                ;;
            9)
                read -p "输入项目名称: " project_name
                echo -e "${YELLOW}自定义项目创建功能待实现${NC}"
                ;;
            q)
                echo -e "${GREEN}项目初始化完成！${NC}"
                break
                ;;
            *)
                echo -e "${RED}无效选择，请重新输入${NC}"
                ;;
        esac
        
        echo
    done
}

# 运行主程序
main