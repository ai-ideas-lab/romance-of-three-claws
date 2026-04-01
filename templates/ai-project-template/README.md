# AI Project Template

基于TypeScript + Prisma + PostgreSQL的AI应用项目模板

## 🚀 快速开始

```bash
# 1. 克隆模板
git clone https://github.com/ai-ideas-lab/ai-project-template.git my-project
cd my-project

# 2. 安装依赖
npm install

# 3. 配置环境变量
cp .env.example .env
# 编辑 .env 文件，填入必要的配置

# 4. 初始化数据库
npm run db:migrate
npm run db:seed

# 5. 启动开发服务器
npm run dev
```

## 📁 项目结构

```
project-template/
├── src/
│   ├── api/              # API路由
│   │   ├── routes/       # 路由定义
│   │   ├── middleware/   # 中间件
│   │   └── validators/   # 请求验证
│   ├── services/         # 业务逻辑
│   ├── models/           # 数据模型
│   ├── utils/            # 工具函数
│   ├── config/           # 配置文件
│   └── app.ts            # 应用入口
├── prisma/
│   ├── schema.prisma     # 数据库模式
│   ├── migrations/       # 迁移文件
│   └── seeds/            # 种子数据
├── tests/
│   ├── unit/             # 单元测试
│   ├── integration/      # 集成测试
│   └── setup.ts          # 测试配置
├── docs/
│   ├── api.md            # API文档
│   ├── architecture.md   # 架构文档
│   └── deployment.md     # 部署文档
├── scripts/
│   ├── build.sh          # 构建脚本
│   ├── deploy.sh         # 部署脚本
│   └── test.sh           # 测试脚本
├── .github/
│   └── workflows/        # GitHub Actions
│       ├── ci.yml        # 持续集成
│       └── deploy.yml    # 自动部署
├── docker-compose.yml    # Docker编排
├── Dockerfile            # Docker镜像
├── .env.example          # 环境变量示例
├── .eslintrc.js          # ESLint配置
├── .prettierrc           # Prettier配置
├── tsconfig.json         # TypeScript配置
├── jest.config.js        # Jest配置
└── package.json          # 项目配置
```

## 🛠️ 技术栈

### 核心技术
- **运行时**: Node.js 22.x
- **语言**: TypeScript 5.x
- **框架**: Express / Fastify
- **数据库**: PostgreSQL 15+
- **ORM**: Prisma 5.x

### AI集成
- **OpenAI API**: GPT-4 / GPT-3.5-turbo
- **Anthropic API**: Claude 3
- **本地模型**: Ollama (可选)

### 开发工具
- **测试**: Jest + Supertest
- **代码质量**: ESLint + Prettier
- **类型检查**: TypeScript strict mode
- **API文档**: Swagger / OpenAPI

### 部署
- **容器化**: Docker + Docker Compose
- **CI/CD**: GitHub Actions
- **监控**: Prometheus + Grafana (可选)

## 📝 开发规范

### Git提交规范
```
feat: 新功能
fix: 修复bug
docs: 文档更新
style: 代码格式
refactor: 重构
test: 测试
chore: 构建/工具
```

### 分支策略
- `main`: 生产分支
- `develop`: 开发分支
- `feature/*`: 功能分支
- `hotfix/*`: 紧急修复

### 代码审查
- 所有PR必须经过审查
- 测试覆盖率不低于80%
- TypeScript无编译错误
- ESLint无错误

## 🧪 测试

```bash
# 单元测试
npm run test:unit

# 集成测试
npm run test:integration

# 覆盖率报告
npm run test:coverage

# 监听模式
npm run test:watch
```

## 📊 监控

### 健康检查
- GET `/health` - 服务健康状态
- GET `/metrics` - Prometheus指标

### 日志
- Winston日志库
- 结构化JSON格式
- 日志级别: error, warn, info, debug

## 🚢 部署

### Docker部署
```bash
# 构建镜像
docker build -t my-project .

# 运行容器
docker run -p 3000:3000 my-project

# Docker Compose
docker-compose up -d
```

### 环境变量
```env
# 应用配置
NODE_ENV=production
PORT=3000

# 数据库
DATABASE_URL=postgresql://user:pass@localhost:5432/db

# AI API
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# 可选：监控
PROMETHEUS_ENABLED=true
GRAFANA_ENABLED=true
```

## 📚 文档

- [API文档](docs/api.md)
- [架构设计](docs/architecture.md)
- [部署指南](docs/deployment.md)
- [贡献指南](CONTRIBUTING.md)

## 🤝 贡献

1. Fork项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: Add AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建Pull Request

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 🙏 致谢

基于以下最佳实践构建：
- [TypeScript Best Practices](https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html)
- [Prisma Best Practices](https://www.prisma.io/docs/guides)
- [Express Security Best Practices](https://expressjs.com/en/advanced/best-practice-security.html)
- [12 Factor App](https://12factor.net/)

---

**创建时间**: 2026-04-01
**维护者**: AI Ideas Lab
**版本**: 1.0.0
