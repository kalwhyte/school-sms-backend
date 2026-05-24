export interface StaffRow {
  id: string;
  userId: string;
  schoolId: string;
  fullName: string;
  roleTitle: string;
  subjectSpecialty: string | null;
  photoUrl: string | null;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
  user: {
    id: string;
    phone: string;
    email: string | null;
    role: string;
    isActive: boolean;
    lastLogin: Date | null;
  };
}
