import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Teacher creates a request
export const createRequest = async (req: Request, res: Response) => {
    const { itemId, quantity, reason, requesterId } = req.body;

    try {
        const request = await prisma.request.create({
            data: {
                itemId: Number(itemId),
                quantity: Number(quantity),
                reason,
                requesterId: Number(requesterId),
                status: 'PENDING',
            },
        });
        res.status(201).json(request);
    } catch (error) {
        res.status(500).json({ error: 'Failed to create request' });
    }
};

// Admin/Storekeeper approves or rejects
export const updateRequestStatus = async (req: Request, res: Response) => {
    const { id } = req.params;
    const { status, adminNote } = req.body; // APPROVED, REJECTED

    try {
        const request = await prisma.request.findUnique({ where: { id: Number(id) }, include: { item: true } });
        if (!request) return res.status(404).json({ error: 'Request not found' });

        if (request.status !== 'PENDING') return res.status(400).json({ error: 'Request already processed' });

        if (status === 'APPROVED') {
            if (request.item.quantity < request.quantity) {
                return res.status(400).json({ error: 'Insufficient stock to approve' });
            }

            // Deduct stock
            await prisma.item.update({
                where: { id: request.itemId },
                data: { quantity: { decrement: request.quantity } },
            });

            // Create Transaction
            await prisma.transaction.create({
                data: {
                    type: 'OUT',
                    quantity: request.quantity,
                    itemId: request.itemId,
                    userId: request.requesterId, // Charged to requester
                    reason: `Request #${request.id} Approved`,
                }
            });
        }

        const updatedRequest = await prisma.request.update({
            where: { id: Number(id) },
            data: { status, adminNote },
        });

        res.json(updatedRequest);
    } catch (error) {
        res.status(500).json({ error: 'Failed to update request' });
    }
};
