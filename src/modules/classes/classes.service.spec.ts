import { beforeEach, describe, expect, it, jest } from '@jest/globals';
import { Test, TestingModule } from '@nestjs/testing';
import {
  ConflictException,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';

import { ClassesService } from './classes.service';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { TermEnum } from './dto/create-classes.dto';

const mockPrisma = {
  class: {
    findUnique: jest.fn(),
    findFirst: jest.fn(),
    findMany: jest.fn(),
    count: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
  },
  staff: { findFirst: jest.fn() },
  classEnrollment: { count: jest.fn() },
};

const schoolId = 'school-uuid-001';
const classId = 'class-uuid-001';

const fakeClassRow = {
  id: classId,
  schoolId,
  name: 'JSS 1',
  arm: 'A',
  academicYear: '2024/2025',
  term: 'first',
  createdAt: new Date(),
  classTeacher: null,
  _count: { students: 0, subjects: 0 },
};

const createDto = {
  name: 'JSS 1',
  arm: 'A',
  academicYear: '2024/2025',
  term: TermEnum.first,
};

describe('ClassesService', () => {
  let service: ClassesService;

  beforeEach(async () => {
    jest.clearAllMocks();
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ClassesService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();
    service = module.get<ClassesService>(ClassesService);
  });

  describe('create', () => {
    it('creates a class and returns formatted result', async () => {
      mockPrisma.class.findUnique.mockResolvedValueOnce(null as any);
      mockPrisma.class.create.mockResolvedValueOnce(fakeClassRow as any);

      const result = await service.create(schoolId, createDto);
      expect(result.name).toBe('JSS 1');
      expect(result.studentCount).toBe(0);
    });

    it('throws ConflictException when class already exists', async () => {
      mockPrisma.class.findUnique.mockResolvedValueOnce(fakeClassRow as any);
      await expect(service.create(schoolId, createDto)).rejects.toThrow(
        ConflictException,
      );
    });

    it('validates teacherId exists in school', async () => {
      mockPrisma.class.findUnique.mockResolvedValueOnce(null as any);
      mockPrisma.staff.findFirst.mockResolvedValueOnce(null as any); // staff not found

      await expect(
        service.create(schoolId, { ...createDto, teacherId: 'ghost-staff' }),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('findAll', () => {
    it('returns paginated list', async () => {
      mockPrisma.class.findMany.mockResolvedValueOnce([fakeClassRow as any]);
      mockPrisma.class.count.mockResolvedValueOnce(1);

      const result = await service.findAll(schoolId, {});
      expect(result.data).toHaveLength(1);
      expect(result.meta.total).toBe(1);
    });
  });

  describe('remove', () => {
    it('blocks delete when students are enrolled', async () => {
      mockPrisma.class.findFirst.mockResolvedValueOnce({ id: classId });
      mockPrisma.classEnrollment.count.mockResolvedValueOnce(5);

      await expect(service.remove(schoolId, classId)).rejects.toThrow(
        BadRequestException,
      );
      expect(mockPrisma.class.delete).not.toHaveBeenCalled();
    });

    it('deletes class when no students enrolled', async () => {
      mockPrisma.class.findFirst.mockResolvedValueOnce({ id: classId });
      mockPrisma.classEnrollment.count.mockResolvedValueOnce(0);
      mockPrisma.class.delete.mockResolvedValueOnce({} as any);

      const result = await service.remove(schoolId, classId);
      expect(result.message).toContain('deleted');
    });
  });
});
