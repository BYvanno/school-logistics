"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateRequestStatus = exports.createRequest = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
// Teacher creates a request
const createRequest = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { itemId, quantity, reason, requesterId } = req.body;
    try {
        const request = yield prisma.request.create({
            data: {
                itemId: Number(itemId),
                quantity: Number(quantity),
                reason,
                requesterId: Number(requesterId),
                status: 'PENDING',
            },
        });
        res.status(201).json(request);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to create request' });
    }
});
exports.createRequest = createRequest;
// Admin/Storekeeper approves or rejects
const updateRequestStatus = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { id } = req.params;
    const { status, adminNote } = req.body; // APPROVED, REJECTED
    try {
        const request = yield prisma.request.findUnique({ where: { id: Number(id) }, include: { item: true } });
        if (!request)
            return res.status(404).json({ error: 'Request not found' });
        if (request.status !== 'PENDING')
            return res.status(400).json({ error: 'Request already processed' });
        if (status === 'APPROVED') {
            if (request.item.quantity < request.quantity) {
                return res.status(400).json({ error: 'Insufficient stock to approve' });
            }
            // Deduct stock
            yield prisma.item.update({
                where: { id: request.itemId },
                data: { quantity: { decrement: request.quantity } },
            });
            // Create Transaction
            yield prisma.transaction.create({
                data: {
                    type: 'OUT',
                    quantity: request.quantity,
                    itemId: request.itemId,
                    userId: request.requesterId, // Charged to requester
                    reason: `Request #${request.id} Approved`,
                }
            });
        }
        const updatedRequest = yield prisma.request.update({
            where: { id: Number(id) },
            data: { status, adminNote },
        });
        res.json(updatedRequest);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to update request' });
    }
});
exports.updateRequestStatus = updateRequestStatus;
