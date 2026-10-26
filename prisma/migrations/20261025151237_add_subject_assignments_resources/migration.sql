/*
  Warnings:

  - The values [ss2] on the enum `class_levels` will be removed. If these variants are still used in the database, this will fail.

*/

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "user_roles" ADD VALUE 'bursar';
ALTER TYPE "user_roles" ADD VALUE 'counsellor';

-- CreateTable
CREATE TABLE "assignments" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "school_id" UUID NOT NULL,
    "subject_id" UUID NOT NULL,
    "title" TEXT NOT NULL,
    "instructions" TEXT,
    "due_date" TIMESTAMPTZ(6),
    "attachment_url" TEXT,
    "is_published" BOOLEAN NOT NULL DEFAULT false,
    "created_by" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "assignments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "assignment_submissions" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "assignment_id" UUID NOT NULL,
    "student_id" UUID NOT NULL,
    "file_url" TEXT,
    "answer_text" TEXT,
    "submitted_at" TIMESTAMPTZ(6),
    "score" DECIMAL,
    "feedback" TEXT,
    "graded_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "assignment_submissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "subject_resources" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "school_id" UUID NOT NULL,
    "subject_id" UUID NOT NULL,
    "title" TEXT NOT NULL,
    "author" TEXT,
    "publisher" TEXT,
    "edition" TEXT,
    "description" TEXT,
    "resource_url" TEXT NOT NULL,
    "created_by" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "subject_resources_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "assignments_school_id_subject_id_idx" ON "assignments"("school_id", "subject_id");

-- CreateIndex
CREATE INDEX "assignments_subject_id_is_published_idx" ON "assignments"("subject_id", "is_published");

-- CreateIndex
CREATE INDEX "assignments_due_date_idx" ON "assignments"("due_date");

-- CreateIndex
CREATE INDEX "assignment_submissions_student_id_idx" ON "assignment_submissions"("student_id");

-- CreateIndex
CREATE INDEX "assignment_submissions_assignment_id_submitted_at_idx" ON "assignment_submissions"("assignment_id", "submitted_at");

-- CreateIndex
CREATE UNIQUE INDEX "assignment_submissions_assignment_id_student_id_key" ON "assignment_submissions"("assignment_id", "student_id");

-- CreateIndex
CREATE INDEX "subject_resources_school_id_subject_id_idx" ON "subject_resources"("school_id", "subject_id");

-- AddForeignKey
ALTER TABLE "assignments" ADD CONSTRAINT "assignments_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "schools"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "assignments" ADD CONSTRAINT "assignments_subject_id_fkey" FOREIGN KEY ("subject_id") REFERENCES "subjects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "assignments" ADD CONSTRAINT "assignments_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "assignment_submissions" ADD CONSTRAINT "assignment_submissions_assignment_id_fkey" FOREIGN KEY ("assignment_id") REFERENCES "assignments"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "assignment_submissions" ADD CONSTRAINT "assignment_submissions_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "subject_resources" ADD CONSTRAINT "subject_resources_school_id_fkey" FOREIGN KEY ("school_id") REFERENCES "schools"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "subject_resources" ADD CONSTRAINT "subject_resources_subject_id_fkey" FOREIGN KEY ("subject_id") REFERENCES "subjects"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "subject_resources" ADD CONSTRAINT "subject_resources_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
