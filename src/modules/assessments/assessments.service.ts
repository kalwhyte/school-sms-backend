import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import {
  CreateAssessmentDto,
  UpdateAssessmentDto,
  BulkScoresDto,
} from './dto/create-assessments.dto';
import { AssessmentType } from '@prisma/client';

// ── WAEC grading scale ────────────────────────────────────────────────────────
function getGrade(score: number): string {
  if (score >= 75) return 'A1';
  if (score >= 70) return 'B2';
  if (score >= 65) return 'B3';
  if (score >= 60) return 'C4';
  if (score >= 55) return 'C5';
  if (score >= 50) return 'C6';
  if (score >= 45) return 'D7';
  if (score >= 40) return 'E8';
  return 'F9';
}

@Injectable()
export class AssessmentsService {
  private readonly logger = new Logger(AssessmentsService.name);

  constructor(private readonly prisma: PrismaService) {}

  // ─────────────────────────────────────────────
  // CREATE ASSESSMENT
  // ─────────────────────────────────────────────
  async create(schoolId: string, createdBy: string, dto: CreateAssessmentDto) {
    // Verify subject belongs to this school
    const subject = await this.prisma.subject.findFirst({
      where: { id: dto.subjectId, schoolId },
      select: { id: true, name: true, classId: true },
    });
    if (!subject)
      throw new NotFoundException('Subject not found in this school.');

    const assessment = await this.prisma.assessment.create({
      data: {
        subjectId: subject.id,
        title: dto.title,
        type: dto.type,
        maxScore: dto.maxScore,
        passingScore: dto.passingScore ?? null,
        date: new Date(dto.date),
        isPublished: false,
        createdBy,
      },
      include: {
        subject: { select: { id: true, name: true, classId: true } },
      },
    });

    this.logger.log(
      `Assessment created: ${assessment.title} for subject ${subject.name}`,
    );
    return assessment;
  }

