import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { PrismaClient } from '@prisma/client';

dotenv.config();

import authRoutes from './routes/authRoutes';
import inventoryRoutes from './routes/inventoryRoutes';
import requestRoutes from './routes/requestRoutes';
import { errorHandler } from './middleware/errorMiddleware';

const app = express();
const prisma = new PrismaClient();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Health Check - must be before other routes
app.get('/', (req, res) => {
    res.send('School Logistics API is running');
});

// Basic user route to test DB
app.get('/api/users', async (req, res) => {
    try {
        const users = await prisma.user.findMany();
        res.json(users);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch users' });
    }
});

app.use('/api/auth', authRoutes);
app.use('/api/inventory', inventoryRoutes);
app.use('/api/requests', requestRoutes);

app.use(errorHandler);

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
