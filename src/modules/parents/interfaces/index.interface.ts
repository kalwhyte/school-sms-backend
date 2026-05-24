export interface ParentRow {
  id: string;
  userId: string;
  schoolId: string;
  fullName: string;
  phone: string;
  email: string | null;
  occupation: string | null;
  createdAt: Date;
  updatedAt: Date;
  user: {
    id: string;
    role: string;
    isActive: boolean;
    lastLogin: Date | null;
  };
  students: {
    relationship: string;
    student: {
      id: string;
      fullName: string;
      admissionNumber: string;
    };
  }[];
}
