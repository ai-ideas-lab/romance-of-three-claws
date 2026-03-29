#!/bin/bash

# 孔明智能助手 - 现代CLI工具智能配置脚本
# 用途：自动检测并配置现代CLI工具的别名和集成

echo "=== 孔明智能助手 - 现代CLI工具智能配置 ==="
echo "配置时间: $(date)"
echo

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# 工具映射数组
declare -A tool_mapping=(
    ["eza"]="ls|现代文件列表"
    ["bat"]="cat|现代文件查看"
    ["fd"]="find|现代文件搜索"
    ["rg"]="grep|现代文本搜索"
    ["dust"]="du|磁盘使用分析"
    ["gh"]="git|GitHub CLI"
    ["fzf"]="fzf|模糊查找器"
    ["rustc"]="rust|Rust编译器"
)

echo -e "${BLUE}=== 工具检测状态 ===${NC}"

# 检测工具可用性
available_tools=()
unavailable_tools=()

for tool in "${!tool_mapping[@]}"; do
    if command -v "$tool" &> /dev/null; then
        desc="${tool_mapping[$tool]}"
        echo -e "${GREEN}✅ $tool${NC} - $desc"
        available_tools+=("$tool")
    else
        desc="${tool_mapping[$tool]}"
        echo -e "${YELLOW}⚠️  $tool${NC} - $desc (待安装)"
        unavailable_tools+=("$tool")
    fi
done

echo

# 如果没有可用工具，提供安装建议
if [[ ${#available_tools[@]} -eq 0 ]]; then
    echo -e "${RED}❌ 没有检测到现代CLI工具${NC}"
    echo "请先安装以下工具："
    echo "brew install eza bat fd rg dust gh fzf rust"
    echo
    exit 1
fi

# 创建工具别名配置
echo -e "${BLUE}=== 生成智能别名配置 ===${NC}"
config_file="modern_tool_aliases.sh"

cat > "$config_file" << 'EOF'
#!/bin/bash
# 孔明智能助手 - 现代CLI工具别名配置
# 自动加载检测到的现代CLI工具

# 颜色输出函数
print_color() {
    local color=$1
    local text=$2
    case $color in
        "green") echo -e "\033[0;32m$text\033[0m" ;;
        "yellow") echo -e "\033[1;33m$text\033[0m" ;;
        "blue") echo -e "\033[0;34m$text\033[0m" ;;
        "red") echo -e "\033[0;31m$text\033[0m" ;;
        *) echo "$text" ;;
    esac
}

EOF

# 为每个可用工具生成别名
for tool in "${available_tools[@]}"; do
    case $tool in
        "eza")
            cat >> "$config_file" << EOF
# eza - 现代文件列表工具
if command -v eza &> /dev/null; then
    alias ls='eza --color=auto --icons=auto'
    alias l='eza -l --color=auto --icons=auto'
    alias ll='eza -la --color=auto --icons=auto'
    alias la='eza -la --color=auto --icons=auto'
    alias tree='eza --tree --color=auto --icons=auto'
    print_color "green" "✅ eza 别名已加载 (ls, l, ll, la, tree)"
fi

EOF
            ;;
        "bat")
            cat >> "$config_file" << EOF
# bat - 现代文件查看工具
if command -v bat &> /dev/null; then
    alias cat='bat --paging=never --style=plain'
    alias batcat='bat --paging=never --style=plain'
    alias more='bat --paging=always'
    alias less='bat --paging=always'
    print_color "green" "✅ bat 别名已加载 (cat, batcat, more, less)"
fi

EOF
            ;;
        "fd")
            cat >> "$config_file" << EOF
# fd - 现代文件搜索工具
if command -v fd &> /dev/null; then
    alias find='fd --hidden --exclude .git'
    alias fdd='fd --type d --hidden --exclude .git'
    alias fdf='fd --type f --hidden --exclude .git'
    print_color "green" "✅ fd 别名已加载 (find, fdd, fdf)"
fi

EOF
            ;;
        "rg")
            cat >> "$config_file" << EOF
