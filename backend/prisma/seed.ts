import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
    const adminEmail = 'admin@school.com';
    const existingAdmin = await prisma.user.findUnique({ where: { email: adminEmail } });

    if (!existingAdmin) {
        const hashedPassword = await bcrypt.hash('admin123', 10);
        await prisma.user.create({
            data: {
                email: adminEmail,
                name: 'Admin User',
                password: hashedPassword,
                role: 'ADMIN',
            },
        });
        console.log('Admin user created');
    } else {
        console.log('Admin user already exists');
    }

    // Create default categories
    const categories = ['Stationery', 'Electronics', 'Furniture', 'Sports', 'Cleaning'];
    for (const name of categories) {
        const existingCategory = await prisma.category.findUnique({ where: { name } });
        if (!existingCategory) {
            await prisma.category.create({ data: { name } });
            console.log(`Category '${name}' created`);
        }
    }
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
