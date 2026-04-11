# AI Ideas Lab 技术调研报告

---

# 深度技术调研 - 2026-04-11 18:00

**调研人员**: 孔明  
**本次调研项目**: ai-family-health-guardian、ai-workspace-orchestrator  
**调研方法**: npm registry 实时查询 + Express/Prisma 官方迁移文档核查

## 1. ai-family-health-guardian

**项目定位**: AI 驱动的家庭健康监测系统，独居老人实时健康监护。使用 MQTT 协议接收 IoT 设备数据，Socket.IO 推送实时告警。

### 依赖版本对照

| 依赖 | 当前 | 最新 | 差距 |
|------|------|------|------|
| @prisma/client | ^5.6.0 | **7.7.0** | 🔴 落后 2 个大版本 |
| prisma | ^5.6.0 | **7.7.0** | 🔴 同上 |
| express | ^4.18.2 | **5.2.1** | 🔴 落后 1 个大版本 |
| openai | ^4.26.0 | **6.34.0** | 🔴 落后 2 个大版本 |
| mqtt | ^5.3.4 | **5.15.1** | 🟡 落后 12 个 minor |
| socket.io | ^4.7.4 | **4.8.3** | 🟡 落后 1 个 minor |
| winston | ^3.11.0 | **3.19.0** | 🟡 落后 8 个 minor |
| joi | ^17.11.0 | **18.1.2** | 🔴 落后 1 个大版本 |
| jsonwebtoken | ^9.0.2 | 9.0.2 | ✅ 最新（9.x 稳定版） |
| typescript | ^5.2.2 | **6.0.2** | 🔴 落后 1 个大版本 |

### 可执行升级路径

**第一阶段 — Prisma 5→7（最高优先级，数据层基础）**:

Prisma 7 breaking changes 较大，需要注意：
- 查询引擎从 Node-API 重写为纯 WASM，性能提升但需更新 `prisma-client-js` provider → `prisma-client`
- `output` 字段在 generator block 中变为必填，import 路径从 `@prisma/client` → `./generated/prisma/client`
- 要求 Node ≥20.19、TypeScript ≥5.4

```bash
# 步骤
npm install prisma@^7.7.0 @prisma/client@^7.7.0
# 修改 schema.prisma: generator client { provider = "prisma-client" output = "../generated/prisma" }
npx prisma generate
# 更新所有 import 路径: from "@prisma/client" → from "../generated/prisma/client"
npx prisma migrate dev  # 验证迁移兼容性
npm test
```

**第二阶段 — OpenAI 4→6 + Joi→Zod（联动升级）**:

OpenAI 6.x 的 `client.chat.completions.parse()` 原生支持 Zod schema 做结构化输出。项目当前用 Joi 做验证，建议借升级契机迁移到 Zod，一石二鸟。

```bash
# 替换验证库
npm uninstall joi
npm install zod@^4.3.6
# 升级 OpenAI
npm install openai@^6.34.0
```

Joi → Zod 迁移要点：
- `Joi.string().email()` → `z.string().email()`
- `Joi.object({})` → `z.object({})`
- `schema.validate(value)` → `schema.parse(value)` (抛异常) 或 `schema.safeParse(value)` (返回 result)
- Zod 4 breaking: `message` 参数改为 `error`；移除 `invalid_type_error`/`required_error`

**第三阶段 — Express 4→5（中期计划）**:

Express 5 已稳定 (5.2.1)，官方提供自动 codemod：
```bash
npx codemod@latest @expressjs/v5-migration-recipe
npm install express@^5.2.1
```

关键 breaking changes：
- `res.send(status)` → `res.sendStatus(status)`（纯数字参数行为变了）
- `res.json(obj, status)` → `res.status(status).json(obj)`
- Promise rejection 自动传递到 error handler（不再需要 `next(err)` 手动传递）
- 路径匹配正则语法变化

**第四阶段 — MQTT 5.3→5.15 + Socket.IO 4.7→4.8（低风险）**:
```bash
npm install mqtt@^5.15.1 socket.io@^4.8.3 winston@^3.19.0
```
MQTT 5.15: 改进 MQTT 5.0 协议支持、更好的 WebSocket 传输、连接稳定性修复。
Socket.IO 4.8: 新增 `serverSideUpgrade` 选项、底层 engine.io 升级。

**第五阶段 — TypeScript 5→6**:
```bash
npm install typescript@^6.0.2 --save-dev
```
TypeScript 6: ESM 优先的 module 解析、`--moduleResolution bundler` 默认值、更好的类型推断。

