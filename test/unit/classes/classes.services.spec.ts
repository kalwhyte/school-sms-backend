/* eslint-disable @typescript-eslint/no-unsafe-assignment */
// ─── classes.service.spec.ts ──────────────────────────────────────────────────
import { Test, TestingModule } from '@nestjs/testing';
import {
  ConflictException,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { ClassLevel, ClassStream, Term } from '@prisma/client';

import { ClassesService } from '../../../src/modules/classes/classes.service';
import { ClassHelperService } from '../../../src/modules/classes/services/index.service';
import { PrismaService } from '../../../src/infrastructure/database/prisma.service';

// ─── Shared fixtures ──────────────────────────────────────────────────────────

const SCHOOL_ID = 'school-uuid-001';
const CLASS_ID = 'class-uuid-001';
const STAFF_ID = 'staff-uuid-001';

const mockClassRow = {
  id: CLASS_ID,
  schoolId: SCHOOL_ID,
  name: 'JSS 1',
  arm: 'A',
  level: ClassLevel.jss1,
  stream: ClassStream.science,
  academicYear: '2024/2025',
  term: Term.first,
  createdAt: new Date('2024-09-01'),
  classTeacher: {
    id: STAFF_ID,
    fullName: 'Nosa Ade',
    roleTitle: 'Class Teacher',
    photoUrl: null,
  },
  _count: { students: 3, subjects: 5 },
};

const formattedClass = {
  id: CLASS_ID,
  schoolId: SCHOOL_ID,
  name: 'JSS 1',
  arm: 'A',
  level: ClassLevel.jss1,
  stream: ClassStream.science,
  academicYear: '2024/2025',
  term: Term.first,
  createdAt: new Date('2024-09-01'),
  classTeacher: mockClassRow.classTeacher,
  studentCount: 3,
  subjectCount: 5,
};

// ─── Prisma mock ──────────────────────────────────────────────────────────────

const prismaMock = {
  class: {
    findUnique: jest.fn(),
    findFirst: jest.fn(),
    findMany: jest.fn(),
    count: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
  },
  classEnrollment: {
    count: jest.fn(),
  },
};

// ─── Helper mock ─────────────────────────────────────────────────────────────

const helperMock = {
  assertClassExists: jest.fn(),
  validateStaff: jest.fn(),
  classSelect: jest.fn().mockReturnValue({}),
  formatClass: jest.fn().mockReturnValue(formattedClass),
};

// ─── Test suite ───────────────────────────────────────────────────────────────

describe('ClassesService', () => {
  let service: ClassesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ClassesService,
        { provide: PrismaService, useValue: prismaMock },
        { provide: ClassHelperService, useValue: helperMock },
      ],
    }).compile();

    service = module.get<ClassesService>(ClassesService);
    jest.clearAllMocks();
    // Default: formatClass always returns the formatted fixture
    helperMock.formatClass.mockReturnValue(formattedClass);
  });

  // ───────────────────────────────────────────────────────────────────────────
  // CREATE
  // ───────────────────────────────────────────────────────────────────────────

  describe('create', () => {
    const dto = {
      name: 'JSS 1',
      arm: 'A',
      level: ClassLevel.jss1,
      stream: ClassStream.science,
      academicYear: '2024/2025',
      term: Term.first,
      teacherId: STAFF_ID,
    };

    it('creates a class and returns formatted result', async () => {
      prismaMock.class.findUnique.mockResolvedValue(null);
      prismaMock.class.create.mockResolvedValue(mockClassRow);

      const result = await service.create(SCHOOL_ID, dto);

      expect(prismaMock.class.findUnique).toHaveBeenCalledWith(
        expect.objectContaining({
          where: {
            schoolId_name_arm_academicYear_term: {
              schoolId: SCHOOL_ID,
              name: dto.name,
              arm: dto.arm,
              academicYear: dto.academicYear,
              term: dto.term,
            },
          },
        }),
      );
      expect(helperMock.validateStaff).toHaveBeenCalledWith(
        SCHOOL_ID,
        STAFF_ID,
      );
      expect(prismaMock.class.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            schoolId: SCHOOL_ID,
            name: dto.name,
            arm: dto.arm,
            level: dto.level,
            stream: dto.stream,
            academicYear: dto.academicYear,
            term: dto.term,
            teacherId: dto.teacherId,
          }),
        }),
      );
      expect(result).toEqual(formattedClass);
    });

    it('creates a class without a teacher when teacherId is omitted', async () => {
      const dtoNoTeacher = { ...dto, teacherId: undefined };
      prismaMock.class.findUnique.mockResolvedValue(null);
      prismaMock.class.create.mockResolvedValue({
        ...mockClassRow,
        classTeacher: null,
      });

      await service.create(SCHOOL_ID, dtoNoTeacher);

      expect(helperMock.validateStaff).not.toHaveBeenCalled();
      expect(prismaMock.class.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ teacherId: null }),
        }),
      );
    });

    it('creates a class with null stream when stream is omitted', async () => {
      const dtoNoStream = { ...dto, stream: undefined };
      prismaMock.class.findUnique.mockResolvedValue(null);
      prismaMock.class.create.mockResolvedValue(mockClassRow);

      await service.create(SCHOOL_ID, dtoNoStream);

      expect(prismaMock.class.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ stream: null }),
        }),
      );
    });

    it('throws ConflictException when class already exists', async () => {
      prismaMock.class.findUnique.mockResolvedValue({ id: CLASS_ID });

      await expect(service.create(SCHOOL_ID, dto)).rejects.toThrow(
        ConflictException,
      );
      expect(prismaMock.class.create).not.toHaveBeenCalled();
    });

    it('throws NotFoundException when teacherId does not belong to school', async () => {
      prismaMock.class.findUnique.mockResolvedValue(null);
      helperMock.validateStaff.mockRejectedValue(new NotFoundException());

      await expect(service.create(SCHOOL_ID, dto)).rejects.toThrow(
        NotFoundException,
      );
      expect(prismaMock.class.create).not.toHaveBeenCalled();
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // FIND ALL
  // ───────────────────────────────────────────────────────────────────────────

  describe('findAll', () => {
    it('returns paginated list with correct meta', async () => {
      prismaMock.class.findMany.mockResolvedValue([mockClassRow] as never);
      prismaMock.class.count.mockResolvedValue(1);

      const result = await service.findAll(SCHOOL_ID, { page: 1, limit: 20 });

      expect(result.data).toHaveLength(1);
      expect(result.meta).toEqual({
        total: 1,
        page: 1,
        limit: 20,
        totalPages: 1,
      });
    });

    it('applies academicYear and term filters to the where clause', async () => {
      prismaMock.class.findMany.mockResolvedValue([]);
      prismaMock.class.count.mockResolvedValue(0);

      await service.findAll(SCHOOL_ID, {
        academicYear: '2024/2025',
        term: Term.first,
      });

      expect(prismaMock.class.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            schoolId: SCHOOL_ID,
            academicYear: '2024/2025',
            term: Term.first,
          }),
        }),
      );
    });

    it('applies level and stream filters', async () => {
      prismaMock.class.findMany.mockResolvedValue([]);
      prismaMock.class.count.mockResolvedValue(0);

      await service.findAll(SCHOOL_ID, {
        level: ClassLevel.ss1,
        stream: ClassStream.science,
      });

      expect(prismaMock.class.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            level: ClassLevel.ss1,
            stream: ClassStream.science,
          }),
        }),
      );
    });

    it('calculates skip correctly from page and limit', async () => {
      prismaMock.class.findMany.mockResolvedValue([]);
      prismaMock.class.count.mockResolvedValue(0);

      await service.findAll(SCHOOL_ID, { page: 3, limit: 10 });

      expect(prismaMock.class.findMany).toHaveBeenCalledWith(
        expect.objectContaining({ skip: 20, take: 10 }),
      );
    });

    it('returns empty data array when no classes found', async () => {
      prismaMock.class.findMany.mockResolvedValue([]);
      prismaMock.class.count.mockResolvedValue(0);

      const result = await service.findAll(SCHOOL_ID, {});

      expect(result.data).toEqual([]);
      expect(result.meta.total).toBe(0);
      expect(result.meta.totalPages).toBe(0);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // FIND ONE
  // ───────────────────────────────────────────────────────────────────────────

  describe('findOne', () => {
    it('returns a formatted class when found', async () => {
      prismaMock.class.findFirst.mockResolvedValue(mockClassRow);

      const result = await service.findOne(SCHOOL_ID, CLASS_ID);

      expect(prismaMock.class.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: CLASS_ID, schoolId: SCHOOL_ID },
        }),
      );
      expect(result).toEqual(formattedClass);
    });

    it('throws NotFoundException when class does not exist', async () => {
      prismaMock.class.findFirst.mockResolvedValue(null);

      await expect(service.findOne(SCHOOL_ID, CLASS_ID)).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // UPDATE
  // ───────────────────────────────────────────────────────────────────────────

  describe('update', () => {
    const updateDto = { name: 'JSS 2', arm: 'B' };

    beforeEach(() => {
      helperMock.assertClassExists.mockResolvedValue(undefined);
      prismaMock.class.findFirst.mockResolvedValue({
        name: 'JSS 1',
        arm: 'A',
        academicYear: '2024/2025',
        term: Term.first,
      });
      prismaMock.class.update.mockResolvedValue(mockClassRow);
    });

    it('updates and returns formatted class', async () => {
      prismaMock.class.findFirst
        // first call: get current record
        .mockResolvedValueOnce({
          name: 'JSS 1',
          arm: 'A',
          academicYear: '2024/2025',
          term: Term.first,
        })
        // second call: collision check → no collision
        .mockResolvedValueOnce(null);

      const result = await service.update(SCHOOL_ID, CLASS_ID, updateDto);

      expect(helperMock.assertClassExists).toHaveBeenCalledWith(
        SCHOOL_ID,
        CLASS_ID,
      );
      expect(prismaMock.class.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: CLASS_ID },
          data: expect.objectContaining({ name: 'JSS 2', arm: 'B' }),
        }),
      );
      expect(result).toEqual(formattedClass);
    });

    it('validates teacherId when provided', async () => {
      prismaMock.class.findFirst.mockResolvedValue(null); // no collision
      prismaMock.class.update.mockResolvedValue(mockClassRow);

      await service.update(SCHOOL_ID, CLASS_ID, { teacherId: STAFF_ID });

      expect(helperMock.validateStaff).toHaveBeenCalledWith(
        SCHOOL_ID,
        STAFF_ID,
      );
    });

    it('allows unsetting teacher by passing teacherId: null', async () => {
      prismaMock.class.update.mockResolvedValue({
        ...mockClassRow,
        classTeacher: null,
      });

      await service.update(SCHOOL_ID, CLASS_ID, { teacherId: null });

      expect(prismaMock.class.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ teacherId: null }),
        }),
      );
    });

    it('throws ConflictException when name/arm collision detected', async () => {
      prismaMock.class.findFirst
        .mockResolvedValueOnce({
          name: 'JSS 1',
          arm: 'A',
          academicYear: '2024/2025',
          term: Term.first,
        })
        .mockResolvedValueOnce({ id: 'other-class-id' }); // collision exists

      await expect(
        service.update(SCHOOL_ID, CLASS_ID, { name: 'JSS 2', arm: 'B' }),
      ).rejects.toThrow(ConflictException);

      expect(prismaMock.class.update).not.toHaveBeenCalled();
    });

    it('throws NotFoundException when class does not exist', async () => {
      helperMock.assertClassExists.mockRejectedValue(new NotFoundException());

      await expect(
        service.update(SCHOOL_ID, CLASS_ID, updateDto),
      ).rejects.toThrow(NotFoundException);
    });

    it('skips collision check when only stream is updated', async () => {
      await service.update(SCHOOL_ID, CLASS_ID, {
        stream: ClassStream.arts,
      });

      // findFirst should not be called for collision check (no name/arm change)
      expect(prismaMock.class.findFirst).not.toHaveBeenCalled();
      expect(prismaMock.class.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: { stream: ClassStream.arts },
        }),
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // REMOVE
  // ───────────────────────────────────────────────────────────────────────────

  describe('remove', () => {
    beforeEach(() => {
      helperMock.assertClassExists.mockResolvedValue(undefined);
    });

    it('deletes class and returns success message', async () => {
      prismaMock.classEnrollment.count.mockResolvedValue(0);
      prismaMock.class.delete.mockResolvedValue({ id: CLASS_ID });

      const result = await service.remove(SCHOOL_ID, CLASS_ID);

      expect(prismaMock.classEnrollment.count).toHaveBeenCalledWith({
        where: { classId: CLASS_ID },
      });
      expect(prismaMock.class.delete).toHaveBeenCalledWith({
        where: { id: CLASS_ID },
      });
      expect(result).toEqual({ message: 'Class deleted successfully.' });
    });

    it('throws BadRequestException when students are enrolled', async () => {
      prismaMock.classEnrollment.count.mockResolvedValue(12);

      await expect(service.remove(SCHOOL_ID, CLASS_ID)).rejects.toThrow(
        BadRequestException,
      );
      await expect(service.remove(SCHOOL_ID, CLASS_ID)).rejects.toThrow(
        /12 enrolled student/,
      );
      expect(prismaMock.class.delete).not.toHaveBeenCalled();
    });

    it('throws NotFoundException when class does not exist', async () => {
      helperMock.assertClassExists.mockRejectedValue(new NotFoundException());

      await expect(service.remove(SCHOOL_ID, CLASS_ID)).rejects.toThrow(
        NotFoundException,
      );
      expect(prismaMock.classEnrollment.count).not.toHaveBeenCalled();
      expect(prismaMock.class.delete).not.toHaveBeenCalled();
    });
  });
});
