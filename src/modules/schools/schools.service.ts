import {
  Injectable,
  ConflictException,
  NotFoundException,
  Logger,
} from '@nestjs/common';
import * as crypto from 'crypto'; // Replaced bcrypt with Node.js's crypto module
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { StorageService } from '../../infrastructure/storage/storage.service';
import { OnboardSchoolDto } from './dto/onboard-school.dto';
import { UpdateSchoolDto } from './dto/update-schools.dto';
import { SchoolRow, SchoolWithStatsRow } from './interfaces/index.interface';

@Injectable()
export class SchoolsService {
  private readonly logger = new Logger(SchoolsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: StorageService,
  ) {}

  // ─────────────────────────────────────────────
  // ONBOARD — create school + first admin atomically
  // ─────────────────────────────────────────────

  async onboard(dto: OnboardSchoolDto) {
    const { school: schoolDto, admin } = dto;

    if (!schoolDto || !admin) {
      throw new ConflictException('School and admin details are required.');
    }

    // Guard: schoolCode must be globally unique
    const existing = await this.prisma.school.findUnique({
      where: { schoolCode: schoolDto.schoolCode },
    });
    if (existing) {
      throw new ConflictException(
        `School code "${schoolDto.schoolCode}" is already taken.`,
      );
    }
    console.log(existing);

    // IMPORTANT: Using crypto.createHash('sha256') is a less secure alternative to bcrypt for password hashing.
    // For production environments, it is highly recommended to install and use bcrypt or a similar robust password hashing library.
    const hashed = crypto
      .createHash('sha256')
      .update(admin.password!)
      .digest('hex');

    // Atomic: create School + User (admin) + Staff profile in one transaction
    const result = await this.prisma.$transaction(async (tx) => {
      const school = await tx.school.create({
        data: {
          name: schoolDto.name!,
          address: schoolDto.address!,
          schoolCode: schoolDto.schoolCode!,
          currency: schoolDto.currency ?? 'NGN',
          logoUrl: schoolDto.logoUrl ?? null,
        },
      });
      console.log(school);

      // Check phone not already used in this school (should be impossible for
      // first admin, but guards re-runs / retries)
      const existingUser = await tx.user.findUnique({
        where: {
          schoolId_phone: {
            schoolId: school.id,
            phone: admin.phone!,
          },
        },
      });
      if (existingUser) {
        throw new ConflictException(
          'A user with this phone number already exists in this school.',
        );
      }
      console.log(existingUser);

      const user = await tx.user.create({
        data: {
          schoolId: school.id,
          phone: admin.phone!,
          password: hashed,
          role: 'admin',
          isActive: true,
        },
      });
      console.log(user);

      const staff = await tx.staff.create({
        data: {
          userId: user.id,
          schoolId: school.id,
          fullName: admin.fullName!,
          roleTitle: admin.roleTitle ?? 'Administrator',
          isActive: true,
        },
      });
      console.log(staff);

      return { school, user, staff };
    });
    console.log(result);

    this.logger.log(
      `School onboarded: ${result.school.schoolCode} (id: ${result.school.id})`,
    );

    return {
      school: this.formatSchool(result.school),
      admin: {
        userId: result.user.id,
        phone: result.user.phone,
        role: result.user.role,
        fullName: result.staff.fullName,
      },
    };
  }

  // ─────────────────────────────────────────────
  // GET ONE
  // ─────────────────────────────────────────────

  async findOne(schoolId: string) {
    const school = (await this.prisma.school.findUnique({
      where: { id: schoolId },
      select: {
        id: true,
        name: true,
        address: true,
        logoUrl: true,
        schoolCode: true,
        subscriptionTier: true,
        currency: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
        _count: {
          select: {
            students: true,
            staff: true,
            users: true,
          },
        },
      },
    })) as SchoolWithStatsRow | null;

    if (!school || !school.isActive) {
      throw new NotFoundException('School not found.');
    }

    return this.formatSchoolWithStats(school);
  }

  // ─────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────

  async update(schoolId: string, dto: UpdateSchoolDto) {
    await this.assertExists(schoolId);

    const updated = (await this.prisma.school.update({
      where: { id: schoolId },
      data: {
        ...(dto.name !== undefined && { name: dto.name }),
        ...(dto.address !== undefined && { address: dto.address }),
        ...(dto.currency !== undefined && { currency: dto.currency }),
        ...(dto.logoUrl !== undefined && { logoUrl: dto.logoUrl }),
      },
      select: {
        id: true,
        name: true,
        address: true,
        logoUrl: true,
        schoolCode: true,
        subscriptionTier: true,
        currency: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    })) as SchoolRow;

    this.logger.log(`School updated: ${schoolId}`);
    return this.formatSchool(updated);
  }

  // ─────────────────────────────────────────────
  // UPLOAD LOGO
  // ─────────────────────────────────────────────

  async uploadLogo(schoolId: string, file: any) {
    await this.assertExists(schoolId);

    const uploadResult = await this.storage.uploadImage(file, {
      folder: `schools/${schoolId}/logo`,
      publicId: 'logo',
      overwrite: true,
      transformation: [{ width: 400, height: 400, crop: 'limit' }],
    });

    const updated = await this.prisma.school.update({
      where: { id: schoolId },
      data: { logoUrl: uploadResult.secure_url },
      select: { id: true, logoUrl: true },
    });

    return { logoUrl: updated.logoUrl };
  }

  // ─────────────────────────────────────────────
  // DEACTIVATE (soft delete)
  // ─────────────────────────────────────────────

  async deactivate(schoolId: string) {
    await this.assertExists(schoolId);

    await this.prisma.school.update({
      where: { id: schoolId },
      data: {
        isActive: false,
        deletedAt: new Date(),
      },
    });

    this.logger.warn(`School deactivated: ${schoolId}`);
    return { message: 'School deactivated.' };
  }

  // ─────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────

  private async assertExists(schoolId: string): Promise<void> {
    const school = await this.prisma.school.findUnique({
      where: { id: schoolId },
      select: { id: true, isActive: true },
    });
    if (!school || !school.isActive) {
      throw new NotFoundException('School not found.');
    }
  }

  private formatSchool(school: SchoolRow) {
    return {
      id: school.id,
      name: school.name,
      address: school.address,
      logoUrl: school.logoUrl,
      schoolCode: school.schoolCode,
      subscriptionTier: school.subscriptionTier,
      currency: school.currency,
      isActive: school.isActive,
      createdAt: school.createdAt,
      updatedAt: school.updatedAt,
    };
  }

  private formatSchoolWithStats(school: SchoolWithStatsRow) {
    return {
      ...this.formatSchool(school),
      stats: {
        totalStudents: school._count.students,
        totalStaff: school._count.staff,
        totalUsers: school._count.users,
      },
    };
  }
}
