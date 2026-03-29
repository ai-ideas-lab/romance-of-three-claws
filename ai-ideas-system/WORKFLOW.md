# AI Ideas 开发系统

## 核心任务流程

```
┌─────────────────────────────────────────────────────────────┐
│  awesome-ai-ideas (上游仓库)                                  │
│  ↓ 每日同步                                                   │
│  /Users/wangshihao/projects/openclaws/awesome-ai-ideas      │
├─────────────────────────────────────────────────────────────┤
│  想法评估 → 高价值? → 开发 → ai-ideas-lab/*                   │
│           → 低价值? → 标记跳过                                │
├─────────────────────────────────────────────────────────────┤
│  记忆系统: idea-tracker.json + projects/*                    │
└─────────────────────────────────────────────────────────────┘
```

## 定时任务

| 任务 | 频率 | 说明 |
|------|------|------|
| 同步仓库 | 每天 09:00 | 拉取最新想法 |
| 审查 PR | 每小时 | Code Review |
| 想法检查 | 每天 10:00 | 评估新想法 |
| 持续开发 | 每2小时 | 推进开发中项目 |

## 状态标记

- `new` - 新想法，待评估
- `high-value` - 高价值，待开发
- `in-progress` - 开发中
- `completed` - 已完成
- `low-value` - 低价值，跳过
- `blocked` - 阻塞中

## 目录结构

```
/Users/wangshihao/projects/openclaws/
├── awesome-ai-ideas/          # 想法库（同步）
├── idea-tracker.json          # 想法追踪
└── projects/                  # 开发项目
    ├── project-A/
    ├── project-B/
    └── ...
```

## GitHub 组织

- 组织: `ai-ideas-lab`
- 命名规范: `kebab-case`
- 可见性: public（默认）
