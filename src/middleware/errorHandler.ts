import { Request, Response, NextFunction } from 'express';

export interface AppError extends Error {
  statusCode?: number;
  isOperational?: boolean;
}

export const errorHandler = (
  error: AppError,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const statusCode = error.statusCode || 500;
  const message = error.message || 'Internal Server Error';
  
  console.error(`❌ Error ${statusCode}: ${message}`);
  console.error(error.stack);
  
  // Don't leak error details in production
  const response = {
    success: false,
    error: {
      message: process.env.NODE_ENV === 'development' ? message : 'Something went wrong',
      ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
    }
  };
  
  res.status(statusCode).json(response);
};

export const createError = (message: string, statusCode: number = 500): AppError => {
  const error = new Error(message) as AppError;
  error.statusCode = statusCode;
  error.isOperational = true;
  return error;
};