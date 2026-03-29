import { Request, Response } from 'express';
import { prisma } from '../utils/database';
import { AuthRequest } from '../middleware/auth';
import { createError } from '../middleware/errorHandler';

export class SocialController {
  
  // Create a social group
  static async createGroup(req: AuthRequest, res: Response) {
    try {
      const { name, description, isPrivate } = req.body;

      const group = await prisma.socialGroup.create({
        data: {
          name,
          description,
          isPrivate: isPrivate || false,
          members: {
            connect: {
              id: req.user!.id
            }
          }
        },
        include: {
          members: true,
          challenges: true
        }
      });

      res.status(201).json({
        success: true,
        data: group
      });
    } catch (error) {
      console.error('Error creating group:', error);
      res.status(500).json({
        success: false,
        error: { message: 'Failed to create group' }
      });
    }
  }

  // Get user's groups
  static async getUserGroups(req: AuthRequest, res: Response) {
    try {
      const groups = await prisma.socialGroup.findMany({
        where: {
          OR: [
            { isPublic: false },
            {
              members: {
                some: {
                  id: req.user!.id
                }
              }
            }
          ]
        },
        include: {
          members: {
            select: {
              id: true,
              name: true,
              avatar: true
            }
          },
          challenges: {
            select: {
              id: true,
              title: true,
              isActive: true
            }
          }
        },
        orderBy: { createdAt: 'desc' }
      });

      res.json({
        success: true,
        data: groups
      });
    } catch (error) {
      console.error('Error getting user groups:', error);
      res.status(500).json({
        success: false,
        error: { message: 'Failed to get user groups' }
      });
    }
  }

  // Join a group
  static async joinGroup(req: AuthRequest, res: Response) {
    try {
      const { groupId } = req.params;

      const group = await prisma.socialGroup.findUnique({
        where: { id: groupId }
      });

      if (!group) {
        throw createError('Group not found', 404);
      }

      if (group.isPrivate) {
        throw createError('Cannot join private group', 400);
      }

      await prisma.socialGroup.update({
        where: { id: groupId },
        data: {
          members: {
            connect: {
              id: req.user!.id
            }
          }
        }
      });

      res.json({
        success: true,
        message: 'Successfully joined group'
      });
    } catch (error) {
      console.error('Error joining group:', error);
      if (error instanceof Error && error.message.includes('not found')) {
        res.status(404).json({
          success: false,
          error: { message: error.message }
        });
      } else if (error instanceof Error && error.message.includes('private')) {
        res.status(400).json({
          success: false,
          error: { message: error.message }
        });
      } else {
        res.status(500).json({
          success: false,
          error: { message: 'Failed to join group' }
        });
      }
    }
  }

  // Leave a group
  static async leaveGroup(req: AuthRequest, res: Response) {
    try {
      const { groupId } = req.params;

      await prisma.socialGroup.update({
        where: { id: groupId },
        data: {
          members: {
            disconnect: {
              id: req.user!.id
            }
          }
        }
      });

      res.json({
        success: true,
        message: 'Successfully left group'
      });
    } catch (error) {
      console.error('Error leaving group:', error);
      res.status(500).json({
        success: false,
        error: { message: 'Failed to leave group' }
      });
    }
  }

  // Create a group challenge
  static async createChallenge(req: AuthRequest, res: Response) {
    try {
      const { groupId, title, description, targetValue, unit, startDate, endDate } = req.body;

      // Verify user is member of the group
      const group = await prisma.socialGroup.findFirst({
        where: {
          id: groupId,
          members: {
            some: {
              id: req.user!.id
            }
          }
        }
      });

      if (!group) {
        throw createError('You are not a member of this group', 403);
      }

      const challenge = await prisma.groupChallenge.create({
        data: {
          groupId,
          title,
          description,
          targetValue,
          unit,
          startDate: new Date(startDate),
          endDate: new Date(endDate),
          isActive: true
        },
        include: {
          group: {
            select: {
              id: true,
              name: true
            }
          }
        }
      });

      // Auto-enroll all group members
      const groupMembers = await prisma.socialGroup.findUnique({
        where: { id: groupId },
        select: { members: true }
      });

      if (groupMembers?.members) {
        await prisma.userChallenge.createMany({
          data: groupMembers.members.map(member => ({
            userId: member.id,
            challengeId: challenge.id,
            progress: 0
          }))
        });
      }

      res.status(201).json({
        success: true,
        data: challenge
      });
    } catch (error) {
      console.error('Error creating challenge:', error);
      if (error instanceof Error && error.message.includes('not a member')) {
        res.status(403).json({
          success: false,
          error: { message: error.message }
        });
      } else {
        res.status(500).json({
          success: false,
          error: { message: 'Failed to create challenge' }
        });
      }
    }
  }

  // Get group challenges
  static async getGroupChallenges(req: AuthRequest, res: Response) {
    try {
      const { groupId } = req.params;
      const { status = 'active' } = req.query;

      const challenges = await prisma.groupChallenge.findMany({
        where: {
          groupId,
          ...(status === 'active' && { isActive: true }),
          ...(status === 'completed' && { isActive: false })
        },
        include: {
          group: {
            select: {
              id: true,
              name: true
            }
          },
          userChallenges: {
            where: {
              userId: req.user!.id
            },
            select: {
              id: true,
              progress: true,
              completed: true,
              completedAt: true
            }
          }
        },
        orderBy: { createdAt: 'desc' }
      });

      res.json({
        success: true,
        data: challenges
      });
    } catch (error) {
      console.error('Error getting group challenges:', error);
      res.status(500).json({
        success: false,
        error: { message: 'Failed to get group challenges' }
      });
    }
  }

