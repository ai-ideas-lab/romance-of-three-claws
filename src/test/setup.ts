import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Test database setup
export async function setupTestDatabase() {
  // Clean the database before each test
  await cleanupTestDatabase();
}

export async function cleanupTestDatabase() {
  try {
    // Delete all records in the correct order to respect foreign key constraints
    await prisma.userChallenge.deleteMany();
    await prisma.achievement.deleteMany();
    await prisma.carbonRecord.deleteMany();
    await prisma.userPreference.deleteMany();
    await prisma.groupChallenge.deleteMany();
    await prisma.socialGroup.deleteMany();
    await prisma.user.deleteMany();
  } catch (error) {
    console.error('Error cleaning up test database:', error);
  }
}

export { prisma };