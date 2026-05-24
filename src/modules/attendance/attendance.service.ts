// import { Injectable, NotFoundException, Logger } from '@nestjs/common';
// import { PrismaService } from '../../infrastructure/database/prisma.service';
// import { BulkAttendanceDto } from './dto/attendanceEntry.dto';

// @Injectable()
// export class AttendanceService {
//   private readonly logger = new Logger(AttendanceService.name);

//   constructor(private readonly prisma: PrismaService) {}

//   // ─────────────────────────────────────────────
//   // BULK SUBMIT (idempotent — upsert per student+date)
//   // ─────────────────────────────────────────────
//   async bulkSubmit(
//     schoolId: string,
//     recordedByUserId: string,
//     dto: BulkAttendanceDto,
//   ) {
//     // Verify class belongs to school
//     const cls = await this.prisma.class.findFirst({
//       where: { id: dto.classId, schoolId },
//       select: { id: true, name: true },
//     });
//     if (!cls) throw new NotFoundException('Class not found in this school.');

//     const date = new Date(dto.date);

//     // Upsert each record — idempotent, re-submitting same date+student overwrites
//     const upserts = dto.records.map((entry) =>
//       this.prisma.attendance.upsert({
//         where: {
//           studentId_date: {
//             studentId: entry.studentId,
//             date,
//           },
//         },
//         update: {
//           status: entry.status!,
//           reason: entry.reason ?? null,
//           recordedBy: recordedByUserId,
//           recordedAt: new Date(),
//         },
//         create: {
//           studentId: entry.studentId,
//           classId: dto.classId,
//           date,
//           status: entry.status!,
//           reason: entry.reason ?? null,
//           recordedBy: recordedByUserId,
//         },
//       }),
//     );

//     const results = await this.prisma.$transaction(upserts);

//     this.logger.log(
//       `Attendance submitted for class ${dto.classId} on ${dto.date} — ${results.length} records`,
//     );

//     return {
//       date: dto.date,
//       classId: dto.classId,
//       submitted: results.length,
//       summary: {
//         present: results.filter((r) => r.status === 'present').length,
//         absent: results.filter((r) => r.status === 'absent').length,
//         late: results.filter((r) => r.status === 'late').length,
//       },
//     };
//   }

//   // ─────────────────────────────────────────────
//   // GET BY CLASS — for a single date or date range
//   // ─────────────────────────────────────────────
//   async findByClass(
//     schoolId: string,
//     classId: string,
//     query: { date?: string; from?: string; to?: string },
//   ) {
//     // Verify class belongs to school
//     const cls = await this.prisma.class.findFirst({
//       where: { id: classId, schoolId },
//       select: { id: true, name: true },
//     });
//     if (!cls) throw new NotFoundException('Class not found in this school.');

//     // Build date filter
//     let dateFilter: Record<string, unknown> = {};
//     if (query.date) {
//       dateFilter = { date: new Date(query.date) };
//     } else if (query.from || query.to) {
//       dateFilter = {
//         date: {
//           ...(query.from && { gte: new Date(query.from) }),
//           ...(query.to && { lte: new Date(query.to) }),
//         },
//       };
//     }

//     const records = await this.prisma.attendance.findMany({
//       where: { classId, ...dateFilter },
//       orderBy: [{ date: 'desc' }, { student: { fullName: 'asc' } }],
//       include: {
//         student: {
//           select: { id: true, fullName: true, admissionNumber: true },
//         },
//       },
//     });

//     // Group by date for easy consumption on the frontend
//     const grouped = records.reduce<
//       Record<
//         string,
//         {
//           date: string;
//           classId: string;
//           className: string;
//           records: typeof records;
//           summary: {
//             present: number;
//             absent: number;
//             late: number;
//             total: number;
//           };
//         }
//       >
//     >((acc, r) => {
//       const key = r.date.toISOString().split('T')[0];
//       if (!acc[key]) {
//         acc[key] = {
//           date: key,
//           classId,
//           className: cls.name,
//           records: [],
//           summary: { present: 0, absent: 0, late: 0, total: 0 },
//         };
//       }
//       acc[key].records.push(r);
//       acc[key].summary[r.status] += 1;
//       acc[key].summary.total += 1;
//       return acc;
//     }, {});

