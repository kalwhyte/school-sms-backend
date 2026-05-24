import {
  Injectable,
  ConflictException,
  NotFoundException,
  Logger,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { StorageService } from '../../infrastructure/storage/storage.service';
import type { MulterFile } from '../../infrastructure/storage/storage.service';
import { StaffHelperService } from './services/index.service';
import { CreateStaffDto } from './dto/create-staff.dto';
import { UpdateStaffDto } from './dto/update-staff.dto';
import { StaffQueryDto } from './dto/staff-query.dto';
import { StaffRow } from './interfaces/staffRow';
import { ALLOWED_STAFF_ROLES, StaffRole } from './guards/roles.guard';

@Injectable()
export class StaffService {
  private readonly logger = new Logger(StaffService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: StorageService,
    private readonly helper: StaffHelperService,
  ) {}

  async create(schoolId: string, dto: CreateStaffDto) {
    if (!ALLOWED_STAFF_ROLES.includes(dto.role as StaffRole)) {
      throw new BadRequestException(
        `role must be one of: ${ALLOWED_STAFF_ROLES.join(', ')}`,
      );
    }

    const existingUser = await this.prisma.user.findUnique({
      where: { schoolId_phone: { schoolId, phone: dto.phone! } },
    });
    if (existingUser) {
      throw new ConflictException(
        'A user with this phone number already exists in this school.',
      );
    }

    const result = await this.prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          schoolId,
          phone: dto.phone!,
          role: dto.role as StaffRole,
          isActive: true,
        },
      });

      const staff = await tx.staff.create({
        data: {
          userId: user.id,
          schoolId,
          fullName: dto.fullName!,
          roleTitle: dto.roleTitle!,
          subjectSpecialty: dto.subjectSpecialty ?? null,
          photoUrl: dto.photoUrl ?? null,
          isActive: true,
        },
        select: this.helper.staffSelect(),
      });

      return staff;
    });

    this.logger.log(`Staff created: ${result.id} in school ${schoolId}`);
    return this.helper.formatStaff(result);
  }

  async findAll(schoolId: string, query: StaffQueryDto) {
    const { page = 1, limit = 20, search, role, isActive } = query;
    const skip = (page - 1) * limit;

    const where = {
      schoolId,
      ...(isActive !== undefined && { isActive }),
      ...(role && { user: { role: role as StaffRole } }),
      ...(search && {
        fullName: { contains: search, mode: 'insensitive' as const },
      }),
    };

    const [data, total] = await Promise.all([
      this.prisma.staff.findMany({
        where,
        skip,
        take: limit,
        orderBy: { fullName: 'asc' },
        select: this.helper.staffSelect(),
      }),
      this.prisma.staff.count({ where }),
    ]);

    return {
      data: (data as unknown as StaffRow[]).map((s) =>
        this.helper.formatStaff(s),
      ),
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(schoolId: string, staffId: string) {
    const staff = (await this.prisma.staff.findFirst({
      where: { id: staffId, schoolId },
      select: this.helper.staffSelect(),
    })) as unknown as StaffRow | null;

    if (!staff) throw new NotFoundException('Staff member not found.');
    return this.helper.formatStaff(staff);
  }

  async update(schoolId: string, staffId: string, dto: UpdateStaffDto) {
    await this.helper.assertExists(schoolId, staffId);

    if (dto.role && !ALLOWED_STAFF_ROLES.includes(dto.role as StaffRole)) {
      throw new BadRequestException(
        `role must be one of: ${ALLOWED_STAFF_ROLES.join(', ')}`,
      );
    }

    const updated = await this.prisma.$transaction(async (tx) => {
      const staff = await tx.staff.update({
        where: { id: staffId },
        data: {
          ...(dto.fullName !== undefined && { fullName: dto.fullName }),
          ...(dto.roleTitle !== undefined && { roleTitle: dto.roleTitle }),
          ...(dto.subjectSpecialty !== undefined && {
            subjectSpecialty: dto.subjectSpecialty,
          }),
          ...(dto.photoUrl !== undefined && { photoUrl: dto.photoUrl }),
        },
        select: this.helper.staffSelect(),
      });

      if (dto.role) {
        await tx.user.update({
          where: { id: (staff as unknown as StaffRow).user.id },
          data: { role: dto.role as StaffRole },
        });
      }

      return staff;
    });

    this.logger.log(`Staff updated: ${staffId}`);
    return this.helper.formatStaff(updated);
  }

  async uploadPhoto(schoolId: string, staffId: string, file: MulterFile) {
    await this.helper.assertExists(schoolId, staffId);

    const uploadResult = await this.storage.uploadImage(file, {
      folder: `schools/${schoolId}/staff`,
      publicId: staffId,
      overwrite: true,
      transformation: [
        { width: 400, height: 400, crop: 'fill', gravity: 'face' },
      ],
    });

    const updated = await this.prisma.staff.update({
      where: { id: staffId },
      data: { photoUrl: uploadResult.secure_url },
      select: { id: true, photoUrl: true },
    });

    return { photoUrl: updated.photoUrl };
  }

  async remove(schoolId: string, staffId: string) {
    await this.helper.assertExists(schoolId, staffId);

    const staff = await this.prisma.staff.findFirst({
      where: { id: staffId, schoolId },
      select: { userId: true },
    });

    await this.prisma.$transaction([
      this.prisma.staff.update({
        where: { id: staffId },
        data: { isActive: false },
      }),
      this.prisma.user.update({
        where: { id: staff!.userId },
        data: { isActive: false },
      }),
    ]);

    this.logger.log(`Staff deactivated: ${staffId}`);
    return { message: 'Staff member deactivated.' };
  }
}
