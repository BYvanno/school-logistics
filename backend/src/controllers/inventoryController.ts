import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getItems = async (req: Request, res: Response) => {
    try {
        const items = await prisma.item.findMany({ include: { category: true, supplier: true } });
        res.json(items);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch items' });
    }
};

export const createItem = async (req: Request, res: Response) => {
    try {
        const { name, categoryId, quantity, unit, minStockLevel, description } = req.body;
        const item = await prisma.item.create({
            data: {
                name,
                categoryId: Number(categoryId),
                quantity: Number(quantity),
                unit,
                minStockLevel: Number(minStockLevel),
                description,
            },
        });
        res.status(201).json(item);
    } catch (error) {
        res.status(400).json({ error: 'Failed to create item' });
    }
};

export const updateItem = async (req: Request, res: Response) => {
    try {
        const { id } = req.params;
        const { name, categoryId, quantity, unit, minStockLevel, description } = req.body;
        const item = await prisma.item.update({
            where: { id: Number(id) },
            data: {
                name,
                categoryId: categoryId ? Number(categoryId) : undefined,
                quantity: quantity ? Number(quantity) : undefined,
                unit,
                minStockLevel: minStockLevel ? Number(minStockLevel) : undefined,
                description,
            },
        });
        res.json(item);
    } catch (error) {
        res.status(400).json({ error: 'Failed to update item' });
    }
};


export const updateStock = async (req: Request, res: Response) => {
    // Stock In / Out manually
    const { id } = req.params;
    const { quantity, type, reason, userId } = req.body; // type: IN or OUT

    try {
        const item = await prisma.item.findUnique({ where: { id: Number(id) } });
        if (!item) return res.status(404).json({ error: 'Item not found' });

        let newQuantity = item.quantity;
        if (type === 'IN') newQuantity += Number(quantity);
        else if (type === 'OUT') newQuantity -= Number(quantity);

        if (newQuantity < 0) return res.status(400).json({ error: 'Insufficient stock' });

        const updatedItem = await prisma.item.update({
            where: { id: Number(id) },
            data: { quantity: newQuantity },
        });

        // Record Transaction
        await prisma.transaction.create({
            data: {
                type,
                quantity: Number(quantity),
                itemId: Number(id),
                userId: Number(userId),
                reason,
            },
        });

        res.json(updatedItem);
    } catch (error) {
        res.status(500).json({ error: 'Failed to update stock' });
    }
};

export const getItemTransactions = async (req: Request, res: Response) => {
    try {
        const { id } = req.params;
        const transactions = await prisma.transaction.findMany({
            where: { itemId: Number(id) },
            orderBy: { createdAt: 'desc' },
            include: { user: true },
        });
        res.json(transactions);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch transactions' });
    }
};

export const getGlobalStockLedger = async (req: Request, res: Response) => {
    try {
        const items = await prisma.item.findMany({
            include: { transactions: true }
        });

        const report = items.map(item => {
            const totalOut = item.transactions
                .filter(t => t.type === 'OUT')
                .reduce((sum, t) => sum + t.quantity, 0);

            // To ensure the report balances (In - Out = Remainder):
            // We interpret 'Total In' as the sum needed to reach current stock given the outflows.
            // Total In - Total Out = Current Quantity
            // Therefore: Total In = Current Quantity + Total Out
            const currentQuantity = item.quantity;
            const totalIn = currentQuantity + totalOut;

            return {
                id: item.id,
                date: new Date(), // Report date
                name: item.name,
                unit: item.unit,
                incomingQuantity: totalIn,
                outgoingQuantity: totalOut,
                remainder: currentQuantity
            };
        });

        res.json(report);
    } catch (error) {
        res.status(500).json({ error: 'Failed to generate stock ledger' });
    }
};
