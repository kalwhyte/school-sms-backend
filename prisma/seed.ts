// ─── seed.ts ─────────────────────────────────────────────────────────────────
import 'dotenv/config';
import {
  PrismaClient,
  UserRole,
  ClassLevel,
  ClassStream,
  Term,
} from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { PrismaPg } from '@prisma/adapter-pg';

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error('DATABASE_URL is not configured');
}

const adapter = new PrismaPg({ connectionString });

const prisma = new PrismaClient({ adapter });

// ─── Constants ────────────────────────────────────────────────────────────────
const SCHOOL_ID = '55473dfa-dd2b-41e5-b85e-8da87261fa12';
const ACADEMIC_YEAR = '2026/2027';
const TERM = Term.third;
const HASH = bcrypt.hashSync('Password@123', 10);

// IDs already in DB — skip these on create
const EXISTING = {
  classId: 'afa8bb8f-12ea-480d-949b-ace41851d9c1', // JSS 2 B
  teacherId: '623d1d91-0f9d-4507-ac8d-cb54d6fb5126', // Nosa Ade
  studentId: '95738447-114b-4bfa-8238-1e8ac5880bbb', // Emmanuel Tony
  creatorId: 'd6974752-6a58-4a5f-a137-58e640de8166',
};

// ─── Helpers ──────────────────────────────────────────────────────────────────

function rand(min: number, max: number) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}
function pick<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}
function nigerianPhone() {
  const prefix = pick(['080', '081', '070', '090', '091']);
  return `+234${prefix}${String(rand(10000000, 99999999))}`;
}

const maleFirst = [
  'Emeka',
  'Chidi',
  'Tunde',
  'Seun',
  'Femi',
  'Kunle',
  'Gbenga',
  'Dayo',
  'Nnamdi',
  'Uche',
  'Ike',
  'Obinna',
  'Adewale',
  'Babatunde',
  'Ifeanyi',
  'Tobi',
  'Jide',
  'Rotimi',
  'Kola',
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
  'Ifeoma',
  'Nkechi',
  'Tolani',
  'Folake',
  'Taiwo',
  'Kehinde',
  'Temi',
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
  'Abiodun',
  'Fashola',
  'Balogun',
  'Dike',
  'Olatunji',
  'Afolabi',
  'Okorie',
  'Mbah',
];

function randomName(gender: 'male' | 'female') {
  const first = gender === 'male' ? pick(maleFirst) : pick(femaleFirst);
  return `${first} ${pick(lastNames)}`;
}

// ─── Class definitions ────────────────────────────────────────────────────────

const CLASS_DEFS = [
  {
    name: 'JSS 1',
    arm: 'C',
    level: ClassLevel.jss1,
    stream: ClassStream.science,
  },
  {
    name: 'JSS 1',
    arm: 'D',
    level: ClassLevel.jss1,
    stream: ClassStream.general,
  },
  {
    name: 'JSS 2',
    arm: 'C',
    level: ClassLevel.jss2,
    stream: ClassStream.general,
  },
  // JSS 2 B already exists — seeded via EXISTING.classId
  {
    name: 'JSS 3',
    arm: 'D',
    level: ClassLevel.jss3,
    stream: ClassStream.general,
  },
  {
    name: 'JSS 3',
    arm: 'C',
    level: ClassLevel.jss3,
    stream: ClassStream.general,
  },
  {
    name: 'SS 1',
    arm: 'C',
    level: ClassLevel.ss1,
    stream: ClassStream.science,
  },
  { name: 'SS 1', arm: 'D', level: ClassLevel.ss1, stream: ClassStream.arts },
  {
    name: 'SS 2',
    arm: 'C',
    level: ClassLevel.ss2,
    stream: ClassStream.science,
  },
  {
    name: 'SS 2',
    arm: 'D',
    level: ClassLevel.ss2,
    stream: ClassStream.commercial,
  },
  {
    name: 'SS 3',
    arm: 'C',
    level: ClassLevel.ss3,
    stream: ClassStream.science,
  },
  { name: 'SS 3', arm: 'D', level: ClassLevel.ss3, stream: ClassStream.arts },
];

