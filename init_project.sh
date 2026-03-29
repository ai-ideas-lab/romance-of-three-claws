#!/usr/bin/env bash
# 孔明智能助手 - 项目初始化脚本
# 快速创建标准化项目结构

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${CYAN}孔明智能助手 - 项目初始化脚本${NC}"
    echo "用法: $0 <项目名称> [项目类型]"
    echo
    echo "项目类型:"
    echo "  node      - Node.js 项目 (默认)"
    echo "  react     - React 前端项目"
    echo "  vue       - Vue.js 项目"
    echo "  python    - Python 项目"
    echo "  django    - Django 项目"
    echo "  flask     - Flask 项目"
    echo "  rust      - Rust 项目"
    echo "  go        - Go 项目"
    echo "  docker    - Docker 项目"
    echo "  api       - API 项目"
    echo
    echo "示例:"
    echo "  $0 my-web-app react"
    echo "  $0 my-api python"
}

# 检查参数
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_TYPE="${2:-node}"

# 检查项目目录是否已存在
if [ -d "$PROJECT_NAME" ]; then
    echo -e "${RED}错误: 目录 '$PROJECT_NAME' 已存在${NC}"
    exit 1
fi

echo -e "${BLUE}正在创建项目 '$PROJECT_NAME' (类型: $PROJECT_TYPE)...${NC}"
echo

# 创建基础目录结构
create_base_structure() {
    echo -e "${YELLOW}创建基础目录结构...${NC}"
    mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME" || exit 1
    mkdir -p src docs tests scripts .github
    mkdir -p src/components src/utils src/types
    mkdir -p docs/api docs/deployment
    mkdir -p tests/unit tests/integration
    mkdir -p scripts/deploy scripts/build
    mkdir -p .github/workflows
}

