export interface IAuthenticatedUser {
  userId: string;
  schoolId: string;
  role: string;
  phone: string | null;
  fullName: string;
  photoUrl?: string | null;
}
