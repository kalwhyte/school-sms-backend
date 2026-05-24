import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import {
  CreateLeaveRequestDto,
  DecideLeaveRequestDto,
  LeaveRequestQueryDto,
} from './dto/leave-requests.dto';
import { NotificationsService } from '../notifications/notifications.service';
import { LeaveStatus } from '@prisma/client';

@Injectable()
export class LeaveRequestsService {
  private readonly logger = new Logger(LeaveRequestsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService,
  ) {}

  // ─────────────────────────────────────────────
  // SUBMIT LEAVE REQUEST (parent)
  // ─────────────────────────────────────────────
  async create(
    schoolId: string,
    submittedBy: string,
    dto: CreateLeaveRequestDto,
  ) {
    // Verify student belongs to school
    const student = await this.prisma.student.findFirst({
      where: { id: dto.studentId, schoolId },
      select: { id: true, fullName: true, classId: true },
    });
    if (!student) throw new NotFoundException('Student not found.');

    const fromDate = new Date(dto.fromDate);
    const toDate = new Date(dto.toDate);

    if (toDate < fromDate) {
      throw new BadRequestException('toDate cannot be before fromDate.');
    }

    // Check for overlapping pending/approved requests
    const overlap = await this.prisma.leaveRequest.findFirst({
      where: {
        studentId: dto.studentId,
        schoolId,
        status: { in: [LeaveStatus.pending, LeaveStatus.approved] },
        fromDate: { lte: toDate },
        toDate: { gte: fromDate },
      },
    });
    if (overlap) {
      throw new BadRequestException(
        `An overlapping leave request already exists (${overlap.fromDate.toISOString().slice(0, 10)} → ${overlap.toDate.toISOString().slice(0, 10)}).`,
      );
    }

    const leaveRequest = await this.prisma.leaveRequest.create({
      data: {
        studentId: dto.studentId,
        schoolId,
        submittedBy,
        reason: dto.reason,
        fromDate,
        toDate,
        status: LeaveStatus.pending,
      },
      include: {
        student: {
          select: { id: true, fullName: true, admissionNumber: true },
        },
        submitter: { select: { id: true } },
      },
    });

    // Notify class teacher
    if (student.classId) {
      const cls = await this.prisma.class.findUnique({
        where: { id: student.classId },
        select: { teacherId: true },
      });

      if (cls?.teacherId) {
        const staff = await this.prisma.staff.findUnique({
          where: { id: cls.teacherId },
          select: { userId: true },
        });

        if (staff?.userId) {
          await this.notificationsService.notify({
            userId: staff.userId,
            schoolId,
            title: '📋 Leave Request Submitted',
            body: `${student.fullName} has a pending leave request from ${dto.fromDate} to ${dto.toDate}.`,
            type: 'leave_request_submitted',
            payload: {
              leaveRequestId: leaveRequest.id,
              studentId: dto.studentId,
            },
          });
        }
      }
    }

    this.logger.log(
      `Leave request created: ${student.fullName} — ${dto.fromDate} to ${dto.toDate}`,
    );

    return leaveRequest;
  }

