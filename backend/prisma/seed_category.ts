import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    const category = await prisma.category.upsert({
        where: { id: 1 },
        update: {},
        create: {
            name: 'Stationery',
        },
    });
    console.log('Category seeded:', category);
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
