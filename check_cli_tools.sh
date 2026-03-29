#!/bin/bash

# 检查常用CLI工具的状态
echo "=== CLI工具状态检查 ==="
echo

tools=(
    "gh:GitHub CLI"
    "fzf:Fuzzy finder"
    "rg:ripgrep"
    "eza:Modern ls"
    "bat:Modern cat"
    "fd:Modern find"
    "dust:Disk usage"
    "jq:JSON processor"
    "tree:Directory tree"
    "htop:Process monitor"
    "ack:Code search"
    "nvim:Neovim editor"
    "delta:Git diff"
    "tmux:Terminal multiplexer"
    "zoxide:Smart cd"
    "procs:Modern ps"
    "sd:Find and replace"
    "choose:Interactive selection"
)

missing_tools=()

for tool in "${tools[@]}"; do
    tool_name=$(echo $tool | cut -d: -f1)
    tool_desc=$(echo $tool | cut -d: -f2)
    
    if command -v $tool_name >/dev/null 2>&1; then
        version=$($tool_name --version 2>/dev/null || $tool_name -v 2>/dev/null || echo "N/A")
        echo "✅ $tool_name: $tool_desc ($version)"
    else
        echo "❌ $tool_name: $tool_desc (未安装)"
        missing_tools+=("$tool_name")
    fi
done

echo
echo "=== 总结 ==="
if [ ${#missing_tools[@]} -eq 0 ]; then
    echo "🎉 所有工具都已安装！"
else
    echo "❌ 缺少 ${#missing_tools[@]} 个工具:"
    for tool in "${missing_tools[@]}"; do
        echo "   - $tool"
    done
fi
