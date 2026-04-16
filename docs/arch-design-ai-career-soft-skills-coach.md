# AI 职场软技能导师 - 架构设计文档

> **项目名称**: AI Career Soft Skills Coach  
> **设计版本**: v1.0  
> **设计日期**: 2026-04-16  
> **架构师**: 孔明  

---

## 1. 项目概述

### 1.1 项目目标
为职场新人（0-3年）提供AI驱动的软技能训练平台，通过场景模拟、邮件优化、会议准备等功能，帮助用户快速提升职场沟通能力。

### 1.2 核心价值
- **场景模拟训练**: 报告、反馈、谈判、冲突、面试等高频场景
- **智能反馈系统**: 实时分析用户表现，提供改进建议
- **个性化学习**: 基于用户岗位和痛点定制学习路径
- **多端支持**: Web、移动端、微信小程序全覆盖

### 1.3 技术挑战
- **实时交互体验**: 低延迟的AI对话生成
- **个性化推荐**: 基于用户行为的智能场景推荐
- **内容质量**: 高质量的职场场景设计和反馈算法
- **可扩展性**: 支持用户规模增长和企业客户需求

---

## 2. 技术选型深度分析

### 2.1 候选方案对比

#### 方案一：Node.js + PostgreSQL + Redis + OpenAI
**架构特点**：成熟技术栈，快速开发，OpenAI API生态完善

**优势分析**：
- **性能**: Node.js异步I/O适合高并发API调用，Redis缓存提升响应速度
- **开发效率**: 丰富的npm生态，TypeScript支持良好
- **社区支持**: Node.js社区活跃，问题解决方案多
- **学习曲线**: 前端开发者熟悉，团队上手快
- **成本**: OpenAI API按量计费，初期成本可控

**劣势分析**：
- **AI依赖**: 对OpenAI API依赖度高，成本随用户增长
- **并发限制**: Node.js单线程模型，需要集群部署
- **中文优化**: OpenAI对中文理解不如本地模型

#### 方案二：Python FastAPI + PostgreSQL + Redis + GLM-4
**架构特点**：Python生态，GLM-4中文优化，FastAPI高性能

**优势分析**：
- **AI能力**: GLM-4中文理解更优，更适合职场场景
- **性能**: FastAPI异步性能优异，自动API文档生成
- **AI生态**: Python AI/ML生态最完善，算法实现灵活
- **数据处理**: Pandas等库便于用户行为分析
- **成本**: GLM-4性价比相对较高

**劣势分析**：
- **开发效率**: 相对Node.js稍慢，部署复杂度较高
- **前端协作**: 前后端技术栈差异，团队协作成本高
- **学习曲线**: Python学习曲线较陡峭

#### 方案三：Go + TiDB + Kafka + Claude API
**架构特点**：高并发性能，分布式架构，企业级可靠性

**优势分析**：
- **性能**: Go协程模型支持极高并发，TiDB分布式数据库
- **可靠性**: Go强类型，编译型语言，内存安全
- **扩展性**: Kafka消息队列支持水平扩展
- **企业级**: 适合大型企业客户部署
- **成本**: 长期来看成本效益高

**劣势分析**：
- **开发复杂度**: Go学习曲线陡峭，开发效率较低
- **AI生态**: Claude API集成复杂度较高
- **团队要求**: 需要专业Go开发团队

### 2.2 技术维度评分 (1-10分)

| 技术方案 | 性能 | 开发效率 | 社区支持 | 学习曲线 | 成本 | 总分 |
|---------|------|----------|----------|----------|------|------|
| Node.js + OpenAI | 8 | 9 | 9 | 8 | 7 | 41 |
| Python + GLM-4 | 7 | 8 | 8 | 6 | 8 | 37 |
| Go + Claude | 10 | 6 | 7 | 5 | 6 | 34 |

### 2.3 推荐方案

**推荐方案**: Node.js + PostgreSQL + Redis + GLM-4 + DeepSeek

**推荐理由**:
1. **平衡性最优**: 在性能、开发效率、成本之间取得最佳平衡
2. **团队适配**: 与现有技术栈兼容，降低团队学习成本
3. **中文优化**: GLM-4 + DeepSeek双模型策略，确保中文理解能力
4. **生态成熟**: Node.js生态丰富，快速实现MVP
5. **成本可控**: 混合使用不同API，优化成本结构

---

## 3. 系统架构设计

### 3.1 整体架构图

```mermaid
graph TB
    subgraph "客户端层"
        A[Web前端 React]
        B[移动端 React Native]
        C[微信小程序]
    end
    
    subgraph "网关层"
        D[Nginx负载均衡]
        E[API Gateway Fastify]
        F[CDN加速]
    end
    
    subgraph "应用服务层"
        G[用户服务 User Service]
        H[对话引擎 Dialogue Engine]
        I[场景管理 Scenario Service]
        J[分析引擎 Analysis Engine]
        K[推荐系统 Recommendation Service]
        L[通知系统 Notification Service]
    end
    
    subgraph "AI服务层"
        M[LLM网关 LLM Gateway]
        N[GLM-4 API]
        O[DeepSeek API]
        P[Whisper ASR]
        Q[Edge TTS]
        R[内容审核 Content Moderation]
    end
    
    subgraph "数据存储层"
        S[PostgreSQL 主数据库]
        T[Redis 缓存]
        U[Elasticsearch 搜索]
        V[MinIO 文件存储]
        W[向量数据库 VectorDB]
    end
    
    subgraph "基础设施层"
        X[Kubernetes集群]
        Y[监控 Prometheus]
        Z[日志 ELK]
        AA[CI/CD GitLab CI]
    end
    
    A --> D
    B --> D
    C --> D
    D --> E
    E --> G
    E --> H
    E --> I
    E --> J
    E --> K
    E --> L
    
    H --> M
    I --> M
    J --> M
    K --> W
    
    M --> N
    M --> O
    P --> N
    Q --> O
    R --> N
    
    G --> S
    H --> S
    I --> S
    J --> S
    K --> S
    
    G --> T
    H --> T
    I --> T
    K --> T
    
    J --> U
    K --> U
    
    L --> V
    H --> V
    
    S --> X
    T --> X
    U --> X
    V --> X
    
    X --> Y
    X --> Z
    X --> AA
```

### 3.2 核心模块职责

#### 3.2.1 用户服务 (User Service)
- **用户认证**: JWT令牌管理，OAuth2.0集成
- **用户画像**: 职位、经验、技能标签管理
- **权限控制**: RBAC角色权限管理
- **订阅管理**: 订阅状态、权益管理

#### 3.2.2 对话引擎 (Dialogue Engine)
- **场景模拟**: 多角色对话生成与管理
- **实时交互**: WebSocket长连接，流式响应
- **上下文管理**: 对话历史、用户状态跟踪
- **反馈生成**: 实时分析用户表现，提供改进建议

#### 3.2.3 场景管理 (Scenario Service)
- **场景库管理**: 场景模板、案例库维护
- **个性化推荐**: 基于用户画像的场景推荐
- **难度分级**: 初级、中级、高级场景管理
- **用户进度**: 学习进度、成就系统

#### 3.2.4 分析引擎 (Analysis Engine)
- **邮件优化**: 邮件内容分析、改写建议
- **会议准备**: 会议议题、发言要点生成
- **复盘分析**: 对话复盘、改进建议
- **行为分析**: 用户行为模式识别

#### 3.2.5 推荐系统 (Recommendation Service)
- **内容推荐**: 场景、练习内容推荐
- **学习路径**: 个性化学习路径规划
- **智能调度**: 最佳练习时间推荐
- **效果预测**: 学习效果预测模型

### 3.3 数据流设计

