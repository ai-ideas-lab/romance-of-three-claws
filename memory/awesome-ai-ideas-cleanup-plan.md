# awesome-ai-ideas 项目整理方案

## 当前问题分析

### 根目录文件统计
- **27个.md文件**：报告、配置、文档
- **40个.sh脚本**：安装、配置、工具脚本
- **多个目录**：ai-*项目、docs、backups等

### 主要问题
1. **报告文件散落**：final_*.md, *_report.md等应归档
2. **脚本文件混乱**：40个.sh脚本应分类整理
3. **配置文件暴露**：OpenClaw配置文件不应在根目录

---

## 整理方案

### 目标目录结构
```
awesome-ai-ideas/
├── README.md                    # 主文档（保留）
├── LICENSE                      # 许可证（如果有）
├── docs/                        # 文档目录
│   ├── reports/                 # 报告文档
│   │   ├── final-*.md
│   │   ├── *_report.md
│   │   └── evolution-*.md
│   └── guides/                  # 指南文档
│       └── backup_skills_strategy.md
├── scripts/                     # 脚本目录
│   ├── install/                 # 安装脚本
│   │   ├── *_installer.sh
│   │   └── cli_tools_installer.sh
│   ├── config/                  # 配置脚本
│   │   ├── config_optimizer*.sh
│   │   └── ai_project_config.sh
│   ├── docker/                  # Docker脚本
│   │   └── docker_*.sh
│   └── utils/                   # 工具脚本
│       ├── env_*.sh
│       └── check_*.sh
├── .openclaw/                   # OpenClaw配置（隐藏目录）
│   ├── AGENTS.md
│   ├── BOOTSTRAP.md
│   ├── HEARTBEAT.md
│   ├── IDENTITY.md
│   ├── MEMORY.md
│   ├── SOUL.md
│   ├── TOOLS.md
│   ├── TOOL_UPDATE.md
│   └── USER.md
├── projects/                    # AI项目目录
│   ├── ai-family-health-guardian/
│   ├── ai-ideas-system/
│   └── ai-workspace-orchestrator/
└── [其他现有目录]
```

---

## 自动化任务设计

### 每日整理任务（Cron）
**时间**：每天09:00  
**任务名**：🗂️ awesome-ai-ideas 项目整理

#### 检查规则
1. **根目录.md文件检查**
   - 排除：README.md, LICENSE
   - 匹配：`*_report.md`, `final_*.md`, `evolution*.md`, `*_progress.md`
   - 动作：移动到 `docs/reports/`

2. **根目录.sh文件检查**
   - 匹配：`*_installer.sh` → `scripts/install/`
   - 匹配：`config_*.sh` → `scripts/config/`
   - 匹配：`docker_*.sh` → `scripts/docker/`
   - 匹配：`env_*.sh`, `check_*.sh` → `scripts/utils/`

3. **OpenClaw配置文件检查**
   - 匹配：AGENTS.md, BOOTSTRAP.md, HEARTBEAT.md等
   - 动作：移动到 `.openclaw/` 目录

#### 执行流程
```bash
# 1. 检查并创建目录
mkdir -p docs/reports docs/guides
mkdir -p scripts/install scripts/config scripts/docker scripts/utils
mkdir -p .openclaw

# 2. 移动报告文件
git mv *_report.md docs/reports/ 2>/dev/null
git mv final_*.md docs/reports/ 2>/dev/null
git mv evolution*.md docs/reports/ 2>/dev/null

# 3. 移动脚本文件
git mv *_installer.sh scripts/install/ 2>/dev/null
git mv config_*.sh scripts/config/ 2>/dev/null
git mv docker_*.sh scripts/docker/ 2>/dev/null
git mv env_*.sh scripts/utils/ 2>/dev/null
git mv check_*.sh scripts/utils/ 2>/dev/null

# 4. 移动OpenClaw配置
git mv AGENTS.md BOOTSTRAP.md HEARTBEAT.md .openclaw/ 2>/dev/null
git mv IDENTITY.md MEMORY.md SOUL.md .openclaw/ 2>/dev/null
git mv TOOLS.md TOOL_UPDATE.md USER.md .openclaw/ 2>/dev/null

# 5. 更新.gitignore（如果需要）
echo ".openclaw/" >> .gitignore

# 6. 提交更改
git add .
git commit -m "chore: 自动整理项目结构

- 移动报告文件到 docs/reports/
- 移动脚本文件到 scripts/分类目录
- 移动OpenClaw配置到 .openclaw/
- 优化项目结构，提升可维护性"

# 7. 推送更改
git push origin main
```

### 每周深度整理（Cron）
**时间**：每周日23:00  
**任务名**：🗂️ awesome-ai-ideas 深度整理

#### 检查内容
1. **生成目录索引**
   - 扫描 `docs/reports/` 生成README
   - 扫描 `scripts/` 各子目录生成README

2. **清理重复文件**
   - 检查 `*.backup` 文件
   - 检查重复的配置文件

3. **更新主README**
   - 更新项目结构说明
   - 更新贡献指南

---

## 实施步骤

### 第一步：手动整理（立即执行）
1. 创建目标目录结构
2. 移动现有文件
3. 提交PR

### 第二步：创建Cron任务（今天）
1. 创建每日整理任务（09:00）
2. 创建每周深度整理任务（周日23:00）

### 第三步：更新文档（今天）
1. 更新README.md说明新结构
2. 创建CONTRIBUTING.md
3. 更新.gitignore

---

## 预期效果

### 整理前
- 根目录：67个文件（27 md + 40 sh）
- 混乱度：高
- 可维护性：差

### 整理后
- 根目录：5-10个核心文件
- 结构：清晰分类
- 可维护性：优秀
- 自动化：每日维护

---

## 注意事项

1. **保守移动**：只移动明确匹配的文件
2. **保留README**：根目录README.md不移动
3. **Git历史**：使用git mv保留历史
4. **测试优先**：先在分支测试，再合并main
5. **文档更新**：移动后更新相关引用

---

*方案创建时间：2026-04-04*
*执行状态：待实施*
