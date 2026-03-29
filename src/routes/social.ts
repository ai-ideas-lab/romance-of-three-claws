import { Router } from 'express';
import { SocialController } from '../controllers/socialController';
import { authenticate } from '../middleware/auth';

const router = Router();

// All social routes require authentication
router.use(authenticate);

// Group management
router.post('/groups', SocialController.createGroup);
router.get('/groups', SocialController.getUserGroups);
router.post('/groups/:groupId/join', SocialController.joinGroup);
router.post('/groups/:groupId/leave', SocialController.leaveGroup);

// Challenge management
router.post('/challenges', SocialController.createChallenge);
router.get('/groups/:groupId/challenges', SocialController.getGroupChallenges);
router.put('/challenges/:challengeId/progress', SocialController.updateChallengeProgress);

// Social features
router.get('/groups/:groupId/leaderboard', SocialController.getLeaderboard);
router.get('/stats', SocialController.getUserSocialStats);

export { router as socialRoutes };