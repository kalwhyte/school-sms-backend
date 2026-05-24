import {
  Injectable,
  ConflictException,
  NotFoundException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { SubjectsHelperService } from './services/index.service';
import { SubjectRow, TimetablePeriodRow } from './interfaces/index.interface';
import { CreateSubjectDto } from './dto/create-subjects.dto';
import {
  UpdateSubjectDto,
  CreateTimetablePeriodDto,
} from './dto/update-subjects.dto';

@Injectable()
export class SubjectsService {
  private readonly logger = new Logger(SubjectsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly subjectsHelper: SubjectsHelperService,
  ) {}

  // ─────────────────────────────────────────────
  // CREATE SUBJECT
  // ─────────────────────────────────────────────

  async create(schoolId: string, dto: CreateSubjectDto) {
    // Confirm class belongs to school
    const cls = await this.prisma.class.findFirst({
      where: { id: dto.classId, schoolId },
      select: { id: true },
    });
    if (!cls) throw new NotFoundException('Class not found in this school.');

    // Subject name must be unique within a class
    const existing = await this.prisma.subject.findUnique({
      where: { classId_name: { classId: dto.classId, name: dto.name } },
    });
    if (existing) {
      throw new ConflictException(
        `Subject "${dto.name}" already exists in this class.`,
      );
    }

    if (dto.teacherId) {
      await this.subjectsHelper.assertStaffExists(schoolId, dto.teacherId);
    }

    const created = await this.prisma.subject.create({
      data: {
        schoolId,
        name: dto.name,
        classId: dto.classId,
        isCore: dto.isCore ?? true,
        teacherId: dto.teacherId ?? null,
      },
      select: this.subjectsHelper.subjectSelect(),
    });

    this.logger.log(`Subject created: ${created.id}`);
    return this.subjectsHelper.formatSubject(created);
  }

  // ─────────────────────────────────────────────
  // LIST BY CLASS
  // ─────────────────────────────────────────────

  async findAll(schoolId: string, classId?: string) {
    const where = {
      schoolId,
      ...(classId && { classId }),
    };

    const data = await this.prisma.subject.findMany({
      where,
      orderBy: { name: 'asc' },
      select: this.subjectsHelper.subjectSelect(),
    });

    return (data as unknown as SubjectRow[]).map((s) =>
      this.subjectsHelper.formatSubject(s),
    );
  }

  // ─────────────────────────────────────────────
  // GET ONE
  // ─────────────────────────────────────────────

  async findOne(schoolId: string, subjectId: string) {
    const subject = await this.prisma.subject.findFirst({
      where: { id: subjectId, schoolId },
      select: this.subjectsHelper.subjectSelect(),
    });

    if (!subject) throw new NotFoundException('Subject not found.');
    return this.subjectsHelper.formatSubject(subject);
  }

  // ─────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────

  async update(schoolId: string, subjectId: string, dto: UpdateSubjectDto) {
    await this.subjectsHelper.assertSubjectExists(schoolId, subjectId);

    if (dto.teacherId) {
      await this.subjectsHelper.assertStaffExists(schoolId, dto.teacherId);
    }

    if (dto.name) {
      const subject = await this.prisma.subject.findFirst({
        where: { id: subjectId },
        select: { classId: true },
      });
      const collision = await this.prisma.subject.findFirst({
        where: {
          classId: subject!.classId,
          name: dto.name,
          NOT: { id: subjectId },
        },
      });
      if (collision) {
        throw new ConflictException(
          `Subject "${dto.name}" already exists in this class.`,
        );
      }
    }

    const updated = await this.prisma.subject.update({
      where: { id: subjectId },
      data: {
        ...(dto.name !== undefined && { name: dto.name }),
        ...(dto.isCore !== undefined && { isCore: dto.isCore }),
        ...(dto.teacherId !== undefined && { teacherId: dto.teacherId }),
      },
      select: this.subjectsHelper.subjectSelect(),
    });

    return this.subjectsHelper.formatSubject(updated);
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────

  async remove(schoolId: string, subjectId: string) {
    await this.subjectsHelper.assertSubjectExists(schoolId, subjectId);

    const assessmentCount = await this.prisma.assessment.count({
      where: { subjectId },
    });
    if (assessmentCount > 0) {
      throw new BadRequestException(
        `Cannot delete a subject with ${assessmentCount} assessment(s). Archive assessments first.`,
      );
    }

    await this.prisma.subject.delete({ where: { id: subjectId } });
    return { message: 'Subject deleted.' };
  }

  // ─────────────────────────────────────────────
  // TIMETABLE — CREATE PERIOD
  // ─────────────────────────────────────────────

  async createTimetablePeriod(
    schoolId: string,
    subjectId: string,
    dto: CreateTimetablePeriodDto,
  ) {
    const subject = await this.prisma.subject.findFirst({
      where: { id: subjectId, schoolId },
      select: { id: true, classId: true },
    });
    if (!subject) throw new NotFoundException('Subject not found.');

    this.subjectsHelper.assertEndAfterStart(dto.startTime!, dto.endTime!);

    const startTime = this.subjectsHelper.parseTime(dto.startTime!);
    const endTime = this.subjectsHelper.parseTime(dto.endTime!);

    // Check for overlap on the same class + day
    await this.subjectsHelper.assertNoOverlap(
      subject.classId,
      dto.dayOfWeek!,
      startTime,
      endTime,
    );

    const period = (await this.prisma.timetablePeriod.create({
      data: {
        classId: subject.classId,
        subjectId,
        dayOfWeek: dto.dayOfWeek!,
        startTime,
        endTime,
      },
      select: this.subjectsHelper.periodSelect(),
    })) as unknown as TimetablePeriodRow;

    return this.subjectsHelper.formatPeriod(period);
  }

  // ─────────────────────────────────────────────
  // TIMETABLE — LIST FOR SUBJECT
  // ─────────────────────────────────────────────

  async getTimetable(schoolId: string, subjectId: string) {
    await this.subjectsHelper.assertSubjectExists(schoolId, subjectId);

    const periods = await this.prisma.timetablePeriod.findMany({
      where: { subjectId },
      orderBy: [{ dayOfWeek: 'asc' }, { startTime: 'asc' }],
      select: this.subjectsHelper.periodSelect(),
    });

    return (periods as unknown as TimetablePeriodRow[]).map((p) =>
      this.subjectsHelper.formatPeriod(p),
    );
  }

  // ─────────────────────────────────────────────
  // TIMETABLE — DELETE PERIOD
  // ─────────────────────────────────────────────

  async deleteTimetablePeriod(
    schoolId: string,
    subjectId: string,
    periodId: string,
  ) {
    await this.subjectsHelper.assertSubjectExists(schoolId, subjectId);

    const period = await this.prisma.timetablePeriod.findFirst({
      where: { id: periodId, subjectId },
    });
    if (!period) throw new NotFoundException('Timetable period not found.');

    await this.prisma.timetablePeriod.delete({ where: { id: periodId } });
    return { message: 'Timetable period removed.' };
  }
}
