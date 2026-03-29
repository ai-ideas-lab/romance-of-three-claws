#!/bin/bash
# 🎯 Docker环境配置和智能项目管理器
# 孔明第59轮优化 - 完善Docker生态和项目管理智能系统

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
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

# 检查是否需要安装Docker
check_docker_installation() {
    log_info "检查Docker安装状态..."
    
    if command -v docker >/dev/null 2>&1; then
        log_success "Docker已安装: $(docker --version)"
        return 0
    else
        log_warning "Docker未安装，开始安装..."
        return 1
    fi
}

# 安装Docker Desktop
install_docker() {
    log_info "开始安装Docker Desktop..."
    
    # 检查Homebrew是否已安装
    if ! command -v brew >/dev/null 2>&1; then
        log_error "Homebrew未安装，请先安装Homebrew"
        exit 1
    fi
    
    # 安装Docker Desktop
    if brew install --cask docker; then
        log_success "Docker Desktop安装成功"
        
        # 等待Docker Desktop启动
        log_info "等待Docker Desktop启动..."
        sleep 10
        
        # 验证Docker安装
        if docker --version >/dev/null 2>&1; then
            log_success "Docker验证成功"
        else
            log_warning "Docker安装验证失败，请手动启动Docker Desktop"
        fi
    else
        log_error "Docker Desktop安装失败"
        exit 1
    fi
}

# 配置Docker镜像加速
configure_docker_mirror() {
    log_info "配置Docker镜像加速..."
    
    # 创建或修改Docker配置文件
    mkdir -p ~/.docker
    
    cat > ~/.docker/daemon.json << EOF
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ],
  "insecure-registries": [],
  "debug": false,
  "experimental": false,
  "max-concurrent-downloads": 10,
  "max-concurrent-uploads": 5
}
EOF
    
    log_success "Docker镜像加速配置完成"
}

# 安装Docker Compose
install_docker_compose() {
    log_info "检查Docker Compose..."
    
    if command -v docker-compose >/dev/null 2>&1; then
        log_success "Docker Compose已安装: $(docker-compose --version)"
    else
        log_info "安装Docker Compose..."
        
        # 使用Homebrew安装
        if brew install docker-compose; then
            log_success "Docker Compose安装成功"
        else
            log_error "Docker Compose安装失败"
            exit 1
        fi
    fi
}

# 创建Docker项目配置
create_docker_project_configs() {
    log_info "创建Docker项目配置..."
    
    # Cherry Studio Docker配置
    mkdir -p /Users/wangshihao/projects/ai/cherry-studio/docker
    cat > /Users/wangshihao/projects/ai/cherry-studio/docker/docker-compose.dev.yml << EOF
version: '3.8'

services:
  # 开发环境
  dev:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - ./src:/app/src
      - ./packages:/app/packages
    ports:
      - "3000:3000"
      - "8080:8080"
    environment:
      - NODE_ENV=development
      - VITE_API_BASE_URL=http://localhost:8080
    command: npm run dev

  # 测试环境
  test:
    build:
      context: .
      dockerfile: Dockerfile.test
    volumes:
      - ./src:/app/src
      - ./packages:/app/packages
    command: npm test

  # 构建环境
  build:
    build:
      context: .
      dockerfile: Dockerfile.build
    volumes:
      - ./dist:/app/dist
    command: npm run build
EOF

    # Ring项目Docker配置
    mkdir -p /Users/wangshihao/projects/ai/Ring/docker
    cat > /Users/wangshihao/projects/ai/Ring/docker/docker-compose.yml << EOF
version: '3.8'

services:
  # Ring网站服务
  web:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./content:/usr/share/nginx/html
    restart: unless-stopped

  # 文件构建服务
  build:
    image: node:18-alpine
    volumes:
      - .:/app
      - /app/node_modules
    working_dir: /app
    command: npm install && npm run build
    environment:
      - NODE_ENV=production
EOF

    log_success "Docker项目配置创建完成"
}

