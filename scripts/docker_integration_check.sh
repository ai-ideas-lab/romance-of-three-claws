#!/bin/bash

# Docker技能集成优化脚本 - 第60轮优化
# 功能：Docker技能集成、系统优化、智能配置

echo "🚀 Docker技能集成优化启动 - $(date)"
echo "================================"

# 颜色定义
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 1. 已安装Docker技能检查
echo -e "${BLUE}🐳 已安装Docker技能检查${NC}"
echo "--------------------------"

if [ -d "/Users/wangshihao/.openclaw/workspace/skills/docker-essentials" ]; then
    echo -e "${GREEN}✅ docker-essentials: 已安装${NC}"
    
    # 检查docker命令是否可用
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}✅ Docker 命令: 可用${NC}"
        docker --version 2>/dev/null | head -1
    else
        echo -e "${YELLOW}⚠️  Docker 命令: 不可用${NC}"
    fi
else
    echo -e "${RED}❌ docker-essentials: 未安装${NC}"
fi

# 2. 其他Docker技能安装状态检查
echo -e "\n${BLUE}🔍 其他Docker技能安装状态${NC}"
echo "---------------------------"

skills=("docker-compose" "docker-ctl" "docker-diag")

for skill in "${skills[@]}"; do
    skill_path="/Users/wangshihao/.openclaw/workspace/skills/$skill"
    if [ -d "$skill_path" ]; then
        echo -e "${GREEN}✅ $skill: 已安装${NC}"
    else
        echo -e "${YELLOW}⏳ $skill: 安装中${NC}"
    fi
done

# 3. Docker环境完整性检查
echo -e "\n${BLUE}🔬 Docker环境完整性检查${NC}"
echo "------------------------"

# Docker Desktop状态
if [ -d "/Applications/Docker.app" ]; then
    echo -e "${GREEN}✅ Docker Desktop: 已安装${NC}"
    
    # 检查Docker是否运行
    if docker info &> /dev/null; then
        echo -e "${GREEN}✅ Docker服务: 运行正常${NC}"
        echo "   🔹 Docker版本: $(docker --version)"
        echo "   🔹 容器数量: $(docker ps -q | wc -l) 个运行中"
        echo "   🔹 镜像数量: $(docker images -q | wc -l) 个"
    else
        echo -e "${YELLOW}⚠️  Docker服务: 未运行${NC}"
        echo "   🔹 建议: 启动Docker Desktop"
    fi
else
    echo -e "${YELLOW}⚠️  Docker Desktop: 未安装${NC}"
    echo "   🔹 建议: 从官网下载Docker Desktop"
fi

# 4. Docker Compose检查
echo -e "\n${BLUE}🔄 Docker Compose检查${NC}"
echo "---------------------"

if command -v docker-compose &> /dev/null; then
    echo -e "${GREEN}✅ docker-compose: 可用${NC}"
    docker-compose --version 2>/dev/null | head -1
else
    echo -e "${YELLOW}⚠️  docker-compose: 不可用${NC}"
    echo "   🔹 建议: 等待docker-compose技能安装完成"
fi

# 5. Dockerfile检查
echo -e "\n${BLUE}📄 Dockerfile检查${NC}"
echo "-----------------"

if [ -f "Dockerfile" ]; then
    echo -e "${GREEN}✅ Dockerfile: 当前目录存在${NC}"
    echo "   🔹 文件大小: $(stat -f%z Dockerfile) 字节"
    echo "   🔹 最后修改: $(stat -f%Sm Dockerfile)"
else
    echo -e "${CYAN}📋 Dockerfile: 当前目录不存在${NC}"
    echo "   🔹 建议: 创建Dockerfile以开始容器化"
fi

# 6. .dockerignore检查
echo -e "\n${BLUE}🔒 .dockerignore检查${NC}"
echo "---------------------"

if [ -f ".dockerignore" ]; then
    echo -e "${GREEN}✅ .dockerignore: 存在${NC}"
    echo "   🔹 忽略规则数: $(wc -l < .dockerignore) 条"
else
    echo -e "${CYAN}📋 .dockerignore: 不存在${NC}"
    echo "   🔹 建议: 创建.dockerignore优化构建上下文"
fi

# 7. Docker优化建议
echo -e "\n${BLUE}💡 Docker优化建议${NC}"
echo "================"

echo "基于当前环境状态，建议以下优化："

if ! docker info &> /dev/null; then
    echo "   🔸 优先任务:"
    echo "      - 启动Docker Desktop"
    echo "      - 等待Docker服务完全启动"
    echo "      - 验证docker命令可用性"
fi

if ! command -v docker-compose &> /dev/null; then
    echo "   🔸 等待技能安装:"
    echo "      - 等待docker-compose技能安装完成"
    echo "      - 验证docker-compose命令可用性"
    echo "      - 创建docker-compose.yml文件"
fi

if [ ! -f "Dockerfile" ]; then
    echo "   🔸 项目容器化:"
    echo "      - 为项目创建Dockerfile"
    echo "      - 设置适当的基础镜像"
    echo "      - 配置构建和运行环境"
fi

# 8. Docker工作流模板
echo -e "\n${BLUE}🛠️ Docker工作流模板${NC}"
echo "=================="

echo "为Cherry Studio项目准备的Docker工作流模板："

echo "📋 Dockerfile模板:"
cat << 'EOF'
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]
EOF

echo -e "\n📋 docker-compose.yml模板:"
cat << 'EOF'
version: '3.8'

services:
  cherry-studio:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    volumes:
      - ./logs:/app/logs
    
  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
    
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: cherry_studio
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: secret
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
EOF

# 9. 集成检查清单
echo -e "\n${BLUE}✅ 集成检查清单${NC}"
echo "================"

check_items=(
    "Docker Desktop安装和运行"
    "docker-essentials技能可用"
    "docker-compose技能可用"
    "Dockerfile项目配置"
    "docker-compose.yml多容器配置"
    "环境变量和卷挂载配置"
    "端口映射和网络配置"
    "日志和监控配置"
)

for item in "${check_items[@]}"; do
    echo "   📋 $item: 待完成"
done

# 10. 下一步行动计划
echo -e "\n${BLUE}🎯 下一步行动计划${NC}"
echo "=================="

echo "🔹 立即执行:"
echo "   1. 启动Docker Desktop"
echo "   2. 等待docker-compose技能安装完成"
echo "   3. 验证Docker命令可用性"

echo -e "\n🔹 短期任务:"
echo "   1. 为Cherry Studio创建Dockerfile"
echo "   2. 创建docker-compose.yml配置"
echo "   3. 配置环境变量和卷挂载"

echo -e "\n🔹 中期优化:"
echo "   1. 配置Docker镜像缓存优化"
echo "   2. 设置多阶段构建"
echo "   3. 配置Docker网络和卷管理"

echo -e "\n${BLUE}✅ Docker集成优化检查完成 - $(date)${NC}"
echo "================================"