import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { Prisma } from '@prisma/client';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(private readonly prisma: PrismaService) {}

  // ─────────────────────────────────────────────
  // CREATE — single notification
  // ─────────────────────────────────────────────
  async notify(data: {
    userId: string;
    schoolId: string;
    title: string;
    body: string;
    type: string;
    payload?: Record<string, unknown>;
  }) {
    return this.prisma.notification.create({
      data: {
        userId: data.userId,
        schoolId: data.schoolId,
        title: data.title,
        body: data.body,
        type: data.type,
        data: (data.payload as object) ?? Prisma.JsonNull,
        isSystem: false,
        isRead: false,
      },
    });
  }

  // ─────────────────────────────────────────────
  // CREATE — bulk (fan-out)
  // ─────────────────────────────────────────────
  async notifyMany(
    userIds: string[],
    base: {
      schoolId: string;
      title: string;
      body: string;
      type: string;
      payload?: Record<string, unknown>;
    },
  ) {
    if (userIds.length === 0) return;
    await this.prisma.notification.createMany({
      data: userIds.map((userId) => ({
        userId,
        schoolId: base.schoolId,
        title: base.title,
        body: base.body,
        type: base.type,
        data: (base.payload as object) ?? Prisma.JsonNull,
        isSystem: false,
        isRead: false,
      })),
      skipDuplicates: true,
    });
    this.logger.log(
      `Fanned out ${userIds.length} notifications — type: ${base.type}`,
    );
  }
  // ─────────────────────────────────────────────
  // LIST — for current user
  // ─────────────────────────────────────────────
  async findAll(
    schoolId: string,
    userId: string,
    query: { page?: number; limit?: number; unreadOnly?: boolean },
  ) {
    const page = Math.max(1, query.page ?? 1);
    const limit = Math.min(100, Math.max(1, query.limit ?? 20));
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = { userId, schoolId };
    if (query.unreadOnly) where.isRead = false;

    const [notifications, total, unreadCount] = await Promise.all([
      this.prisma.notification.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.notification.count({ where }),
      this.prisma.notification.count({
        where: { userId, schoolId, isRead: false },
      }),
    ]);

    return {
      data: notifications,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        unreadCount,
      },
    };
  }

  // ─────────────────────────────────────────────
  // MARK SINGLE AS READ
  // ─────────────────────────────────────────────
  async markRead(schoolId: string, userId: string, notificationId: string) {
    const notification = await this.prisma.notification.findFirst({
      where: { id: notificationId, userId, schoolId },
    });
    if (!notification) throw new NotFoundException('Notification not found.');

    return this.prisma.notification.update({
      where: { id: notificationId },
      data: { isRead: true },
    });
  }

  // ─────────────────────────────────────────────
  // MARK ALL AS READ
  // ─────────────────────────────────────────────
  async markAllRead(schoolId: string, userId: string) {
    const updated = await this.prisma.notification.updateMany({
      where: { userId, schoolId, isRead: false },
      data: { isRead: true },
    });

    this.logger.log(
      `Marked ${updated.count} notifications as read for user ${userId}`,
    );
    return { marked: updated.count };
  }
}