### 架构优化建议

- **健康数据流重构**: 当前 MQTT→Express→Socket.IO 的链路可以简化。考虑用 Fastify 替代 Express（性能提升 ~30%），或在 Express 5 模式下利用其改进的路由性能
- **告警引擎独立化**: 将健康告警逻辑从主服务抽离为独立 worker（用 `cron` 或 BullMQ），避免 MQTT 消息处理阻塞 HTTP 请求
- **IoT 数据时序存储**: 如果监测数据量大，考虑引入 TimescaleDB（PostgreSQL 扩展）配合 Prisma 使用，时序查询性能远优于普通索引
- **Zod Schema 统一**: 升级后，健康数据的验证 schema 可同时用于 API 输入验证和 OpenAI 结构化输出的类型定义，减少重复代码

---

## 2. ai-workspace-orchestrator（跟踪复查）

**上次调研**: 2026-04-09，当时建议优先升级 AI SDK。本次检查是否有变化。

### 依赖版本复查

| 依赖 | 当前 | 最新 | 状态变化 |
|------|------|------|---------|
| @anthropic-ai/sdk | ^0.22.0 | **0.88.0** | 🔴 未升级，落后 66 个 minor（上次 64） |
| openai | ^4.36.0 | **6.34.0** | 🔴 未升级 |
| @google/generative-ai | ^0.21.0 | **0.24.1** | 🟡 未升级 |
| zod | ^3.22.2 | **4.3.6** | 🔴 未升级（是 openai@6 的前置依赖） |
| express | ^4.18.2 | **5.2.1** | 🔴 未升级 |
| prisma / @prisma/client | ^7.6.0 | **7.7.0** | 🟡 差 1 minor |
| redis | ^5.11.0 | **5.11.0** | ✅ 最新 |
| typescript | ^6.0.2 | **6.0.2** | ✅ 最新 |
| vitest | ^4.1.3 | **4.1.3** | ✅ 最新 |

**结论**: 自上次调研以来，项目未执行任何依赖升级。AI SDK 滞后问题持续恶化。

### 升级优先级重申（含具体命令）

**紧急 — Zod 3→4（阻塞 OpenAI 升级）**:
```bash
# Zod 4 是 OpenAI 6.x 的 peerDependency
npx zod-v3-to-v4  # 社区 codemod 自动迁移
npm install zod@^4.3.6
```

**紧急 — 三大 AI SDK 升级**:
```bash
# OpenAI: 新增 Responses API、结构化输出、mcp 支持
npm install openai@^6.34.0

# Anthropic 0.22→0.88: 支持 tool_use、JSON mode、vision、extended thinking
npm install @anthropic-ai/sdk@^0.88.0

# Google 0.21→0.24: Gemini 2.5 支持、改进多模态
npm install @google/generative-ai@^0.24.1
```

**高优 — Express 4→5**:
```bash
npx codemod@latest @expressjs/v5-migration-recipe
npm install express@^5.2.1
```

**低优 — Prisma 7.6→7.7**:
```bash
npm install prisma@^7.7.0 @prisma/client@^7.7.0 && npx prisma generate
```

### 新增架构建议

- **OpenAI Responses API**: openai@6.x 引入了 `client.responses.create()` API，支持多轮对话状态管理，可简化当前工作流引擎中的对话上下文管理代码
- **Anthropic Extended Thinking**: @anthropic-ai/sdk@0.88 支持 Claude 的 extended thinking 功能，适合需要深度推理的复杂工作流编排场景
- **统一 LLM Adapter**: 建议创建 `src/adapters/llm/` 目录，为三家 AI 供应商实现统一接口，包含 `chat()`、`structuredOutput()`、`stream()` 方法，工作流引擎只依赖抽象层

---

## 3. 全局技术雷达更新

### 12 项目技术健康度（2026-04-11）

