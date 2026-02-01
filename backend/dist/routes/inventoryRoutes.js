"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const inventoryController_1 = require("../controllers/inventoryController");
const authMiddleware_1 = require("../middleware/authMiddleware");
const router = (0, express_1.Router)();
router.get('/', authMiddleware_1.authenticateToken, inventoryController_1.getItems);
router.post('/', authMiddleware_1.authenticateToken, (0, authMiddleware_1.authorizeRole)(['ADMIN', 'STOREKEEPER']), inventoryController_1.createItem);
// Update stock
router.patch('/:id/stock', authMiddleware_1.authenticateToken, (0, authMiddleware_1.authorizeRole)(['ADMIN', 'STOREKEEPER']), inventoryController_1.updateStock);
// Update generic details
router.put('/:id', authMiddleware_1.authenticateToken, (0, authMiddleware_1.authorizeRole)(['ADMIN', 'STOREKEEPER']), inventoryController_1.updateItem);
// Get item transactions
router.get('/:id/transactions', authMiddleware_1.authenticateToken, inventoryController_1.getItemTransactions);
// Global Stock Ledger
router.get('/reports/ledger', authMiddleware_1.authenticateToken, inventoryController_1.getGlobalStockLedger);
exports.default = router;
