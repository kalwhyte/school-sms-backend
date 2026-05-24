// export interface IReport-cards {}
import { AssessmentType } from '@prisma/client';
import { Prisma } from '@prisma/client';
import { Term } from '@prisma/client';
// ── Helpers ───────────────────────────────────────────────────────────────────
export function getGrade(percentage: number): string {
  if (percentage >= 75) return 'A1';
  if (percentage >= 70) return 'B2';
  if (percentage >= 65) return 'B3';
  if (percentage >= 60) return 'C4';
  if (percentage >= 55) return 'C5';
  if (percentage >= 50) return 'C6';
  if (percentage >= 45) return 'D7';
  if (percentage >= 40) return 'E8';
  return 'F9';
}

export function getRemark(percentage: number): string {
  if (percentage >= 75) return 'Distinction';
  if (percentage >= 60) return 'Credit';
  if (percentage >= 40) return 'Pass';
  return 'Fail';
}

// ── Types ─────────────────────────────────────────────────────────────────────

export type AssessmentEntry = {
  id: string;
  title: string;
  type: AssessmentType;
  score: number;
  maxScore: number;
  percentage: number;
};

export type SubjectResult = {
  subjectId: string;
  subjectName: string;
  isCore: boolean;
  assessments: AssessmentEntry[];
  total: { score: number; maxScore: number; percentage: number };
  grade: string;
  remark: string;
};

// Shape of what Prisma returns for scores.findMany with the include below
export type ScoreWithAssessment = {
  id: string;
  studentId: string;
  assessmentId: string;
  gradedBy: string | null;
  gradedAt: Date;
  score: Prisma.Decimal;
  assessment: {
    id: string;
    title: string;
    type: AssessmentType;
    maxScore: Prisma.Decimal;
    date: Date;
    subjectId: string;
    term: Term | null;
    academicYear: string | null;
  };
};
