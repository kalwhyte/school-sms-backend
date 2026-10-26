import 'dotenv/config';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Prisma initialized successfully');
  await prisma.$connect();
  console.log('Connected');
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
