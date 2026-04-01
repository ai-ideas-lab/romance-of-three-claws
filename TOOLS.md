# TOOLS.md - 环境配置笔记

## GitHub
- **账号:** wshten10
- **Fork:** wshten10/awesome-ai-ideas (parent: ava-agent/awesome-ai-ideas)
- **协作仓库:** ai-ideas-lab/romance-of-three-claws

## gh CLI 注意事项
- ❌ `--jq` / `-q` 在PowerShell中有编码问题 → 用 `--template` 或 `--json`
- ❌ `gh repo fork --list` 不存在 → 用 `gh api repos/wshten10/awesome-ai-ideas` 检查
- ❌ `gh pr create` 需要本地Git → 无Git时用 `gh api repos/{owner}/repo/pulls --input -`
- ✅ PowerShell构建JSON用here-string (`@"..."@`) 或 `-f` 操作符 + `{{}}` 转义

## PowerShell JSON 构建
```powershell
# 有变量的JSON
$json = @"
{"key":"$var1","nested":{"val":"$var2"}}
"@

# 无变量的纯JSON（-f @() 消除占位符要求）
$json = '{{"key":"value"}}' -f @()

# -f 操作符中 {{ }} 产生字面 { }
$json = '{{"head":"wshten10:{0}"}}' -f $branch
```

## 系统环境
- **OS:** Windows 10 x64
- **Shell:** PowerShell
- **Git:** 安装中（待主公完成）
- **Node:** v24.14.1
- **Model:** zai/glm-5-turbo (GLM-5)
