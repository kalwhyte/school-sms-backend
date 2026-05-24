import {
  Injectable,
  NotFoundException,
  ConflictException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { UserQueryDto } from './dto/user-query.dto';
import { UpdateUserDto } from './dto/update-users.dto';
import { UserRow } from './interfaces/index.interface';
import { UsersHelperService } from './services/index.service';

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly helper: UsersHelperService,
  ) {}

  // ─────────────────────────────────────────────
  // GET CURRENT USER (me)
  // ─────────────────────────────────────────────

  async getMe(userId: string) {
    const user = (await this.prisma.user.findUnique({
      where: { id: userId },
      select: this.helper.userSelect(),
    })) as unknown as UserRow | null;

    if (!user) throw new NotFoundException('User not found.');
    return this.helper.formatUser(user);
  }

  // ─────────────────────────────────────────────
  // LIST — admin only
  // ─────────────────────────────────────────────

  async findAll(schoolId: string, query: UserQueryDto) {
    const { page = 1, limit = 20, role, isActive, phone } = query;
    const skip = (page - 1) * limit;

    const where = {
      schoolId,
      ...(role !== undefined && { role }),
      ...(isActive !== undefined && { isActive }),
      ...(phone && { phone: { contains: phone } }),
    };

    const [data, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: this.helper.userSelect(),
      }),
      this.prisma.user.count({ where }),
    ]);

    return {
      data: (data as unknown as UserRow[]).map((u) =>
        this.helper.formatUser(u),
      ),
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  // ─────────────────────────────────────────────
  // GET ONE — admin or self
  // ─────────────────────────────────────────────

  async findOne(schoolId: string, userId: string) {
    const user = (await this.prisma.user.findFirst({
      where: { id: userId, schoolId },
      select: this.helper.userSelect(),
    })) as unknown as UserRow | null;

    if (!user) throw new NotFoundException('User not found.');
    return this.helper.formatUser(user);
  }

  // ─────────────────────────────────────────────
  // UPDATE — admin updates any; user updates own phone/email only
  // ─────────────────────────────────────────────

  async update(
    schoolId: string,
    targetUserId: string,
    dto: UpdateUserDto,
    requesterId: string,
    requesterRole: string,
  ) {
    const isAdmin = requesterRole === 'admin';
    const isSelf = requesterId === targetUserId;

    if (!isAdmin && !isSelf) {
      throw new ForbiddenException('You can only update your own profile.');
    }

    // Non-admins cannot change role or isActive
    if (!isAdmin && (dto.role !== undefined || dto.isActive !== undefined)) {
      throw new ForbiddenException(
        'Only admins can change role or account status.',
      );
    }

    await this.helper.assertExists(schoolId, targetUserId);

    // Phone uniqueness guard within the school
    if (dto.phone) {
      const conflict = await this.prisma.user.findUnique({
        where: { schoolId_phone: { schoolId, phone: dto.phone } },
        select: { id: true },
      });
      if (conflict && conflict.id !== targetUserId) {
        throw new ConflictException(
          'This phone number is already registered in this school.',
        );
      }
    }

    const updated = (await this.prisma.user.update({
      where: { id: targetUserId },
      data: {
        ...(dto.phone !== undefined && { phone: dto.phone }),
        ...(dto.email !== undefined && { email: dto.email }),
        ...(dto.role !== undefined && { role: dto.role }),
        ...(dto.isActive !== undefined && { isActive: dto.isActive }),
      },
      select: this.helper.userSelect(),
    })) as unknown as UserRow;

    this.logger.log(`User updated: ${targetUserId} by ${requesterId}`);
    return this.helper.formatUser(updated);
  }

  // ─────────────────────────────────────────────
  // DEACTIVATE — admin only
  // ─────────────────────────────────────────────

  async deactivate(schoolId: string, userId: string, requesterId: string) {
    if (userId === requesterId) {
      throw new ForbiddenException('You cannot deactivate your own account.');
    }

    await this.helper.assertExists(schoolId, userId);
    await this.prisma.user.update({
      where: { id: userId },
      data: { isActive: false },
    });

    // Cascade: also deactivate Staff/Parent profile if present
    await this.prisma.staff.updateMany({
      where: { userId },
      data: { isActive: false },
    });

    this.logger.warn(`User deactivated: ${userId}`);
    return { message: 'User deactivated.' };
  }

  // ─────────────────────────────────────────────
  // REACTIVATE — admin only
  // ─────────────────────────────────────────────

  async reactivate(schoolId: string, userId: string) {
    await this.helper.assertExists(schoolId, userId, false); // pass false to check even inactive

    await this.prisma.user.update({
      where: { id: userId },
      data: { isActive: true },
    });

    await this.prisma.staff.updateMany({
      where: { userId },
      data: { isActive: true },
    });

    return { message: 'User reactivated.' };
  }
}