//     return Object.values(grouped);
//   }

//   // ─────────────────────────────────────────────
//   // GET STUDENT SUMMARY — counts per status
//   // ─────────────────────────────────────────────
//   async getStudentSummary(
//     schoolId: string,
//     studentId: string,
//     query: { from?: string; to?: string },
//   ) {
//     // Verify student belongs to school
//     const student = await this.prisma.student.findFirst({
//       where: { id: studentId, schoolId },
//       select: { id: true, fullName: true, admissionNumber: true },
//     });
//     if (!student) throw new NotFoundException('Student not found.');

//     const dateFilter: Record<string, unknown> = {};
//     if (query.from || query.to) {
//       dateFilter.date = {
//         ...(query.from && { gte: new Date(query.from) }),
//         ...(query.to && { lte: new Date(query.to) }),
//       };
//     }

//     const [present, absent, late] = await Promise.all([
//       this.prisma.attendance.count({
//         where: { studentId, status: 'present', ...dateFilter },
//       }),
//       this.prisma.attendance.count({
//         where: { studentId, status: 'absent', ...dateFilter },
//       }),
//       this.prisma.attendance.count({
//         where: { studentId, status: 'late', ...dateFilter },
//       }),
//     ]);

//     const total = present + absent + late;
//     const attendancePercentage =
//       total > 0 ? Math.round(((present + late) / total) * 100 * 100) / 100 : 0;

//     return {
//       student,
//       summary: {
//         present,
//         absent,
//         late,
//         total,
//         attendancePercentage,
//       },
//       ...(query.from && { from: query.from }),
//       ...(query.to && { to: query.to }),
//     };
//   }
// }

import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { BulkAttendanceDto } from './dto/attendanceEntry.dto';
import { NotificationsService } from '../notifications/notifications.service';
import { AttendanceStatus } from '@prisma/client';

@Injectable()
export class AttendanceService {
  private readonly logger = new Logger(AttendanceService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly notificationsService: NotificationsService,
  ) {}

  async bulkSubmit(
    schoolId: string,
    recordedByUserId: string,
    dto: BulkAttendanceDto,
  ) {
    const cls = await this.prisma.class.findFirst({
      where: { id: dto.classId, schoolId },
      select: { id: true, name: true },
    });
    if (!cls) throw new NotFoundException('Class not found in this school.');

    const date = new Date(dto.date);

    const upserts = dto.records.map((entry) =>
      this.prisma.attendance.upsert({
        where: { studentId_date: { studentId: entry.studentId, date } },
        update: {
          status: entry.status!,
          reason: entry.reason ?? null,
          recordedBy: recordedByUserId,
          recordedAt: new Date(),
        },
        create: {
          studentId: entry.studentId,
          classId: dto.classId,
          date,
          status: entry.status!,
          reason: entry.reason ?? null,
          recordedBy: recordedByUserId,
        },
      }),
    );

    const results = await this.prisma.$transaction(upserts);

    this.logger.log(
      `Attendance submitted for class ${dto.classId} on ${dto.date} — ${results.length} records`,
    );

    // ── Notify parents of absent students (fire and forget) ──────────────────
    const absentStudentIds = dto.records
      .filter((r) => r.status === AttendanceStatus.absent)
      .map((r) => r.studentId);

    if (absentStudentIds.length > 0) {
      this.notifyAbsentParents(
        schoolId,
        absentStudentIds,
        dto.date,
        cls.name,
      ).catch((err: unknown) => {
        this.logger.error(`Absent notification fan-out failed: ${String(err)}`);
      });
    }

    return {
      date: dto.date,
      classId: dto.classId,
      submitted: results.length,
      summary: {
        present: results.filter((r) => r.status === 'present').length,
        absent: results.filter((r) => r.status === 'absent').length,
        late: results.filter((r) => r.status === 'late').length,
      },
    };
  }

