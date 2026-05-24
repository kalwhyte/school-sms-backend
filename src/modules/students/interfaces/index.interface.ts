export interface Student {
  id: string;
  fullName: string;
  dob: string;
  gender: string;
  classId: string;
  guardianName: string;
  admissionNumber: string;
  photoUrl: string;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
  userId: string;
  schoolId: string;
  user: User;
  currentClass: CurrentClass;
  enrollments: Enrollment[];
  parents: Parent[];
}

export interface User {
  id: string;
  phone: string | null;
  email: string | null;
  isActive: boolean;
  lastLogin: string | null;
}

export interface CurrentClass {
  id: string;
  name: string;
}

export interface Enrollment {
  id: string;
  classId: string;
  enrolledAt: string;
  class: Class;
}

export interface Class {
  id: string;
  name: string;
}

export interface Parent {
  id: string;
  parentId: string;
  parent: Parent2;
}

export interface Parent2 {
  id: string;
  fullName: string;
  user: User2;
}

export interface User2 {
  id: string;
  phone: string | null;
  email: string | null;
  isActive: boolean;
  lastLogin: string | null;
}

export interface Meta {
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export interface School {
  id: string;
  name: string;
  address: string;
  logoUrl: string | null;
  schoolCode: string;
  subscriptionTier: string;
  createdAt: string;
  updatedAt: string;
}
