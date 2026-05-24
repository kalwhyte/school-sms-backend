-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "attendance_statuses" ADD VALUE 'excused';
ALTER TYPE "attendance_statuses" ADD VALUE 'sick';
ALTER TYPE "attendance_statuses" ADD VALUE 'suspended';

-- AlterTable
ALTER TABLE "attendance" ADD COLUMN     "reason" TEXT;
