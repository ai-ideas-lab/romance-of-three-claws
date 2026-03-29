import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { prisma } from '../utils/database';
import { userValidationSchemas } from '../middleware/validation';
import { AuthRequest } from '../middleware/auth';
import { createError } from '../middleware/errorHandler';

export class UserController {
  
  // User registration
  static async register(req: Request, res: Response) {
    try {
      const { email, password, name } = req.body;

      // Check if user already exists
      const existingUser = await prisma.user.findUnique({
        where: { email }
      });

      if (existingUser) {
        throw createError('User already exists with this email', 409);
      }

      // Hash password
      const saltRounds = 12;
      const hashedPassword = await bcrypt.hash(password, saltRounds);

      // Create user
      const user = await prisma.user.create({
        data: {
          email,
          password: hashedPassword,
          name
        },
        select: {
          id: true,
          email: true,
          name: true,
          avatar: true,
          createdAt: true
        }
      });

      // Create user preferences
      await prisma.userPreference.create({
        data: {
          userId: user.id,
          preferredCategories: [],
          notificationsEnabled: true,
          language: 'zh-CN',
          currency: 'CNY'
        }
      });

      // Generate token
      const token = jwt.sign(
        { 
          id: user.id, 
          email: user.email, 
          name: user.name 
        },
        process.env.JWT_SECRET!,
        { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
      );

      res.status(201).json({
        success: true,
        data: {
          user,
          token
        }
      });
    } catch (error) {
      console.error('Registration error:', error);
      if (error instanceof Error && error.message.includes('already exists')) {
        res.status(409).json({
          success: false,
          error: { message: error.message }
        });
      } else {
        res.status(500).json({
          success: false,
          error: { message: 'Failed to register user' }
        });
      }
    }
  }

  // User login
  static async login(req: Request, res: Response) {
    try {
      const { email, password } = req.body;

      // Find user
      const user = await prisma.user.findUnique({
        where: { email }
      });

      if (!user) {
        throw createError('Invalid credentials', 401);
      }

      // Check password
      const isPasswordValid = await bcrypt.compare(password, user.password);
      if (!isPasswordValid) {
        throw createError('Invalid credentials', 401);
      }

      // Generate token
      const token = jwt.sign(
        { 
          id: user.id, 
          email: user.email, 
          name: user.name 
        },
        process.env.JWT_SECRET!,
        { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
      );

      // Get user preferences
      const preferences = await prisma.userPreference.findFirst({
        where: { userId: user.id }
      });

      res.json({
        success: true,
        data: {
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            avatar: user.avatar,
            createdAt: user.createdAt
          },
          preferences,
          token
        }
      });
    } catch (error) {
      console.error('Login error:', error);
      if (error instanceof Error && error.message.includes('Invalid credentials')) {
        res.status(401).json({
          success: false,
          error: { message: error.message }
        });
      } else {
        res.status(500).json({
          success: false,
          error: { message: 'Failed to login user' }
        });
      }
    }
  }

  // Get current user profile
  static async getProfile(req: AuthRequest, res: Response) {
    try {
      const user = await prisma.user.findUnique({
        where: { id: req.user!.id },
        select: {
          id: true,
          email: true,
          name: true,
          avatar: true,
          createdAt: true,
          updatedAt: true
        }
      });

      const preferences = await prisma.userPreference.findFirst({
        where: { userId: req.user!.id }
      });

      res.json({
        success: true,
        data: {
          user,
          preferences
        }
      });
    } catch (error) {
      console.error('Error getting profile:', error);
      res.status(500).json({
        success: false,
        error: { message: 'Failed to get profile' }
      });
    }
  }

  // Update user profile
  static async updateProfile(req: AuthRequest, res: Response) {
    try {
      const { name, avatar, preferences } = req.body;

      const updateData: any = {};
      if (name) updateData.name = name;
      if (avatar) updateData.avatar = avatar;

      // Update user
      const user = await prisma.user.update({
        where: { id: req.user!.id },
        data: updateData,
        select: {
          id: true,
          email: true,
          name: true,
          avatar: true,
          updatedAt: true
        }
      });

      // Update preferences if provided
      if (preferences) {
        await prisma.userPreference.upsert({
          where: { userId: req.user!.id },
          update: {
            ...preferences,
            preferredCategories: preferences.preferredCategories || []
          },
          create: {
            userId: req.user!.id,
            ...preferences,
            preferredCategories: preferences.preferredCategories || []
          }
        });
      }

      // Get updated preferences
      const updatedPreferences = await prisma.userPreference.findFirst({
        where: { userId: req.user!.id }
      });

      res.json({
        success: true,
        data: {
          user,
          preferences: updatedPreferences
        }
      });
    } catch (error) {
      console.error('Error updating profile:', error);
      res.status(500).json({
        success: false,
        error: { message: 'Failed to update profile' }
      });
    }
  }

  // Change password
  static async changePassword(req: AuthRequest, res: Response) {
    try {
      const { currentPassword, newPassword } = req.body;

      // Get user with password
      const user = await prisma.user.findUnique({
        where: { id: req.user!.id }
      });

      if (!user) {
        throw createError('User not found', 404);
      }

      // Verify current password
      const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.password);
      if (!isCurrentPasswordValid) {
        throw createError('Current password is incorrect', 400);
      }

      // Hash new password
      const saltRounds = 12;
      const hashedNewPassword = await bcrypt.hash(newPassword, saltRounds);

      // Update password
      await prisma.user.update({
        where: { id: req.user!.id },
        data: { password: hashedNewPassword }
      });

      res.json({
        success: true,
        message: 'Password updated successfully'
      });
    } catch (error) {
      console.error('Error changing password:', error);
      if (error instanceof Error && error.message.includes('Current password')) {
        res.status(400).json({
          success: false,
          error: { message: error.message }
        });
      } else {
        res.status(500).json({
          success: false,
          error: { message: 'Failed to change password' }
        });
      }
    }
  }

  // Delete user account
  static async deleteAccount(req: AuthRequest, res: Response) {
    try {
      // Delete all related data
      await prisma.carbonRecord.deleteMany({
        where: { userId: req.user!.id }
      });

      await prisma.achievement.deleteMany({
        where: { userId: req.user!.id }
      });

      await prisma.userChallenge.deleteMany({
        where: { userId: req.user!.id }
      });

      await prisma.userPreference.deleteMany({
        where: { userId: req.user!.id }
      });

      // Delete user
      await prisma.user.delete({
        where: { id: req.user!.id }
      });

      res.json({
        success: true,
        message: 'Account deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting account:', error);
      res.status(500).json({
        success: false,
        error: { message: 'Failed to delete account' }
      });
    }
  }
}