```mermaid
sequenceDiagram
    participant U as 用户
    participant GW as API Gateway
    participant DS as 对话服务
    participant LE as LLM网关
    participant AI as AI模型
    participant DB as 数据库
    participant Cache as Redis

    U->>GW: WebSocket连接
    GW->>DS: 建立对话会话
    DS->>Cache: 存储对话上下文
    DS->>LE: 发送对话请求
    LE->>AI: GLM-4/DeepSeek API
    AI->>LE: 流式响应
    LE->>DS: 实时返回结果
    DS->>Cache: 更新对话状态
    DS->>GW: WebSocket推送结果
    GW->>U: 实时显示对话内容
    
    U->>GW: POST /api/scenarios
    GW->>IS: 场景查询请求
    IS->>Cache: 检查缓存
    IS->>DB: 查询场景模板
    IS->>Cache: 更新缓存
    IS->>GW: 返回场景列表
    
    U->>GW: POST /api/analysis
    GW->>AE: 分析请求
    AE->>LE: AI分析请求
    LE->>AI: 内容分析
    AI->>LE: 分析结果
    LE->>AE: 返回分析结果
    AE->>DB: 存储分析记录
    AE->>GW: 返回优化建议
```

---

## 4. 目录结构设计

### 4.1 项目目录树

```
ai-career-soft-skills-coach/
├── docs/                           # 文档目录
│   ├── architecture.md            # 架构设计文档
│   ├── api-spec.md                # API规范文档
│   ├── deployment.md              # 部署文档
│   └── user-guide.md             # 用户使用指南
├── packages/                      # 微服务包
│   ├── api-gateway/              # API网关服务
│   │   ├── src/
│   │   │   ├── controllers/      # 控制器
│   │   │   ├── middleware/       # 中间件
│   │   │   ├── routes/           # 路由定义
│   │   │   ├── services/         # 服务层
│   │   │   ├── utils/            # 工具函数
│   │   │   └── types/            # TypeScript类型定义
│   │   ├── tests/                # 测试文件
│   │   ├── dist/                 # 构建产物
│   │   └── package.json
│   ├── user-service/             # 用户服务
│   │   ├── src/
│   │   │   ├── models/           # 数据模型
│   │   │   ├── repositories/     # 数据访问层
│   │   │   ├── services/         # 业务逻辑层
│   │   │   └── controllers/      # API控制器
│   │   └── package.json
│   ├── dialogue-engine/           # 对话引擎服务
│   │   ├── src/
│   │   │   ├── conversation/     # 对话管理
│   │   │   ├── context/          # 上下文管理
│   │   │   ├── feedback/         # 反馈生成
│   │   │   └── real-time/       # 实时通信
│   │   └── package.json
│   ├── scenario-service/          # 场景管理服务
│   │   ├── src/
│   │   │   ├── scenarios/        # 场景管理
│   │   │   ├── templates/       # 模板管理
│   │   │   ├── difficulty/      # 难度管理
│   │   │   └── progress/        # 进度管理
│   │   └── package.json
│   ├── analysis-engine/          # 分析引擎服务
│   │   ├── src/
│   │   │   ├── email/           # 邮件优化
│   │   │   ├── meeting/         # 会议准备
│   │   │   ├── review/          # 复盘分析
│   │   │   └── behavior/        # 行为分析
│   │   └── package.json
│   ├── recommendation-service/   # 推荐系统服务
│   │   ├── src/
│   │   │   ├── content/         # 内容推荐
│   │   │   ├── learning/        # 学习路径
│   │   │   ├── scheduling/      # 智能调度
│   │   │   └── prediction/      # 效果预测
│   │   └── package.json
│   └── notification-service/     # 通知服务
│       ├── src/
│       │   ├── push/            # 推送通知
│       │   ├── email/           # 邮件通知
│       │   ├── sms/             # 短信通知
│       │   └── websocket/       # WebSocket通知
│       └── package.json
├── web/                          # Web前端
│   ├── src/
│   │   ├── components/          # React组件
│   │   │   ├── common/          # 通用组件
│   │   │   ├── scenarios/       # 场景组件
│   │   │   ├── dialogue/        # 对话组件
│   │   │   ├── analysis/        # 分析组件
│   │   │   └── profile/        # 用户组件
│   │   ├── pages/              # 页面组件
│   │   ├── hooks/              # 自定义Hooks
│   │   ├── services/           # API服务
│   │   ├── store/              # 状态管理
│   │   ├── utils/              # 工具函数
│   │   └── types/              # TypeScript类型
│   ├── public/                 # 静态资源
│   ├── tests/                  # 测试文件
│   └── package.json
├── mobile/                     # 移动端
│   ├── src/
│   │   ├── components/         # React Native组件
│   │   ├── screens/           # 页面
│   │   ├── navigation/        # 导航
│   │   ├── services/          # API服务
│   │   └── utils/             # 工具函数
│   ├── android/               # Android原生配置
│   └── ios/                   # iOS原生配置
├── infrastructure/            # 基础设施配置
│   ├── kubernetes/            # K8s配置
│   ├── docker/               # Docker配置
│   ├── monitoring/           # 监控配置
│   └── ci-cd/               # CI/CD配置
├── scripts/                   # 脚本文件
│   ├── deploy/              # 部署脚本
│   ├── migrate/             # 数据库迁移
│   └── backup/              # 备份脚本
├── config/                   # 配置文件
│   ├── database.ts          # 数据库配置
│   ├── redis.ts            # Redis配置
│   ├── ai.ts               # AI服务配置
│   └── environment.ts      # 环境配置
├── tests/                    # 集成测试
│   ├── e2e/                # 端到端测试
│   ├── integration/        # 集成测试
│   └── performance/        # 性能测试
├── .github/                 # GitHub配置
│   └── workflows/           # GitHub Actions
├── docker-compose.yml       # Docker编排
├── .env.example             # 环境变量示例
├── .gitignore              # Git忽略文件
├── package.json            # 根package.json
└── README.md               # 项目说明
```

### 4.2 文件命名规范

#### 4.2.1 代码文件
- **控制器**: `[Name]Controller.ts` (如: `UserController.ts`)
- **服务**: `[Name]Service.ts` (如: `DialogueService.ts`)
- **模型**: `[Name].model.ts` (如: `User.model.ts`)
- **类型**: `[Name].types.ts` (如: `dialogue.types.ts`)
- **工具**: `[Name].utils.ts` (如: `date.utils.ts`)

#### 4.2.2 配置文件
- **环境配置**: `.env.[environment]` (如: `.env.development`)
- **数据库配置**: `database.config.ts`
- **AI配置**: `ai.config.ts`

#### 4.2.3 测试文件
- **单元测试**: `[Name].test.ts`
- **集成测试**: `[Name].int.test.ts`
- **端到端测试**: `[Name].e2e.test.ts`

---

## 5. 核心API设计

### 5.1 RESTful API端点列表

#### 5.1.1 用户管理模块

```typescript
// 用户注册
POST /api/v1/auth/register
// 请求体
{
  "email": "user@example.com",
  "password": "password123",
  "profile": {
    "name": "张三",
    "position": "软件工程师",
    "experience": 1,
    "department": "技术部",
    "skills": ["沟通", "团队协作"]
  }
}

// 用户登录
POST /api/v1/auth/login
// 请求体
{
  "email": "user@example.com",
  "password": "password123"
}

// 获取用户信息
GET /api/v1/users/profile
// 响应
{
  "id": "user123",
  "email": "user@example.com",
  "profile": {
    "name": "张三",
    "position": "软件工程师",
    "experience": 1,
    "progress": {
      "totalScenarios": 20,
      "completedScenarios": 8,
      "skillLevels": {
        "沟通": "中级",
        "团队协作": "初级"
      }
    }
  }
}

// 更新用户画像
PUT /api/v1/users/profile
// 请求体
{
  "position": "高级软件工程师",
  "experience": 3,
  "skills": ["沟通", "团队协作", "项目管理"],
  "goals": ["提升演讲能力", "改善向上管理"]
}
```

#### 5.1.2 场景管理模块

