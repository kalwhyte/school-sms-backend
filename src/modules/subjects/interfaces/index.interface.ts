export interface SubjectRow {
  id: string;
  schoolId: string;
  name: string;
  classId: string;
  isCore: boolean;
  createdAt: Date;
  class: { id: string; name: string; arm: string };
  teacher: { id: string; fullName: string; roleTitle: string } | null;
  _count: { assessments: number };
}

export interface TimetablePeriodRow {
  id: string;
  classId: string;
  subjectId: string;
  dayOfWeek: string;
  startTime: Date;
  endTime: Date;
  subject: { id: string; name: string };
}
