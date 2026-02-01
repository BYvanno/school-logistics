import { Router } from 'express';
import { getItems, createItem, updateStock, updateItem, getItemTransactions, getGlobalStockLedger } from '../controllers/inventoryController';
import { authenticateToken, authorizeRole } from '../middleware/authMiddleware';

const router = Router();

router.get('/', authenticateToken, getItems);
router.post('/', authenticateToken, authorizeRole(['ADMIN', 'STOREKEEPER']), createItem);
// Update stock
router.patch('/:id/stock', authenticateToken, authorizeRole(['ADMIN', 'STOREKEEPER']), updateStock);
// Update generic details
router.put('/:id', authenticateToken, authorizeRole(['ADMIN', 'STOREKEEPER']), updateItem);
// Get item transactions
router.get('/:id/transactions', authenticateToken, getItemTransactions);
// Global Stock Ledger
router.get('/reports/ledger', authenticateToken, getGlobalStockLedger);

export default router;