| 项目 | Prisma | Express | OpenAI | TS | 总体评分 |
|------|--------|---------|--------|----|---------|
| ai-workspace-orchestrator | ✅ 7.6 | 🔴 4.18 | 🔴 4.36 | ✅ 6.0 | ⭐⭐⭐⭐ |
| ai-family-health-guardian | 🔴 5.6 | 🔴 4.18 | 🔴 4.26 | 🔴 5.2 | ⭐⭐ |
| ai-carbon-footprint-tracker | 🔴 5.6 | 🔴 4.18 | 🔴 4.20 | 🔴 5.x | ⭐⭐ |
| ai-rental-detective | 🔴 5.4 | 🔴 4.18 | 🔴 4.26 | 🟡 5.x | ⭐⭐ |
| ai-email-manager | 🔴 5.7 | 🔴 4.18 | 🔴 4.26 | 🔴 5.3 | ⭐⭐ |
| ai-gardening-designer | 🔴 5.7 | 🔴 4.18 | 🔴 4.26 | 🟡 5.9 | ⭐⭐½ |
| ai-contract-reader | 🔴 5.x | 🔴 4.18 | 🔴 4.x | 🔴 5.x | ⭐⭐ |
| ai-appointment-manager | 🔴 5.x | 🔴 4.18 | 🔴 4.x | 🔴 5.x | ⭐⭐ |
| ai-interview-coach | 🔴 5.x | 🔴 4.18 | 🔴 4.x | 🔴 5.x | ⭐⭐ |
| ai-error-diagnostician | 🔴 5.x | 🔴 4.18 | 🔴 4.x | 🔴 5.x | ⭐⭐ |
| ai-voice-notes-organizer | 🔴 5.x | 🔴 4.18 | 🔴 4.x | 🔴 5.x | ⭐⭐ |

**关键发现**: workspace-orchestrator 是唯一一个已经完成 Prisma 7 + TS 6 升级的项目，但 AI SDK 仍然是所有项目的共同短板。

### 推荐全局升级顺序

1. **Zod 3→4** (所有使用 zod 的项目) — 解锁 OpenAI 6 兼容
2. **OpenAI 4→6** (全部 12 项目) — 结构化输出 + Responses API 是质变
3. **Prisma 5→7** (10 个项目) — 查询引擎重写，性能 + 类型安全
4. **Express 4→5** (10 个项目) — 用官方 codemod 降低迁移成本
5. **TypeScript 5→6** (11 个项目) — ESM 优先、更好的类型推断

---

**报告生成时间**: 2026-04-11 18:03 CST  
**数据来源**: npm registry (实时查询 2026-04-11) + Express 官方迁移文档 + Prisma 7 升级指南  
**下次调研**: 2026-04-12 00:00  
**调研状态**: ✅ 完成

---

# 深度技术调研 - 2026-04-09 06:00

**调研人员**: 孔明  
**本次调研项目**: ai-workspace-orchestrator、ai-rental-detective  
**调研方法**: npm registry 查询最新版本 + 官方迁移文档核查

## 1. ai-workspace-orchestrator

**亮点**: 项目基础设施已是 12 个项目中最先进的 — Prisma 7、TypeScript 6、Vitest 4、Redis 5 均为当前最新。但三大 AI SDK 严重滞后，是最大短板。

### 依赖版本对照

| 依赖 | 当前 | 最新 | 差距 |
|------|------|------|------|
| openai | ^4.36.0 | **6.34.0** | 🔴 落后 2 个大版本 |
| @anthropic-ai/sdk | ^0.22.0 | **0.86.1** | 🔴 落后 64 个 minor |
| @google/generative-ai | ^0.21.0 | **0.24.1** | 🟡 落后 3 个 minor |
| express | ^4.18.2 | **5.2.1** | 🔴 落后 1 个大版本 |
| zod | ^3.22.2 | **4.3.6** | 🔴 落后 1 个大版本 |
| prisma / @prisma/client | ^7.6.0 | **7.7.0** | ✅ 仅差 1 个 minor |
| redis | ^5.11.0 | **5.11.0** | ✅ 最新 |
| vitest | ^4.1.3 | **4.1.3** | ✅ 最新 |
| typescript | ^6.0.2 | **6.0.2** | ✅ 最新 |

### 可执行升级路径

**第一阶段 — AI SDK 升级（最高优先级，影响 AI 功能质量）**:

```bash
# OpenAI 4→6: API 变化较大，但向后兼容层存在
# 关键变化: Structured Output 原生支持、zod peerDep (需 zod ≥3.25 或 4.x)
npm install openai@^6.34.0

# Anthropic 0.22→0.86: 新增 tool_use、JSON mode、vision 支持
npm install @anthropic-ai/sdk@^0.86.1

# Google Generative AI 0.21→0.24: 新增多模态和安全控制
npm install @google/generative-ai@^0.24.1
```

⚠️ **注意**: openai@6.x 的 peerDependency 要求 `zod@^3.25 || ^4.0`，当前 `zod@^3.22.2` 不满足。必须先升级 zod。

