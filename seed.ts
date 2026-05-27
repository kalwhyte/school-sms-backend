// ─── seed.constants.ts ───────────────────────────────────────────────────────
// Shared constants, static data, and helper functions used across seed files.

import { UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt'; // bcryptjs has no native bindings — no build issues

export const SCHOOL_ID = '4d5d245a-69bd-4630-a3d8-92d9493595e4';
export const SCHOOL_CODE = 'GFA010';
export const ACADEMIC_YEAR = '2024/2025';
export const TERM = 'first';
export const TERM_FEE = 75000;

// Synchronous hash — safe in a seed script, no top-level await needed
export const HASH = bcrypt.hashSync('Password@123', 10);

// ─── existing IDs (already in DB — never re-create these) ────────────────────
export const EXISTING = {
  classId: '1d0ef9ff-1ff6-4b54-8e14-10b8b1c84365', // JSS2-B
  teacherId: 'fbb064f7-eb5a-4e3f-968a-c348b9c8ab69', // Nosa Ade
  subjectId: 'fc7bf8ef-08d0-448e-a35f-d79755896742', // English Language JSS2-B
  assessmentId: 'b5143a2d-3c36-47d8-be63-0b4a29f433dd', // CA Test 1
  studentId: '029050a0-a58b-4e06-ac02-940f5a33d415', // Emmanuel Tony
  creatorId: '80a6a05c-5cdb-47bc-8e25-453609ba02e0',
};

// ─── helpers ─────────────────────────────────────────────────────────────────

export function uuid(): string {
  return crypto.randomUUID();
}

export function rand(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

export function pick<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

export function padNum(n: number, len = 4): string {
  return String(n).padStart(len, '0');
}

export function nigerianPhone(): string {
  return `+234${pick(['80', '81', '70', '90', '91'])}${padNum(rand(10000000, 99999999), 8)}`;
}

// ─── name pools ──────────────────────────────────────────────────────────────

const maleFirst = [
  'Emeka',
  'Chidi',
  'Tunde',
  'Seun',
  'Femi',
  'Kunle',
  'Bola',
  'Gbenga',
  'Dayo',
  'Kayode',
  'Nnamdi',
  'Uche',
  'Ike',
  'Obinna',
  'Chukwuemeka',
  'Adewale',
  'Babatunde',
  'Oluwaseun',
  'Ifeanyi',
  'Tobi',
  'Jide',
  'Rotimi',
  'Kola',
  'Leke',
  'Sola',
];
const femaleFirst = [
  'Ngozi',
  'Amaka',
  'Chioma',
  'Adaeze',
  'Blessing',
  'Funke',
  'Yetunde',
  'Sade',
  'Bisi',
  'Kemi',
  'Adeola',
  'Chiamaka',
  'Uchenna',
  'Ifeoma',
  'Nkechi',
  'Tolani',
  'Folake',
  'Taiwo',
  'Kehinde',
  'Omowunmi',
  'Temi',
  'Joke',
  'Shade',
  'Bunmi',
  'Lara',
];
const lastNames = [
  'Okafor',
  'Adeyemi',
  'Nwachukwu',
  'Eze',
  'Okonkwo',
  'Adebayo',
  'Obi',
  'Chukwu',
  'Adesanya',
  'Nwosu',
  'Ogundimu',
  'Onyekachi',
  'Ikenna',
  'Abiodun',
  'Fashola',
  'Balogun',
  'Ogundele',
  'Dike',
  'Olatunji',
  'Afolabi',
  'Okorie',
  'Nzekwe',
  'Adegoke',
  'Olawale',
  'Obasi',
  'Akinwande',
  'Uchegbu',
  'Agbaje',
  'Onyeka',
  'Mbah',
];

export function randomName(gender: 'male' | 'female'): string {
  const first = gender === 'male' ? pick(maleFirst) : pick(femaleFirst);
  return `${first} ${pick(lastNames)}`;
}

// ─── class definitions ────────────────────────────────────────────────────────

export const CLASS_DEFS = [
  { name: 'JSS 1', arm: 'A', level: 'jss1', stream: 'science' },
  { name: 'JSS 1', arm: 'B', level: 'jss1', stream: 'art' },
  { name: 'JSS 2', arm: 'A', level: 'jss2', stream: 'science' },
  { name: 'JSS 2', arm: 'B', level: 'jss2', stream: 'art' }, // ← existing
  { name: 'JSS 3', arm: 'A', level: 'jss3', stream: 'science' },
  { name: 'JSS 3', arm: 'B', level: 'jss3', stream: 'art' },
  { name: 'SS 1', arm: 'A', level: 'ss1', stream: 'science' },
  { name: 'SS 1', arm: 'B', level: 'ss1', stream: 'art' },
  { name: 'SS 2', arm: 'A', level: 'ss2', stream: 'science' },
  { name: 'SS 2', arm: 'B', level: 'ss2', stream: 'art' },
  { name: 'SS 3', arm: 'A', level: 'ss3', stream: 'science' },
  { name: 'SS 3', arm: 'B', level: 'ss3', stream: 'art' },
];

export const SUBJECTS_BY_LEVEL: Record<string, string[]> = {
  jss1: [
    'English Language',
    'Mathematics',
    'Basic Science',
    'Social Studies',
    'Christian Religious Studies',
  ],
  jss2: [
    'English Language',
    'Mathematics',
    'Basic Science',
    'Social Studies',
    'Business Studies',
  ],
  jss3: [
    'English Language',
    'Mathematics',
    'Basic Science',
    'Basic Technology',
    'Civic Education',
  ],
  ss1: ['English Language', 'Mathematics', 'Physics', 'Chemistry', 'Biology'],
  ss2: [
    'English Language',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Further Mathematics',
  ],
  ss3: ['English Language', 'Mathematics', 'Physics', 'Chemistry', 'Economics'],
};

export const ASSESSMENT_TEMPLATES = [
  { title: 'CA Test 1', type: 'CA', maxScore: 20, passingScore: 10 },
  { title: 'CA Test 2', type: 'CA', maxScore: 20, passingScore: 10 },
  { title: 'Examination', type: 'EXAM', maxScore: 60, passingScore: 30 },
];

export const ADMIN_STAFF = [
  {
    role: UserRole.principal,
    title: 'Principal',
    name: 'Dr. Funmilayo Adeyinka',
  },
  {
    role: UserRole.vice_principal,
    title: 'Vice Principal',
    name: 'Mr. Chukwuemeka Obi',
  },
  { role: UserRole.admin, title: 'Bursar', name: 'Mrs. Adaeze Onyekachi' },
];
