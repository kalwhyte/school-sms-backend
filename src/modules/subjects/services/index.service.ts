import { Injectable } from '@nestjs/common';
import {
  BadRequestException,
  ConflictException,
  NotFoundException,
} from '@nestjs/common/exceptions';
import { SubjectRow, TimetablePeriodRow } from '../interfaces/index.interface';
import { PrismaService } from '../../../infrastructure/database/prisma.service';
import { DayOfWeek } from '@prisma/client';

@Injectable()
export class SubjectsHelperService {
  constructor(private prisma: PrismaService) {}

  // ─────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────

  async assertSubjectExists(schoolId: string, subjectId: string) {
    const s = await this.prisma.subject.findFirst({
      where: { id: subjectId, schoolId },
      select: { id: true },
    });
    if (!s) throw new NotFoundException('Subject not found.');
  }

  async assertStaffExists(schoolId: string, staffId: string) {
    const s = await this.prisma.staff.findFirst({
      where: { id: staffId, schoolId, isActive: true },
      select: { id: true },
    });
    if (!s)
      throw new NotFoundException(
        `Staff member ${staffId} not found in this school.`,
      );
  }

  assertEndAfterStart(start: string, end: string) {
    const [sh, sm] = start.split(':').map(Number);
    const [eh, em] = end.split(':').map(Number);
    if (eh * 60 + em <= sh * 60 + sm) {
      throw new BadRequestException('endTime must be after startTime.');
    }
  }

  async assertNoOverlap(
    classId: string,
    dayOfWeek: string,
    startTime: Date,
    endTime: Date,
  ) {
    // A period overlaps if existing.start < newEnd AND existing.end > newStart
    const overlap = await this.prisma.timetablePeriod.findFirst({
      where: {
        classId,
        dayOfWeek: dayOfWeek as DayOfWeek,
        startTime: { lt: endTime },
        endTime: { gt: startTime },
      },
    });
    if (overlap) {
      throw new ConflictException(
        'This time slot overlaps with an existing period for this class.',
      );
    }
  }

  // Prisma @db.Time stores time as a Date on epoch day — use 1970-01-01
  parseTime(hhmm: string): Date {
    const [h, m] = hhmm.split(':').map(Number);
    return new Date(Date.UTC(1970, 0, 1, h, m, 0));
  }

  subjectSelect() {
    return {
      id: true,
      schoolId: true,
      name: true,
      classId: true,
      isCore: true,
      createdAt: true,
      class: { select: { id: true, name: true, arm: true } },
      teacher: { select: { id: true, fullName: true, roleTitle: true } },
      _count: { select: { assessments: true } },
    } as const;
  }

  periodSelect() {
    return {
      id: true,
      classId: true,
      subjectId: true,
      dayOfWeek: true,
      startTime: true,
      endTime: true,
      subject: { select: { id: true, name: true } },
    } as const;
  }

  formatSubject(s: SubjectRow) {
    return {
      id: s.id,
      schoolId: s.schoolId,
      name: s.name,
      classId: s.classId,
      isCore: s.isCore,
      createdAt: s.createdAt,
      class: s.class,
      teacher: s.teacher ?? null,
      assessmentCount: s._count.assessments,
    };
  }

  formatPeriod(p: TimetablePeriodRow) {
    const fmt = (d: Date) =>
      `${String(d.getUTCHours()).padStart(2, '0')}:${String(d.getUTCMinutes()).padStart(2, '0')}`;
    return {
      id: p.id,
      classId: p.classId,
      subjectId: p.subjectId,
      dayOfWeek: p.dayOfWeek,
      startTime: fmt(p.startTime),
      endTime: fmt(p.endTime),
      subject: p.subject,
    };
  }
}