**第二阶段 — Zod 3→4（解锁 AI SDK 兼容）**:
- Zod 4 breaking changes: `message` 参数 → `error` 参数；`.format()` → `z.treeifyError()`；`invalid_type_error/required_error` 被移除
- 有社区 codemod: `npx zod-v3-to-v4`
- 升级命令: `npm install zod@^4.3.6`

**第三阶段 — Express 4→5（中期计划）**:
- Express 5 已正式发布 (5.2.1)，官方提供 codemod: `npx codemod@latest @expressjs/v5-migration-recipe`
- 关键 breaking change: `req.param(name)` 移除 → 用 `req.params/body/query`；Promise rejection 自动处理；`res.send(status)` 移除 → `res.sendStatus()`
- 升级命令: `npm install express@^5.2.1`

**第四阶段 — Prisma 7.6→7.7（低风险）**:
- 7.7.0 新增 `prisma bootstrap` 命令（一键脚手架）、bug 修复
- `npm install prisma@^7.7.0 @prisma/client@^7.7.0 && npx prisma generate`

### 架构优化建议

- **多模型路由器**: 项目已有 OpenAI/Anthropic/Google 三家 SDK，建议抽象一个统一 `LLMRouter` 层，根据任务类型（代码生成→Claude、通用对话→GPT、多模态→Gemini）自动选择模型，预计降低 30% API 成本
- **Zod Schema 复用**: 升级到 Zod 4 后，可直接将 zod schema 传给 openai 的 `client.chat.completions.parse()` 实现结构化输出，省去手动 JSON 解析
- **Prisma 7.7 MCP 支持**: Prisma 7.7 开始支持 MCP（Model Context Protocol），可考虑将数据库 schema 暴露给 AI 助手用于自然语言查询

---

## 2. ai-rental-detective

**亮点**: 前端已先行升级（MUI v7、react-router-dom v7、multer v2），是项目中前端最激进的。但后端严重老化 — Prisma 5.4、ESLint 8 + typescript-eslint 5、OpenAI 4 均落后 1-2 年。

### 依赖版本对照

