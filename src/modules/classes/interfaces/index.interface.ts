export interface ClassRow {
  _count: any;
  id?: string;
  name: string;
  gradeLevel: string;
  schoolId: string;
  subjectId: string;
  arm: string;
  academicYear: string;
  term: string;
  classTeacher: string;
  studentCount: number;
  subjectCount: number;
  createdAt?: Date;
  updatedAt?: Date;
}

export type CreateClassDto = Omit<ClassRow, 'id' | 'createdAt' | 'updatedAt'>;

export type UpdateClassDto = Partial<CreateClassDto>;