  // ─────────────────────────────────────────────
  // LIST ASSESSMENTS
  // ─────────────────────────────────────────────
  async findAll(
    schoolId: string,
    query: {
      subjectId?: string;
      classId?: string;
      type?: AssessmentType;
      page?: number;
      limit?: number;
    },
  ) {
    const page = Math.max(1, query.page ?? 1);
    const limit = Math.min(100, Math.max(1, query.limit ?? 20));
    const skip = (page - 1) * limit;

    // Build where — scope to school via subject → school relation
    const where: Record<string, unknown> = {
      subject: { schoolId },
    };

    if (query.subjectId) where.subjectId = query.subjectId;
    if (query.type) where.type = query.type;
    if (query.classId) {
      where.subject = { schoolId, classId: query.classId };
    }

    const [assessments, total] = await Promise.all([
      this.prisma.assessment.findMany({
        where,
        skip,
        take: limit,
        orderBy: { date: 'desc' },
        include: {
          subject: {
            select: { id: true, name: true, classId: true },
          },
          _count: { select: { scores: true } },
        },
      }),
      this.prisma.assessment.count({ where }),
    ]);

    return {
      data: assessments,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  // ─────────────────────────────────────────────
  // GET SINGLE ASSESSMENT
  // ─────────────────────────────────────────────
  async findOne(schoolId: string, assessmentId: string) {
    const assessment = await this.prisma.assessment.findFirst({
      where: {
        id: assessmentId,
        subject: { schoolId },
      },
      include: {
        subject: { select: { id: true, name: true, classId: true } },
        _count: { select: { scores: true } },
      },
    });
    if (!assessment) throw new NotFoundException('Assessment not found.');
    return assessment;
  }

  // ─────────────────────────────────────────────
  // UPDATE ASSESSMENT
  // ─────────────────────────────────────────────
  async update(
    schoolId: string,
    assessmentId: string,
    dto: UpdateAssessmentDto,
  ) {
    // Prevent lowering maxScore below highest existing score
    if (dto.maxScore !== undefined) {
      const highestScore = await this.prisma.score.aggregate({
        where: { assessmentId },
        _max: { score: true },
      });
      const highest = Number(highestScore._max.score ?? 0);
      if (dto.maxScore < highest) {
        throw new BadRequestException(
          `Cannot set maxScore below the highest recorded score (${highest}).`,
        );
      }
    }

    return this.prisma.assessment.update({
      where: { id: assessmentId },
      data: {
        ...(dto.title && { title: dto.title }),
        ...(dto.type && { type: dto.type }),
        ...(dto.maxScore !== undefined && { maxScore: dto.maxScore }),
        ...(dto.passingScore !== undefined && {
          passingScore: dto.passingScore,
        }),
        ...(dto.date && { date: new Date(dto.date) }),
        ...(dto.isPublished !== undefined && { isPublished: dto.isPublished }),
      },
      include: {
        subject: { select: { id: true, name: true, classId: true } },
      },
    });
  }

  // ─────────────────────────────────────────────
  // DELETE ASSESSMENT
  // ─────────────────────────────────────────────
  async remove(schoolId: string, assessmentId: string) {
    await this.findOne(schoolId, assessmentId);

    await this.prisma.assessment.delete({ where: { id: assessmentId } });
    this.logger.log(`Assessment ${assessmentId} deleted`);
  }

  // ─────────────────────────────────────────────
  // BULK SUBMIT SCORES (idempotent upsert)
  // ─────────────────────────────────────────────
  async bulkSubmitScores(
    schoolId: string,
    assessmentId: string,
    gradedBy: string,
    dto: BulkScoresDto,
  ) {
    const assessment = await this.findOne(schoolId, assessmentId);
    const maxScore = Number(assessment.maxScore);

    // Validate all scores are within range before touching DB
    const overLimit = dto.scores.filter((s) => s.score > maxScore);
    if (overLimit.length > 0) {
      throw new BadRequestException(
        `${overLimit.length} score(s) exceed the maximum score of ${maxScore}.`,
      );
    }

    const upserts = dto.scores.map((entry) =>
      this.prisma.score.upsert({
        where: {
          assessmentId_studentId: {
            assessmentId,
            studentId: entry.studentId,
          },
        },
        update: {
          score: entry.score,
          gradedBy,
          gradedAt: new Date(),
        },
        create: {
          assessmentId,
          studentId: entry.studentId,
          score: entry.score,
          gradedBy,
        },
      }),
    );

    const results = await this.prisma.$transaction(upserts);

    this.logger.log(
      `Scores submitted for assessment ${assessmentId} — ${results.length} records`,
    );

    return {
      assessmentId,
      submitted: results.length,
      maxScore,
      scores: results.map((r) => ({
        studentId: r.studentId,
        score: Number(r.score),
        grade: getGrade((Number(r.score) / maxScore) * 100),
        gradedAt: r.gradedAt,
      })),
    };
  }

  // ─────────────────────────────────────────────
  // GET ALL SCORES FOR AN ASSESSMENT
  // ─────────────────────────────────────────────
  async getScores(schoolId: string, assessmentId: string) {
    const assessment = await this.findOne(schoolId, assessmentId);
    const maxScore = Number(assessment.maxScore);

    const scores = await this.prisma.score.findMany({
      where: { assessmentId },
      orderBy: { score: 'desc' },
      include: {
        student: {
          select: { id: true, fullName: true, admissionNumber: true },
        },
      },
    });

    return {
      assessment: {
        id: assessment.id,
        title: assessment.title,
        type: assessment.type,
        maxScore,
        date: assessment.date,
        isPublished: assessment.isPublished,
      },
      scores: scores.map((s, index) => ({
        position: index + 1,
        studentId: s.studentId,
        fullName: s.student.fullName,
        admissionNumber: s.student.admissionNumber,
        score: Number(s.score),
        percentage: Math.round((Number(s.score) / maxScore) * 100 * 100) / 100,
        grade: getGrade((Number(s.score) / maxScore) * 100),
        gradedAt: s.gradedAt,
      })),
      summary: {
        total: scores.length,
        average:
          scores.length > 0
            ? Math.round(
                (scores.reduce((sum, s) => sum + Number(s.score), 0) /
                  scores.length) *
                  100,
              ) / 100
            : 0,
        highest: scores.length > 0 ? Number(scores[0].score) : 0,
        lowest: scores.length > 0 ? Number(scores[scores.length - 1].score) : 0,
      },
    };
  }

  // ─────────────────────────────────────────────
  // GET STUDENT RESULTS — all scores for a student in a subject
  // ─────────────────────────────────────────────
  async getStudentResults(schoolId: string, studentId: string) {
    // Verify student belongs to school
    const student = await this.prisma.student.findFirst({
      where: { id: studentId, schoolId },
      select: {
        id: true,
        fullName: true,
        admissionNumber: true,
        classId: true,
      },
    });
    if (!student) throw new NotFoundException('Student not found.');

    const scores = await this.prisma.score.findMany({
      where: { studentId },
      include: {
        assessment: {
          include: {
            subject: { select: { id: true, name: true } },
          },
        },
      },
      orderBy: { assessment: { date: 'desc' } },
    });

    // Group by subject
    const bySubject = scores.reduce<
      Record<
        string,
        {
          subject: { id: string; name: string };
          scores: typeof scores;
        }
      >
    >((acc, s) => {
      const subjectId = s.assessment.subject.id;
      if (!acc[subjectId]) {
        acc[subjectId] = { subject: s.assessment.subject, scores: [] };
      }
      acc[subjectId].scores.push(s);
      return acc;
    }, {});

    return {
      student,
      results: Object.values(bySubject).map(
        ({ subject, scores: subScores }) => {
          const maxTotal = subScores.reduce(
            (sum, s) => sum + Number(s.assessment.maxScore),
            0,
          );
          const scoreTotal = subScores.reduce(
            (sum, s) => sum + Number(s.score),
            0,
          );
          const percentage =
            maxTotal > 0
              ? Math.round((scoreTotal / maxTotal) * 100 * 100) / 100
              : 0;

          return {
            subject,
            assessments: subScores.map((s) => ({
              id: s.assessment.id,
              title: s.assessment.title,
              type: s.assessment.type,
              score: Number(s.score),
              maxScore: Number(s.assessment.maxScore),
              percentage:
                Math.round(
                  (Number(s.score) / Number(s.assessment.maxScore)) * 100 * 100,
                ) / 100,
              grade: getGrade(
                (Number(s.score) / Number(s.assessment.maxScore)) * 100,
              ),
              date: s.assessment.date,
            })),
            total: { score: scoreTotal, maxScore: maxTotal, percentage },
            overallGrade: getGrade(percentage),
          };
        },
      ),
    };
  }
}
