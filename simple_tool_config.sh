#!/bin/bash

# 孔明智能助手 - 简化版工具配置脚本
# 用途：为未来安装的现代CLI工具生成预配置

echo "=== 孔明智能助手 - 现代CLI工具预配置 ==="
echo "配置时间: $(date)"
echo

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# 工具列表
tools=("eza" "bat" "fd" "rg" "dust" "gh" "fzf" "rustc")

echo -e "${BLUE}=== 工具预配置状态 ===${NC}"

# 检测工具
available=()
unavailable=()

for tool in "${tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        echo -e "${GREEN}✅ $tool${NC} - 已安装"
        available+=("$tool")
    else
        echo -e "${YELLOW}⚠️  $tool${NC} - 待安装"
        unavailable+=("$tool")
    fi
done

echo

# 生成配置文件
config_file="tool_aliases.sh"

cat > "$config_file" << 'EOF'
#!/bin/bash
# 孔明智能助手 - 工具别名配置
# 在安装新工具时自动加载相应的别名

# 颜色输出函数
color_print() {
    case $1 in
        "green") echo -e "\033[0;32m$2\033[0m" ;;
        "yellow") echo -e "\033[1;33m$2\033[0m" ;;
        "blue") echo -e "\033[0;34m$2\033[0m" ;;
        *) echo "$2" ;;
    esac
}

EOF

# 为每个工具生成配置
for tool in "${tools[@]}"; do
    cat >> "$config_file" << EOF
# $tool 配置
if command -v $tool &> /dev/null; then
    case $tool in
        eza)
            alias ls='eza --color=auto --icons=auto'
            alias l='eza -l --color=auto --icons=auto'
            alias ll='eza -la --color=auto --icons=auto'
            color_print "green" "✅ eza 别名已加载"
            ;;
        bat)
            alias cat='bat --paging=never --style=plain'
            alias more='bat --paging=always'
            color_print "green" "✅ bat 别名已加载"
            ;;
        fd)
            alias find='fd --hidden --exclude .git'
            alias fdd='fd --type d --hidden --exclude .git'
            color_print "green" "✅ fd 别名已加载"
            ;;
        rg)
            alias grep='rg --hidden --glob "!.git"'
            alias rgi='rg --hidden --glob "!.git" -i'
            color_print "green" "✅ ripgrep 别名已加载"
            ;;
        dust)
            alias du='dust -r'
            color_print "green" "✅ dust 别名已加载"
            ;;
        gh)
            alias gitpr='gh pr'
            alias gitissue='gh issue'
            color_print "green" "✅ gh 别名已加载"
            ;;
        fzf)
            alias f='fzf'
            alias ff='fzf --filter'
            # 搜索函数
            search_history() { history | fzf; }
            search_files() { fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'; }
            color_print "green" "✅ fzf 别名已加载"
            ;;
        rustc)
            alias cb='cargo build'
            alias cr='cargo run'
            alias ct='cargo test'
            color_print "green" "✅ Rust 别名已加载"
            ;;
    esac
fi

EOF
done

cat >> "$config_file" << EOF

# 配置完成
color_print "blue" "=== 工具配置完成 ==="
color_print "green" "已配置工具数量: \$(grep -c "alias" \$0)"
color_print "yellow" "使用 'source tool_aliases.sh' 加载配置"

EOF

chmod +x "$config_file"

echo -e "${BLUE}=== 预配置生成完成 ===${NC}"
echo -e "${GREEN}✅ tool_aliases.sh${NC} - 工具别名配置文件"
echo

echo -e "${BLUE}=== 配置摘要 ===${NC}"
if [[ ${#available[@]} -gt 0 ]]; then
    echo -e "${GREEN}已配置工具 (${#available[@]}):${NC} ${available[*]}"
fi
echo -e "${YELLOW}待配置工具 (${#unavailable[@]}):${NC} ${unavailable[*]}"
echo

echo -e "${YELLOW}=== 使用说明 ===${NC}"
echo "1. 工具安装完成后运行: source tool_aliases.sh"
echo "2. 添加到 ~/.zshrc: echo 'source $(pwd)/tool_aliases.sh' >> ~/.zshrc"
echo "3. 重启终端或运行: source ~/.zshrc"
echo

echo "=== 预配置完成 ==="