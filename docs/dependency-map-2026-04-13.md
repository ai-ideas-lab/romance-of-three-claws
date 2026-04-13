# AI Ideas Lab 项目依赖关系分析报告 - Mon Apr 13 17:03:37 CST 2026

## 项目信息收集
| 项目名称 | 技术栈 | 主要依赖 | 内部共享包 | API调用关系 |
|---------|--------|---------|-----------|----------|
| ai-appointment-manager |  Node.js AI/ML Database |   dependencies,    @prisma/client,    @types/express-validator,    bcryptjs,    cors |  | 待分析 |
| ai-career-soft-skills-coach | 未找到 package.json | - | - | - |
| ai-family-health-guardian |  Node.js AI/ML Database |   dependencies,    @prisma/client,    bcryptjs,    cors,    cron |  | 待分析 |

## 共享依赖分析
### 多个项目共用的依赖包：
| 依赖包 | 使用项目数 | 使用项目 |
|--------|------------|---------|
| dependencies | 2 | ai-appointment-manager,ai-family-health-guardian |
| @prisma/client | 2 | ai-appointment-manager,ai-family-health-guardian |
| bcryptjs | 2 | ai-appointment-manager,ai-family-health-guardian |
| cors | 2 | ai-appointment-manager,ai-family-health-guardian |
| dotenv | 2 | ai-appointment-manager,ai-family-health-guardian |
| express | 2 | ai-appointment-manager,ai-family-health-guardian |
| helmet | 2 | ai-appointment-manager,ai-family-health-guardian |
| jsonwebtoken | 2 | ai-appointment-manager,ai-family-health-guardian |
| nodemailer | 2 | ai-appointment-manager,ai-family-health-guardian |
| openai | 2 | ai-appointment-manager,ai-family-health-guardian |
| winston | 2 | ai-appointment-manager,ai-family-health-guardian |
| dependencies | 2 | ai-appointment-manager,ai-family-health-guardian |
| @prisma/client | 2 | ai-appointment-manager,ai-family-health-guardian |
| bcryptjs | 2 | ai-appointment-manager,ai-family-health-guardian |
| cors | 2 | ai-appointment-manager,ai-family-health-guardian |
| cron | 2 | ai-appointment-manager,ai-family-health-guardian |
| dotenv | 2 | ai-appointment-manager,ai-family-health-guardian |
| express | 2 | ai-appointment-manager,ai-family-health-guardian |
| helmet | 2 | ai-appointment-manager,ai-family-health-guardian |
| jsonwebtoken | 2 | ai-appointment-manager,ai-family-health-guardian |
| nodemailer | 2 | ai-appointment-manager,ai-family-health-guardian |
| openai | 2 | ai-appointment-manager,ai-family-health-guardian |
| winston | 2 | ai-appointment-manager,ai-family-health-guardian |

### 内部共享包分析：
| 内部包 | 使用项目 |
|--------|---------|

## 依赖关系图


## 优化建议
### Monorepo 策略建议：
1. **共享包提取**：将重复依赖提取到 monorepo 根目录的 packages/ 目录
2. **版本统一**：制定统一的依赖版本管理策略，避免版本冲突
3. **CI/CD 优化**：使用 monorepo 构建工具（如 Turbo、Nx）优化构建流程
4. **依赖监控**：建立依赖安全监控，及时更新废弃包

### 具体行动项：
- [ ] 创建 monorepo 根目录的 package.json 和工作区配置
- [ ] 识别并提取 3-5 个最常用的共享依赖
- [ ] 统一 TypeScript 配置和 ESLint 规则
- [ ] 建立依赖版本升级流程
- [ ] 设置定期的依赖安全检查
