import { Request, Response } from 'express';
import { OpenAI } from 'openai';
import { prisma } from '../utils/database';
import { aiValidationSchemas } from '../middleware/validation';
import { AuthRequest } from '../middleware/auth';
import { createError } from '../middleware/errorHandler';

export class AIController {
  private openai: OpenAI;

  constructor() {
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY
    });
  }

  // Analyze a carbon record with AI
  static async analyzeRecord(req: AuthRequest, res: Response) {
    try {
      const { recordData, context } = req.body;

      // Validate input
      const { error } = aiValidationSchemas.analyzeRecord.validate(req.body);
      if (error) {
        return res.status(400).json({
          success: false,
          error: {
            message: 'Validation failed',
            details: error.details.map(detail => ({
              field: detail.path.join('.'),
              message: detail.message
            }))
          }
        });
      }

      const analysisPrompt = `
你是一个碳足迹分析专家。请基于以下碳足迹记录，提供详细的分析和建议：

**记录信息：**
- 类别：${recordData.category}
- 类型：${recordData.type}
- 数量：${recordData.amount} ${recordData.unit}
- 描述：${recordData.description || '无'}
- 上下文：${context || '无'}

**请提供以下分析：**
1. 碳排放严重程度评估（低/中/高）
2. 与同类活动的比较（高于/低于平均）
3. 主要减排建议（3-5条具体建议）
4. 相关环保知识（1-2条）
5. 潜在的替代方案（2-3个）
6. 长期改善策略

**输出格式：**
请用中文回复，使用以下JSON格式：
{
  "severityLevel": "低|中|高",
  "comparison": "描述该排放量与同类活动的比较",
  "reductionTips": ["建议1", "建议2", "建议3"],
  "knowledge": ["知识1", "知识2"],
  "alternatives": ["替代方案1", "替代方案2", "替代方案3"],
  "longTermStrategies": ["策略1", "策略2"]
}
      `;

      const completion = await this.openai.chat.completions.create({
        model: process.env.OPENAI_MODEL || 'gpt-4',
        messages: [
          {
            role: 'system',
            content: '你是一个专业的碳足迹分析师，专门帮助用户理解和减少碳排放。'
          },
          {
            role: 'user',
            content: analysisPrompt
          }
        ],
        max_tokens: 1000,
        temperature: 0.7
      });

      const aiResponse = completion.choices[0].message.content;
      
      try {
        const analysisResult = JSON.parse(aiResponse);
        
        // Update the record with AI analysis
        await prisma.carbonRecord.update({
          where: {
            id: recordData.id // Assuming recordData contains id
          },
          data: {
            analyzed: true,
            aiInsights: JSON.stringify(analysisResult, null, 2)
          }
        });

        res.json({
          success: true,
          data: {
            analysis: analysisResult,
            timestamp: new Date().toISOString()
          }
        });
      } catch (parseError) {
        console.error('Failed to parse AI response:', parseError);
        
        // Store raw response if parsing fails
        await prisma.carbonRecord.update({
          where: {
            id: recordData.id
          },
          data: {
            analyzed: true,
            aiInsights: aiResponse
          }
        });

        res.json({
          success: true,
          data: {
            analysis: {
              rawResponse: aiResponse,
              severityLevel: '未知',
              comparison: '分析结果格式化失败',
              reductionTips: ['请手动分析此记录'],
              knowledge: [],
              alternatives: [],
              longTermStrategies: []
            },
            timestamp: new Date().toISOString()
          }
        });
      }
    } catch (error) {
      console.error('AI analysis error:', error);
      res.status(500).json({
        success: false,
        error: { message: 'Failed to analyze carbon record with AI' }
      });
    }
  }

  // Generate personalized carbon reduction plan
  static async generateReductionPlan(req: AuthRequest, res: Response) {
    try {
      const userId = req.user!.id;
      
      // Get user's carbon records for the last 30 days
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      const records = await prisma.carbonRecord.findMany({
        where: {
          userId,
          date: { gte: thirtyDaysAgo }
        }
      });

      if (records.length === 0) {
        throw createError('No carbon data available to generate plan', 400);
      }

      // Calculate summary statistics
      const totalEmission = records.reduce((sum, record) => sum + record.carbonEmission, 0);
      const byCategory = records.reduce((acc, record) => {
        acc[record.category] = (acc[record.category] || 0) + record.carbonEmission;
        return acc;
      }, {} as Record<string, number>);

      const prompt = `
你是一个碳减排计划专家。基于以下用户的碳排放数据，生成个性化的30天碳减排计划：

**用户数据（过去30天）：**
- 总碳排放：${totalEmission.toFixed(2)} kg CO2e
- 记录数量：${records.length} 条
- 各类别分布：
${Object.entries(byCategory).map(([category, emission]) => 
  `- ${category}: ${emission.toFixed(2)} kg CO2e (${((emission / totalEmission) * 100).toFixed(1)}%)`
).join('\n')}

**要求：**
1. 识别2-3个最大的碳排放来源
2. 针对每个主要来源制定具体的30天行动计划
3. 包含每日、每周的具体行动建议
4. 提供可量化的减排目标
5. 包含习惯培养建议
6. 考虑用户日常生活场景

**输出格式：**
请用中文回复，使用以下JSON格式：
{
  "summary": "总体减排计划概述",
  "mainSources": ["主要来源1", "主要来源2"],
  "dailyGoals": {
    "goal1": "目标描述",
    "targetReduction": "预期减排量"
  },
  "weeklyActions": [
    {
      "week": 1,
      "focus": "本周重点",
      "actions": ["行动1", "行动2", "行动3"]
    }
  ],
  "dailyHabits": ["习惯1", "习惯2"],
  "trackingMethods": ["追踪方法1", "追踪方法2"],
  "motivation": "激励策略"
}
      `;

      const completion = await this.openai.chat.completions.create({
        model: process.env.OPENAI_MODEL || 'gpt-4',
        messages: [
          {
            role: 'system',
            content: '你是一个专业的碳减排计划专家，帮助用户制定科学可行的减排计划。'
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        max_tokens: 1500,
        temperature: 0.7
      });

      const aiResponse = completion.choices[0].message.content;
      
      try {
        const reductionPlan = JSON.parse(aiResponse);
        
        // Save the plan to user preferences or create a new achievement
        await prisma.userPreference.upsert({
          where: { userId },
          update: {
            reductionPlan: JSON.stringify(reductionPlan, null, 2)
          },
          create: {
            userId,
            reductionPlan: JSON.stringify(reductionPlan, null, 2)
          }
        });

        // Create achievement
        await prisma.achievement.create({
          data: {
            userId,
            title: '碳减排计划',
            description: '为你生成了个性化30天碳减排计划',
            icon: '🎯',
            points: 50
          }
        });

        res.json({
          success: true,
          data: {
            plan: reductionPlan,
            generatedAt: new Date().toISOString()
          }
        });
      } catch (parseError) {
        console.error('Failed to parse AI response:', parseError);
        
        res.json({
          success: true,
          data: {
            plan: {
              summary: '分析结果格式化失败，请重新尝试',
              mainSources: [],
              dailyGoals: {},
              weeklyActions: [],
              dailyHabits: [],
              trackingMethods: [],
              motivation: ''
            },
            generatedAt: new Date().toISOString()
          }
        });
      }
    } catch (error) {
      console.error('AI reduction plan error:', error);
      res.status(500).json({
        success: false,
        error: { message: 'Failed to generate reduction plan' }
      });
    }
  }

  // Chat interface for carbon advice
  static async chatAdvice(req: AuthRequest, res: Response) {
    try {
      const { message } = req.body;

      if (!message) {
        return res.status(400).json({
          success: false,
          error: { message: 'Message is required' }
        });
      }

      const chatPrompt = `
你是一个环保生活顾问，专门帮助用户解答关于碳排放和环保生活的问题。用户的提问是：

"${message}"

请提供：
1. 直接回答用户的问题
2. 相关的碳减排建议
3. 实用的生活技巧
4. 鼓励和支持的语气

请用中文回答，保持专业但友好的语调。
      `;

      const completion = await this.openai.chat.completions.create({
        model: process.env.OPENAI_MODEL || 'gpt-4',
        messages: [
          {
            role: 'system',
            content: '你是一个专业的环保生活顾问，帮助用户理解碳排放并提供实用的环保建议。'
          },
          {
            role: 'user',
            content: chatPrompt
          }
        ],
        max_tokens: 500,
        temperature: 0.8
      });

      const response = completion.choices[0].message.content;

      // Save chat interaction for future reference
      await prisma.carbonRecord.create({
        data: {
          userId: req.user!.id,
          category: 'OTHER',
          type: 'INDIRECT',
          amount: 0,
          unit: 'conversation',
          source: 'ai_chat',
          description: `AI咨询: ${message}`,
          carbonEmission: 0
        }
      });

      res.json({
        success: true,
        data: {
          response,
          timestamp: new Date().toISOString()
        }
      });
    } catch (error) {
      console.error('AI chat error:', error);
      res.status(500).json({
        success: false,
        error: { message: 'Failed to get AI advice' }
      });
    }
  }

  // Get carbon insights and trends
  static async getInsights(req: AuthRequest, res: Response) {
    try {
      const userId = req.user!.id;
      const { period = 'month' } = req.query;

      // Calculate date range based on period
      let startDate: Date;
      const now = new Date();
      
      switch (period) {
        case 'week':
          startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
          break;
        case 'month':
          startDate = new Date(now.getFullYear(), now.getMonth(), 1);
          break;
        case 'year':
          startDate = new Date(now.getFullYear(), 0, 1);
          break;
        default:
          startDate = new Date(now.getFullYear(), now.getMonth(), 1);
      }

      const records = await prisma.carbonRecord.findMany({
        where: {
          userId,
          date: { gte: startDate }
        },
        orderBy: { date: 'asc' }
      });

      if (records.length === 0) {
        return res.json({
          success: true,
          data: {
            insights: '暂无足够数据生成洞察',
            trends: [],
            recommendations: []
          }
        });
      }

      // Generate insights using AI
      const totalEmission = records.reduce((sum, record) => sum + record.carbonEmission, 0);
      const avgDailyEmission = totalEmission / records.length;
      
      const insightsPrompt = `
基于用户的碳足迹数据，生成智能洞察：

**数据概览：**
- 总排放量：${totalEmission.toFixed(2)} kg CO2e
- 记录数量：${records.length} 条
- 平均每日排放：${avgDailyEmission.toFixed(2)} kg CO2e

**按类别分布：**
${records.reduce((acc, record) => {
  acc[record.category] = (acc[record.category] || 0) + 1;
  return acc;
}, {} as Record<string, number>)});

请提供：
1. 3-4个关键洞察
2. 2-3个改进建议
3. 未来趋势预测

用JSON格式回复：
{
  "insights": ["洞察1", "洞察2", "洞察3"],
  "recommendations": ["建议1", "建议2"],
  "trends": ["趋势1", "趋势2"]
}
      `;

      const completion = await this.openai.chat.completions.create({
        model: process.env.OPENAI_MODEL || 'gpt-4',
        messages: [
          {
            role: 'system',
            content: '你是一个数据分析专家，专门从碳足迹数据中提取有价值的洞察。'
          },
          {
            role: 'user',
            content: insightsPrompt
          }
        ],
        max_tokens: 800,
        temperature: 0.6
      });

      const aiResponse = completion.choices[0].message.content;
      
      let insights;
      try {
        insights = JSON.parse(aiResponse);
      } catch {
        insights = {
          insights: ['分析结果格式化失败，请重新尝试'],
          recommendations: [],
          trends: []
        };
      }

      res.json({
        success: true,
        data: {
          insights: insights.insights,
          recommendations: insights.recommendations,
          trends: insights.trends,
          period,
          generatedAt: new Date().toISOString()
        }
      });
    } catch (error) {
      console.error('AI insights error:', error);
      res.status(500).json({
        success: false,
        error: { message: 'Failed to generate insights' }
      });
    }
  }
}