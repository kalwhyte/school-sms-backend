import { Injectable, Logger } from '@nestjs/common';
import { AnnouncementAudience, UserRole } from '@prisma/client';
import { PrismaService } from '../../../infrastructure/database/prisma.service';
import { NotificationsService } from '../../notifications/notifications.service';

@Injectable()
export class AnnouncementsHelperService {
  private readonly logger = new Logger(AnnouncementsHelperService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService,
  ) {}
  // ─────────────────────────────────────────────
  // PRIVATE — resolve target users by audience
  // ─────────────────────────────────────────────
  async fanOutNotifications(announcement: {
    id: string;
    schoolId: string;
    title: string;
    body: string;
    audience: AnnouncementAudience;
    classId: string | null;
  }) {
    const targetUserIds = await this.resolveTargetUserIds(announcement);

    if (targetUserIds.length === 0) {
      this.logger.warn(
        `No target users found for announcement ${announcement.id}`,
      );
      return;
    }

    await this.notificationsService.notifyMany(targetUserIds, {
      schoolId: announcement.schoolId,
      title: announcement.title,
      body: announcement.body,
      type: 'announcement',
      payload: { announcementId: announcement.id },
    });

    // Bulk insert notifications
    // await this.prisma.notification.createMany({
    //   data: targetUserIds.map((userId) => ({
    //     userId,
    //     schoolId: announcement.schoolId,
    //     title: announcement.title,
    //     body: announcement.body,
    //     type: 'announcement',
    //     data: { announcementId: announcement.id },
    //     isSystem: false,
    //     isRead: false,
    //   })),
    //   skipDuplicates: true,
    // });

    this.logger.log(
      `Fanned out ${targetUserIds.length} notifications for announcement ${announcement.id}`,
    );
  }

  async resolveTargetUserIds(announcement: {
    schoolId: string;
    audience: AnnouncementAudience;
    classId: string | null;
  }): Promise<string[]> {
    const { schoolId, audience, classId } = announcement;

    switch (audience) {
      case AnnouncementAudience.all: {
        // All active users in the school
        const users = await this.prisma.user.findMany({
          where: { schoolId, isActive: true },
          select: { id: true },
        });
        return users.map((u) => u.id);
      }

      case AnnouncementAudience.parents: {
        // All users with role = parent in this school
        const users = await this.prisma.user.findMany({
          where: { schoolId, isActive: true, role: UserRole.parent },
          select: { id: true },
        });
        return users.map((u) => u.id);
      }

      case AnnouncementAudience.teachers: {
        // All users with teacher roles in this school
        const users = await this.prisma.user.findMany({
          where: {
            schoolId,
            isActive: true,
            role: {
              in: [
                UserRole.class_teacher,
                UserRole.subject_teacher,
                UserRole.admin,
                UserRole.principal,
                UserRole.vice_principal,
              ],
            },
          },
          select: { id: true },
        });
        return users.map((u) => u.id);
      }

      case AnnouncementAudience.class: {
        if (!classId) return [];
        // All students enrolled in this class + their parents
        const students = await this.prisma.student.findMany({
          where: { classId, schoolId, isActive: true },
          select: {
            userId: true,
            parents: {
              include: {
                parent: { select: { userId: true } },
              },
            },
          },
        });

        const userIds = new Set<string>();
        for (const student of students) {
          if (student.userId) userIds.add(student.userId);
          for (const ps of student.parents) {
            if (ps.parent.userId) userIds.add(ps.parent.userId);
          }
        }
        return Array.from(userIds);
      }

      default:
        return [];
    }
  }

  buildAudienceFilter(
    userRole: string,
    userClassId: string | null,
  ): Array<Record<string, unknown>> {
    // Everyone sees 'all' announcements
    const filters: Array<Record<string, unknown>> = [
      { audience: AnnouncementAudience.all },
    ];

    // Role-based filters
    if (userRole === 'parent') {
      filters.push({ audience: AnnouncementAudience.parents });
    }

    if (
      [
        'class_teacher',
        'subject_teacher',
        'admin',
        'principal',
        'vice_principal',
      ].includes(userRole)
    ) {
      filters.push({ audience: AnnouncementAudience.teachers });
    }

    // Class-specific announcements
    if (userClassId) {
      filters.push({
        audience: AnnouncementAudience.class,
        classId: userClassId,
      });
    }

    return filters;
  }
}
