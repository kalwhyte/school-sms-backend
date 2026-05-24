import { Injectable } from '@nestjs/common';
import { NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../infrastructure/database/prisma.service';
import { UserRow } from '../interfaces/index.interface';

@Injectable()
export class UsersHelperService {
  constructor(private readonly prisma: PrismaService) {}

  // ─────────────────────────────────────────────
  // PUBLIC HELPERS
  // ─────────────────────────────────────────────

  async assertExists(
    schoolId: string,
    userId: string,
    mustBeActive = true,
  ): Promise<void> {
    const user = await this.prisma.user.findFirst({
      where: {
        id: userId,
        schoolId,
        ...(mustBeActive && { isActive: true }),
      },
      select: { id: true },
    });
    if (!user) throw new NotFoundException('User not found.');
  }

  userSelect() {
    return {
      id: true,
      schoolId: true,
      phone: true,
      email: true,
      role: true,
      isActive: true,
      lastLogin: true,
      createdAt: true,
      updatedAt: true,
      staff: {
        select: {
          id: true,
          fullName: true,
          roleTitle: true,
          photoUrl: true,
        },
      },
      parent: {
        select: {
          id: true,
          fullName: true,
          occupation: true,
        },
      },
      student: {
        select: {
          id: true,
          fullName: true,
          admissionNumber: true,
        },
      },
    } as const;
  }

  formatUser(user: UserRow) {
    // Resolve display name + profile id from whichever relation is populated
    const profile = user.staff ?? user.parent ?? user.student ?? null;
    const fullName = profile
      ? 'fullName' in profile
        ? profile.fullName
        : ''
      : '';

    const photoUrl = user.staff?.photoUrl ?? null;

    return {
      id: user.id,
      schoolId: user.schoolId,
      phone: user.phone,
      email: user.email,
      role: user.role,
      isActive: user.isActive,
      lastLogin: user.lastLogin,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      fullName,
      photoUrl,
      profile: profile ?? null,
    };
  }
}
