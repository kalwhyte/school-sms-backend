import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';
import { CreateThreadDto, SendMessageDto } from './dto/messages.dto';

@Injectable()
export class MessagesService {
  private readonly logger = new Logger(MessagesService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService,
  ) {}

  // ─────────────────────────────────────────────
  // START THREAD (parent initiates)
  // Idempotent — returns existing thread if already exists
  // ─────────────────────────────────────────────
  async createThread(
    schoolId: string,
    callerUserId: string,
    dto: CreateThreadDto,
  ) {
    // Resolve caller's Parent record
    const parent = await this.prisma.parent.findFirst({
      where: { userId: callerUserId, schoolId },
      select: { id: true, fullName: true, userId: true },
    });
    if (!parent) {
      throw new ForbiddenException('Only parents can start message threads.');
    }

    // Verify teacher belongs to this school
    const teacher = await this.prisma.staff.findFirst({
      where: { id: dto.teacherId, schoolId },
      select: { id: true, fullName: true, userId: true },
    });
    if (!teacher)
      throw new NotFoundException('Teacher not found in this school.');

    // Verify student belongs to this school
    const student = await this.prisma.student.findFirst({
      where: { id: dto.studentId, schoolId },
      select: { id: true, fullName: true },
    });
    if (!student)
      throw new NotFoundException('Student not found in this school.');

    // Upsert thread — one thread per parent+teacher+student combination
    const thread = await this.prisma.messageThread.upsert({
      where: {
        parentId_teacherId_studentId: {
          parentId: parent.id,
          teacherId: dto.teacherId,
          studentId: dto.studentId,
        },
      },
      update: {}, // already exists — no update needed
      create: {
        schoolId,
        parentId: parent.id,
        teacherId: dto.teacherId,
        studentId: dto.studentId,
      },
      include: {
        parent: { select: { id: true, fullName: true } },
        teacher: { select: { id: true, fullName: true } },
        student: { select: { id: true, fullName: true } },
        messages: {
          orderBy: { sentAt: 'desc' },
          take: 1,
        },
      },
    });

    // Send the first message
    const message = await this.prisma.message.create({
      data: {
        threadId: thread.id,
        senderId: callerUserId,
        body: dto.firstMessage,
      },
    });

    // Notify the teacher
    this.notifyRecipient(
      teacher.userId,
      schoolId,
      parent.fullName,
      dto.firstMessage,
      thread.id,
    ).catch((err: unknown) => {
      this.logger.error(`Message notification failed: ${String(err)}`);
    });

    this.logger.log(
      `Thread created: parent ${parent.id} ↔ teacher ${dto.teacherId} re student ${dto.studentId}`,
    );

    return { thread, firstMessage: message };
  }

