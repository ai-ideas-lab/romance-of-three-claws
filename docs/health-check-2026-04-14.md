# AI Ideas Lab 项目健康巡检报告 - 2026-04-14

## 项目概览

| 项目名称 | 状态 | Git状态 | README | 测试 | 最近提交 |
|---------|------|---------|--------|------|-----------|
| ai-appointment-manager | 🟡 警告 | ⚠️ 有未提交更改 (15个文件) | ✅ 有 | ❌ 无 | 🔴 20557天前: 44f2c06 |
| ai-carbon-footprint-tracker | 🟡 警告 | ⚠️ 有未提交更改 (node_modules) | ✅ 有 | ✅ 有 | 🔴 20557天前: 28130a5 |
| ai-career-soft-skills-coach-bak | 🟢 健康 | ✅ 干净 | ✅ 有 | ✅ 有 | 🔴 20557天前: 07ad796 |
| ai-contract-reader | 🟡 警告 | ⚠️ 有未提交更改 | ✅ 有 | ✅ 有 | 🔴 20557天前: e635eac |
| ai-email-manager | 🟢 健康 | ✅ 干净 | ✅ 有 | ✅ 有 | 🔴 20557天前: 1b30981 |
| ai-error-diagnostician | 🟡 警告 | ⚠️ 有未提交更改 | ✅ 有 | ✅ 有 | 🔴 20557天前: 71922e1 |
| ai-family-health-guardian | 🟡 警告 | ⚠️ 有未提交更改 | ✅ 有 | ✅ 有 | 🔴 20557天前: 09adb86 |
| ai-gardening-designer | 🔴 异常 | ⚠️ 有未提交更改 (13个文件) | ❌ 无 | ✅ 有 | 🔴 20557天前: 9531d03 |
| ai-interview-coach | 🟡 警告 | ⚠️ 有未提交更改 | ✅ 有 | ✅ 有 | 🔴 20557天前: 9bc20ac |
| ai-rental-detective | 🔴 异常 | ⚠️ 有未提交更改 | ✅ 有 | ❌ 无 | 🔴 20557天前: e635eac |
| ai-voice-notes-organizer | 🟡 警告 | ⚠️ 有未提交更改 | ✅ 有 | ❌ 无 | 🔴 20557天前: 28130a5 |
| ai-workspace-orchestrator | 🟡 警告 | ⚠️ 有未提交更改 | ✅ 有 | ❌ 无 | 🔴 20557天前: 28130a5 |

## 状态统计

- 🟢 健康: 2 个项目 (16.7%)
- 🟡 警告: 9 个项目 (75.0%)  
- 🔴 异常: 2 个项目 (16.7%)

## 详细分析

### 🟢 健康项目
1. **ai-career-soft-skills-coach-bak** - Git干净，有README和测试
2. **ai-email-manager** - Git干净，有README和测试

### 🟡 警告项目
1. **ai-appointment-manager** - 有未提交更改，缺少测试
2. **ai-carbon-footprint-tracker** - 有node_modules更改，有README和测试
3. **ai-contract-reader** - 有未提交更改，有README和测试
4. **ai-error-diagnostician** - 有未提交更改，有README和测试
5. **ai-family-health-guardian** - 有未提交更改，有README和测试
6. **ai-interview-coach** - 有未提交更改，有README和测试
7. **ai-voice-notes-organizer** - 有未提交更改，有README但缺少测试
8. **ai-workspace-orchestrator** - 有未提交更改，有README但缺少测试

### 🔴 异常项目
1. **ai-gardening-designer** - 有未提交更改，缺少README但有测试
2. **ai-rental-detective** - 有未提交更改，有README但缺少测试

## 安全漏洞检测结果

所有项目均发现存在安全漏洞，主要涉及：
- 🔴 **Critical**: axios漏洞 (ai-carbon-footprint-tracker)
- 🟡 **High**: TypeScript ESLint相关漏洞
- 🟡 **High**: lodash漏洞
- 🟡 **Moderate**: esbuild、vite漏洞

## 建议行动

### 立即处理 (🔴 异常项目)
1. **ai-gardening-designer**: 
   - 创建README.md文档
   - 提交未提交的更改
   - 修复安全漏洞

2. **ai-rental-detective**:
   - 添加测试文件
   - 提交未提交的更改
   - 修复安全漏洞

### 短期处理 (🟡 警告项目)
1. 所有项目提交未提交的更改
2. ai-appointment-manager、ai-voice-notes-organizer、ai-workspace-orchestrator 添加测试文件
3. 全面修复各项目的npm安全漏洞

### 长期建议
1. 建立定期的依赖更新和安全审计机制
2. 实施测试覆盖率要求
3. 加强项目文档维护

## 生成时间
2026-04-14 08:00:00

## 巡检人员
孔明 (AI项目健康巡检系统)