  async findByClass(
    schoolId: string,
    classId: string,
    query: { date?: string; from?: string; to?: string },
  ) {
    const cls = await this.prisma.class.findFirst({
      where: { id: classId, schoolId },
      select: { id: true, name: true },
    });
    if (!cls) throw new NotFoundException('Class not found in this school.');

    let dateFilter: Record<string, unknown> = {};
    if (query.date) {
      dateFilter = { date: new Date(query.date) };
    } else if (query.from || query.to) {
      dateFilter = {
        date: {
          ...(query.from && { gte: new Date(query.from) }),
          ...(query.to && { lte: new Date(query.to) }),
        },
      };
    }

    const records = await this.prisma.attendance.findMany({
      where: { classId, ...dateFilter },
      orderBy: [{ date: 'desc' }, { student: { fullName: 'asc' } }],
      include: {
        student: {
          select: { id: true, fullName: true, admissionNumber: true },
        },
      },
    });

    const grouped = records.reduce<
      Record<
        string,
        {
          date: string;
          classId: string;
          className: string;
          records: typeof records;
          summary: {
            present: number;
            absent: number;
            late: number;
            total: number;
          };
        }
      >
    >((acc, r) => {
      const key = r.date.toISOString().split('T')[0];
      if (!acc[key]) {
        acc[key] = {
          date: key,
          classId,
          className: cls.name,
          records: [],
          summary: { present: 0, absent: 0, late: 0, total: 0 },
        };
      }
      acc[key].records.push(r);
      acc[key].summary[r.status as 'present' | 'absent' | 'late'] += 1;
      acc[key].summary.total += 1;
      return acc;
    }, {});

    return Object.values(grouped);
  }

  async getStudentSummary(
    schoolId: string,
    studentId: string,
    query: { from?: string; to?: string },
  ) {
    const student = await this.prisma.student.findFirst({
      where: { id: studentId, schoolId },
      select: { id: true, fullName: true, admissionNumber: true },
    });
    if (!student) throw new NotFoundException('Student not found.');

    const dateFilter: Record<string, unknown> = {};
    if (query.from || query.to) {
      dateFilter.date = {
        ...(query.from && { gte: new Date(query.from) }),
        ...(query.to && { lte: new Date(query.to) }),
      };
    }

    const [present, absent, late] = await Promise.all([
      this.prisma.attendance.count({
        where: { studentId, status: 'present', ...dateFilter },
      }),
      this.prisma.attendance.count({
        where: { studentId, status: 'absent', ...dateFilter },
      }),
      this.prisma.attendance.count({
        where: { studentId, status: 'late', ...dateFilter },
      }),
    ]);

    const total = present + absent + late;
    const attendancePercentage =
      total > 0 ? Math.round(((present + late) / total) * 100 * 100) / 100 : 0;

    return {
      student,
      summary: { present, absent, late, total, attendancePercentage },
      ...(query.from && { from: query.from }),
      ...(query.to && { to: query.to }),
    };
  }

  // ─────────────────────────────────────────────
  // PRIVATE — notify parents of absent students
  // ─────────────────────────────────────────────
  private async notifyAbsentParents(
    schoolId: string,
    studentIds: string[],
    date: string,
    className: string,
  ) {
    for (const studentId of studentIds) {
      const student = await this.prisma.student.findUnique({
        where: { id: studentId },
        select: {
          fullName: true,
          userId: true,
          parents: {
            include: {
              parent: { select: { userId: true } },
            },
          },
        },
      });

      if (!student) continue;

      const parentUserIds = student.parents
        .map((ps) => ps.parent.userId)
        .filter((id): id is string => id !== null);

      if (parentUserIds.length > 0) {
        await this.notificationsService.notifyMany(parentUserIds, {
          schoolId,
          title: 'Attendance Alert',
          body: `${student.fullName} was marked absent from ${className} on ${date}.`,
          type: 'attendance_alert',
          payload: { studentId, date, className },
        });
      }

      if (student.userId) {
        await this.notificationsService.notify({
          userId: student.userId,
          schoolId,
          title: 'Attendance Marked',
          body: `You were marked absent from ${className} on ${date}.`,
          type: 'attendance_alert',
          payload: { studentId, date, className },
        });
      }
    }
  }
}
