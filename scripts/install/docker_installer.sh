#!/bin/bash

# 孔明智能助手 - Docker环境安装器
# 为OpenClaw工作空间安装Docker Desktop

echo "🏯 孔明Docker环境安装器启动"
echo "⏰ 时间: $(date)"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查是否已安装Docker
if command -v docker >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker已安装${NC}"
    echo "版本信息:"
    docker --version
    docker-compose --version 2>/dev/null || echo "Docker Compose 未安装"
    echo ""
    echo "🎉 Docker环境已就绪！"
    exit 0
fi

echo -e "${BLUE}🔍 检测到Docker未安装，开始安装...${NC}"
echo ""

# 检查Homebrew是否可用
if ! command -v brew >/dev/null 2>&1; then
    echo -e "${RED}❌ Homebrew未安装，需要先安装Homebrew${NC}"
    echo -e "${YELLOW}📝 请运行以下命令安装Homebrew:${NC}"
    echo "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

echo -e "${BLUE}📦 正在通过Homebrew安装Docker Desktop...${NC}"
echo "这可能需要较长时间..."
echo ""

# 安装Docker Desktop
brew install --cask docker

# 检查安装是否成功
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Docker Desktop安装成功${NC}"
    echo ""
    
    # 验证安装
    echo -e "${BLUE}🔍 验证Docker安装...${NC}"
    echo "Docker版本:"
    docker --version
    
    if command -v docker-compose >/dev/null 2>&1; then
        echo ""
        echo "Docker Compose版本:"
        docker-compose --version
    else
        echo ""
        echo -e "${YELLOW}⚠️ Docker Compose未找到，可能需要单独安装${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}🎉 Docker Desktop安装完成！${NC}"
    echo ""
    echo -e "${YELLOW}📝 重要提示:${NC}"
    echo "1. 请启动Docker Desktop应用程序"
    echo "2. 等待Docker服务完全启动"
    echo "3. 验证docker命令是否可用"
    echo ""
    echo -e "${BLUE}🔄 配置PATH环境变量...${NC}"
    
    # 检查PATH中是否已包含Docker
    if ! echo "$PATH" | grep -q "/Applications/Docker.app/Contents/Resources/bin"; then
        echo "正在将Docker添加到PATH..."
        
        # 检查使用的shell
        if [[ "$SHELL" == */zsh ]]; then
            CONFIG_FILE="$HOME/.zshrc"
        else
            CONFIG_FILE="$HOME/.bash_profile"
        fi
        
        # 添加Docker到PATH
        echo 'export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"' >> "$CONFIG_FILE"
        echo "已将Docker添加到 $CONFIG_FILE"
        
        echo ""
        echo -e "${YELLOW}📝 请重新启动终端或运行以下命令使配置生效:${NC}"
        echo "source $CONFIG_FILE"
    else
        echo "PATH已包含Docker路径"
    fi
    
else
    echo -e "${RED}❌ Docker Desktop安装失败${NC}"
    exit 1
fi