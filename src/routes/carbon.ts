import { Router } from 'express';
import { CarbonController } from '../controllers/carbonController';
import { authenticate } from '../middleware/auth';
import { validate, carbonValidationSchemas } from '../middleware/validation';

const router = Router();

// All routes require authentication
router.use(authenticate);

// Carbon record management
router.post('/records', validate(carbonValidationSchemas.createRecord), CarbonController.createRecord);
router.get('/records', CarbonController.getUserRecords);
router.get('/summary', CarbonController.getCarbonSummary);
router.put('/records/:id', validate(carbonValidationSchemas.updateRecord), CarbonController.updateRecord);
router.delete('/records/:id', CarbonController.deleteRecord);

export { router as carbonRoutes };