```typescript
// 获取场景列表
GET /api/v1/scenarios?page=1&limit=10&category=presentation&difficulty=beginner
// 查询参数
// - page: 页码
// - limit: 每页数量
// - category: 场景类别 (presentation/feedback/negotiation/conflict/interview)
// - difficulty: 难度 (beginner/intermediate/advanced)
// 响应
{
  "scenarios": [
    {
      "id": "scenario123",
      "title": "项目进度汇报",
      "description": "向技术经理汇报项目进展",
      "category": "presentation",
      "difficulty": "beginner",
      "duration": 15,
      "role": "汇报人",
      "characters": [
        {"name": "技术经理", "description": "关注项目细节和风险"},
        {"name": "产品经理", "description": "关注业务价值"}
      ],
      "learningPoints": ["结构化表达", "数据支撑", "风险预判"]
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 25
  }
}

// 获取场景详情
GET /api/v1/scenarios/{scenarioId}
// 响应
{
  "id": "scenario123",
  "title": "项目进度汇报",
  "description": "向技术经理汇报项目进展",
  "content": {
    "background": "你的项目进行到一半，需要向技术经理汇报当前进展",
    "objectives": ["清晰展示项目进展", "识别潜在风险", "获取支持"],
    "dialogueFlow": [
      {
        "step": 1,
        "situation": "技术经理询问项目整体进度",
        "yourRole": "汇报人",
        "expectedResponse": "使用STAR法则结构化回答"
      }
    ]
  },
  "templates": {
    "opening": "尊敬的技术经理，关于XX项目的进展我想向您汇报一下...",
    "structure": "整体进展 → 里程碑达成 → 遇到的问题 → 需要的支持",
    "closing": "以上是项目进展汇报，请您指示"
  }
}
```

#### 5.1.3 对话引擎模块

```typescript
// 建立对话会话
POST /api/v1/dialogues/sessions
// 请求体
{
  "scenarioId": "scenario123",
  "mode": "text" // text/voice
}
// 响应
{
  "sessionId": "dialogue123",
  "scenario": {
    "id": "scenario123",
    "title": "项目进度汇报"
  },
  "context": {
    "currentStep": 1,
    "characters": [
      {"name": "技术经理", "type": "ai"},
      {"name": "你", "type": "user"}
    ]
  },
  "instructions": "请按照场景要求，以汇报人的身份与AI技术经理对话"
}

// 发送对话消息
POST /api/v1/dialogues/{sessionId}/messages
// 请求体
{
  "content": "技术经理您好，关于XX项目的进展我想向您汇报一下...",
  "type": "user" // user/ai
}
// 响应
{
  "messageId": "msg123",
  "content": "好的，请详细汇报一下项目目前的进展情况。",
  "type": "ai",
  "timestamp": "2026-04-16T12:00:00Z",
  "feedback": {
    "score": 8,
    "strengths": ["问候得体", "目的明确"],
    "improvements": ["可以加入具体数据支撑"],
    "suggestions": "建议使用'截至目前，项目完成了80%的工作量'这样的表述"
  }
}

// 获取对话历史
GET /api/v1/dialogues/{sessionId}/history?limit=50
// 响应
{
  "sessionId": "dialogue123",
  "messages": [
    {
      "id": "msg123",
      "content": "技术经理您好，关于XX项目的进展我想向您汇报一下...",
      "type": "user",
      "timestamp": "2026-04-16T12:00:00Z"
    },
    {
      "id": "msg124", 
      "content": "好的，请详细汇报一下项目目前的进展情况。",
      "type": "ai",
      "timestamp": "2026-04-16T12:00:30Z",
      "feedback": {
        "score": 8,
        "analysis": "开门见山，直接切入主题"
      }
    }
  ]
}

// 结束对话会话
POST /api/v1/dialogues/{sessionId}/complete
// 请求体
{
  "rating": 8,
  "feedback": "很有帮助，AI的反馈很及时"
}
// 响应
{
  "sessionId": "dialogue123",
  "summary": {
    "duration": "15分钟",
    "totalMessages": 20,
    "averageScore": 7.5,
    "improvementAreas": ["结构化表达", "数据支撑"],
    "nextSteps": ["继续练习类似场景", "关注表达逻辑"]
  }
}
```

#### 5.1.4 分析引擎模块

```typescript
// 邮件内容分析
POST /api/v1/analysis/email
// 请求体
{
  "content": "王总，关于昨天的会议，我想确认一下下个季度的目标...",
  "type": "draft", // draft/sent
  "context": {
    "recipient": "王总",
    "purpose": "目标确认",
    "tone": "formal"
  }
}
// 响应
{
  "analysis": {
    "clarity": 7,
    "tone": 8,
    "structure": 6,
    "professionalism": 8
  },
  "suggestions": [
    "建议在开头明确会议主题",
    "可以加入具体的时间节点",
    "结尾可以询问下一步安排"
  ],
  "improvedVersion": "尊敬的王总，关于昨天会议确定的下季度目标，我想和您确认一下具体的执行计划和时间安排...",
  "keywords": ["目标确认", "季度计划", "执行安排"]
}

// 会议准备分析
POST /api/v1/analysis/meeting
// 请求体
{
  "meetingType": "project_review",
  "topic": "Q2项目进展汇报",
  "duration": 30,
  "attendees": ["技术总监", "产品经理", "测试负责人"],
  "myRole": "项目负责人"
}
// 响应
{
  "agenda": {
    "opening": "开场白和会议目标 (2分钟)",
    "progress_update": "项目进展汇报 (10分钟)",
    "issues_discussion": "问题讨论 (10分钟)",
    "next_steps": "下一步计划 (5分钟)",
    "summary": "总结 (3分钟)"
  },
  "keyPoints": [
    "项目完成度：75%",
    "主要成果：完成核心模块开发",
    "风险点：测试进度滞后",
    "支持需求：增加测试资源"
  ],
  "qAndA": [
    {
      "question": "项目完成度是否符合预期？",
      "answer": "基本符合预期，核心模块已完成，但测试进度需要加强"
    },
    {
      "question": "需要什么支持？",
      "answer": "希望增加2名测试工程师，确保项目按时交付"
    }
  ],
  "speechStructure": "开场→现状→成果→问题→需求→总结"
}
```

#### 5.1.5 推荐系统模块

```typescript
// 获取推荐场景
GET /api/v1/recommendations/scenarios?limit=5
// 响应
{
  "recommendations": [
    {
      "scenario": {
        "id": "scenario456",
        "title": "向上沟通技巧",
        "category": "presentation",
        "difficulty": "intermediate"
      },
      "reason": "根据你的用户画像，推荐提升向上沟通能力",
      "priority": "high",
      "estimatedTime": 20,
      "learningOutcome": "能够清晰地向领导汇报工作"
    }
  ],
  "algorithm": {
    "basedOn": ["userSkills", "learningGoals", "historicalPerformance"],
    "confidence": 0.85
  }
}

// 获取学习路径推荐
GET /api/v1/recommendations/learning-path
// 响应
{
  "path": {
    "title": "职场新人成长路径",
    "duration": "3个月",
    "stages": [
      {
        "stage": 1,
        "name": "基础沟通",
        "duration": "2周",
        "scenarios": ["自我介绍", "日常沟通", "会议参与"],
        "goals": ["建立基础沟通能力", "适应职场环境"]
      },
      {
        "stage": 2,
        "name": "专业表达",
        "duration": "3周", 
        "scenarios": ["工作汇报", "问题反馈", "需求澄清"],
        "goals": ["提升专业表达能力", "准确传递信息"]
      }
    ]
  }
}
```

### 5.2 请求/响应Schema定义

#### 5.2.1 通用响应格式

```typescript
interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
  timestamp: string;
  requestId: string;
}

interface PaginatedResponse<T> {
  success: boolean;
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
  timestamp: string;
  requestId: string;
}
```

#### 5.2.2 错误响应格式

```typescript
interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: any;
    field?: string;
  };
  timestamp: string;
  requestId: string;
}

// 错误码定义
enum ErrorCode {
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  AUTHENTICATION_ERROR = 'AUTHENTICATION_ERROR',
  AUTHORIZATION_ERROR = 'AUTHORIZATION_ERROR',
  NOT_FOUND = 'NOT_FOUND',
  RATE_LIMIT_EXCEEDED = 'RATE_LIMIT_EXCEEDED',
  INTERNAL_ERROR = 'INTERNAL_ERROR',
  AI_SERVICE_ERROR = 'AI_SERVICE_ERROR'
}
```

