import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { createError } from './errorHandler';

export interface AuthRequest extends Request {
  user?: {
    id: string;
    email: string;
    name: string;
  };
}

export const authenticate = (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw createError('Authorization token required', 401);
    }
    
    const token = authHeader.substring(7); // Remove 'Bearer ' prefix
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;
    
    req.user = {
      id: decoded.id,
      email: decoded.email,
      name: decoded.name
    };
    
    next();
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      throw createError('Invalid token', 401);
    }
    next(error);
  }
};

export const optionalAuth = (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;
      
      req.user = {
        id: decoded.id,
        email: decoded.email,
        name: decoded.name
      };
    }
    
    next();
  } catch (error) {
    // Continue without authentication for optional auth
    next();
  }
};