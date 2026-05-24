-- CreateEnum
CREATE TYPE "class_levels" AS ENUM ('jss1', 'jss2', 'jss3', 'ss1', 'ss2', 'ss3');

-- CreateEnum
CREATE TYPE "class_streams" AS ENUM ('science', 'commercial', 'arts', 'general');

-- AlterTable
ALTER TABLE "classes" ADD COLUMN     "level" "class_levels",
ADD COLUMN     "stream" "class_streams";

-- AlterTable
ALTER TABLE "report_cards" ADD COLUMN     "attendance_days_absent" INTEGER,
ADD COLUMN     "attendance_days_present" INTEGER,
ADD COLUMN     "attendance_percentage" DECIMAL,
ADD COLUMN     "average_score" DECIMAL,
ADD COLUMN     "class_position" INTEGER,
ADD COLUMN     "class_teacher_remark" TEXT,
ADD COLUMN     "next_term_begins" DATE,
ADD COLUMN     "principal_remark" TEXT,
ADD COLUMN     "total_score" DECIMAL,
ADD COLUMN     "total_students_in_class" INTEGER;