### 5.3 认证和授权方案

#### 5.3.1 认证方案

```typescript
// JWT Token结构
interface JwtPayload {
  sub: string;  // 用户ID
  email: string; // 用户邮箱
  role: UserRole; // 用户角色
  plan: SubscriptionPlan; // 订阅计划
  iat: number;  // 签发时间
  exp: number;  // 过期时间
  sessionId?: string; // 会话ID
}

// 支持的认证方式
enum AuthProvider {
  EMAIL_PASSWORD = 'email_password',
  WECHAT = 'wechat',
  GOOGLE = 'google',
  APPLE = 'apple'
}
```

#### 5.3.2 权限控制

```typescript
// 用户角色定义
enum UserRole {
  USER = 'user',
  PREMIUM_USER = 'premium_user',
  ENTERPRISE_USER = 'enterprise_user',
  ADMIN = 'admin'
}

// 订阅计划
enum SubscriptionPlan {
  FREE = 'free',
  BASIC = 'basic',
  PROFESSIONAL = 'professional',
  ENTERPRISE = 'enterprise'
}

// 权限矩阵
enum Permission {
  // 场景权限
  VIEW_SCENARIOS = 'view:scenarios',
  START_SCENARIO = 'start:scenario',
  COMPLETE_SCENARIO = 'complete:scenario',
  
  // 对话权限
  USE_VOICE_DIALOGUE = 'use:voice_dialogue',
  UNLIMITED_DIALOGUE = 'unlimited:dialogue',
  
  // 分析权限
  USE_EMAIL_ANALYSIS = 'use:email_analysis',
  USE_MEETING_ANALYSIS = 'use:meeting_analysis',
  
  // 推荐权限
  PERSONALIZED_RECOMMENDATION = 'personalized:recommendation',
  
  // 管理权限
  MANAGE_TEAM = 'manage:team',
  VIEW_ANALYTICS = 'view:analytics'
}

// 权限检查中间件
const checkPermission = (permission: Permission) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = req.user as User;
    if (!user.hasPermission(permission)) {
      throw new ErrorUnauthorized('Insufficient permissions');
    }
    next();
  };
};
```

---

## 6. 数据模型设计

### 6.1 数据库Schema (Prisma)

```typescript
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// 用户相关模型
model User {
  id          String   @id @default(cuid())
  email       String   @unique
  password    String
  name        String
  avatar      String?
  
  // 用户画像
  profile     UserProfile?
  
  // 订阅信息
  subscription Subscription?
  
  // 用户统计
  statistics  UserStatistics?
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  // 关系
  dialogues   Dialogue[]
  scenarios   ScenarioProgress[]
  analyses    Analysis[]
  recommendations Recommendation[]
  
  @@map("users")
}

model UserProfile {
  id           String   @id @default(cuid())
  userId       String   @unique
  position     String?
  experience   Int?     // 工作年限
  department   String?
  skills       String[] // JSON数组，存储技能标签
  goals        String[] // 学习目标
  industry     String?
  companySize String?
  
  // 学习偏好
  learningStyle String? // visual/auditory/kinesthetic
  preferredTime String? // morning/afternoon/evening
  
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt
  
  @@map("user_profiles")
}

model Subscription {
  id               String      @id @default(cuid())
  userId           String      @unique
  plan             SubscriptionPlan
  status           SubscriptionStatus
  startDate        DateTime
  endDate          DateTime?
  autoRenew        Boolean     @default(true)
  paymentMethodId  String?
  transactions     Transaction[]
  
  createdAt        DateTime    @default(now())
  updatedAt        DateTime    @updatedAt
  
  @@map("subscriptions")
}

// 场景相关模型
model Scenario {
  id          String   @id @default(cuid())
  title       String
  description String
  category    ScenarioCategory
  difficulty  Difficulty
  duration    Int      // 预计时长（分钟）
  role        String   // 用户角色
  characters  Json     // AI角色信息
  content     Json     // 场景内容
  templates   Json     // 模板内容
  learningPoints String[] // 学习要点
  tags        String[]
  
  // 状态
  isActive    Boolean  @default(true)
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  // 关系
  progresses  ScenarioProgress[]
  templates   ScenarioTemplate[]
  
  @@map("scenarios")
}

model ScenarioTemplate {
  id        String   @id @default(cuid())
  scenarioId String
  name      String
  content   Json
  type      TemplateType
  
  createdAt DateTime @default(now())
  
  @@map("scenario_templates")
}

model ScenarioProgress {
  id          String   @id @default(cuid())
  userId      String
  scenarioId  String
  status      ProgressStatus
  startTime   DateTime?
  endTime     DateTime?
  score       Int?
  attempts    Int      @default(0)
  feedback    Json?
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  @@unique([userId, scenarioId])
  @@map("scenario_progress")
}

// 对话相关模型
model DialogueSession {
  id          String   @id @default(cuid())
  userId      String
  scenarioId   String?
  mode        DialogueMode
  status      SessionStatus
  startTime   DateTime @default(now())
  endTime     DateTime?
  duration    Int?     // 对话时长（秒）
  score       Int?
  feedback    Json?
  
  // 关系
  messages    DialogueMessage[]
  
  @@map("dialogue_sessions")
}

model DialogueMessage {
  id          String   @id @default(cuid())
  sessionId   String
  role        MessageRole
  content     String
  type        MessageType
  timestamp   DateTime @default(now())
  feedback    Json?
  metadata    Json?
  
  @@map("dialogue_messages")
}

// 分析相关模型
model Analysis {
  id          String     @id @default(cuid())
  userId      String
  type        AnalysisType
  content     String
  context     Json
  result      Json
  suggestions Json[]
  confidence  Float?
  
  createdAt   DateTime   @default(now())
  
  @@map("analyses")
}

// 推荐相关模型
model Recommendation {
  id           String           @id @default(cuid())
  userId       String
  type         RecommendationType
  targetId     String           // 场景ID、学习路径ID等
  reason       String
  priority     Priority
  status       RecommendationStatus
  isClicked    Boolean          @default(false)
  isCompleted  Boolean          @default(false)
  metadata     Json?
  
  createdAt    DateTime         @default(now())
  expiresAt    DateTime?
  
  @@map("recommendations")
}

// 系统模型
model UserStatistics {
  id                    String   @id @default(cuid())
  userId                String   @unique
  
  // 使用统计
  totalDialogues       Int      @default(0)
  totalScenarios       Int      @default(0)
  totalAnalyses        Int      @default(0)
  totalTimeSpent       Int      @default(0) // 总使用时间（秒）
  
  // 能力评估
  skillAssessments     Json    // 各项技能评分
  
  // 学习效果
  averageScore        Float?
  improvementRate     Float?
  
  lastActiveDate      DateTime
  
  createdAt            DateTime @default(now())
  updatedAt            DateTime @updatedAt
  
  @@map("user_statistics")
}

model Transaction {
  id            String           @id @default(cuid())
  subscriptionId String
  amount        Float
  currency      String           @default("CNY")
  status        TransactionStatus
  provider      String           // 支付渠道
  transactionId String           // 第三方交易ID
  
  createdAt     DateTime         @default(now())
  
  @@map("transactions")
}

// 枚举定义
enum SubscriptionPlan {
  FREE
  BASIC
  PROFESSIONAL
  ENTERPRISE
}

enum SubscriptionStatus {
  ACTIVE
  CANCELLED
  EXPIRED
  PENDING
}

enum ScenarioCategory {
  PRESENTATION
  FEEDBACK
  NEGOTIATION
  CONFLICT
  INTERVIEW
  PERFORMANCE_REVIEW
  TEAM_MANAGEMENT
  UPWARD_MANAGEMENT
}

enum Difficulty {
  BEGINNER
  INTERMEDIATE
  ADVANCED
}

enum ProgressStatus {
  NOT_STARTED
  IN_PROGRESS
  COMPLETED
  PAUSED
}

enum DialogueMode {
  TEXT
  VOICE
}

enum SessionStatus {
  ACTIVE
  COMPLETED
  TERMINATED
}

enum MessageRole {
  USER
  AI
  SYSTEM
}

enum MessageType {
  TEXT
  VOICE
  SYSTEM
}

enum AnalysisType {
  EMAIL
  MEETING
  REPORT
  FEEDBACK
  REVIEW
}

enum RecommendationType {
  SCENARIO
  LEARNING_PATH
  SKILL_IMPROVEMENT
  PRACTICE_SCHEDULE
}

enum Priority {
  LOW
  MEDIUM
  HIGH
  URGENT
}

enum RecommendationStatus {
  ACTIVE
  DISMISSED
  COMPLETED
  EXPIRED
}

enum TransactionStatus {
  PENDING
  COMPLETED
  FAILED
  REFUNDED
}

enum TemplateType {
  OPENING
  CLOSING
  STRUCTURE
  KEY_POINTS
  RESPONSE
}
```

