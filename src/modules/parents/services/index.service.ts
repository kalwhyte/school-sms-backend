import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../infrastructure/database/prisma.service';

type ParentRow = {
  id: string;
  userId: string;
  schoolId: string;
  fullName: string;
  phone: string | null;
  email: string | null;
  occupation: string | null;
  createdAt: Date;
  updatedAt: Date;
  user: { id: string; role: string; isActive: boolean; lastLogin: Date | null };
  students: Array<{
    relationship: string;
    student: { id: string; fullName: string; admissionNumber: string };
  }>;
};

@Injectable()
export class ParentsHelper {
  static parentSelect: any;
  static formatParent: any;
  static assertExists: any;
  constructor(private readonly prisma: PrismaService) {}

  // ─────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────

  async assertExists(schoolId: string, parentId: string) {
    const p = await this.prisma.parent.findFirst({
      where: { id: parentId, schoolId },
      select: { id: true },
    });
    if (!p) throw new NotFoundException('Parent not found.');
  }

  parentSelect() {
    return {
      id: true,
      userId: true,
      schoolId: true,
      fullName: true,
      phone: true,
      email: true,
      occupation: true,
      createdAt: true,
      updatedAt: true,
      user: {
        select: {
          id: true,
          role: true,
          isActive: true,
          lastLogin: true,
        },
      },
      students: {
        select: {
          relationship: true,
          student: {
            select: {
              id: true,
              fullName: true,
              admissionNumber: true,
            },
          },
        },
      },
    };
  }

  formatParent(parent: ParentRow) {
    return {
      id: parent.id,
      userId: parent.userId,
      schoolId: parent.schoolId,
      fullName: parent.fullName,
      phone: parent.phone,
      email: parent.email,
      occupation: parent.occupation,
      role: parent.user.role,
      isActive: parent.user.isActive,
      lastLogin: parent.user.lastLogin,
      createdAt: parent.createdAt,
      updatedAt: parent.updatedAt,
      students: parent.students.map((ps) => ({
        studentId: ps.student.id,
        fullName: ps.student.fullName,
        admissionNumber: ps.student.admissionNumber,
        relationship: ps.relationship,
      })),
    };
  }
}
