import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';

export const validate = (schema: Joi.ObjectSchema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error } = schema.validate(req.body);
    
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
    
    next();
  };
};

// Common validation schemas
export const userValidationSchemas = {
  register: Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().min(8).required(),
    name: Joi.string().min(2).max(50).required()
  }),
  
  login: Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().required()
  }),
  
  updateProfile: Joi.object({
    name: Joi.string().min(2).max(50),
    avatar: Joi.string().uri(),
    preferences: Joi.object({
      notificationsEnabled: Joi.boolean(),
      dailyGoal: Joi.number().positive(),
      language: Joi.string(),
      currency: Joi.string()
    })
  })
};

export const carbonValidationSchemas = {
  createRecord: Joi.object({
    category: Joi.string().valid('TRANSPORTATION', 'FOOD', 'ENERGY', 'SHOPPING', 'HOUSING', 'WASTE', 'OTHER').required(),
    type: Joi.string().valid('DIRECT', 'INDIRECT', 'OFFSET').required(),
    amount: Joi.number().positive().required(),
    unit: Joi.string().required(),
    source: Joi.string().allow(''),
    description: Joi.string().allow(''),
    location: Joi.string().allow('')
  }),
  
  updateRecord: Joi.object({
    amount: Joi.number().positive(),
    unit: Joi.string(),
    description: Joi.string(),
    analyzed: Joi.boolean()
  })
};

export const aiValidationSchemas = {
  analyzeRecord: Joi.object({
    recordData: Joi.object({
      category: Joi.string().required(),
      type: Joi.string().required(),
      amount: Joi.number().positive().required(),
      unit: Joi.string().required(),
      description: Joi.string().allow('')
    }).required(),
    context: Joi.string().allow('')
  })
};