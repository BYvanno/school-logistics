import { Router } from 'express';
import { createRequest, updateRequestStatus } from '../controllers/requestController';
import { authenticateToken, authorizeRole } from '../middleware/authMiddleware';

const router = Router();

router.post('/', authenticateToken, createRequest); // Any authenticated user (Teacher)
router.patch('/:id/status', authenticateToken, authorizeRole(['ADMIN', 'STOREKEEPER']), updateRequestStatus);

export default router;
