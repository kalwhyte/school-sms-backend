import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../infrastructure/database/prisma.service';
import { StaffRow } from '../interfaces/staffRow';

export interface FormattedStaff {
  id: string;
  userId: string;
  schoolId: string;
  fullName: string;
  roleTitle: string;
  subjectSpecialty: string | null;
  photoUrl: string | null;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
  phone: string;
  email: string | null;
  role: string;
  lastLogin: Date | null;
}

@Injectable()
export class StaffHelperService {
  constructor(private readonly prisma: PrismaService) {}

  // ─────────────────────────────────────────────
  // Reusable Prisma select shape
  // ─────────────────────────────────────────────

  staffSelect() {
    return {
      id: true,
      userId: true,
      schoolId: true,
      fullName: true,
      roleTitle: true,
      subjectSpecialty: true,
      photoUrl: true,
      isActive: true,
      createdAt: true,
      updatedAt: true,
      user: {
        select: {
          id: true,
          phone: true,
          email: true,
          role: true,
          isActive: true,
          lastLogin: true,
        },
      },
    } as const;
  }

  // ─────────────────────────────────────────────
  // Map DB row → API response shape
  // ─────────────────────────────────────────────

  formatStaff(staff: StaffRow): FormattedStaff {
    return {
      id: staff.id,
      userId: staff.userId,
      schoolId: staff.schoolId,
      fullName: staff.fullName,
      roleTitle: staff.roleTitle,
      subjectSpecialty: staff.subjectSpecialty,
      photoUrl: staff.photoUrl,
      isActive: staff.isActive,
      createdAt: staff.createdAt,
      updatedAt: staff.updatedAt,
      phone: staff.user.phone,
      email: staff.user.email,
      role: staff.user.role,
      lastLogin: staff.user.lastLogin,
    };
  }

  // ─────────────────────────────────────────────
  // Guard — throws 404 if staff doesn't exist in school
  // ─────────────────────────────────────────────

  async assertExists(schoolId: string, staffId: string): Promise<void> {
    const staff = await this.prisma.staff.findFirst({
      where: { id: staffId, schoolId },
      select: { id: true },
    });
    if (!staff) throw new NotFoundException('Staff member not found.');
  }
}