# 智能项目管理函数
smart_project_manager() {
    log_info "启动智能项目管理系统..."
    
    while true; do
        clear
        echo "🎯 智能项目管理中心"
        echo "========================"
        echo "1. Cherry Studio项目状态"
        echo "2. Ring项目状态"
        echo "3. 多项目任务管理"
        echo "4. 开发环境检查"
        echo "5. Docker环境管理"
        echo "6. 项目健康监控"
        echo "7. 退出"
        echo ""
        
        read -p "请选择操作 (1-7): " choice
        
        case $choice in
            1)
                check_project_status "Cherry Studio" "/Users/wangshihao/projects/ai/cherry-studio"
                ;;
            2)
                check_project_status "Ring" "/Users/wangshihao/projects/ai/Ring"
                ;;
            3)
                multi_project_management
                ;;
            4)
                development_environment_check
                ;;
            5)
                docker_environment_management
                ;;
            6)
                project_health_monitor
                ;;
            7)
                log_info "退出智能项目管理系统"
                break
                ;;
            *)
                log_error "无效选择，请重新输入"
                ;;
        esac
        
        read -p "按回车键继续..."
    done
}

# 检查项目状态
check_project_status() {
    local project_name=$1
    local project_path=$2
    
    echo ""
    echo "🚀 $project_name 项目状态"
    echo "================================"
    
    if [ -d "$project_path" ]; then
        echo "✅ 项目目录存在: $project_path"
        echo "✅ Git状态:"
        cd "$project_path" && git status --porcelain
        cd - > /dev/null
        
        echo ""
        echo "📁 项目结构:"
        ls -la "$project_path" | head -20
        
        echo ""
        echo "🔧 依赖状态:"
        if [ -f "$project_path/package.json" ]; then
            echo "✅ package.json 存在"
            if [ -d "$project_path/node_modules" ]; then
                echo "✅ node_modules 已安装"
            else
                echo "⚠️  node_modules 未安装"
            fi
        fi
        
        if [ -f "$project_path/yarn.lock" ]; then
            echo "✅ 使用Yarn包管理器"
        elif [ -f "$project_path/package-lock.json" ]; then
            echo "✅ 使用NPM包管理器"
        fi
    else
        echo "❌ 项目目录不存在: $project_path"
    fi
}

# 多项目管理
multi_project_management() {
    echo ""
    echo "🎯 多项目任务管理"
    echo "================================"
    
    # Cherry Studio任务
    echo ""
    echo "🍒 Cherry Studio 任务:"
    echo "1. 开发环境启动"
    echo "2. 代码质量检查"
    echo "3. 构建打包"
    echo "4. 测试运行"
    
    # Ring任务
    echo ""
    echo "💍 Ring 任务:"
    echo "1. 内容管理"
    echo "2. 静态网站构建"
    echo "3. 部署准备"
    echo "4. 文档更新"
    
    echo ""
    read -p "选择要执行的任务 (1-8): " task_choice
    
    case $task_choice in
        1)
            log_info "启动Cherry Studio开发环境..."
            cd /Users/wangshihao/projects/ai/cherry-studio && npm run dev
            ;;
        2)
            log_info "Cherry Studio代码质量检查..."
            cd /Users/wangshihao/projects/ai/cherry-studio && npm run lint
            ;;
        3)
            log_info "Cherry Studio构建打包..."
            cd /Users/wangshihao/projects/ai/cherry-studio && npm run build
            ;;
        4)
            log_info "Cherry Studio测试运行..."
            cd /Users/wangshihao/projects/ai/cherry-studio && npm test
            ;;
        5)
            log_info "Ring内容管理..."
            cd /Users/wangshihao/projects/ai/Ring
            # 这里可以添加内容管理命令
            ;;
        6)
            log_info "Ring静态网站构建..."
            cd /Users/wangshihao/projects/ai/Ring && npm run build
            ;;
        7)
            log_info "Ring部署准备..."
            cd /Users/wangshihao/projects/ai/Ring
            # 这里可以添加部署准备命令
            ;;
        8)
            log_info "Ring文档更新..."
            cd /Users/wangshihao/projects/ai/Ring
            # 这里可以添加文档更新命令
            ;;
        *)
            log_error "无效选择"
            ;;
    esac
}