# 创建README
create_readme() {
    echo -e "${YELLOW}创建 README.md...${NC}"
    cat > README.md << EOF
# $PROJECT_NAME

项目描述

## 功能特性

- 特性1
- 特性2
- 特性3

## 开发环境要求

- Node.js >= 16.0.0
- npm >= 8.0.0

## 快速开始

\`\`\`bash
# 克隆项目
git clone <repository-url>
cd $PROJECT_NAME

# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 运行测试
npm test
\`\`\`

## 项目结构

\`\`\`
$PROJECT_NAME/
├── src/                 # 源代码
│   ├── components/     # 组件
│   ├── utils/         # 工具函数
│   └── types/         # TypeScript 类型
├── docs/              # 文档
├── tests/             # 测试
├── scripts/           # 脚本
└── .github/           # GitHub Actions
\`\`\`

## 贡献指南

1. Fork 项目
2. 创建特性分支 (\`git checkout -b feature/AmazingFeature\`)
3. 提交更改 (\`git commit -m 'Add some AmazingFeature'\`)
4. 推送到分支 (\`git push origin feature/AmazingFeature\`)
5. 打开 Pull Request

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件
EOF
}

# 创建.gitignore
create_gitignore() {
    echo -e "${YELLOW}创建 .gitignore...${NC}"
    cat > .gitignore << EOF
# 依赖
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# 构建输出
dist/
build/
out/

# 环境变量
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# 操作系统
.DS_Store
Thumbs.db

# 临时文件
*.tmp
*.temp
EOF
}

# 创建package.json
create_package_json() {
    echo -e "${YELLOW}创建 package.json...${NC}"
    cat > package.json << EOF
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "description": "",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "build": "npm run build:prod",
    "build:prod": "NODE_ENV=production npm run compile",
    "compile": "babel src -d dist",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "lint": "eslint src/",
    "lint:fix": "eslint src/ --fix",
    "format": "prettier --write src/",
    "format:check": "prettier --check src/",
    "prepare": "husky install"
  },
  "keywords": [],
  "author": "",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2"
  },
  "devDependencies": {
    "@babel/core": "^7.22.9",
    "@babel/preset-env": "^7.22.9",
    "@types/jest": "^29.5.3",
    "eslint": "^8.45.0",
    "husky": "^8.0.3",
    "jest": "^29.6.1",
    "nodemon": "^3.0.1",
    "prettier": "^3.0.0"
  }
}
EOF
}

# 根据项目类型创建特定配置
create_project_config() {
    case "$PROJECT_TYPE" in
        "node")
            create_node_config
            ;;
        "react")
            create_react_config
            ;;
        "vue")
            create_vue_config
            ;;
        "python")
            create_python_config
            ;;
        "django")
            create_django_config
            ;;
        "flask")
            create_flask_config
            ;;
        "rust")
            create_rust_config
            ;;
        "go")
            create_go_config
            ;;
        "docker")
            create_docker_config
            ;;
        "api")
            create_api_config
            ;;
        *)
            echo -e "${RED}错误: 未知的项目类型 '$PROJECT_TYPE'${NC}"
            exit 1
            ;;
    esac
}

# Node.js 配置
create_node_config() {
    echo -e "${YELLOW}创建 Node.js 配置文件...${NC}"
    cat > .babelrc << EOF
{
  "presets": ["@babel/preset-env"]
}
EOF

    cat > jest.config.js << EOF
module.exports = {
  testEnvironment: 'node',
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/**/*.test.js',
    '!src/**/*.spec.js'
  ]
};
EOF

    # 创建主文件
    cat > src/index.js << EOF
// $PROJECT_NAME - 主入口文件

console.log('Hello from $PROJECT_NAME!');
EOF
}

# React 配置
create_react_config() {
    PROJECT_TYPE="node"
    create_node_config
    
    echo -e "${YELLOW}创建 React 配置文件...${NC}"
    cat > package.json << EOF
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "description": "",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
EOF

    cat > public/index.html << EOF
<!DOCTYPE html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8" />
    <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta name="description" content="$PROJECT_NAME" />
    <title>$PROJECT_NAME</title>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
EOF

    cat > src/App.js << EOF
import React from 'react';

function App() {
  return (
    <div className="App">
      <h1>$PROJECT_NAME</h1>
    </div>
  );
}

export default App;
EOF

    cat > src/index.js << EOF
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF
}

# Vue 配置
create_vue_config() {
    echo -e "${YELLOW}创建 Vue.js 配置文件...${NC}"
    cat > package.json << EOF
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "description": "",
  "main": "src/index.js",
  "scripts": {
    "serve": "vue-cli-service serve",
    "build": "vue-cli-service build",
    "lint": "vue-cli-service lint"
  },
  "dependencies": {
    "vue": "^3.2.47"
  },
  "devDependencies": {
    "@vue/cli-plugin-babel": "~5.0.0",
    "@vue/cli-plugin-eslint": "~5.0.0",
    "@vue/cli-service": "~5.0.0"
  },
  "eslintConfig": {
    "root": true,
    "env": {
      "node": true
    },
    "extends": [
      'plugin:vue/vue3-essential',
      'eslint:recommended'
    ],
    "parserOptions": {
      "parser": "@babel/eslint-parser"
    }
  },
  "browserslist": [
    "> 1%",
    "last 2 versions",
    "not dead"
  ]
}
EOF
}

# Python 配置
create_python_config() {
    echo -e "${YELLOW}创建 Python 配置文件...${NC}"
    cat > requirements.txt << EOF
flask==2.3.3
python-dotenv==1.0.0
EOF

    cat > .env.example << EOF
FLASK_ENV=development
FLASK_DEBUG=True
SECRET_KEY=your-secret-key-here
EOF

    cat > app.py << EOF
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return f"Hello from $PROJECT_NAME!"

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
EOF

    cat > .flaskenv << EOF
FLASK_APP=app.py
FLASK_ENV=development
EOF
}

# Django 配置
create_django_config() {
    echo -e "${YELLOW}创建 Django 配置文件...${NC}"
    cat > manage.py << EOF
#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys

if __name__ == '__main__':
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', '$PROJECT_NAME.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)
EOF

    mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME" || exit 1
    cat > __init__.py << EOF
EOF

    cat > asgi.py << EOF
"""
ASGI config for $PROJECT_NAME project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/4.2/howto/deployment/asgi/
"""

import os

from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', '$PROJECT_NAME.settings')

application = get_asgi_application()
EOF

    cat > settings.py << EOF
"""
Django settings for $PROJECT_NAME project.

Generated by 'django-admin startproject' using Django 4.2.

For more information on this file, see
https://docs.djangoproject.com/en/4.2/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/4.2/ref/settings/
"""

from pathlib import Path
import os

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'django-insecure-your-secret-key-here'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ALLOWED_HOSTS = []

# Application definition
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = '$PROJECT_NAME.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = '$PROJECT_NAME.wsgi.application'

# Database
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization
LANGUAGE_CODE = 'zh-hans'
TIME_ZONE = 'Asia/Shanghai'
USE_I18N = True
USE_TZ = True

STATIC_URL = 'static/'
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
EOF

    cat > urls.py << EOF
"""$PROJECT_NAME URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path

urlpatterns = [
    path('admin/', admin.site.urls),
]
EOF

    cat > wsgi.py << EOF
"""
WSGI config for $PROJECT_NAME project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/4.2/howto/deployment/wsgi/
"""

import os

from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', '$PROJECT_NAME.settings')

application = get_wsgi_application()
EOF
}

# Flask 配置
create_flask_config() {
    create_python_config
}

# Rust 配置
create_rust_config() {
    echo -e "${YELLOW}创建 Rust 配置文件...${NC}"
    cat > Cargo.toml << EOF
[package]
name = "$PROJECT_NAME"
version = "0.1.0"
edition = "2021"

[dependencies]
EOF

    cat > src/main.rs << EOF
// $PROJECT_NAME - Rust 主程序

fn main() {
    println!("Hello from $PROJECT_NAME!");
}
EOF
}

# Go 配置
create_go_config() {
    echo -e "${YELLOW}创建 Go 配置文件...${NC}"
    cat > go.mod << EOF
module $PROJECT_NAME

go 1.19
EOF

    cat > main.go << EOF
package main

import "fmt"

func main() {
    fmt.Printf("Hello from $PROJECT_name!\n")
}
EOF
}

# Docker 配置
create_docker_config() {
    echo -e "${YELLOW}创建 Docker 配置文件...${NC}"
    cat > Dockerfile << EOF
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm ci --only=production

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
EOF

    cat > docker-compose.yml << EOF
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    volumes:
      - .:/app
      - /app/node_modules
EOF
}

# API 配置
create_api_config() {
    PROJECT_TYPE="node"
    create_node_config
    
    echo -e "${YELLOW}创建 API 专用配置...${NC}"
    cat > src/index.js << EOF
// $PROJECT_NAME - API 服务器

const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(cors());
app.use(express.json());

// 健康检查
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    service: '$PROJECT_NAME'
  });
});

// 根路径
app.get('/', (req, res) => {
  res.json({ 
    message: 'Welcome to $PROJECT_NAME API',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      api: '/api'
    }
  });
});

// API 路由
app.get('/api', (req, res) => {
  res.json({ 
    message: 'This is the API endpoint',
    timestamp: new Date().toISOString()
  });
});

// 错误处理中间件
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// 404 处理
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

app.listen(PORT, () => {
  console.log(\`🚀 $PROJECT_NAME API running on port \${PORT}\`);
});

module.exports = app;
EOF

    # 更新 package.json
    cat > package.json << EOF
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "description": "REST API for $PROJECT_NAME",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "jest",
    "test:watch": "jest --watch"
  },
  "keywords": ["api", "rest", "express"],
  "author": "",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "helmet": "^7.0.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.1",
    "jest": "^29.6.1"
  }
}
EOF
}

# 创建 GitHub Actions 工作流
create_github_workflow() {
    echo -e "${YELLOW}创建 GitHub Actions 工作流...${NC}"
    cat > .github/workflows/ci.yml << EOF
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Use Node.js \${{ matrix.node-version }}
      uses: actions/setup-node@v3
      with:
        node-version: \${{ matrix.node-version }}
        cache: 'npm'
    
    - run: npm ci
    - run: npm run build
    - run: npm test
EOF
}

# 主执行流程
main() {
    create_base_structure
    create_readme
    create_gitignore
    create_project_config
    create_github_workflow
    
    # 返回项目根目录
    cd ..
    
    echo
    echo -e "${GREEN}✅ 项目 '$PROJECT_NAME' 创建成功！${NC}"
    echo
    echo -e "${CYAN}项目结构:${NC}"
    echo -e "${BLUE}📁 $PROJECT_name/${NC}"
    echo -e "${BLUE}  ├── 📁 src/${NC}"
    echo -e "${BLUE}  ├── 📁 docs/${NC}"
    echo -e "${BLUE}  ├── 📁 tests/${NC}"
    echo -e "${BLUE}  ├── 📁 scripts/${NC}"
    echo -e "${BLUE}  ├── 📁 .github/${NC}"
    echo -e "${BLUE}  ├── 📄 README.md${NC}"
    echo -e "${BLUE}  └── 📄 .gitignore${NC}"
    echo
    echo -e "${YELLOW}🚀 下一步:${NC}"
    echo -e "1. cd $PROJECT_NAME"
    echo -e "2. npm install"
    echo -e "3. npm run dev"
    echo
    echo -e "${CYAN}提示: 根据项目类型，你可能需要安装额外的依赖${NC}"
}

# 执行主函数
main