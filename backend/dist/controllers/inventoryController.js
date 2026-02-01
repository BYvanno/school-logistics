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
exports.getGlobalStockLedger = exports.getItemTransactions = exports.updateStock = exports.updateItem = exports.createItem = exports.getItems = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const getItems = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const items = yield prisma.item.findMany({ include: { category: true, supplier: true } });
        res.json(items);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch items' });
    }
});
exports.getItems = getItems;
const createItem = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { name, categoryId, quantity, unit, minStockLevel, description } = req.body;
        const item = yield prisma.item.create({
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
    }
    catch (error) {
        res.status(400).json({ error: 'Failed to create item' });
    }
});
exports.createItem = createItem;
const updateItem = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const { name, categoryId, quantity, unit, minStockLevel, description } = req.body;
        const item = yield prisma.item.update({
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
    }
    catch (error) {
        res.status(400).json({ error: 'Failed to update item' });
    }
});
exports.updateItem = updateItem;
const updateStock = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    // Stock In / Out manually
    const { id } = req.params;
    const { quantity, type, reason, userId } = req.body; // type: IN or OUT
    try {
        const item = yield prisma.item.findUnique({ where: { id: Number(id) } });
        if (!item)
            return res.status(404).json({ error: 'Item not found' });
        let newQuantity = item.quantity;
        if (type === 'IN')
            newQuantity += Number(quantity);
        else if (type === 'OUT')
            newQuantity -= Number(quantity);
        if (newQuantity < 0)
            return res.status(400).json({ error: 'Insufficient stock' });
        const updatedItem = yield prisma.item.update({
            where: { id: Number(id) },
            data: { quantity: newQuantity },
        });
        // Record Transaction
        yield prisma.transaction.create({
            data: {
                type,
                quantity: Number(quantity),
                itemId: Number(id),
                userId: Number(userId),
                reason,
            },
        });
        res.json(updatedItem);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to update stock' });
    }
});
exports.updateStock = updateStock;
const getItemTransactions = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { id } = req.params;
        const transactions = yield prisma.transaction.findMany({
            where: { itemId: Number(id) },
            orderBy: { createdAt: 'desc' },
            include: { user: true },
        });
        res.json(transactions);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch transactions' });
    }
});
exports.getItemTransactions = getItemTransactions;
const getGlobalStockLedger = (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const items = yield prisma.item.findMany({
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
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to generate stock ledger' });
    }
});
exports.getGlobalStockLedger = getGlobalStockLedger;