### 6.2 ER关系图

```mermaid
erDiagram
    User ||--o UserProfile : has
    User ||--o Subscription : has
    User ||--o UserStatistics : has
    User ||--o DialogueSession : creates
    User ||--o ScenarioProgress : completes
    User ||--o Analysis : creates
    User ||--o Recommendation : receives
    
    Subscription ||--o Transaction : has
    
    Scenario ||--o ScenarioTemplate : has
    Scenario ||--o ScenarioProgress : completed_by
    
    DialogueSession ||--o DialogueMessage : contains
    
    UserProfile {
        string id PK
        string userId FK
        string position
        int experience
        string[] skills
        string[] goals
        string learningStyle
        string preferredTime
    }
    
    User {
        string id PK
        string email
        string password
        string name
        string avatar
        datetime createdAt
        datetime updatedAt
    }
    
    Subscription {
        string id PK
        string userId FK
        SubscriptionPlan plan
        SubscriptionStatus status
        datetime startDate
        datetime endDate
        boolean autoRenew
    }
    
    Scenario {
        string id PK
        string title
        string description
        ScenarioCategory category
        Difficulty difficulty
        int duration
        string role
        json characters
        json content
        json templates
        string[] learningPoints
        string[] tags
        boolean isActive
    }
    
    ScenarioProgress {
        string id PK
        string userId FK
        string scenarioId FK
        ProgressStatus status
        datetime startTime
        datetime endTime
        int score
        int attempts
        json feedback
    }
    
    DialogueSession {
        string id PK
        string userId FK
        string scenarioId FK
        DialogueMode mode
        SessionStatus status
        datetime startTime
        datetime endTime
        int duration
        int score
        json feedback
    }
    
    DialogueMessage {
        string id PK
        string sessionId FK
        MessageRole role
        string content
        MessageType type
        json feedback
        json metadata
    }
    
    Analysis {
        string id PK
        string userId FK
        AnalysisType type
        string content
        json context
        json result
        json[] suggestions
        float confidence
    }
    
    Recommendation {
        string id PK
        string userId FK
        RecommendationType type
        string targetId
        string reason
        Priority priority
        RecommendationStatus status
        json metadata
    }
```

### 6.3 索引策略

```sql
-- 用户表索引
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);

-- 用户画像表索引
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX idx_user_profiles_industry ON user_profiles(industry);
CREATE INDEX idx_user_profiles_experience ON user_profiles(experience);

-- 场景表索引
CREATE INDEX idx_scenarios_category ON scenarios(category);
CREATE INDEX idx_scenarios_difficulty ON scenarios(difficulty);
CREATE INDEX idx_scenarios_is_active ON scenarios(is_active);
CREATE INDEX idx_scenarios_created_at ON scenarios(created_at);

-- 场景进度表索引
CREATE INDEX idx_scenario_progress_user_id ON scenario_progress(user_id);
CREATE INDEX idx_scenario_progress_scenario_id ON scenario_progress(scenario_id);
CREATE INDEX idx_scenario_progress_status ON scenario_progress(status);
CREATE INDEX idx_scenario_progress_user_scenario ON scenario_progress(user_id, scenario_id);

-- 对话会话表索引
CREATE INDEX idx_dialogue_sessions_user_id ON dialogue_sessions(user_id);
CREATE INDEX idx_dialogue_sessions_status ON dialogue_sessions(status);
CREATE INDEX idx_dialogue_sessions_start_time ON dialogue_sessions(start_time);

-- 对话消息表索引
CREATE INDEX idx_dialogue_messages_session_id ON dialogue_messages(session_id);
CREATE INDEX idx_dialogue_messages_role ON dialogue_messages(role);
CREATE INDEX idx_dialogue_messages_timestamp ON dialogue_messages(timestamp);

-- 分析表索引
CREATE INDEX idx_analyses_user_id ON analyses(user_id);
CREATE INDEX idx_analyses_type ON analyses(type);
CREATE INDEX idx_analyses_created_at ON analyses(created_at);

-- 推荐表索引
CREATE INDEX idx_recommendations_user_id ON recommendations(user_id);
CREATE INDEX idx_recommendations_type ON recommendations(type);
CREATE INDEX idx_recommendations_priority ON recommendations(priority);
CREATE INDEX idx_recommendations_status ON recommendations(status);
CREATE INDEX idx_recommendations_expires_at ON recommendations(expires_at);

-- 复合索引用于高频查询
CREATE INDEX idx_scenarios_category_difficulty_active ON scenarios(category, difficulty, is_active);
CREATE INDEX idx_scenario_progress_user_score ON scenario_progress(user_id, score DESC);
CREATE INDEX idx_dialogue_sessions_user_duration ON dialogue_sessions(user_id, duration DESC);

-- 全文索引用于场景搜索
CREATE INDEX idx_scenarios_search ON scenarios USING GIN (to_tsvector('chinese', title || ' ' || description));
```

---

## 7. 关键技术难点及解决方案

### 7.1 实时对话体验优化

#### 7.1.1 技术挑战
- **AI响应延迟**: LLM API调用通常需要1-3秒，影响实时对话体验
- **上下文管理长对话**: 对话轮次增加时，上下文窗口限制导致记忆衰减
- **流式响应实现**: 前端需要处理实时流式数据，保证用户体验流畅

#### 7.1.2 解决方案

```typescript
// 1. 多级缓存策略
class DialogueCache {
  private redis: Redis;
  private memoryCache: Map<string, any>;
  
  async getContext(sessionId: string): Promise<DialogueContext> {
    // 1. 先查内存缓存
    const memoryContext = this.memoryCache.get(sessionId);
    if (memoryContext) return memoryContext;
    
    // 2. 查Redis缓存
    const cachedContext = await this.redis.get(`dialogue:${sessionId}`);
    if (cachedContext) {
      const context = JSON.parse(cachedContext);
      this.memoryCache.set(sessionId, context);
      return context;
    }
    
    // 3. 查数据库
    const dbContext = await this.loadContextFromDB(sessionId);
    this.memoryCache.set(sessionId, dbContext);
    await this.redis.setex(`dialogue:${sessionId}`, 3600, JSON.stringify(dbContext));
    
    return dbContext;
  }
}

// 2. 智能上下文压缩
class ContextCompressor {
  compressContext(messages: Message[]): Context {
    // 保留关键信息
    const keyMessages = this.extractKeyMessages(messages);
    const summary = this.generateSummary(messages);
    
    return {
      summary,
      recentMessages: keyMessages.slice(-5), // 保留最近5轮对话
      userPreferences: this.extractPreferences(messages),
      sessionState: this.extractState(messages)
    };
  }
  
  private extractKeyMessages(messages: Message[]): Message[] {
    // 基于重要性和新鲜度筛选消息
    return messages.filter(msg => 
      msg.importance > 0.7 || // 重要消息
      Date.now() - msg.timestamp < 300000 // 5分钟内的新消息
    ).sort((a, b) => b.importance - a.importance);
  }
}

// 3. 流式响应处理
class StreamingResponse {
  private client: WebSocket;
  
  async streamResponse(sessionId: string, userInput: string): Promise<void> {
    const stream = await this.aiService.streamDialogue(sessionId, userInput);
    
    for await (const chunk of stream) {
      const responseChunk = this.parseStreamChunk(chunk);
      
      // 实时发送到客户端
      this.client.send(JSON.stringify({
        type: 'chunk',
        content: responseChunk.content,
        sessionId,
        timestamp: Date.now()
      }));
      
      // 缓存响应片段
      this.cacheChunk(sessionId, responseChunk);
    }
    
    // 发送完整响应
    this.sendCompleteResponse(sessionId);
  }
}
```