// ─── Subjects per level ───────────────────────────────────────────────────────

const SUBJECTS_BY_LEVEL: Record<string, string[]> = {
  jss1: [
    'English Language',
    'Mathematics',
    'Basic Science',
    'Social Studies',
    'Christian Religious Studies',
    'Agricultural Science',
    'Basic Technology',
  ],
  jss2: [
    'English Language',
    'Mathematics',
    'Basic Science',
    'Social Studies',
    'Business Studies',
    'Agricultural Science',
    'Basic Technology',
  ],
  jss3: [
    'English Language',
    'Mathematics',
    'Basic Science',
    'Basic Technology',
    'Civic Education',
    'Agricultural Science',
    'Business Studies',
  ],
  ss1: [
    'English Language',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Geography',
    'Civic Education',
  ],
  ss2: [
    'English Language',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Further Mathematics',
    'Biology',
    'Geography',
  ],
  ss3: [
    'English Language',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Economics',
    'Biology',
    'Literature in English',
  ],
};

// ─── Admin staff ──────────────────────────────────────────────────────────────

const ADMIN_STAFF = [
  {
    role: UserRole.principal,
    roleTitle: 'Principal',
    name: 'Professor Whyte Walker',
  },
  {
    role: UserRole.vice_principal,
    roleTitle: 'Vice Principal',
    name: 'Mr. Chukwuemeka Obi',
  },
  { role: UserRole.admin, roleTitle: 'Bursar', name: 'Mrs. Adaeze Onyekachi' },
];

// ─── Main ─────────────────────────────────────────────────────────────────────

