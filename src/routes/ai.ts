import { Router } from 'express';
import { AIController } from '../controllers/aiController';
import { validate, aiValidationSchemas } from '../middleware/validation';
import { authenticate } from '../middleware/auth';

const router = Router();

// All AI routes require authentication
router.use(authenticate);

// AI analysis routes
router.post('/analyze', validate(aiValidationSchemas.analyzeRecord), AIController.analyzeRecord);
router.post('/reduction-plan', AIController.generateReductionPlan);
router.post('/chat', AIController.chatAdvice);
router.get('/insights', AIController.getInsights);

export { router as aiRoutes };