#### 7.1.3 性能优化指标

```yaml
实时性能目标:
  响应时间:
    第一字符响应: < 500ms
    平均延迟: < 1.5s
    95分位延迟: < 2s
  
  并发支持:
    同时在线用户: 10,000+
    每秒对话数: 5,000+
  
  缓存命中率:
    对话上下文: > 90%
    场景模板: > 95%
    用户画像: > 98%
```

### 7.2 AI个性化推荐算法

#### 7.2.1 技术挑战
- **冷启动问题**: 新用户缺乏历史行为数据，推荐准确率低
- **多维度特征融合**: 需要结合用户画像、历史表现、学习目标等多个维度
- **实时推荐要求**: 推荐结果需要实时生成，不能有显著延迟

#### 7.2.2 解决方案

```typescript
// 混合推荐系统
class HybridRecommendationEngine {
  private collaborativeFilter: CollaborativeFilter;
  private contentBasedFilter: ContentBasedFilter;
  private knowledgeBasedFilter: KnowledgeBasedFilter;
  
  async getRecommendations(userId: string, context: Context): Promise<Recommendation[]> {
    // 1. 协同过滤推荐
    const collaborativeRecs = await this.collaborativeFilter.recommend(userId);
    
    // 2. 基于内容的推荐
    const contentRecs = await this.contentBasedFilter.recommend(userId, context);
    
    // 3. 基于知识的推荐
    const knowledgeRecs = await this.knowledgeBasedFilter.recommend(userId);
    
    // 4. 混合排序和去重
    const mergedRecs = this.mergeAndRank([
      ...collaborativeRecs,
      ...contentRecs,
      ...knowledgeRecs
    ], userId);
    
    return mergedRecs.slice(0, 5); // 返回前5个推荐
  }
  
  private mergeAndRank(recs: Recommendation[], userId: string): Recommendation[] {
    // 使用多目标排序算法
    return recs.sort((a, b) => {
      const scoreA = this.calculateScore(a, userId);
      const scoreB = this.calculateScore(b, userId);
      return scoreB - scoreA;
    });
  }
  
  private calculateScore(rec: Recommendation, userId: string): number {
    const user = this.userService.getUser(userId);
    
    // 多维度权重
    const weights = {
      relevance: 0.4,     // 相关性
      difficulty: 0.2,     // 难度适配
      popularity: 0.2,    // 流行度
      novelty: 0.1,       // 新颖性
    };
    
    return (
      this.calculateRelevance(rec, user) * weights.relevance +
      this.calculateDifficultyFit(rec, user) * weights.difficulty +
      this.calculatePopularity(rec) * weights.popularity +
      this.calculateNovelty(rec) * weights.novelty
    );
  }
}

// 冷启动解决方案
class ColdStartHandler {
  async handleNewUser(user: User): Promise<Recommendation[]> {
    // 1. 基于用户画像的推荐
    const profileBasedRecs = await this.getProfileBasedRecommendations(user);
    
    // 2. 基于行业/职位的推荐
    const roleBasedRecs = await this.getRoleBasedRecommendations(user);
    
    // 3. 热门场景推荐
    const popularRecs = await this.getPopularScenarios();
    
    // 4. 教学路径推荐
    const pathRecs = await this.getLearningPathRecommendations(user);
    
    return [...profileBasedRecs, ...roleBasedRecs, ...popularRecs, ...pathRecs]
      .slice(0, 8);
  }
  
  private getProfileBasedRecommendations(user: User): Recommendation[] {
    // 基于用户基本信息和技能进行推荐
    const userProfile = user.profile;
    
    return this.scenarioService.getScenariosByCriteria({
      industry: userProfile.industry,
      experience: userProfile.experience,
      skills: userProfile.skills
    });
  }
}
```

### 7.3 内容质量控制

#### 7.3.1 技术挑战
- **场景真实性**: AI生成的职场场景需要贴近真实工作环境
- **反馈准确性**: AI反馈需要专业、准确、有建设性
- **内容安全性**: 避免生成敏感、不当的职场建议

#### 7.3.2 解决方案

```typescript
// 内容质量评估系统
class ContentQualityAssessment {
  private llmEvaluator: LLMService;
  private ruleEngine: RuleEngine;
  private humanReviewQueue: Queue;
  
  async assessScenarioContent(content: ScenarioContent): Promise<QualityReport> {
    // 1. 自动评估
    const autoReport = await this.autoAssess(content);
    
    // 2. 规则引擎检查
    const ruleReport = this.ruleEngine.validate(content);
    
    // 3. 专家评估（抽样）
    let expertReport: ExpertReview | null = null;
    if (this.needsExpertReview(content)) {
      expertReport = await this.queueForExpertReview(content);
    }
    
    return {
      autoAssessment: autoReport,
      ruleValidation: ruleReport,
      expertReview: expertReport,
      overallScore: this.calculateOverallScore(autoReport, ruleReport, expertReport),
      recommendations: this.generateRecommendations(autoReport, ruleReport)
    };
  }
  
  private async autoAssess(content: ScenarioContent): Promise<AutoAssessment> {
    const prompt = `
      请评估以下职场场景内容的质量：
      
      场景标题：${content.title}
      描述：${content.description}
      学习要点：${content.learningPoints.join(', ')}
      
      请从以下几个维度评估（1-10分）：
      1. 职场真实性：场景是否贴近真实工作环境
      2. 教育价值：是否具有学习和提升价值
      3. 语言表达：表达是否专业、清晰
      4. 完整性：要素是否齐全
      5. 安全性：是否存在不当或敏感内容
      
      请提供详细的改进建议。
    `;
    
    const evaluation = await this.llmEvaluator.evaluate(prompt);
    
    return {
      realism: evaluation.realism,
      educationalValue: evaluation.educationalValue,
      languageQuality: evaluation.languageQuality,
      completeness: evaluation.completeness,
      safety: evaluation.safety,
      feedback: evaluation.feedback
    };
  }
}

// 内容安全过滤器
class ContentSafetyFilter {
  private keywordFilter: KeywordFilter;
  private sentimentAnalyzer: SentimentAnalyzer;
  private policyEngine: PolicyEngine;
  
  async filterContent(content: string, context: FilterContext): Promise<FilterResult> {
    // 1. 关键词过滤
    const keywordResult = this.keywordFilter.scan(content);
    
    // 2. 情感分析
    const sentimentResult = this.sentimentAnalyzer.analyze(content);
    
    // 3. 政策检查
    const policyResult = this.policyEngine.check(content, context);
    
    // 4. 综合评估
    const isSafe = this.isContentSafe(keywordResult, sentimentResult, policyResult);
    
    return {
      isSafe,
      riskLevel: this.calculateRiskLevel(keywordResult, sentimentResult, policyResult),
      warnings: this.generateWarnings(keywordResult, sentimentResult, policyResult),
      suggestedModifications: this.generateModifications(content, context)
    };
  }
  
  private isContentSafe(
    keywordResult: KeywordScanResult,
    sentimentResult: SentimentResult,
    policyResult: PolicyCheckResult
  ): boolean {
    return (
      !keywordResult.hasForbiddenKeywords &&
      sentimentResult.overallSentiment !== 'negative' &&
      policyResult.compliant &&
      keywordResult.riskScore < 0.3
    );
  }
}
```

---

## 8. 部署方案

### 8.1 Docker配置

#### 8.1.1 Docker Compose编排

