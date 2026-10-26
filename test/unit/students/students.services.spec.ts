import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException, ConflictException } from '@nestjs/common';
import { StudentsService } from '../../../src/modules/students/students.service';
import { PrismaService } from '../../../src/infrastructure/database/prisma.service';
import { StudentsHelperService } from '../../../src/modules/students/services/index.service';
import {
  CreateStudentDto,
  Gender,
} from '../../../src/modules/students/dto/create-students.dto';

// ─── fixtures ─────────────────────────────────────────────────────────────────

const SCHOOL_ID = 'school-001';
const STUDENT_ID = 'student-001';
const CLASS_ID = 'class-001';
const USER_ID = 'user-001';

const mockStudent = {
  id: STUDENT_ID,
  admissionNumber: 'GFA010/2026/0001',
  fullName: 'Emmanuel Tony',
  dob: new Date('2007-07-14'),
  gender: 'male',
  classId: CLASS_ID,
  guardianName: 'Mrs. Ngozi Okafor',
  photoUrl: null,
  isActive: true,
  schoolId: SCHOOL_ID,
  userId: USER_ID,
  createdAt: new Date(),
  updatedAt: new Date(),
  user: { phone: '+2348012345678', email: 'emeka@gmail.com', isActive: true },
  currentClass: { id: CLASS_ID, name: 'JSS 2' },
  enrollments: [],
  parents: [],
};

const mockUser = {
  id: USER_ID,
  schoolId: SCHOOL_ID,
  phone: '+2348012345678',
  email: 'emeka@gmail.com',
  isActive: true,
};

const formattedStudent = {
  id: STUDENT_ID,
  admissionNumber: 'GFA010/2026/0001',
  fullName: 'Emmanuel Tony',
  dateOfBirth: '2007-07-14',
  gender: 'male',
  phone: '+2348012345678',
  email: 'emeka@gmail.com',
  isActive: true,
};

// ─── mock factories ───────────────────────────────────────────────────────────

function buildPrismaMock() {
  return {
    class: { findFirst: jest.fn() },
    school: { findUnique: jest.fn() },
    user: { findFirst: jest.fn(), create: jest.fn(), update: jest.fn() },
    student: {
      create: jest.fn(),
      findMany: jest.fn(),
      findFirst: jest.fn(),
      count: jest.fn(),
      update: jest.fn(),
      updateMany: jest.fn(),
    },
    classEnrollment: {
      create: jest.fn(),
      deleteMany: jest.fn(),
    },
    $transaction: jest.fn(),
  };
}

function buildHelperMock() {
  return {
    generateAdmissionNumber: jest.fn().mockResolvedValue('GFA010/2026/0001'),
    formatStudent: jest.fn().mockReturnValue(formattedStudent),
  };
}

// ─── test suite ───────────────────────────────────────────────────────────────

