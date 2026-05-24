import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../infrastructure/database/prisma.service';

@Injectable()
export class StudentsHelperService {
  constructor(private readonly prisma: PrismaService) {}

  // ─────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────

  async generateAdmissionNumber(
    schoolId: string,
    schoolCode: string,
  ): Promise<string> {
    const year = new Date().getFullYear();
    const prefix = `${schoolCode}/${year}/`;

    const count = await this.prisma.student.count({
      where: { schoolId, admissionNumber: { startsWith: prefix } },
    });

    const sequence = String(count + 1).padStart(4, '0');
    return `${prefix}${sequence}`;
  }

  formatStudent(
    student: {
      id: string;
      admissionNumber: string;
      fullName: string;
      dob: Date | null;
      gender: string | null;
      classId: string | null;
      guardianName: string | null;
      photoUrl: string | null;
      isActive: boolean;
      schoolId: string;
      userId: string | null;
      createdAt: Date;
      updatedAt: Date;
      currentClass?: { id: string; name: string } | null;
    },
    user: { phone: string | null; email: string | null } | null,
  ) {
    return {
      id: student.id,
      admissionNumber: student.admissionNumber,
      fullName: student.fullName,
      dateOfBirth: student.dob ? student.dob.toISOString().split('T')[0] : null,
      gender: student.gender,
      guardianName: student.guardianName,
      phone: user?.phone ?? null,
      email: user?.email ?? null,
      photoUrl: student.photoUrl,
      isActive: student.isActive,
      classId: student.classId,
      currentClass: student.currentClass ?? null,
      schoolId: student.schoolId,
      userId: student.userId,
      createdAt: student.createdAt,
      updatedAt: student.updatedAt,
    };
  }
}
