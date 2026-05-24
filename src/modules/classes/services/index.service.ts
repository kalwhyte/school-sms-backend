import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../infrastructure/database/prisma.service';
import { ClassRow } from '../interfaces/index.interface';

@Injectable()
export class ClassHelperService {
  constructor(private readonly prisma: PrismaService) {}

  // ─────────────────────────────────────────────
  // PUBLIC HELPERS
  // ─────────────────────────────────────────────

  async assertClassExists(schoolId: string, classId: string) {
    const cls = await this.prisma.class.findFirst({
      where: { id: classId, schoolId },
      select: { id: true },
    });
    if (!cls) throw new NotFoundException('Class not found.');
  }

  async assertStaffExists(schoolId: string, staffId: string) {
    const staff = await this.prisma.staff.findFirst({
      where: { id: staffId, schoolId, isActive: true },
      select: { id: true },
    });
    if (!staff)
      throw new NotFoundException(
        `Staff member ${staffId} not found in this school.`,
      );
  }

  async validateStaff(schoolId: string, staffId: string): Promise<void> {
    await this.assertStaffExists(schoolId, staffId);
  }

  classSelect() {
    return {
      id: true,
      schoolId: true,
      name: true,
      arm: true,
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

  formatClass(cls: ClassRow) {
    return {
      id: cls.id,
      schoolId: cls.schoolId,
      name: cls.name,
      arm: cls.arm,
      academicYear: cls.academicYear,
      term: cls.term,
      createdAt: cls.createdAt,
      classTeacher: cls.classTeacher ?? null,
      studentCount: (cls._count as { students: number })?.students ?? 0,
      subjectCount: (cls._count as { subjects: number })?.subjects ?? 0,
    };
  }
}
