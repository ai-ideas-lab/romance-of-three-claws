import { Request, Response, NextFunction } from 'express';

interface RateLimitStore {
  [key: string]: {
    count: number;
    resetTime: number;
  };
}

const rateLimitStore: RateLimitStore = {};

const windowMs = parseInt(process.env.RATE_LIMIT_WINDOW || '900000'); // 15 minutes
const maxRequests = parseInt(process.env.RATE_LIMIT_MAX || '100'); // 100 requests per window

export const rateLimiter = (req: Request, res: Response, next: NextFunction) => {
  const clientId = req.ip || req.connection.remoteAddress || 'unknown';
  const now = Date.now();
  
  // Clean expired entries
  Object.keys(rateLimitStore).forEach(key => {
    if (rateLimitStore[key].resetTime < now) {
      delete rateLimitStore[key];
    }
  });
  
  // Get or create client entry
  if (!rateLimitStore[clientId]) {
    rateLimitStore[clientId] = {
      count: 0,
      resetTime: now + windowMs
    };
  }
  
  const client = rateLimitStore[clientId];
  
  // Check if window has reset
  if (client.resetTime < now) {
    client.count = 0;
    client.resetTime = now + windowMs;
  }
  
  // Check if limit exceeded
  if (client.count >= maxRequests) {
    const remainingTime = Math.ceil((client.resetTime - now) / 1000);
    return res.status(429).json({
      success: false,
      error: {
        message: 'Too many requests',
        code: 'RATE_LIMIT_EXCEEDED',
        retryAfter: remainingTime
      }
    });
  }
  
  // Increment count
  client.count++;
  
  // Add rate limit headers
  res.set({
    'X-RateLimit-Limit': maxRequests,
    'X-RateLimit-Remaining': maxRequests - client.count,
    'X-RateLimit-Reset': client.resetTime,
    'Retry-After': Math.ceil((client.resetTime - now) / 1000)
  });
  
  next();
};