# 开发环境检查
development_environment_check() {
    echo ""
    echo "🔧 开发环境检查"
    echo "================================"
    
    # Node.js环境
    echo "Node.js: $(node --version)"
    echo "npm: $(npm --version)"
    echo "yarn: $(yarn --version 2>/dev/null || echo '未安装')"
    
    # Python环境
    echo ""
    echo "Python: $(python3 --version)"
    echo "pip: $(pip3 --version 2>/dev/null || echo '未安装')"
    
    # Rust环境
    echo ""
    echo "Rust: $(rustc --version 2>/dev/null || echo '未安装')"
    
    # Docker环境
    echo ""
    if command -v docker >/dev/null 2>&1; then
        echo "Docker: $(docker --version)"
        echo "Docker Compose: $(docker-compose --version 2>/dev/null || echo '未安装')"
    else
        echo "Docker: 未安装"
    fi
    
    # Git状态
    echo ""
    echo "Git配置:"
    git config --global user.name
    git config --global user.email
}

# Docker环境管理
docker_environment_management() {
    echo ""
    echo "🐳 Docker环境管理"
    echo "================================"
    
    if command -v docker >/dev/null 2>&1; then
        echo "Docker系统状态:"
        docker info 2>/dev/null || echo "Docker未运行"
        
        echo ""
        echo "Docker容器状态:"
        docker ps -a
        
        echo ""
        echo "Docker镜像列表:"
        docker images | head -10
    else
        log_error "Docker未安装"
    fi
}

# 项目健康监控
project_health_monitor() {
    echo ""
    echo "📊 项目健康监控"
    echo "================================"
    
    # Cherry Studio健康状态
    echo "🍒 Cherry Studio:"
    if [ -d "/Users/wangshihao/projects/ai/cherry-studio" ]; then
        echo "✅ 项目目录存在"
        if [ -f "/Users/wangshihao/projects/ai/cherry-studio/package.json" ]; then
            echo "✅ package.json存在"
            if [ -d "/Users/wangshihao/projects/ai/cherry-studio/node_modules" ]; then
                echo "✅ 依赖已安装"
            else
                echo "⚠️  依赖未安装"
            fi
        else
            echo "❌ package.json不存在"
        fi
    else
        echo "❌ 项目目录不存在"
    fi
    
    # Ring健康状态
    echo ""
    echo "💍 Ring:"
    if [ -d "/Users/wangshihao/projects/ai/Ring" ]; then
        echo "✅ 项目目录存在"
        if [ -f "/Users/wangshihao/projects/ai/Ring/package.json" ]; then
            echo "✅ package.json存在"
            if [ -d "/Users/wangshihao/projects/ai/Ring/node_modules" ]; then
                echo "✅ 依赖已安装"
            else
                echo "⚠️  依赖未安装"
            fi
        else
            echo "❌ package.json不存在"
        fi
    else
        echo "❌ 项目目录不存在"
    fi
    
    # 系统资源状态
    echo ""
    echo "💻 系统资源状态:"
    echo "CPU负载: $(top -l 1 -n 0 | grep "CPU usage" | awk '{print $3}')"
    echo "内存使用: $(ps -caxm -orss,comm | awk '{ sum += $1 } END { print sum/1024/1024 " GB" }')"
    echo "磁盘使用: $(df -h / | tail -1 | awk '{print $5}')"
}

# 主函数
main() {
    echo "🎯 孔明第59轮优化 - Docker环境配置和智能项目管理"
    echo "=================================================="
    
    # 检查Docker安装状态
    if ! check_docker_installation; then
        install_docker
    fi
    
    # 配置Docker镜像加速
    configure_docker_mirror
    
    # 安装Docker Compose
    install_docker_compose
    
    # 创建Docker项目配置
    create_docker_project_configs
    
    echo ""
    echo "🎉 Docker环境配置完成！"
    echo ""
    echo "🚀 启动智能项目管理系统？(y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        smart_project_manager
    fi
    
    log_success "第59轮优化完成！"
}

# 运行主函数
main "$@"