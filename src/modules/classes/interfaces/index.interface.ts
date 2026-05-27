import { ClassLevel, ClassStream, Term } from '@prisma/client';

export interface ClassTeacherRow {
  id: string;
  fullName: string;
  roleTitle: string | null;
  photoUrl: string | null;
}

export interface ClassCountRow {
  students: number;
  subjects: number;
}

export interface ClassRow {
  id: string;
  schoolId: string;
  name: string;
  arm: string;
  level: ClassLevel;
  stream: ClassStream | null;
  academicYear: string;
  term: Term;
  createdAt: Date;
  classTeacher: ClassTeacherRow | null;
  _count: ClassCountRow;
}

export interface FormattedClass {
  id: string;
  schoolId: string;
  name: string;
  arm: string;
  level: ClassLevel;
  stream: ClassStream | null;
  academicYear: string;
  term: Term;
  createdAt: Date;
  classTeacher: ClassTeacherRow | null;
  studentCount: number;
  subjectCount: number;
}