describe('StudentsService', () => {
  let service: StudentsService;
  let prisma: ReturnType<typeof buildPrismaMock>;
  let helper: ReturnType<typeof buildHelperMock>;

  beforeEach(async () => {
    prisma = buildPrismaMock();
    helper = buildHelperMock();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        StudentsService,
        { provide: PrismaService, useValue: prisma },
        { provide: StudentsHelperService, useValue: helper },
      ],
    }).compile();

    service = module.get<StudentsService>(StudentsService);
  });

  // ─── create ───────────────────────────────────────────────────────────────

  describe('create', () => {
    const CreateStudentDto: CreateStudentDto = {
      fullName: 'Emmanuel Tony',
      classId: CLASS_ID,
      phone: '+2348012345678',
      email: 'emeka@gmail.com',
      dateOfBirth: '2007-07-14',
      gender: Gender.MALE,
      guardianName: 'Mrs. Ngozi Okafor',
    };

    beforeEach(() => {
      prisma.class.findFirst.mockResolvedValue({ id: CLASS_ID, name: 'JSS 2' });
      prisma.user.findFirst.mockResolvedValue(null); // no conflict
      prisma.school.findUnique.mockResolvedValue({ schoolCode: 'GFA010' });
      prisma.$transaction.mockImplementation(
        async (fn: (arg: any) => Promise<unknown>) =>
          await fn({
            user: { create: jest.fn().mockResolvedValue(mockUser) },
            student: { create: jest.fn().mockResolvedValue(mockStudent) },
            classEnrollment: { create: jest.fn() },
          } as any),
      );
    });

    it('should enrol a student and return formatted data', async () => {
      const result = await service.create(SCHOOL_ID, CreateStudentDto);

      expect(prisma.class.findFirst).toHaveBeenCalledWith({
        where: { id: CLASS_ID, schoolId: SCHOOL_ID },
        select: { id: true, name: true },
      });
      expect(helper.generateAdmissionNumber).toHaveBeenCalledWith(
        SCHOOL_ID,
        'GFA010',
      );
      expect(helper.formatStudent).toHaveBeenCalled();
      expect(result).toEqual(formattedStudent);
    });

    it('should throw NotFoundException when class does not belong to school', async () => {
      prisma.class.findFirst.mockResolvedValueOnce(null);

      await expect(service.create(SCHOOL_ID, CreateStudentDto)).rejects.toThrow(
        NotFoundException,
      );
      expect(prisma.$transaction).not.toHaveBeenCalled();
    });

    it('should throw ConflictException when phone is already registered in school', async () => {
      prisma.user.findFirst.mockResolvedValueOnce({ id: 'other-user' });

      await expect(service.create(SCHOOL_ID, CreateStudentDto)).rejects.toThrow(
        ConflictException,
      );
      expect(prisma.$transaction).not.toHaveBeenCalled();
    });

    it('should throw NotFoundException when school record does not exist', async () => {
      prisma.user.findFirst.mockResolvedValueOnce(null);
      prisma.school.findUnique.mockResolvedValueOnce(null);

      await expect(service.create(SCHOOL_ID, CreateStudentDto)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should skip phone conflict check when dto.phone is absent', async () => {
      const { ...dtoWithoutPhone } = CreateStudentDto;

      await service.create(SCHOOL_ID, dtoWithoutPhone);

      // user.findFirst is only called for phone check — should not be called
      expect(prisma.user.findFirst).not.toHaveBeenCalled();
    });
  });

  // ─── findAll ──────────────────────────────────────────────────────────────

  describe('findAll', () => {
    beforeEach(() => {
      prisma.student.findMany.mockResolvedValue([mockStudent]);
      prisma.student.count.mockResolvedValue(1);
    });

    it('should return paginated student list with correct meta', async () => {
      const result = await service.findAll(SCHOOL_ID, { page: 1, limit: 20 });

      expect(result.data).toHaveLength(1);
      expect(result.meta).toEqual({
        total: 1,
        page: 1,
        limit: 20,
        totalPages: 1,
      });
    });

    it('should default page to 1 and limit to 20', async () => {
      await service.findAll(SCHOOL_ID, {});

      const findManyCall = prisma.student.findMany.mock.calls[0] as [
        { skip: number; take: number },
      ];
      expect(findManyCall[0].skip).toBe(0);
      expect(findManyCall[0].take).toBe(20);
    });

    it('should cap limit at 100', async () => {
      await service.findAll(SCHOOL_ID, { limit: 999 });

      const [findManyCall] = prisma.student.findMany.mock.calls[0] as [
        { skip: number; take: number },
      ];
      expect(findManyCall[0].take).toBe(100);
    });

    it('should filter by classId when provided', async () => {
      await service.findAll(SCHOOL_ID, { classId: CLASS_ID });

      const [findManyCall] = prisma.student.findMany.mock.calls[0] as [
        { skip: number; take: number },
      ];
      expect(findManyCall[0].where.classId).toBe(CLASS_ID);
    });

    it('should filter by isActive when provided', async () => {
      await service.findAll(SCHOOL_ID, { isActive: false });

      const [findManyCall] = prisma.student.findMany.mock.calls[0] as [
        { skip: number; take: number },
      ];
      expect(findManyCall[0].where.isActive).toBe(false);
    });

    it('should apply search OR filter on fullName and admissionNumber', async () => {
      await service.findAll(SCHOOL_ID, { search: 'Emeka' });

      const [findManyCall] = prisma.student.findMany.mock.calls[0] as [
        { skip: number; take: number },
      ];
      expect(findManyCall[0].where.OR).toEqual([
        { fullName: { contains: 'Emeka', mode: 'insensitive' } },
        { admissionNumber: { contains: 'Emeka', mode: 'insensitive' } },
      ]);
    });

    it('should calculate totalPages correctly', async () => {
      prisma.student.count.mockResolvedValueOnce(45);

      const result = await service.findAll(SCHOOL_ID, { limit: 20 });

      expect(result.meta.totalPages).toBe(3); // ceil(45/20)
    });
  });

  // ─── findOne ──────────────────────────────────────────────────────────────

  describe('findOne', () => {
    it('should return a formatted student with history and parents', async () => {
      prisma.student.findFirst.mockResolvedValueOnce(mockStudent);

      const result = await service.findOne(SCHOOL_ID, STUDENT_ID);

      expect(prisma.student.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: STUDENT_ID, schoolId: SCHOOL_ID },
        }),
      );
      expect(result).toMatchObject(formattedStudent);
      expect(result.enrollmentHistory).toEqual([]);
      expect(result.parents).toEqual([]);
    });

    it('should throw NotFoundException when student is not found', async () => {
      prisma.student.findFirst.mockResolvedValueOnce(null);

      await expect(service.findOne(SCHOOL_ID, STUDENT_ID)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should map enrollmentHistory rows correctly', async () => {
      prisma.student.findFirst.mockResolvedValueOnce({
        ...mockStudent,
        enrollments: [
          {
            classId: CLASS_ID,
            class: { name: 'JSS 2', arm: 'A' },
            enrolledAt: new Date('2025-09-01'),
          },
        ],
      });

      const result = await service.findOne(SCHOOL_ID, STUDENT_ID);

      expect(result.enrollmentHistory[0]).toEqual({
        classId: CLASS_ID,
        className: 'JSS 2',
        enrolledAt: new Date('2025-09-01'),
      });
    });

    it('should map parent rows correctly', async () => {
      prisma.student.findFirst.mockResolvedValueOnce({
        ...mockStudent,
        parents: [
          {
            parentId: 'parent-001',
            parent: {
              fullName: 'Mrs. Ngozi Okafor',
              user: {
                phone: '+2348099999999',
                email: 'ngozi@gmail.com',
                isActive: true,
                lastLogin: null,
              },
            },
          },
        ],
      });

      const result = await service.findOne(SCHOOL_ID, STUDENT_ID);

      expect(result.parents[0]).toEqual({
        parentId: 'parent-001',
        fullName: 'Mrs. Ngozi Okafor',
        phone: '+2348099999999',
        email: 'ngozi@gmail.com',
        isActive: true,
        lastLogin: null,
      });
    });
  });

  // ─── update ───────────────────────────────────────────────────────────────

  describe('update', () => {
    const dto = { fullName: 'Emmanuel Updated', phone: '+2348099999999' };

    beforeEach(() => {
      prisma.student.findFirst.mockResolvedValue(mockStudent);
      prisma.user.findFirst.mockResolvedValue(null); // no phone conflict
      prisma.$transaction.mockImplementation(async (fn: any) =>
        fn({
          user: { update: jest.fn() },
          student: {
            update: jest.fn().mockResolvedValue({
              ...mockStudent,
              ...dto,
              user: mockStudent.user,
            }),
          },
        }),
      );
    });

    it('should update and return formatted student', async () => {
      const result = await service.update(SCHOOL_ID, STUDENT_ID, dto);

      expect(prisma.student.findFirst).toHaveBeenCalledWith({
        where: { id: STUDENT_ID, schoolId: SCHOOL_ID },
      });
      expect(helper.formatStudent).toHaveBeenCalled();
      expect(result).toEqual(formattedStudent);
    });

    it('should throw NotFoundException when student does not exist', async () => {
      prisma.student.findFirst.mockResolvedValueOnce(null);

      await expect(
        service.update(SCHOOL_ID, STUDENT_ID, dto as any),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw ConflictException when new phone is already taken', async () => {
      prisma.user.findFirst.mockResolvedValueOnce({ id: 'other-user' });

      await expect(
        service.update(SCHOOL_ID, STUDENT_ID, dto as any),
      ).rejects.toThrow(ConflictException);
      expect(prisma.$transaction).not.toHaveBeenCalled();
    });
  });

  // ─── deactivate ───────────────────────────────────────────────────────────

  describe('deactivate', () => {
    it('should soft-delete the student, user, and remove enrollment', async () => {
      prisma.student.findFirst.mockResolvedValueOnce(mockStudent);
      prisma.$transaction.mockResolvedValueOnce([]);

      await service.deactivate(SCHOOL_ID, STUDENT_ID);

      expect(prisma.$transaction).toHaveBeenCalledWith([
        expect.anything(), // student.update
        expect.anything(), // user.update
        expect.anything(), // classEnrollment.deleteMany
      ]);
    });

    it('should throw NotFoundException when student does not exist', async () => {
      prisma.student.findFirst.mockResolvedValueOnce(null);

      await expect(service.deactivate(SCHOOL_ID, STUDENT_ID)).rejects.toThrow(
        NotFoundException,
      );
      expect(prisma.$transaction).not.toHaveBeenCalled();
    });
  });

  // ─── bulkPromote ──────────────────────────────────────────────────────────

  describe('bulkPromote', () => {
    const TARGET_CLASS_ID = 'class-002';
    const dto = {
      studentIds: ['student-001', 'student-002'],
      targetClassId: TARGET_CLASS_ID,
    };

    it('should throw NotFoundException when target class is not in the school', async () => {
      prisma.class.findFirst.mockResolvedValueOnce(null);

      await expect(service.bulkPromote(SCHOOL_ID, dto as any)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should return promoted and failed counts', async () => {
      prisma.class.findFirst.mockResolvedValueOnce({
        id: TARGET_CLASS_ID,
        name: 'JSS 3',
      });

      // First student succeeds, second fails
      prisma.$transaction
        .mockImplementationOnce(async (fn: any) =>
          fn({
            student: {
              findFirst: jest.fn().mockResolvedValue(mockStudent),
              update: jest.fn(),
            },
            classEnrollment: { deleteMany: jest.fn(), create: jest.fn() },
          }),
        )
        .mockRejectedValueOnce(new Error('Student not found or inactive'));

      const result = await service.bulkPromote(SCHOOL_ID, dto);

      expect(result.promotedCount).toBe(1);
      expect(result.promotedIds).toContain('student-001');
      expect(result.failed).toHaveLength(1);
      expect(result.failed[0].id).toBe('student-002');
    });

    it('should return all promoted when every student succeeds', async () => {
      prisma.class.findFirst.mockResolvedValueOnce({
        id: TARGET_CLASS_ID,
        name: 'JSS 3',
      });

      prisma.$transaction.mockImplementation(async (fn: any) =>
        fn({
          student: {
            findFirst: jest.fn().mockResolvedValue(mockStudent),
            update: jest.fn(),
          },
          classEnrollment: { deleteMany: jest.fn(), create: jest.fn() },
        }),
      );

      const result = await service.bulkPromote(SCHOOL_ID, dto);

      expect(result.promotedCount).toBe(2);
      expect(result.failed).toHaveLength(0);
    });

    it('should report all as failed when every transaction throws', async () => {
      prisma.class.findFirst.mockResolvedValueOnce({
        id: TARGET_CLASS_ID,
        name: 'JSS 3',
      });
      prisma.$transaction.mockRejectedValue(new Error('DB error'));

      const result = await service.bulkPromote(SCHOOL_ID, dto);

      expect(result.promotedCount).toBe(0);
      expect(result.failed).toHaveLength(2);
    });
  });
});