async function main() {
  console.log('🌱 Starting seed...\n');

  // ── 1. Admin staff ──────────────────────────────────────────────────────────
  console.log('👔 Seeding admin staff...');
  for (const s of ADMIN_STAFF) {
    const phone = nigerianPhone();
    const existing = await prisma.user.findFirst({
      where: { schoolId: SCHOOL_ID, role: s.role },
      select: { id: true },
    });
    if (existing) {
      console.log(`   ↳ ${s.name} (${s.role}) already exists — skipped`);
      continue;
    }
    const user = await prisma.user.create({
      data: {
        schoolId: SCHOOL_ID,
        phone,
        role: s.role,
        password: HASH,
        isActive: true,
      },
    });
    await prisma.staff.create({
      data: {
        schoolId: SCHOOL_ID,
        userId: user.id,
        fullName: s.name,
        roleTitle: s.roleTitle,
        isActive: true,
      },
    });
    console.log(`   ✓ ${s.name} (${s.role})`);
  }

  // ── 2. Classes ──────────────────────────────────────────────────────────────
  console.log('\n🏫 Seeding classes...');
  const classIdMap: Record<string, string> = {
    // pre-load the existing JSS 2 B
    'JSS 2-B': EXISTING.classId,
  };

  for (const def of CLASS_DEFS) {
    const key = `${def.name}-${def.arm}`;
    const existing = await prisma.class.findUnique({
      where: {
        schoolId_name_arm_academicYear_term: {
          schoolId: SCHOOL_ID,
          name: def.name,
          arm: def.arm,
          academicYear: ACADEMIC_YEAR,
          term: TERM,
        },
      },
      select: { id: true },
    });

    if (existing) {
      classIdMap[key] = existing.id;
      console.log(`   ↳ ${key} already exists — skipped`);
      continue;
    }

    const created = await prisma.class.create({
      data: {
        schoolId: SCHOOL_ID,
        name: def.name,
        arm: def.arm,
        level: def.level,
        stream: def.stream,
        academicYear: ACADEMIC_YEAR,
        term: TERM,
      },
    });
    classIdMap[key] = created.id;
    console.log(`   ✓ ${key} (${def.level} / ${def.stream})`);
  }

  // ── 3. Subjects ─────────────────────────────────────────────────────────────
  console.log('\n📚 Seeding subjects...');
  for (const [classKey, classId] of Object.entries(classIdMap)) {
    // Derive level from the key (e.g. "JSS 1-A" → jss1)
    const levelKey = classKey
      .split('-')[0]
      .toLowerCase()
      .replace('jss ', 'jss')
      .replace('ss ', 'ss')
      .trim();

    const subjects = SUBJECTS_BY_LEVEL[levelKey] ?? [];
    for (const subjectName of subjects) {
      const existing = await prisma.subject.findUnique({
        where: { classId_name: { classId, name: subjectName } },
        select: { id: true },
      });
      if (existing) continue;

      await prisma.subject.create({
        data: {
          schoolId: SCHOOL_ID,
          classId,
          name: subjectName,
          isCore: true,
        },
      });
    }
    console.log(`   ✓ ${subjects.length} subjects for ${classKey}`);
  }

  // ── 4. Class teachers (subject teachers) ────────────────────────────────────
  console.log('\n👩‍🏫 Seeding class teachers...');
  const allClassIds = Object.values(classIdMap);
  for (const classId of allClassIds) {
    const phone = nigerianPhone();
    const gender = pick(['male', 'female'] as const);
    const name = randomName(gender);

    const user = await prisma.user.create({
      data: {
        schoolId: SCHOOL_ID,
        phone,
        role: UserRole.class_teacher,
        password: HASH,
        isActive: true,
      },
    });
    const staff = await prisma.staff.create({
      data: {
        schoolId: SCHOOL_ID,
        userId: user.id,
        fullName: name,
        roleTitle: 'Class Teacher',
        isActive: true,
      },
    });
    await prisma.class.update({
      where: { id: classId },
      data: { teacherId: staff.id },
    });
    console.log(`   ✓ ${name} → class ${classId.slice(0, 8)}...`);
  }

  // ── 5. Students ─────────────────────────────────────────────────────────────
  console.log('\n🎒 Seeding students (5 per class)...');
  for (const [classKey, classId] of Object.entries(classIdMap)) {
    for (let i = 0; i < 5; i++) {
      const gender = pick(['male', 'female'] as const);
      const name = randomName(gender);
      const phone = nigerianPhone();

      const user = await prisma.user.create({
        data: {
          schoolId: SCHOOL_ID,
          phone,
          role: UserRole.student,
          password: HASH,
          isActive: true,
        },
      });

      const student = await prisma.student.create({
        data: {
          schoolId: SCHOOL_ID,
          userId: user.id,
          fullName: name,
          gender: gender === 'male' ? 'male' : 'female',
          classId: classId,
          admissionNumber: `WHY100/${ACADEMIC_YEAR.slice(0, 4)}/${String(rand(1000, 9999))}`,
        },
      });

      // Enroll in class
      await prisma.classEnrollment.upsert({
        where: { classId_studentId: { classId, studentId: student.id } },
        create: { classId, studentId: student.id },
        update: {},
      });
    }
    console.log(`   ✓ 5 students enrolled in ${classKey}`);
  }

  // ── Summary ──────────────────────────────────────────────────────────────────
  const [classes, students, staff, subjects] = await Promise.all([
    prisma.class.count({ where: { schoolId: SCHOOL_ID } }),
    prisma.student.count({ where: { schoolId: SCHOOL_ID } }),
    prisma.staff.count({ where: { schoolId: SCHOOL_ID } }),
    prisma.subject.count({ where: { schoolId: SCHOOL_ID } }),
  ]);

  console.log('\n✅ Seed complete!');
  console.log('─'.repeat(30));
  console.log(`   Classes:  ${classes}`);
  console.log(`   Students: ${students}`);
  console.log(`   Staff:    ${staff}`);
  console.log(`   Subjects: ${subjects}`);
  console.log('─'.repeat(30));
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
