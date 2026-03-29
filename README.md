# 🌱 AI Carbon Footprint Tracker

AI驱动的个人碳足迹追踪与管理平台，帮助用户追踪、分析和优化日常碳排放，实现可持续绿色生活。

## ✨ 核心特性

### 🎯 碳排放追踪
- **多维度数据采集**：交通、饮食、能源、购物、住房、废弃物等全场景覆盖
- **智能数据接入**：GPS轨迹、银行账单、智能设备、图片识别等多种方式
- **精准碳排放计算**：基于LCA生命周期评估的科学算法

### 🤖 AI智能分析
- **个性化洞察**：AI分析用户行为模式，提供定制化减排建议
- **预测性分析**：预测未来碳排放趋势，提前预警高排放场景
- **智能推荐引擎**：基于用户习惯和目标推送最有效的减排方案

### 🏆 社交激励系统
- **减碳小队**：朋友组队，互相监督和鼓励
- **挑战任务**：每日、每周环保挑战，成就系统
- **排行榜**：个人和团队的碳排排名，激发竞争意识
- **积分奖励**：环保行为获得积分，兑换绿色产品

### 📊 数据可视化
- **实时仪表板**：直观展示碳排放数据和趋势
- **多维度分析**：按时间、类别、类型等维度进行数据钻取
- **对比分析**：与历史数据、同级别用户进行对比

## 🚀 技术栈

### 后端技术
- **运行时**：Node.js + TypeScript
- **框架**：Express.js
- **数据库**：Prisma + SQLite (PostgreSQL 可选)
- **AI集成**：OpenAI GPT-4
- **认证**：JWT + bcrypt
- **文件上传**：multer
- **日志**：Winston

### 开发工具
- **包管理**：npm
- **代码质量**：ESLint + Prettier
- **测试**：Jest
- **构建工具**：TypeScript Compiler
- **版本控制**：Git

## 🛠️ 安装与运行

### 环境要求
- Node.js >= 18.0.0
- npm >= 8.0.0
- OpenAI API Key

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/ai-ideas-lab/ai-carbon-footprint-tracker.git
cd ai-carbon-footprint-tracker
```

2. **安装依赖**
```bash
npm install
```

3. **环境配置**
```bash
cp .env.example .env
# 编辑 .env 文件，配置你的 OpenAI API Key 和其他设置
```

4. **数据库初始化**
```bash
npx prisma generate
npx prisma db push
```

5. **启动开发服务器**
```bash
npm run dev
```

### 生产部署

1. **构建项目**
```bash
npm run build
```

2. **启动生产服务器**
```bash
npm start
```

## 📁 项目结构

```
ai-carbon-footprint-tracker/
├── src/
│   ├── controllers/          # 控制器层
│   │   ├── carbonController.ts
│   │   ├── userController.ts
│   │   ├── aiController.ts
│   │   └── socialController.ts
│   ├── routes/              # 路由层
│   │   ├── carbon.ts
│   │   ├── user.ts
│   │   ├── ai.ts
│   │   └── social.ts
│   ├── middleware/          # 中间件
│   │   ├── auth.ts
│   │   ├── errorHandler.ts
│   │   ├── requestLogger.ts
│   │   ├── rateLimiter.ts
│   │   └── validation.ts
│   ├── utils/               # 工具函数
│   │   ├── database.ts
│   │   └── carbonFactors.ts
│   ├── test/                # 测试文件
│   │   └── setup.ts
│   └── index.ts             # 应用入口
├── prisma/
│   └── schema.prisma       # 数据库模式
├── data/                   # 数据文件
│   └── carbon-factors.json
├── logs/                   # 日志文件
├── uploads/                # 文件上传目录
├── package.json
├── tsconfig.json
├── jest.config.js
└── README.md
```

## 🌐 API 接口

### 认证相关
- `POST /api/user/register` - 用户注册
- `POST /api/user/login` - 用户登录
- `GET /api/user/profile` - 获取用户信息
- `PUT /api/user/profile` - 更新用户信息

### 碳排放管理
- `POST /api/carbon/records` - 创建碳排放记录
- `GET /api/carbon/records` - 获取用户排放记录
- `GET /api/carbon/summary` - 获取排放摘要
- `PUT /api/carbon/records/:id` - 更新排放记录
- `DELETE /api/carbon/records/:id` - 删除排放记录

### AI分析
- `POST /api/ai/analyze` - AI分析排放记录
- `POST /api/ai/reduction-plan` - 生成减排计划
- `POST /api/ai/chat` - 环保咨询对话
- `GET /api/ai/insights` - 获取AI洞察

### 社交功能
- `POST /api/social/groups` - 创建减排小组
- `GET /api/social/groups` - 获取用户小组
- `POST /api/social/challenges` - 创建挑战
- `GET /api/social/groups/:groupId/leaderboard` - 获取排行榜
- `GET /api/social/stats` - 获取社交统计

## 🔧 开发指南

### 代码规范
- 使用 TypeScript 进行类型检查
- 遵循 ESLint 配置的代码规范
- 编写单元测试确保代码质量
- 使用 Prisma 进行数据库操作

### 提交规范
```
feat: 添加新功能
fix: 修复bug
docs: 文档更新
style: 代码格式化
refactor: 代码重构
test: 测试相关
chore: 构建或辅助工具变动
```

### 数据库操作
```bash
# 生成 Prisma 客户端
npx prisma generate

