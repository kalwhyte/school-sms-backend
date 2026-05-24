import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { CreateAnnouncementDto } from './dto/announcements.dto';
import { AnnouncementAudience } from '@prisma/client';
import { AnnouncementsHelperService } from './services/index.service';

@Injectable()
export class AnnouncementsService {
  private readonly logger = new Logger(AnnouncementsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly helper: AnnouncementsHelperService,
  ) {}

  // ─────────────────────────────────────────────
  // CREATE + FAN-OUT NOTIFICATIONS
  // ─────────────────────────────────────────────
  async create(schoolId: string, authorId: string, dto: CreateAnnouncementDto) {
    // classId required when audience = class
    if (dto.audience === AnnouncementAudience.class && !dto.classId) {
      throw new BadRequestException(
        'classId is required when audience is "class".',
      );
    }

    // Verify class belongs to school if provided
    if (dto.classId) {
      const cls = await this.prisma.class.findFirst({
        where: { id: dto.classId, schoolId },
      });
      if (!cls) throw new NotFoundException('Class not found in this school.');
    }

    // 1. Create the announcement
    const announcement = await this.prisma.announcement.create({
      data: {
        schoolId,
        authorId,
        title: dto.title,
        body: dto.body,
        audience: dto.audience,
        classId: dto.classId ?? null,
      },
      include: {
        author: { select: { id: true } },
        class: { select: { id: true, name: true } },
      },
    });

    // 2. Fan-out notifications asynchronously — don't block the response
    this.helper.fanOutNotifications(announcement).catch((err: unknown) => {
      this.logger.error(
        `Fan-out failed for announcement ${announcement.id}: ${String(err)}`,
      );
    });

    this.logger.log(
      `Announcement "${dto.title}" created for audience "${dto.audience}" in school ${schoolId}`,
    );

    return announcement;
  }

  // ─────────────────────────────────────────────
  // LIST — scoped to user's role/audience
  // ─────────────────────────────────────────────
  async findAll(
    schoolId: string,
    callerUserId: string | null,
    userRole: string,
    query: { page?: number; limit?: number },
  ) {
    const page = Math.max(1, query.page ?? 1);
    const limit = Math.min(100, Math.max(1, query.limit ?? 20));
    const skip = (page - 1) * limit;

    let userClassId: string | null = null;

    if (userRole === 'student') {
      const student = await this.prisma.student.findFirst({
        where: { userId: callerUserId, schoolId },
        select: { classId: true },
      });
      userClassId = student?.classId ?? null;
    }
    // Build audience filter based on role
    const audienceFilter = this.helper.buildAudienceFilter(
      userRole,
      userClassId,
    );

    const [announcements, total] = await Promise.all([
      this.prisma.announcement.findMany({
        where: { schoolId, OR: audienceFilter },
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          author: { select: { id: true } },
          class: { select: { id: true, name: true } },
        },
      }),
      this.prisma.announcement.count({
        where: { schoolId, OR: audienceFilter },
      }),
    ]);

    return {
      data: announcements,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  // ─────────────────────────────────────────────
  // GET SINGLE
  // ─────────────────────────────────────────────
  async findOne(schoolId: string, announcementId: string) {
    const announcement = await this.prisma.announcement.findFirst({
      where: { id: announcementId, schoolId },
      include: {
        author: { select: { id: true } },
        class: { select: { id: true, name: true } },
      },
    });
    if (!announcement) throw new NotFoundException('Announcement not found.');
    return announcement;
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────
  async remove(schoolId: string, announcementId: string) {
    await this.findOne(schoolId, announcementId);
    await this.prisma.announcement.delete({ where: { id: announcementId } });
    this.logger.log(`Announcement ${announcementId} deleted`);
  }
}
