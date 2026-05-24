import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import {
  GenerateReportCardDto,
  GenerateClassReportCardsDto,
  PublishReportCardsDto,
} from './dto/report-card.dto';
import { ReportCardHelperService } from './services/index.service';

@Injectable()
export class ReportCardsService {
  private readonly logger = new Logger(ReportCardsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly helper: ReportCardHelperService,
  ) {}

  // ─────────────────────────────────────────────
  // GENERATE — single student
  // ─────────────────────────────────────────────
  async generateForStudent(schoolId: string, dto: GenerateReportCardDto) {
    const student = await this.prisma.student.findFirst({
      where: { id: dto.studentId, schoolId },
      select: {
        id: true,
        fullName: true,
        admissionNumber: true,
        classId: true,
      },
    });
    if (!student) throw new NotFoundException('Student not found.');
    if (!student.classId) {
      throw new BadRequestException('Student is not enrolled in any class.');
    }

    const result = await this.helper.buildReportCard(
      student.id,
      student.classId,
      dto.term,
      dto.academicYear,
    );

    this.logger.log(
      `Report card generated for student ${student.admissionNumber} — ${dto.term} ${dto.academicYear}`,
    );

    return result;
  }

  // ─────────────────────────────────────────────
  // GENERATE — entire class (bulk)
  // ─────────────────────────────────────────────
  async generateForClass(schoolId: string, dto: GenerateClassReportCardsDto) {
    const cls = await this.prisma.class.findFirst({
      where: { id: dto.classId, schoolId },
      select: { id: true, name: true },
    });
    if (!cls) throw new NotFoundException('Class not found in this school.');

    const students = await this.prisma.student.findMany({
      where: { classId: dto.classId, schoolId, isActive: true },
      select: { id: true, fullName: true, admissionNumber: true },
    });

    if (students.length === 0) {
      throw new BadRequestException('No active students found in this class.');
    }

    const generated: string[] = [];
    const failed: Array<{ studentId: string; reason: string }> = [];

    for (const student of students) {
      try {
        await this.helper.buildReportCard(
          student.id,
          dto.classId,
          dto.term,
          dto.academicYear,
        );
        generated.push(student.id);
      } catch (err) {
        failed.push({
          studentId: student.id,
          reason: err instanceof Error ? err.message : String(err),
        });
      }
    }

    this.logger.log(
      `Bulk report cards for class ${cls.name} — ${generated.length} generated, ${failed.length} failed`,
    );

    return {
      classId: dto.classId,
      className: cls.name,
      term: dto.term,
      academicYear: dto.academicYear,
      generatedCount: generated.length,
      failedCount: failed.length,
      failed,
    };
  }

  // ─────────────────────────────────────────────
  // PUBLISH
  // ─────────────────────────────────────────────
  async publish(schoolId: string, dto: PublishReportCardsDto) {
    const cls = await this.prisma.class.findFirst({
      where: { id: dto.classId, schoolId },
    });
    if (!cls) throw new NotFoundException('Class not found in this school.');

    const updated = await this.prisma.reportCard.updateMany({
      where: {
        classId: dto.classId,
        term: dto.term,
        academicYear: dto.academicYear,
        isPublished: false,
      },
      data: { isPublished: true, publishedAt: new Date() },
    });

    this.logger.log(
      `Published ${updated.count} report cards for class ${dto.classId} — ${dto.term} ${dto.academicYear}`,
    );

    return {
      published: updated.count,
      classId: dto.classId,
      term: dto.term,
      academicYear: dto.academicYear,
    };
  }

  // ─────────────────────────────────────────────
  // LIST — student's report cards
  // ─────────────────────────────────────────────
  async findForStudent(schoolId: string, studentId: string) {
    const student = await this.prisma.student.findFirst({
      where: { id: studentId, schoolId },
      select: { id: true, fullName: true, admissionNumber: true },
    });
    if (!student) throw new NotFoundException('Student not found.');

    const reportCards = await this.prisma.reportCard.findMany({
      where: { studentId },
      orderBy: [{ academicYear: 'desc' }, { term: 'asc' }],
      include: {
        class: { select: { id: true, name: true, arm: true } },
      },
    });

    return {
      student,
      reportCards: reportCards.map((rc) => ({
        id: rc.id,
        term: rc.term,
        academicYear: rc.academicYear,
        class: rc.class,
        isPublished: rc.isPublished,
        publishedAt: rc.publishedAt,
        generatedAt: rc.generatedAt,
        pdfUrl: rc.pdfUrl,
      })),
    };
  }

  // ─────────────────────────────────────────────
  // GET SINGLE
  // ─────────────────────────────────────────────
  async findOne(schoolId: string, reportCardId: string) {
    const reportCard = await this.prisma.reportCard.findFirst({
      where: { id: reportCardId, student: { schoolId } },
      include: {
        student: {
          select: {
            id: true,
            fullName: true,
            admissionNumber: true,
            dob: true,
            gender: true,
          },
        },
        class: { select: { id: true, name: true, arm: true } },
      },
    });
    if (!reportCard) throw new NotFoundException('Report card not found.');

    const results = await this.helper.getStudentScoresForTerm(
      reportCard.studentId,
      reportCard.classId,
      reportCard.term,
      reportCard.academicYear,
    );

    return {
      id: reportCard.id,
      term: reportCard.term,
      academicYear: reportCard.academicYear,
      isPublished: reportCard.isPublished,
      publishedAt: reportCard.publishedAt,
      generatedAt: reportCard.generatedAt,
      pdfUrl: reportCard.pdfUrl,
      student: reportCard.student,
      class: reportCard.class,
      results,
      summary: this.helper.computeSummary(results),
    };
  }
}