```yaml
# docker-compose.yml
version: '3.8'

services:
  # 数据库服务
  postgres:
    image: postgres:15-alpine
    container_name: ai-coach-postgres
    environment:
      POSTGRES_DB: ai_career_coach
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./infrastructure/docker/postgres/init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    networks:
      - ai-coach-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis缓存服务
  redis:
    image: redis:7-alpine
    container_name: ai-coach-redis
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    networks:
      - ai-coach-network
    healthcheck:
      test: ["CMD", "redis-cli", "auth", "${REDIS_PASSWORD}", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Elasticsearch搜索服务
  elasticsearch:
    image: elasticsearch:8.11.0
    container_name: ai-coach-elasticsearch
    environment:
      - discovery.type=single-node
      - ES_JAVA_OPTS=-Xms512m -Xmx512m
      - xpack.security.enabled=false
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"
    networks:
      - ai-coach-network
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:9200 || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5

  # API网关服务
  api-gateway:
    build:
      context: .
      dockerfile: packages/api-gateway/Dockerfile
    container_name: ai-coach-api-gateway
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/ai_career_coach
      - REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379
      - AI_SERVICE_URL=http://ai-service:3001
      - JWT_SECRET=${JWT_SECRET}
    ports:
      - "3000:3000"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - ai-coach-network
    restart: unless-stopped

  # AI服务
  ai-service:
    build:
      context: .
      dockerfile: packages/ai-service/Dockerfile
    container_name: ai-coach-ai-service
    environment:
      - NODE_ENV=production
      - GLM_API_KEY=${GLM_API_KEY}
      - DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379
    ports:
      - "3001:3001"
    depends_on:
      redis:
        condition: service_healthy
    networks:
      - ai-coach-network
    restart: unless-stopped

  # 用户服务
  user-service:
    build:
      context: .
      dockerfile: packages/user-service/Dockerfile
    container_name: ai-coach-user-service
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/ai_career_coach
      - REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379
      - JWT_SECRET=${JWT_SECRET}
    ports:
      - "3002:3002"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - ai-coach-network
    restart: unless-stopped

  # 对话引擎服务
  dialogue-engine:
    build:
      context: .
      dockerfile: packages/dialogue-engine/Dockerfile
    container_name: ai-coach-dialogue-engine
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/ai_career_coach
      - REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379
      - AI_SERVICE_URL=http://ai-service:3001
    ports:
      - "3003:3003"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      ai-service:
        condition: service_started
    networks:
      - ai-coach-network
    restart: unless-stopped

  # 前端Web服务
  web-app:
    build:
      context: ./web
      dockerfile: Dockerfile
    container_name: ai-coach-web-app
    environment:
      - NODE_ENV=production
      - API_BASE_URL=http://api-gateway:3000
    ports:
      - "80:80"
    depends_on:
      - api-gateway
    networks:
      - ai-coach-network
    restart: unless-stopped

  # Nginx反向代理
  nginx:
    image: nginx:alpine
    container_name: ai-coach-nginx
    volumes:
      - ./infrastructure/docker/nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./infrastructure/docker/nginx/conf.d:/etc/nginx/conf.d
    ports:
      - "443:443"
      - "80:80"
    depends_on:
      - api-gateway
      - web-app
    networks:
      - ai-coach-network
    restart: unless-stopped

  # 监控服务
  prometheus:
    image: prom/prometheus:latest
    container_name: ai-coach-prometheus
    volumes:
      - ./infrastructure/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    networks:
      - ai-coach-network
    restart: unless-stopped

  # 监控面板
  grafana:
    image: grafana/grafana:latest
    container_name: ai-coach-grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
      - ./infrastructure/monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./infrastructure/monitoring/grafana/datasources:/etc/grafana/provisioning/datasources
    ports:
      - "3001:3000"
    networks:
      - ai-coach-network
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  elasticsearch_data:
  prometheus_data:
  grafana_data:

networks:
  ai-coach-network:
    driver: bridge
```

#### 8.1.2 Dockerfile配置

```dockerfile
# packages/api-gateway/Dockerfile
FROM node:18-alpine AS base

# 安装依赖
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# 复制package文件
COPY package.json package-lock.json* ./
COPY packages/api-gateway/package.json ./
RUN npm ci --only=production

# 构建应用
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY packages/api-gateway .
RUN npm run build

# 生产环境
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# 创建用户
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# 复制构建产物
COPY --from=builder /app/dist ./dist
COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/packages/api-gateway/node_modules ./packages/api-gateway/node_modules

# 设置权限
USER nextjs

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js

EXPOSE 3000

CMD ["node", "dist/server.js"]
```

### 8.2 CI/CD流水线设计

#### 8.2.1 GitHub Actions配置

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    strategy:
      matrix:
        service: [api-gateway, user-service, dialogue-engine, ai-service]
        node-version: [18.x, 20.x]

    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
        
    - name: Install dependencies
      run: |
        cd packages/${{ matrix.service }}
        npm ci
        
    - name: Run tests
      run: |
        cd packages/${{ matrix.service }}
        npm run test
        npm run test:e2e
        
    - name: Build service
      run: |
        cd packages/${{ matrix.service }}
        npm run build

  security-scan:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Run security audit
      run: |
        npm audit --audit-level moderate
        npm audit fix
        
    - name: Run Snyk security scan
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        
    - name: Run CodeQL analysis
      uses: github/codeql-action@v2
      with:
        languages: ${{ matrix.language }}

  integration-test:
    needs: [test]
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_db
      redis:
        image: redis:7
        
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Docker
      uses: docker/setup-buildx-action@v2
      
    - name: Build services
      run: |
        docker-compose -f docker-compose.ci.yml build
        
    - name: Run integration tests
      run: |
        docker-compose -f docker-compose.ci.yml up -d
        sleep 30
        npm run test:integration
        
    - name: Cleanup
      run: |
        docker-compose -f docker-compose.ci.yml down

  deployment:
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    needs: [test, integration-test]
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup Docker
      uses: docker/setup-buildx-action@v2
      
    - name: Login to Docker Hub
      uses: docker/login-action@v2
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
        
    - name: Build and push images
      run: |
        docker-compose -f docker-compose.prod.yml build
        docker-compose -f docker-compose.prod.yml push
        
    - name: Deploy to production
      uses: appleboy/ssh-action@v1.0.0
      with:
        host: ${{ secrets.PRODUCTION_HOST }}
        username: ${{ secrets.PRODUCTION_USER }}
        key: ${{ secrets.PRODUCTION_SSH_KEY }}
        script: |
          cd /opt/ai-career-coach
          docker-compose -f docker-compose.prod.yml pull
          docker-compose -f docker-compose.prod.yml up -d
          
    - name: Health check
      run: |
        sleep 60
        curl -f https://ai-career-coach.com/health || exit 1
```

### 8.3 监控和告警方案

#### 8.3.1 监控配置

```yaml
# infrastructure/monitoring/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  # 应用服务监控
  - job_name: 'api-gateway'
    static_configs:
      - targets: ['api-gateway:3000']
    metrics_path: '/metrics'
    scrape_interval: 15s
    
  - job_name: 'user-service'
    static_configs:
      - targets: ['user-service:3002']
    metrics_path: '/metrics'
    scrape_interval: 15s
    
  - job_name: 'dialogue-engine'
    static_configs:
      - targets: ['dialogue-engine:3003']
    metrics_path: '/metrics'
    scrape_interval: 15s
    
  - job_name: 'ai-service'
    static_configs:
      - targets: ['ai-service:3001']
    metrics_path: '/metrics'
    scrape_interval: 15s
    
  # 系统监控
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
    scrape_interval: 30s
    
  # 数据库监控
  - job_name: 'postgres-exporter'
    static_configs:
      - targets: ['postgres-exporter:9187']
    scrape_interval: 30s
    
  # Redis监控
  - job_name: 'redis-exporter'
    static_configs:
      - targets: ['redis-exporter:9121']
    scrape_interval: 30s
