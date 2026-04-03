# 🧠 MEMORY.md - 孔明的长期记忆

## 核心身份
- **名字**: 孔明 (Kongming)
- **角色**: AI Ideas Lab 核心开发者和协调决策者
- **邮箱**: kongming@ai-ideas-lab.com
- **协作仓库**: ai-ideas-lab/romance-of-three-claws

## 协作体系
- **卧龙**: 深度思考者，负责架构设计和技术调研（低频高质）
- **凤雏**: 快速执行者，负责原型验证和社区互动（高频快迭）
- **孔明**: 协调决策者，负责项目开发和系统优化（持续运行）
- **分工原则**: 卧龙思考→凤雏验证→孔明决策

## 项目经验（2026-03-28 至今）
- **已完成7个项目**: Career Coach, Contract Reader, Error Diagnostician, Email Manager, Interview Coach, Appointment Manager
- **技术栈**: Node.js 22 + TypeScript 5 + Express/Fastify + Prisma + PostgreSQL
- **AI集成**: OpenAI API + Anthropic API
- **部署**: Docker + Docker Compose + GitHub Actions
- **项目模板**: 已创建标准模板系统（templates/ai-project-template/）

## 关键教训
1. **HEARTBEAT.md要精简**: 历史心跳不要堆积，只保留当前状态，否则每次心跳浪费token
2. **Git操作要谨慎**: rebase前先备份，大文件不要提交（.dmg/.pkg/.iso要.gitignore）
3. **网络问题常见**: Clash Verge代理不稳定，推送失败时先检查网络再排查
4. **定时任务prompt要简洁**: 子agent容易超时，每次只做一小步
5. **不要被紧急问题劫持重要任务**: 记录问题后继续核心工作
6. **系统问题诊断框架**: 4大问题类型（环境缺失、模式偏差、定位偏差、设计缺陷）→ 系统性修复方案
7. **Prompt优化原则**: 精简75% token量，聚焦行动而非记录，去除冗余格式说明，结构化思考模板
8. **Cron设计准则**: delivery.mode="none"隔离会话，频率平衡（巡逻6h，同步4h），简单高效
9. **PowerShell兼容性**: --jq编码问题→--json，--list不存在→API检查，{{}}转义，BOM问题处理
10. **紧急问题处理**: 10个PR重复文件→系统性清理+分支重建，建立CHANGES_REQUESTED跟踪机制

## 系统配置
- **workspace**: /Users/wangshihao/.openclaw/workspace
- **项目目录**: /Users/wangshihao/projects/openclaws/
- **awesome-ai-ideas**: /Users/wangshihao/projects/openclaws/awesome-ai-ideas
- **idea-tracker**: /Users/wangshihao/projects/openclaws/idea-tracker.json
- **Git身份**: 本地仓库级配置，非全局

## 主公偏好
- 语言：中文交互
- 风格：效率优先，不喜欢废话
- token：不缺，质量优先
- 时间：Asia/Shanghai

## 时间线
- 2026-03-28: AI Ideas系统启动，评估29个想法
- 2026-03-29: 完成5个项目，建立三爪协作
- 2026-03-30: 协作体系完善
- 2026-03-31: Appointment Manager完成
- 2026-04-01: 系统架构优化，自动化修复，Prompt重构，PR重复文件问题系统性修复
- 2026-04-02: PR自动化系统建立，分支保护规则优化，项目进度77.8%达成
- 2026-04-03: 认证机制优化(web_search→web_fetch)，健康检查建立，进度确认与网络问题处理

## 技术教训（新增）
- **PowerShell兼容性**: `--jq`编码问题→`--json`，`--list`不存在→API检查，`{{}}`转义，BOM问题
- **Prompt优化原则**: 精简75% token量，聚焦行动而非记录，去除冗余格式说明
- **Cron设计**: delivery.mode="none"隔离会话，频率平衡（巡逻6h，同步4h）
- **Git环境依赖**: `gh pr create`需Git，无Git时用API创建，注意备份rebase

## 系统优化经验
- **问题诊断**: 4大系统问题→环境缺失、模式偏差、定位偏差、设计缺陷
- **修复策略**: 频率优化、暂停低价值任务、增加协作指引
- **应急处理**: 10个PR重复文件问题系统性修复
- **质量管控**: 避免被紧急问题劫持重要任务，记录后继续核心工作

## 协作演进
- **分工细化**: 卧龙深度思考→凤雏快速验证→孔明系统优化
- **反馈机制**: 主公确认修复方向，效率优先导向
- **自动化平衡**: 从高频巡逻优化为合理间隔，确保稳定性
- **项目进度**: 7/9项目完成（77.8%），AI Rental Detective收尾中，卧龙项目稳步推进

## 系统优化里程碑
- **大规模修复**: 10个PR重复文件问题→6小时内系统修复，建立预防机制
- **Prompt重构**: 全系统prompt精简75%，token使用效率显著提升
- **Cron体系优化**: 9个job全面修复，建立频率平衡和会话隔离机制
- **自动化水平**: PR检查、Issue巡逻、协作同步等6大自动化流程稳定运行

## 2026-04-03: 认证机制优化与进度追踪
- **问题解决**: Issue #12 web_search认证失败，启用web_fetch国内源方案
- **健康检查**: 建立系统巡检机制，完成环境检查
- **进度监控**: AI Rental Detective 85%收尾中，测试失败(4/6)，需修复
- **网络优化**: 处理GitHub API超时问题，优化网络稳定性
- **进度确认**: 本周7/9项目完成(77.8%)，三爪协作体系运行稳定
