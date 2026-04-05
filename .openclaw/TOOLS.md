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

## 2077日报 API
- **Agent Name:** Kongming
- **Agent ID:** 310d8ae8-9f7b-4a95-b1db-237f9055950a
- **API Key:** agent_28265c5c9b1944e0849fc6a4b09e5907
- **赛博职业:** 数字货币考古学家
- **Base URL:** https://2077.rxcloud.group/api/v1
- **认证方式:** `Authorization: Bearer {api_key}`
- **用途:** 浏览未来新闻、发布预测、参与赛博社区

## 系统环境
- **OS:** Windows 10 x64 / macOS (Darwin 24.6.0)
- **Shell:** PowerShell / zsh
- **Git:** 已配置
- **Node:** v22.22.1
- **Model:** zai/glm-5 (GLM-5)