```

#### 8.3.2 告警规则

```yaml
# infrastructure/monitoring/alert_rules.yml
groups:
  - name: application-alerts
    rules:
      # API错误率告警
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "API错误率过高"
          description: "API网关5xx错误率在过去5分钟内超过10%"
          
      # 响应时间告警
      - alert: HighLatency
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "API响应时间过高"
          description: "API请求95分位响应时间超过2秒"
          
      # 对话服务告警
      - alert: DialogueServiceErrors
        expr: rate(dialogue_service_errors_total[5m]) > 0.05
        for: 3m
        labels:
          severity: warning
        annotations:
          summary: "对话服务错误率高"
          description: "对话服务错误率在过去5分钟内超过5%"
          
      # AI服务告警
      - alert: AIServiceLatency
        expr: histogram_quantile(0.95, rate(ai_service_response_time_seconds_bucket[5m])) > 3
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "AI服务响应延迟高"
          description: "AI服务请求95分位响应时间超过3秒"
          
      # 数据库连接告警
      - alert: DatabaseConnectionsHigh
        expr: pg_stat_database_numbackends / pg_settings_max_connections * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "数据库连接数过高"
          description: "数据库连接使用率超过80%"
          
      # Redis内存使用告警
      - alert: RedisMemoryHigh
        expr: redis_memory_used_bytes / redis_memory_max_bytes * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Redis内存使用率过高"
          description: "Redis内存使用率超过80%"
          
      # 服务健康检查失败
      - alert: ServiceHealthCheckFailed
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "服务健康检查失败"
          description: "服务 {{ $labels.instance }} 健康检查失败"
```

#### 8.3.3 日志配置

```yaml
# infrastructure/logging/elk-config.yml
elasticsearch:
  hosts:
    - elasticsearch:9200
  sniffing: true
  index: "ai-career-coach-%{+YYYY.MM.DD}"

filebeat:
  inputs:
    - type: log
      enabled: true
      paths:
        - /var/log/ai-career-coach/*.log
      fields:
        app: ai-career-coach
        environment: production
      fields_under_root: true
      multiline:
        pattern: '^\d{4}-\d{2}-\d{2}'
        negate: true
        match: after

kibana:
  host: kibana:5601
```

### 8.4 生产环境部署架构

```mermaid
graph TB
    subgraph "CDN层"
        A[Cloudflare CDN]
        B[DDoS防护]
        C[SSL证书管理]
    end
    
    subgraph "负载均衡层"
        D[Nginx负载均衡]
        E[健康检查]
        F[SSL终止]
    end
    
    subgraph "Kubernetes集群"
        G[API Gateway Pod]
        H[User Service Pod]
        I[Dialogue Engine Pod]
        J[AI Service Pod]
        K[Web App Pod]
        L[Monitoring Pod]
    end
    
    subgraph "数据层"
        M[PostgreSQL Cluster]
        N[Redis Cluster]
        O[Elasticsearch Cluster]
        P[MinIO对象存储]
    end
    
    subgraph "监控层"
        Q[Prometheus]
        R[Grafana]
        S[AlertManager]
        T[ELK Stack]
    end
    
    subgraph "外部服务"
        U[GLM API]
        V[DeepSeek API]
        W[OpenAI API]
        X[WeChat API]
        Y[Payment Gateway]
    end
    
    A --> D
    B --> D
    C --> D
    D --> G
    D --> H
    D --> I
    D --> J
    D --> K
    D --> L
    
    G --> H
    H --> I
    I --> J
    J --> U
    J --> V
    J --> W
    H --> X
    H --> Y
    
    H --> M
    I --> N
    J --> O
    K --> P
    
    G --> Q
    H --> Q
    I --> Q
    J --> Q
    K --> Q
    
    Q --> R
    Q --> S
    Q --> T
    
    classDef pod fill:#f9f,stroke:#333,stroke-width:2px
    classDef database fill:#bbf,stroke:#333,stroke-width:2px
    classDef monitoring fill:#bfb,stroke:#333,stroke-width:2px
    classDef external fill:#fbb,stroke:#333,stroke-width:2px
    
    class G,H,I,J,K,L pod
    class M,N,O,P database
    class Q,R,S,T monitoring
    class U,V,W,X,Y external
```

---

## 9. 实施计划

### 9.1 开发里程碑

| 阶段 | 时间 | 目标 | 交付物 |
|------|------|------|--------|
| **Phase 1: MVP开发** | 4周 | 核心场景模拟功能 | 可用的Web应用 |
| **Week 1** | 基础设施搭建 | 完整的开发环境 |
| **Week 2** | 用户系统 + 5个核心场景 | 用户注册登录，场景库 |
| **Week 3** | 对话引擎 + 反馈系统 | 文字对话，实时反馈 |
| **Week 4** | 基础Web界面 + 测试 | 可用的MVP产品 |
| **Phase 2: 功能扩展** | 6周 | 完整功能集 | 功能完整的产品 |
| **Week 5-6** | 邮件优化 + 会议准备 | 内容分析功能 |
| **Week 7-8** | 移动端适配 | React Native应用 |
| **Week 9-10** | 推荐系统 + 个性化 | 智能推荐引擎 |
| **Phase 3: 优化发布** | 4周 | 性能优化 + 发布 | 生产就绪产品 |
| **Week 11-12** | 性能优化 + 监控 | 部署文档 + 监控系统 |

### 9.2 资源分配

```yaml
人力资源规划:
  开发团队:
    - 全栈开发工程师: 2人
    - 前端开发工程师: 1人
    - 产品设计师: 1人
    - DevOps工程师: 1人
    - QA工程师: 1人
  
  技术栈:
    - 后端: Node.js, TypeScript, Fastify
    - 前端: React, Next.js, Material-UI
    - 数据库: PostgreSQL, Redis
    - AI: GLM-4, DeepSeek API
    - 部署: Docker, Kubernetes, Nginx
  
  时间安排:
    - 总开发周期: 14周
    - MVP发布: 第4周末
    - Beta测试: 第8-10周
    - 正式发布: 第12周末
```

### 9.3 风险控制

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|----------|
| AI API延迟高 | 中 | 中 | 实现多模型fallback，缓存机制 |
| 数据库性能瓶颈 | 低 | 高 | 合理索引设计，读写分离 |
| 用户增长过快 | 中 | 高 | 弹性架构设计，负载均衡 |
| 内容质量不足 | 中 | 中 | 专家审核机制，用户反馈系统 |
| 竞品快速跟进 | 高 | 中 | 持续创新，用户数据积累 |

---

## 10. 总结与建议

### 10.1 技术选型总结

**最终推荐技术栈**：
- **后端**: Node.js + Fastify + TypeScript
- **前端**: React + Next.js + Material-UI
- **数据库**: PostgreSQL + Redis + Elasticsearch
- **AI服务**: GLM-4 + DeepSeek + OpenAI (多模型策略)
- **部署**: Docker + Kubernetes + Nginx

**选择理由**：
1. **技术成熟度高**: 所选技术都是业界主流，团队熟悉度高
2. **开发效率**: 前后端技术统一，降低协作成本
3. **扩展性**: 微服务架构支持水平扩展
4. **成本优化**: 多模型策略平衡成本和效果
5. **社区支持**: 丰富的开源资源和解决方案

### 10.2 关键成功因素

1. **用户体验优先**: 实时对话体验是核心竞争力，必须优化到极致
2. **内容质量保证**: 职场场景的真实性和专业性是用户价值的核心
3. **技术稳定性**: 高可用性保障，避免服务中断影响用户体验
4. **数据安全**: 用户隐私保护和数据安全是底线要求
5. **持续优化**: 基于用户反馈不断优化AI模型和内容质量

### 10.3 后续发展建议

1. **AI能力增强**: 逐步接入更多专业化AI模型，提升场景真实性
2. **社交化功能**: 增加用户社区，促进经验分享和互助
3. **企业定制**: 开发企业版功能，支持批量管理和定制化场景
4. **国际化扩展**: 考虑海外市场，多语言支持
5. **IoT集成**: 与智能设备集成，拓展应用场景

---

*本架构设计文档将持续根据项目进展和技术发展进行更新和维护。*

---
**文档版本**: v1.0  
**最后更新**: 2026-04-16  
**下次评审**: 2026-04-30