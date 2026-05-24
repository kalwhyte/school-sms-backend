export interface UserRow {
  id: string;
  schoolId: string;
  phone: string;
  email: string | null;
  role: string;
  isActive: boolean;
  lastLogin: Date | null;
  createdAt: Date;
  updatedAt: Date;
  staff: {
    id: string;
    fullName: string;
    roleTitle: string;
    photoUrl: string | null;
  } | null;
  parent: {
    id: string;
    fullName: string;
    occupation: string | null;
  } | null;
  student: {
    id: string;
    fullName: string;
    admissionNumber: string;
  } | null;
}