  // ─────────────────────────────────────────────
  // LIST LEAVE REQUESTS
  // ─────────────────────────────────────────────
  async findAll(schoolId: string, query: LeaveRequestQueryDto) {
    const page = Math.max(1, query.page ?? 1);
    const limit = Math.min(100, Math.max(1, query.limit ?? 20));
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = { schoolId };
    if (query.status) where.status = query.status;
    if (query.studentId) where.studentId = query.studentId;

    const [data, total] = await Promise.all([
      this.prisma.leaveRequest.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          student: {
            select: { id: true, fullName: true, admissionNumber: true },
          },
          submitter: { select: { id: true } },
          decider: { select: { id: true } },
        },
      }),
      this.prisma.leaveRequest.count({ where }),
    ]);

    return {
      data,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  // ─────────────────────────────────────────────
  // GET SINGLE
  // ─────────────────────────────────────────────
  async findOne(schoolId: string, leaveRequestId: string) {
    const lr = await this.prisma.leaveRequest.findFirst({
      where: { id: leaveRequestId, schoolId },
      include: {
        student: {
          select: {
            id: true,
            fullName: true,
            admissionNumber: true,
            currentClass: { select: { id: true, name: true, arm: true } },
          },
        },
        submitter: { select: { id: true } },
        decider: { select: { id: true } },
      },
    });
    if (!lr) throw new NotFoundException('Leave request not found.');
    return lr;
  }

  // ─────────────────────────────────────────────
  // DECIDE — approve or reject (admin / class teacher)
  // ─────────────────────────────────────────────
  async decide(
    schoolId: string,
    leaveRequestId: string,
    decidedBy: string,
    dto: DecideLeaveRequestDto,
  ) {
    const lr = await this.findOne(schoolId, leaveRequestId);

    if (lr.status !== LeaveStatus.pending) {
      throw new BadRequestException(
        `Leave request is already ${lr.status} — cannot change decision.`,
      );
    }

    if (dto.status === LeaveStatus.pending) {
      throw new BadRequestException('Decision must be approved or rejected.');
    }

    // Update the leave request
    const updated = await this.prisma.leaveRequest.update({
      where: { id: leaveRequestId },
      data: {
        status: dto.status,
        decisionNote: dto.decisionNote ?? null,
        decidedBy,
        decidedAt: new Date(),
      },
      include: {
        student: {
          select: { id: true, fullName: true, admissionNumber: true },
        },
      },
    });

    // On approval — auto-mark attendance as excused for date range
    if (dto.status === LeaveStatus.approved) {
      await this.markAttendanceExcused(lr);
    }

    // Notify parent/submitter
    await this.notifyDecision(updated, schoolId, dto.status);

    this.logger.log(
      `Leave request ${leaveRequestId} ${dto.status} by ${decidedBy}`,
    );

    return updated;
  }

  // ─────────────────────────────────────────────
  // PRIVATE — mark attendance excused for date range
  // ─────────────────────────────────────────────
  private async markAttendanceExcused(lr: {
    studentId: string;
    fromDate: Date;
    toDate: Date;
    reason: string;
  }) {
    // Get student's current class for attendance records
    const student = await this.prisma.student.findUnique({
      where: { id: lr.studentId },
      select: { classId: true },
    });
    if (!student?.classId) return;

    // Build array of weekday dates in the range
    const dates = getWeekdaysInRange(lr.fromDate, lr.toDate);
    if (dates.length === 0) return;

    // Upsert attendance for each date — idempotent
    const upserts = dates.map((date) =>
      this.prisma.attendance.upsert({
        where: { studentId_date: { studentId: lr.studentId, date } },
        update: {
          status: 'excused',
          reason: `Approved leave: ${lr.reason}`,
        },
        create: {
          studentId: lr.studentId,
          classId: student.classId!,
          date,
          status: 'excused',
          reason: `Approved leave: ${lr.reason}`,
        },
      }),
    );

    await this.prisma.$transaction(upserts);

    this.logger.log(
      `Marked ${dates.length} attendance record(s) as excused for student ${lr.studentId}`,
    );
  }

  // ─────────────────────────────────────────────
  // PRIVATE — notify parent of decision
  // ─────────────────────────────────────────────
  private async notifyDecision(
    lr: {
      id: string;
      studentId: string;
      submittedBy: string | null;
      student: { fullName: string };
      fromDate: Date;
      toDate: Date;
    },
    schoolId: string,
    status: LeaveStatus,
  ) {
    if (!lr.submittedBy) return;

    const emoji = status === LeaveStatus.approved ? '✅' : '❌';
    const label = status === LeaveStatus.approved ? 'Approved' : 'Rejected';

    await this.notificationsService.notify({
      userId: lr.submittedBy,
      schoolId,
      title: `${emoji} Leave Request ${label}`,
      body: `${lr.student.fullName}'s leave request (${lr.fromDate.toISOString().slice(0, 10)} → ${lr.toDate.toISOString().slice(0, 10)}) has been ${status}.`,
      type: 'leave_request_decided',
      payload: { leaveRequestId: lr.id, status },
    });
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function getWeekdaysInRange(from: Date, to: Date): Date[] {
  const dates: Date[] = [];
  const current = new Date(from);
  current.setHours(0, 0, 0, 0);
  const end = new Date(to);
  end.setHours(0, 0, 0, 0);

  while (current <= end) {
    const day = current.getDay();
    // Skip Saturday (6) and Sunday (0)
    if (day !== 0 && day !== 6) {
      dates.push(new Date(current));
    }
    current.setDate(current.getDate() + 1);
  }

  return dates;
}