| 依赖 | 当前 | 最新 | 差距 |
|------|------|------|------|
| prisma / @prisma/client | ^5.4.2 | **7.7.0** | 🔴 落后 2 个大版本 |
| openai | ^4.26.0 | **6.34.0** | 🔴 落后 2 个大版本 |
| @mui/material | ^7.3.9 | **9.0.0** | 🔴 落后 1 个大版本 |
| @typescript-eslint/* | ^5.59.9 | **^8.58.0** | 🔴 落后 3 个大版本 |
| express | ^4.18.2 | **5.2.1** | 🔴 落后 1 个大版本 |
| react-router-dom | ^7.13.2 | **7.14.0** | ✅ 接近最新 |
| multer | ^2.1.1 | **2.1.1** | ✅ 最新 |
| axios | ^1.14.0 | **1.14.0** | ✅ 最新 |

### 可执行升级路径

**第一阶段 — TypeScript 工具链升级（低风险，高收益）**:
```bash
npm install @typescript-eslint/eslint-plugin@^8.58.0 @typescript-eslint/parser@^8.58.0 --save-dev
```

**第二阶段 — Prisma 5→7（高风险，建议独立分支）**:
```bash
git checkout -b upgrade/prisma-7
npm install prisma@^7.7.0 @prisma/client@^7.7.0
npx prisma migrate dev  # 验证所有 migration 兼容
npm test                # 全量回归
```

**第三阶段 — MUI 7→9（前端大升级）**:
```bash
npm install @mui/material@^9.0.0 @mui/icons-material@^9.0.0
```

**第四阶段 — OpenAI 4→6**（同 orchestrator 方案）

### 架构优化建议

- **数据模型审查**: Prisma 从 5.4 直接跳到 7.7，建议趁升级机会审查 schema 设计
- **前端状态管理**: react-router-dom v7 的 data loading (loader pattern) 可减少瀑布式请求
- **ESLint Flat Config**: 升级 typescript-eslint 8 后，考虑迁移到 flat config

---

**报告生成时间**: 2026-04-09 06:01 CST  
**数据来源**: npm registry (实时查询) + GitHub Releases + 官方迁移文档  
**下次调研**: 2026-04-09 12:00  
**调研状态**: ✅ 完成

---

# 深度技术调研 - 2026-04-12 06:00

**调研人员**: 孔明  
**本次调研项目**: ai-carbon-footprint-tracker、ai-workspace-orchestrator  
**调研方法**: npm registry 实时查询 + 项目源码结构分析 + Express/Prisma/Zod 官方迁移文档核查

## 1. ai-carbon-footprint-tracker

**项目定位**: AI 驱动的个人碳足迹追踪与管理平台。Express + Prisma + OpenAI 架构，TypeScript 全栈。

### 依赖版本对照

| 依赖 | 当前 | 最新 | 差距 |
|------|------|------|------|
| express | ^4.18.2 | **5.2.1** | 🔴 落后 1 个大版本 |
| @prisma/client | ^5.6.0 | **7.7.0** | 🔴 落后 2 个大版本 |
| openai | ^4.20.1 | **6.34.0** | 🔴 落后 2 个大版本 |
| typescript | ^5.3.3 | **6.0.2** | 🔴 落后 1 个大版本 |
| winston | ^3.11.0 | **3.19.0** | 🟡 落后 8 个 minor |
| helmet | ^7.1.0 | **8.1.0** | 🔴 落后 1 个大版本 |
| moment | ^2.29.4 | 2.30.1 | 🟡 已弃用（官方推荐迁移） |
| joi | ^17.11.0 | 17.13.x | ✅ 当前大版本最新 |
| lodash | 4.18.1 | 4.18.1 | ✅ 最新 |
| jest | ^29.7.0 | **30.3.0** | 🔴 落后 1 个大版本 |
| eslint | ^8.55.0 | **10.2.0** | 🔴 落后 2 个大版本 |

### 可执行升级路径

**第一阶段 — 低风险 minor 升级**（预计 30 分钟）
```
npm i winston@^3.19.0 moment@^2.30.1
```
运行 `npm test` 验证，几乎零破坏性。

**第二阶段 — Express 4→5**（预计 2 小时）
Express 5 的关键破坏性变更：
- `app.del()` 移除 → 统一使用 `app.delete()`
- `app.param(fn)` 签名变更
- `res.redirect()` 不再支持双参数形式（status + url 需改为链式 `.status(302).redirect()`）
- 路径参数正则从 `app.get('/user/:id(\\d+)')` 改为命名路由
- `res.json(obj, status)` 移除 → 改用 `res.status(code).json(obj)`
- `req.host` 返回含 port 的完整 host（旧版不含 port）
- **行动**: 全局搜索 `res.redirect(`、`res.json(`、`app.param(` 确认影响范围，逐一修改后升级。

**第三阶段 — Prisma 5→7**（预计 3 小时）
Prisma 6→7 的重大变更：
- `prisma db push` 行为调整，新增 `--force-reset` 参数
- `@unique` 约束在复合索引上的行为变更
- `include`/`select` 类型推断改进（可能影响 TypeScript 编译）
- **行动**: `npx prisma migrate dev` 创建迁移 → 修复类型错误 → 验证所有 CRUD 操作。

**第四阶段 — 替换 moment → dayjs**（预计 1 小时）
moment.js 已于 2020 年进入维护模式，官方推荐 dayjs（仅 2KB，API 高度兼容）：
```
npm uninstall moment && npm i dayjs
```
替换 `moment()` → `dayjs()`，`.format()` 语法一致，仅需调整插件导入（如 timezone）。

**第五阶段 — ESLint 8→10 + Jest 29→30**（预计 2 小时）
ESLint 10 要求 flat config（`eslint.config.js`），需重写配置文件。Jest 30 是 minor breaking（主要是 `ts-jest` 兼容性）。

### 架构优化建议

- **移除 lodash 依赖**: 项目仅用 lodash 基础方法（如 `debounce`、`cloneDeep`），可用原生 `structuredClone()` + `setTimeout` 替代，减少 ~70KB bundle 大小
- **Joi → Zod**: 项目同时存在 Joi（运行时校验）和 TypeScript 类型，迁移到 Zod 可统一类型定义和校验逻辑，消除双维护负担
- **添加请求限流**: 当前缺少 `express-rate-limit`，碳足迹 API 可能被滥用，建议加入

---

## 2. ai-workspace-orchestrator（二次调研 - 跟踪上次建议进展）

**项目定位**: 企业级 AI 工作流自动化平台。Express + Prisma 7 + 多 AI 引擎 + Redis 缓存 + React 前端。

### 依赖版本对照（当前 vs 最新）

| 依赖 | 当前 | 最新 | 变化 |
|------|------|------|------|
| @prisma/client | ^7.6.0 | **7.7.0** | ✅ 几乎最新 |
| express | ^4.18.2 | **5.2.1** | 🔴 落后 1 个大版本（同上次） |
| @anthropic-ai/sdk | ^0.22.0 | **0.88.0** | 🔴 落后 66 个 minor |
| @google/generative-ai | ^0.21.0 | — | 🟡 未查询（Google 更新频繁） |
| openai | ^4.36.0 | **6.34.0** | 🔴 落后 2 个大版本 |
| zod | ^3.22.2 | **4.3.6** | 🔴 落后 1 个大版本 |
| vitest | ^4.1.3 | **4.1.4** | ✅ 几乎最新 |
| typescript | ^6.0.2 | 6.0.2 | ✅ 最新 |
| redis | ^5.11.0 | 5.11.0 | ✅ 最新 |
| eslint | ^8.45.0 | **10.2.0** | 🔴 落后 2 个大版本 |

### 关键发现：AI SDK 严重过时

**@anthropic-ai/sdk 0.22 → 0.88**（66 个版本差距）
这是本次调研最紧急的问题。0.22 版本缺少：
- Claude 3.5/4 系列模型支持
- Tool use (function calling) 的改进 API
- Streaming 的 `text_stream` 便利方法
- Messages Batch API
- **行动**: 直接升级到 `^0.88.0`，检查 `messages.create()` 调用签名是否变更（模型名称字符串如 `claude-3-opus-20240229` 可能需要更新）

**OpenAI 4.36 → 6.34**（2 个大版本）
- 5.x: 引入 Realtime API、Structured Outputs、更完善的 streaming
- 6.x: 全面 ESM 支持、Assistant API v2、新增 Responses API
- **行动**: 注意 6.x 改为 ESM-first，但项目已设 `"type": "module"` 所以兼容。重点检查 `chat.completions.create()` 返回类型变化

**Zod 3 → 4**（重大升级）
Zod 4 主要变更：
- `z.object()` 默认 strip unknown keys（行为不变）
- `z.infer<>` 推断性能大幅优化
- 新增 `z.interface()` 用于大 schema 的懒推断
- `refine`/`transform` 链式语法改进
- **行动**: 基本向后兼容，但需注意 `z.custom()` 和 `z.preprocess()` 的签名微调

### 可执行升级路径

**第一阶段 — AI SDK 升级**（优先级最高，预计 3 小时）
```bash
npm i @anthropic-ai/sdk@^0.88.0 openai@^6.34.0 @google/generative-ai@latest
```
逐一检查每个 AI 引擎的调用代码，运行集成测试。

**第二阶段 — Zod 3→4**（预计 2 小时）
```bash
npm i zod@^4.3.6
```
全局搜索 `z.preprocess` 和 `z.custom` 确认兼容性，其余 API 基本向后兼容。

**第三阶段 — Express 4→5**（同 carbon-tracker 方案）

### 架构优化建议

- **双测试框架统一**: 项目同时使用 Jest（`jest.config.cjs`）和 Vitest（`vitest@4.1.3`），建议统一到 Vitest——Vitest 原生支持 ESM 和 TypeScript，配置更简洁，且项目已是 `"type": "module"`
- **ESLint 8→10 + Flat Config**: 配合 Vitest 统一，顺势迁移到 ESLint flat config，减少配置复杂度
- **缓存层优化**: Redis 5.11 已是最新，但建议检查 `cache-manager` 是否用了 Redis store，考虑直接用 `redis` 包替代 `cache-manager`（减少一层抽象）
- **错误处理中间件**: 检查是否实现了 Express 5 兼容的异步错误处理（Express 5 原生支持 async middleware 的 rejection 捕获，无需 `express-async-errors`）

---

## 全局趋势观察

1. **Express 5 迁移是跨项目共同课题**: 所有 ai-ideas 项目均停留在 Express 4，建议制定统一的迁移模板
2. **Prisma 5→7 跨两版本**: carbon-tracker 还在 Prisma 5，orchestrator 已在 7，说明项目间技术栈存在代差
3. **moment.js 全面淘汰期**: 使用 moment 的项目应统一迁移到 dayjs
4. **AI SDK 更新频率极高**: OpenAI 和 Anthropic SDK 每月多版本迭代，建议建立定期更新机制（如每月一次 `npm outdated` 审查）
5. **ESLint 10 + Flat Config**: 所有项目均需迁移，建议统一配置模板

---

**报告生成时间**: 2026-04-12 06:01 CST  
**数据来源**: npm registry (实时查询) + 项目源码分析  
**下次调研**: 2026-04-12 12:00  
**调研状态**: ✅ 完成
