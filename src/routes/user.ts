import { Router } from 'express';
import { UserController } from '../controllers/userController';
import { validate, userValidationSchemas } from '../middleware/validation';

const router = Router();

// Authentication routes (no auth required)
router.post('/register', validate(userValidationSchemas.register), UserController.register);
router.post('/login', validate(userValidationSchemas.login), UserController.login);

// Protected routes
import { authenticate } from '../middleware/auth';
router.use(authenticate);

router.get('/profile', UserController.getProfile);
router.put('/profile', validate(userValidationSchemas.updateProfile), UserController.updateProfile);
router.put('/change-password', UserController.changePassword);
router.delete('/account', UserController.deleteAccount);

export { router as userRoutes };