  // ─────────────────────────────────────────────
  // LIST THREADS — for current user
  // ─────────────────────────────────────────────
  async findThreads(
    schoolId: string,
    callerUserId: string,
    callerRole: string,
    query: { page?: number; limit?: number },
  ) {
    const page = Math.max(1, query.page ?? 1);
    const limit = Math.min(50, Math.max(1, query.limit ?? 20));
    const skip = (page - 1) * limit;

    // Build filter based on role
    const where = await this.buildThreadFilter(
      schoolId,
      callerUserId,
      callerRole,
    );

    const [threads, total] = await Promise.all([
      this.prisma.messageThread.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          parent: { select: { id: true, fullName: true } },
          teacher: { select: { id: true, fullName: true, photoUrl: true } },
          student: { select: { id: true, fullName: true } },
          messages: {
            orderBy: { sentAt: 'desc' },
            take: 1, // last message preview
            select: { body: true, sentAt: true, senderId: true, readAt: true },
          },
        },
      }),
      this.prisma.messageThread.count({ where }),
    ]);

    return {
      data: threads.map((t) => ({
        id: t.id,
        parent: t.parent,
        teacher: t.teacher,
        student: t.student,
        lastMessage: t.messages[0] ?? null,
        createdAt: t.createdAt,
      })),
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  // ─────────────────────────────────────────────
  // GET MESSAGES IN THREAD (paginated)
  // ─────────────────────────────────────────────
  async findMessages(
    schoolId: string,
    threadId: string,
    callerUserId: string,
    callerRole: string,
    query: { page?: number; limit?: number },
  ) {
    const page = Math.max(1, query.page ?? 1);
    const limit = Math.min(50, Math.max(1, query.limit ?? 20));
    const skip = (page - 1) * limit;

    const thread = await this.prisma.messageThread.findFirst({
      where: { id: threadId, schoolId },
      include: {
        parent: { select: { id: true, fullName: true, userId: true } },
        teacher: { select: { id: true, fullName: true, userId: true } },
        student: { select: { id: true, fullName: true } },
      },
    });
    if (!thread) throw new NotFoundException('Thread not found.');

    // Verify caller is a participant
    this.assertIsParticipant(thread, callerUserId, callerRole);

    const [messages, total] = await Promise.all([
      this.prisma.message.findMany({
        where: { threadId },
        skip,
        take: limit,
        orderBy: { sentAt: 'desc' },
        include: {
          sender: {
            select: {
              id: true,
              staff: { select: { fullName: true, photoUrl: true } },
              parent: { select: { fullName: true } },
            },
          },
        },
      }),
      this.prisma.message.count({ where: { threadId } }),
    ]);

    return {
      thread: {
        id: thread.id,
        parent: thread.parent,
        teacher: thread.teacher,
        student: thread.student,
      },
      data: messages.map((m) => ({
        id: m.id,
        body: m.body,
        sentAt: m.sentAt,
        readAt: m.readAt,
        senderId: m.senderId,
        senderName:
          m.sender.staff?.fullName ?? m.sender.parent?.fullName ?? 'Unknown',
        senderPhoto: m.sender.staff?.photoUrl ?? null,
        isOwn: m.senderId === callerUserId,
      })),
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  // ─────────────────────────────────────────────
  // SEND MESSAGE IN THREAD
  // ─────────────────────────────────────────────
  async sendMessage(
    schoolId: string,
    threadId: string,
    callerUserId: string,
    callerRole: string,
    dto: SendMessageDto,
  ) {
    // Students cannot send messages
    if (callerRole === 'student') {
      throw new ForbiddenException('Students cannot send messages.');
    }

    const thread = await this.prisma.messageThread.findFirst({
      where: { id: threadId, schoolId },
      include: {
        parent: { select: { id: true, fullName: true, userId: true } },
        teacher: { select: { id: true, fullName: true, userId: true } },
      },
    });
    if (!thread) throw new NotFoundException('Thread not found.');

    this.assertIsParticipant(thread, callerUserId, callerRole);

    const message = await this.prisma.message.create({
      data: {
        threadId,
        senderId: callerUserId,
        body: dto.body,
      },
    });

    // Notify the other participant
    const recipientUserId =
      callerUserId === thread.parent.userId
        ? thread.teacher.userId
        : thread.parent.userId;

    const senderName =
      callerUserId === thread.parent.userId
        ? thread.parent.fullName
        : thread.teacher.fullName;

    this.notifyRecipient(
      recipientUserId,
      schoolId,
      senderName,
      dto.body,
      threadId,
    ).catch((err: unknown) => {
      this.logger.error(`Message notification failed: ${String(err)}`);
    });

    return message;
  }

  // ─────────────────────────────────────────────
  // MARK THREAD AS READ — marks unread messages as read
  // ─────────────────────────────────────────────
  async markThreadRead(
    schoolId: string,
    threadId: string,
    callerUserId: string,
    callerRole: string,
  ) {
    const thread = await this.prisma.messageThread.findFirst({
      where: { id: threadId, schoolId },
      include: {
        parent: { select: { userId: true } },
        teacher: { select: { userId: true } },
      },
    });
    if (!thread) throw new NotFoundException('Thread not found.');

    this.assertIsParticipant(thread, callerUserId, callerRole);

    // Mark all messages NOT sent by caller as read
    const updated = await this.prisma.message.updateMany({
      where: {
        threadId,
        senderId: { not: callerUserId },
        readAt: null,
      },
      data: { readAt: new Date() },
    });

    return { marked: updated.count };
  }

  // ─────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────
  private async buildThreadFilter(
    schoolId: string,
    callerUserId: string,
    callerRole: string,
  ): Promise<Record<string, unknown>> {
    const base: Record<string, unknown> = { schoolId };

    if (callerRole === 'parent') {
      const parent = await this.prisma.parent.findFirst({
        where: { userId: callerUserId, schoolId },
        select: { id: true },
      });
      if (!parent) return { id: 'none' }; // no threads
      return { ...base, parentId: parent.id };
    }

    if (
      [
        'class_teacher',
        'subject_teacher',
        'admin',
        'principal',
        'vice_principal',
      ].includes(callerRole)
    ) {
      const staff = await this.prisma.staff.findFirst({
        where: { userId: callerUserId, schoolId },
        select: { id: true },
      });
      if (!staff) return { id: 'none' };
      return { ...base, teacherId: staff.id };
    }

    // Admin/principal sees all threads in school
    return base;
  }

  private assertIsParticipant(
    thread: {
      parent: { userId: string };
      teacher: { userId: string };
    },
    callerUserId: string,
    callerRole: string,
  ) {
    const isParent = thread.parent.userId === callerUserId;
    const isTeacher = thread.teacher.userId === callerUserId;
    const isAdmin = ['admin', 'principal', 'vice_principal'].includes(
      callerRole,
    );

    if (!isParent && !isTeacher && !isAdmin) {
      throw new ForbiddenException('You are not a participant in this thread.');
    }
  }

  private async notifyRecipient(
    recipientUserId: string,
    schoolId: string,
    senderName: string,
    messageBody: string,
    threadId: string,
  ) {
    if (!recipientUserId) return;
    const preview =
      messageBody.length > 60
        ? messageBody.substring(0, 60) + '...'
        : messageBody;

    await this.notificationsService.notify({
      userId: recipientUserId,
      schoolId,
      title: `New message from ${senderName}`,
      body: preview,
      type: 'message_received',
      payload: { threadId },
    });
  }
}
