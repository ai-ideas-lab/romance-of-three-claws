# awesome-ai-ideas 项目整理方案

## 当前问题
- 根目录有33个.md文件，过于混乱
- 包括10个PR文档、20个AI想法文档
- 难以区分核心文档和项目文档

## 整理方案

### 目录结构设计
```
awesome-ai-ideas/
├── README.md              # 主文档（保留）
├── README_EN.md           # 英文文档（保留）
├── LICENSE                # 许可证（保留）
├── TEMPLATE.md            # 模板（保留）
├── GITHUB_ABOUT_GUIDE.md  # GitHub指南（保留）
├── docs/
│   ├── ideas/             # AI想法文档
│   │   ├── ai-*.md
│   │   └── README.md      # 目录索引
│   ├── pr/                # PR提案文档
│   │   ├── PR-*.md
│   │   └── README.md      # 目录索引
│   └── archive/           # 历史文档
│       └── README_backup.md
└── [其他现有目录保持不变]
```

### 整理规则

#### 保留在根目录
- README.md
- README_EN.md
- LICENSE
- TEMPLATE.md
- GITHUB_ABOUT_GUIDE.md

#### 移动到 docs/ideas/
- 所有 ai-*.md 文件（20个）
- 创建 docs/ideas/README.md 索引

#### 移动到 docs/pr/
- 所有 PR-*.md 文件（10个）
- 创建 docs/pr/README.md 索引

#### 移动到 docs/archive/
- README_backup.md
- 其他历史文档

### 自动化任务

#### 每日整理任务（Cron）
- 时间：每天09:00
- 检查：根目录新增的.md文件
- 规则：
  - ai-*.md → docs/ideas/
  - PR-*.md → docs/pr/
  - *backup*.md → docs/archive/
- 操作：
  - git mv移动文件
  - 更新目录索引
  - git commit提交
  - git push推送

#### 每周深度整理（Cron）
- 时间：每周日23:00
- 检查：docs/ideas/和docs/pr/的README索引
- 操作：
  - 扫描目录下所有文件
  - 按时间/类型排序
  - 生成新的索引文档
  - 提交更新

## 实施步骤

1. **手动整理（一次性）**
   - 创建目标目录
   - 移动现有文件
   - 创建索引文档
   - 提交PR

2. **设置Cron任务**
   - 每日整理任务
   - 每周深度整理

3. **更新文档**
   - 在README.md中说明目录结构
   - 创建CONTRIBUTING.md指导贡献者

## 预期效果

- 根目录保持简洁（5个核心文件）
- 文档分类清晰（ideas/、pr/、archive/）
- 自动化维护（Cron任务）
- 可持续发展（新文件自动归档）
