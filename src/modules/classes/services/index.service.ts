import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../infrastructure/database/prisma.service';
import { ClassRow, FormattedClass } from '../interfaces/index.interface';

@Injectable()
export class ClassHelperService {
  constructor(private readonly prisma: PrismaService) {}

  // ─── Assertions ───────────────────────────────────────────────────────────

  async assertClassExists(schoolId: string, classId: string): Promise<void> {
    const cls = await this.prisma.class.findFirst({
      where: { id: classId, schoolId },
      select: { id: true },
    });
    if (!cls) throw new NotFoundException('Class not found.');
  }

  async validateStaff(schoolId: string, staffId: string): Promise<void> {
    const staff = await this.prisma.staff.findFirst({
      where: { id: staffId, schoolId, isActive: true },
      select: { id: true },
    });
    if (!staff) {
      throw new NotFoundException(
        `Staff member ${staffId} not found or inactive in this school.`,
      );
    }
  }

  // ─── Prisma select shape ──────────────────────────────────────────────────

  classSelect() {
    return {
      id: true,
      schoolId: true,
      name: true,
      arm: true,
      level: true,
      stream: true,
      academicYear: true,
      term: true,
      createdAt: true,
      classTeacher: {
        select: {
          id: true,
          fullName: true,
          roleTitle: true,
          photoUrl: true,
        },
      },
      _count: {
        select: {
          students: true,
          subjects: true,
        },
      },
    } as const;
  }

  // ─── Response formatter ───────────────────────────────────────────────────

  formatClass(cls: ClassRow): FormattedClass {
    return {
      id: cls.id,
      schoolId: cls.schoolId,
      name: cls.name,
      arm: cls.arm,
      level: cls.level,
      stream: cls.stream ?? null,
      academicYear: cls.academicYear,
      term: cls.term,
      createdAt: cls.createdAt,
      classTeacher: cls.classTeacher ?? null,
      studentCount: cls._count?.students ?? 0,
      subjectCount: cls._count?.subjects ?? 0,
    };
  }
}