# ripgrep - 现代文本搜索工具
if command -v rg &> /dev/null; then
    alias grep='rg --hidden --glob "!.git"'
    alias rgl='rg --hidden --glob "!.git" -l'
    alias rgi='rg --hidden --glob "!.git" -i'
    alias rgb='rg --hidden --glob "!.git" --line-number'
    print_color "green" "✅ ripgrep 别名已加载 (grep, rgl, rgi, rgb)"
fi

EOF
            ;;
        "dust")
            cat >> "$config_file" << EOF
# dust - 磁盘使用分析工具
if command -v dust &> /dev/null; then
    alias du='dust -r'
    alias dus='dust -r'
    alias disk='dust -r'
    print_color "green" "✅ dust 别名已加载 (du, dus, disk)"
fi

EOF
            ;;
        "gh")
            cat >> "$config_file" << EOF
# gh - GitHub CLI
if command -v gh &> /dev/null; then
    alias gitpr='gh pr'
    alias gitissue='gh issue'
    alias gitrepo='gh repo'
    alias gitclone='gh repo clone'
    print_color "green" "✅ gh 别名已加载 (gitpr, gitissue, gitrepo, gitclone)"
fi

EOF
            ;;
        "fzf")
            cat >> "$config_file" << EOF
# fzf - 模糊查找器
if command -v fzf &> /dev/null; then
    # 基础fzf别名
    alias f='fzf'
    alias ff='fzf --filter'
    alias fl='fzf --list'
    
    # 实用搜索函数
    search_history() {
        history | fzf
    }
    
    search_files() {
        fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
    }
    
    search_directories() {
        find . -type d | fzf
    }
    
    search_git_branches() {
        git branch -a | fzf
    }
    
    search_git_commits() {
        git log --oneline --graph | fzf
    }
    
    print_color "green" "✅ fzf 别名已加载 (f, ff, fl)"
    print_color "green" "✅ fzf 函数已加载 (search_history, search_files, search_directories, search_git_branches, search_git_commits)"
fi

EOF
            ;;
        "rustc")
            cat >> "$config_file" << EOF
# Rust 工具链
if command -v rustc &> /dev/null; then
    alias cargo='cargo'
    alias rustc='rustc'
    alias rustup='rustup'
    
    # Cargo别名
    alias cb='cargo build'
    alias cr='cargo run'
    alias ct='cargo test'
    alias ccl='cargo clean'
    alias cf='cargo fmt'
    alias cl='cargo clippy'
    
    print_color "green" "✅ Rust 工具链别名已加载 (cb, cr, ct, ccl, cf, cl)"
fi

EOF
            ;;
    esac
done

cat >> "$config_file" << EOF

# 配置完成提示
echo "$(print_color "blue" "=== 现代CLI工具配置完成 ===")"
echo "已配置 ${#available_tools[@]} 个工具: ${available_tools[*]}"
echo "未配置 ${#unavailable_tools[@]} 个工具: ${unavailable_tools[*]}"
echo
echo "$(print_color "yellow" "使用说明:")"
echo "1. 运行 'source modern_tool_aliases.sh' 加载配置"
echo "2. 将 'source $(pwd)/modern_tool_aliases.sh' 添加到 ~/.zshrc 或 ~/.bashrc"
echo "3. 重启终端或运行 'source ~/.zshrc' 使配置生效"
echo

EOF

chmod +x "$config_file"

echo -e "${BLUE}=== 配置文件生成完成 ===${NC}"
echo -e "${GREEN}✅ modern_tool_aliases.sh${NC} - 已生成智能工具配置文件"
echo

# 显示配置摘要
echo -e "${BLUE}=== 配置摘要 ===${NC}"
echo -e "${GREEN}已配置工具 (${#available_tools[@]}):${NC} ${available_tools[*]}"
if [[ ${#unavailable_tools[@]} -gt 0 ]]; then
    echo -e "${YELLOW}待配置工具 (${#unavailable_tools[@]}):${NC} ${unavailable_tools[*]}"
fi

echo
echo -e "${YELLOW}=== 下一步操作 ===${NC}"
echo "1. 运行 'source modern_tool_aliases.sh' 测试配置"
echo "2. 运行 './env_final_check.sh' 验证环境状态"
echo "3. 将配置添加到shell配置文件中持久化"
echo

echo "=== 配置完成 ==="