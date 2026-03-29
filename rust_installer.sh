#!/bin/bash

# 孔明智能助手 - Rust环境安装器
# 为OpenClaw工作空间添加Rust开发环境

echo "🏯 孔明Rust环境安装器启动"
echo "⏰ 时间: $(date)"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查curl是否可用
if ! command -v curl >/dev/null 2>&1; then
    echo -e "${RED}❌ curl未安装，请先安装curl${NC}"
    exit 1
fi

# 检查是否已安装Rust
if command -v rustc >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Rust已安装${NC}"
    echo "版本信息:"
    rustc --version
    cargo --version
    echo ""
    echo "🎉 Rust环境已就绪！"
    exit 0
fi

echo -e "${BLUE}🔍 检测到Rust未安装，开始安装...${NC}"
echo ""

# 安装Rust
echo -e "${BLUE}📦 正在安装Rust...${NC}"
echo "这可能需要几分钟时间..."
echo ""

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# 检查安装是否成功
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Rust安装成功${NC}"
    echo ""
    
    # 重新加载环境变量
    echo -e "${BLUE}🔄 配置环境变量...${NC}"
    source ~/.cargo/env
    
    # 验证安装
    echo -e "${BLUE}🔍 验证Rust安装...${NC}"
    echo "Rust版本:"
    rustc --version
    echo ""
    echo "Cargo版本:"
    cargo --version
    
    echo ""
    echo -e "${GREEN}🎉 Rust环境安装完成！${NC}"
    
    # 设置常用rust工具
    echo -e "${BLUE}🛠️  安装常用Rust工具...${NC}"
    echo ""
    
    # 安装rust-analyzer (LSP)
    echo "安装rust-analyzer..."
    cargo install rust-analyzer --quiet
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ rust-analyzer 安装成功${NC}"
    else
        echo -e "${YELLOW}⚠️ rust-analyzer 安装失败${NC}"
    fi
    
    # 安装cargo-watch (文件监视)
    echo "安装cargo-watch..."
    cargo install cargo-watch --quiet
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ cargo-watch 安装成功${NC}"
    else
        echo -e "${YELLOW}⚠️ cargo-watch 安装失败${NC}"
    fi
    
    # 安装cargo-tree (依赖树)
    echo "安装cargo-tree..."
    cargo install cargo-tree --quiet
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ cargo-tree 安装成功${NC}"
    else
        echo -e "${YELLOW}⚠️ cargo-tree 安装失败${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}🎯 Rust开发环境完全配置完成！${NC}"
    
else
    echo -e "${RED}❌ Rust安装失败${NC}"
    exit 1
fi