  // Update challenge progress
  static async updateChallengeProgress(req: AuthRequest, res: Response) {
    try {
      const { challengeId } = req.params;
      const { progress } = req.body;

      const userChallenge = await prisma.userChallenge.findFirst({
        where: {
          challengeId,
          userId: req.user!.id
        }
      });

      if (!userChallenge) {
        throw createError('Challenge not found or not enrolled', 404);
      }

      const updatedChallenge = await prisma.userChallenge.update({
        where: { id: userChallenge.id },
        data: {
          progress: Number(progress),
          completed: progress >= 100,
          completedAt: progress >= 100 ? new Date() : null
        }
      });

      // Check if challenge is completed
      if (progress >= 100) {
        // Create achievement
        await prisma.achievement.create({
          data: {
            userId: req.user!.id,
            title: '挑战完成',
            description: `完成了碳减排挑战: ${userChallenge.challenge.title}`,
            icon: '🏆',
            points: 100
          }
        });
      }

      res.json({
        success: true,
        data: updatedChallenge
      });
    } catch (error) {
      console.error('Error updating challenge progress:', error);
      if (error instanceof Error && error.message.includes('not found')) {
        res.status(404).json({
          success: false,
          error: { message: error.message }
        });
      } else {
        res.status(500).json({
          success: false,
          error: { message: 'Failed to update challenge progress' }
        });
      }
    }
  }

  // Get group leaderboard
  static async getLeaderboard(req: AuthRequest, res: Response) {
    try {
      const { groupId } = req.params;
      const { period = 'week' } = req.query;

      // Calculate date range
      let startDate: Date;
      const now = new Date();
      
      switch (period) {
        case 'day':
          startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
          break;
        case 'week':
          startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
          break;
        case 'month':
          startDate = new Date(now.getFullYear(), now.getMonth(), 1);
          break;
        default:
          startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      }

      // Get user achievements and carbon records for the group
      const groupMembers = await prisma.socialGroup.findUnique({
        where: { id: groupId },
        select: { members: true }
      });

      if (!groupMembers?.members) {
        throw createError('Group not found', 404);
      }

      const leaderboard = await Promise.all(
        groupMembers.members.map(async (member) => {
          const achievements = await prisma.achievement.findMany({
            where: {
              userId: member.id,
              createdAt: { gte: startDate }
            }
          });

          const carbonRecords = await prisma.carbonRecord.findMany({
            where: {
              userId: member.id,
              date: { gte: startDate }
            }
          });

          const totalReduction = carbonRecords.reduce((sum, record) => {
            if (record.type === 'OFFSET') {
              return sum + record.carbonEmission;
            } else if (record.category === 'ENERGY' || record.category === 'TRANSPORTATION') {
              return sum - (record.carbonEmission * 0.1); // Assume 10% reduction for tracking
            }
            return sum;
          }, 0);

          const totalPoints = achievements.reduce((sum, achievement) => sum + achievement.points, 0);

          return {
            user: {
              id: member.id,
              name: member.name,
              avatar: member.avatar
            },
            totalPoints,
            totalReduction: Math.max(0, totalReduction),
            achievementsCount: achievements.length,
            recordsCount: carbonRecords.length
          };
        })
      );

      // Sort by total points
      leaderboard.sort((a, b) => b.totalPoints - a.totalPoints);

      res.json({
        success: true,
        data: {
          leaderboard,
          period,
          totalMembers: groupMembers.members.length
        }
      });
    } catch (error) {
      console.error('Error getting leaderboard:', error);
      if (error instanceof Error && error.message.includes('not found')) {
        res.status(404).json({
          success: false,
          error: { message: error.message }
        });
      } else {
        res.status(500).json({
          success: false,
          error: { message: 'Failed to get leaderboard' }
        });
      }
    }
  }

  // Get user social stats
  static async getUserSocialStats(req: AuthRequest, res: Response) {
    try {
      const userId = req.user!.id;

      const [groupsCount, challengesCount, achievementsCount, rank] = await Promise.all([
        prisma.socialGroup.count({
          where: {
            members: {
              some: { id: userId }
            }
          }
        }),
        prisma.userChallenge.count({
          where: { userId }
        }),
        prisma.achievement.count({
          where: { userId }
        }),
        prisma.achievement.count({
          where: {
            createdAt: {
              gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) // Last 30 days
            }
          }
        })
      ]);

      const socialStats = {
        groups: groupsCount,
        activeChallenges: challengesCount,
        totalAchievements: achievementsCount,
        recentAchievements: rank,
        carbonImpact: await this.calculateCarbonImpact(userId)
      };

      res.json({
        success: true,
        data: socialStats
      });
    } catch (error) {
      console.error('Error getting social stats:', error);
      res.status(500).json({
        success: false,
        error: { message: 'Failed to get social stats' }
      });
    }
  }

  // Helper method to calculate carbon impact
  private static async calculateCarbonImpact(userId: string) {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const records = await prisma.carbonRecord.findMany({
      where: {
        userId,
        date: { gte: thirtyDaysAgo }
      }
    });

    const totalEmission = records.reduce((sum, record) => sum + record.carbonEmission, 0);
    const reductions = records.filter(record => 
      record.type === 'OFFSET' || 
      (record.category === 'ENERGY' || record.category === 'TRANSPORTATION')
    ).length;

    return {
      totalEmissions: totalEmission,
      reductionsCount: reductions,
      impactScore: reductions * 10 // Simple scoring
    };
  }
}