# 推送数据库变更
npx prisma db push

# 查看数据库
npx prisma studio
```

### 运行测试
```bash
# 运行所有测试
npm test

# 运行测试并生成覆盖率报告
npm run test:coverage

# 监听模式运行测试
npm run test:watch
```

## 📊 数据模型

### 用户 (User)
- 基本信息：邮箱、姓名、头像
- 认证信息：加密密码
- 关联数据：排放记录、成就、社交关系

### 排放记录 (CarbonRecord)
- 基本信息：类别、类型、数量、单位
- 碳排放数据：排放量计算结果
- AI分析：智能洞察和建议
- 时间戳和位置信息

### 成就系统 (Achievement)
- 成就类型：减排里程碑、社交成就
- 积分奖励：根据成就难度给予不同积分
- 进度追踪：完成状态和完成时间

### 社交功能 (SocialGroup, GroupChallenge)
- 小组管理：创建、加入、退出
- 挑战系统：个人和团队挑战
- 排行榜：基于积分和减排效果

## 🔒 安全考虑

### 数据保护
- 用户密码使用 bcrypt 加密存储
- JWT Token 认证机制
- API 请求限流保护
- 敏感数据脱敏处理

### 隐私保护
- 用户数据本地优先存储
- 明确的数据使用授权机制
- 支持数据导出和账户删除
- 符合 GDPR 等隐私法规

## 🚀 部署指南

### Docker 部署
```bash
# 构建镜像
docker build -t ai-carbon-footprint-tracker .

# 运行容器
docker run -p 3000:3000 ai-carbon-footprint-tracker
```

### 环境变量配置
生产环境需要配置以下环境变量：
- `NODE_ENV`: production
- `DATABASE_URL`: 生产数据库连接字符串
- `JWT_SECRET`: 强 JWT 密钥
- `OPENAI_API_KEY`: OpenAI API 密钥
- `PORT`: 服务端口

### 性能优化
- 启用 Gzip 压缩
- 配置 CDN 加速静态资源
- 数据库索引优化
- Redis 缓存热点数据

## 📈 监控与分析

### 日志监控
- 使用 Winston 记录应用日志
- 错误日志集中收集
- 性能指标监控

### 业务监控
- 用户注册和活跃度
- 碳排放趋势分析
- AI 模型使用情况
- 社交功能参与度

## 🤝 贡献指南

我们欢迎各种形式的贡献！

### 报告问题
- 使用 GitHub Issues 提交 bug 报告
- 提供详细的复现步骤和环境信息

### 功能请求
- 在 Issues 中描述功能需求
- 说明使用场景和预期效果

### 代码贡献
- Fork 项目并创建功能分支
- 遵循代码规范和测试要求
- 提交 Pull Request 并描述变更内容

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 📞 联系我们

- 项目地址：https://github.com/ai-ideas-lab/ai-carbon-footprint-tracker
- 问题反馈：GitHub Issues
- 开发团队：OpenClaw AI Ideas Team

---

**让我们一起为绿色地球贡献力量！** 🌍✨