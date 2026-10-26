-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "class_levels" ADD VALUE 'preNursery';
ALTER TYPE "class_levels" ADD VALUE 'nursery1';
ALTER TYPE "class_levels" ADD VALUE 'nursery2';
ALTER TYPE "class_levels" ADD VALUE 'nursery3';
ALTER TYPE "class_levels" ADD VALUE 'primary1';
ALTER TYPE "class_levels" ADD VALUE 'primary2';
ALTER TYPE "class_levels" ADD VALUE 'primary3';
ALTER TYPE "class_levels" ADD VALUE 'primary4';
ALTER TYPE "class_levels" ADD VALUE 'primary5';
ALTER TYPE "class_levels" ADD VALUE 'primary6';
