import {
  Injectable,
  NotFoundException,
  ConflictException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { CreateStudentDto } from './dto/create-students.dto';
import { UpdateStudentDto } from './dto/update-students.dto';
import { BulkPromoteDto } from './dto/bulk-promote.dto';
import { StudentsHelperService } from './services/index.service';

@Injectable()
export class StudentsService {
  private readonly logger = new Logger(StudentsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly helperService: StudentsHelperService, // Inject StudentsHelperService
  ) {}

  // ─────────────────────────────────────────────
  // ENROLL STUDENT
  // Creates User + Student + ClassEnrollment atomically
  // ─────────────────────────────────────────────
  async create(schoolId: string, dto: CreateStudentDto) {
    // 1. Verify the target class belongs to this school (no isActive — not in schema)
    const targetClass = await this.prisma.class.findFirst({
      where: { id: dto.classId, schoolId },
      select: { id: true, name: true },
    });
    if (!targetClass) {
      throw new NotFoundException('Class not found in this school.');
    }

    // 2. If phone provided, check it's not already used in this school
    if (dto.phone) {
      const existing = await this.prisma.user.findFirst({
        where: { phone: dto.phone, schoolId },
      });
      if (existing) {
        throw new ConflictException(
          'A user with this phone number already exists in this school.',
        );
      }
    }

    // 3. Generate admission number: {SCHOOL_CODE}/{YEAR}/{4-digit-seq}
    const school = await this.prisma.school.findUnique({
      where: { id: schoolId },
      select: { schoolCode: true },
    });
    if (!school) throw new NotFoundException('School not found.');

    const admissionNumber = await this.helperService.generateAdmissionNumber(
      schoolId,
      school.schoolCode,
    );

    // 4. Create User + Student + ClassEnrollment atomically
    const result = await this.prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          schoolId,
          phone: dto.phone! ?? null,
          email: dto.email ?? null,
          role: 'student',
          isActive: true,
        },
      });

      const student = await tx.student.create({
        data: {
          userId: user.id,
          schoolId,
          fullName: dto.fullName!,
          dob: dto.dateOfBirth ? new Date(dto.dateOfBirth) : null, // schema field: dob
          gender: dto.gender ?? null,
          classId: dto.classId, // schema field: classId
          guardianName: dto.guardianName ?? null,
          admissionNumber,
          photoUrl: dto.photoUrl ?? null,
          isActive: true,
        },
      });

      // ClassEnrollment only has: classId, studentId, enrolledAt
      await tx.classEnrollment.create({
        data: {
          studentId: student.id,
          classId: dto.classId!,
          enrolledAt: new Date(), // schema field: enrolledAt
        },
      });

      return { user, student };
    });

    this.logger.log(
      `Enrolled student ${result.student.admissionNumber} in school ${schoolId}`,
    );

    return this.helperService.formatStudent(result.student, result.user);
  }

  // ─────────────────────────────────────────────
  // LIST STUDENTS (paginated)
  // ─────────────────────────────────────────────
  async findAll(
    schoolId: string,
    query: {
      page?: number;
      limit?: number;
      classId?: string;
      isActive?: boolean;
      search?: string;
    },
  ) {
    const page = Math.max(1, query.page ?? 1);
    const limit = Math.min(100, Math.max(1, query.limit ?? 20));
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = { schoolId };

    if (query.classId) where.classId = query.classId; // schema: classId not currentClassId
    if (query.isActive !== undefined) where.isActive = query.isActive;
    if (query.search) {
      where.OR = [
        { fullName: { contains: query.search, mode: 'insensitive' } },
        { admissionNumber: { contains: query.search, mode: 'insensitive' } },
      ];
    }

    const [students, total] = await Promise.all([
      this.prisma.student.findMany({
        where,
        skip,
        take: limit,
        orderBy: { fullName: 'asc' },
        include: {
          user: { select: { phone: true, email: true, isActive: true } },
          currentClass: { select: { id: true, name: true } }, // no level/stream in schema
        },
      }),
      this.prisma.student.count({ where }),
    ]);

    return {
      data: students.map((s) => this.helperService.formatStudent(s, s.user)),
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  // ─────────────────────────────────────────────
  // GET SINGLE STUDENT
  // ─────────────────────────────────────────────
  async findOne(schoolId: string, studentId: string) {
    const student = await this.prisma.student.findFirst({
      where: { id: studentId, schoolId },
      include: {
        user: {
          select: { phone: true, email: true, isActive: true, lastLogin: true },
        },
        currentClass: {
          select: { id: true, name: true, arm: true }, // only fields that exist
        },
        enrollments: {
          orderBy: { enrolledAt: 'desc' as const },
          take: 5,
          include: {
            class: { select: { id: true, name: true, arm: true } },
          },
        },
        parents: {
          include: {
            parent: {
              select: {
                fullName: true,
                user: {
                  select: {
                    phone: true,
                    email: true,
                    isActive: true,
                    lastLogin: true,
                  },
                },
              },
            },
          },
        },
      },
    });

    if (!student) throw new NotFoundException('Student not found.');

    type EnrollmentRow = (typeof student.enrollments)[number];
    type ParentRow = (typeof student.parents)[number];

    return {
      ...this.helperService.formatStudent(student, student.user),
      enrollmentHistory: student.enrollments.map((e: EnrollmentRow) => ({
        classId: e.classId,
        className: e.class.name,
        enrolledAt: e.enrolledAt,
      })),
      parents: student.parents.map((ps: ParentRow) => ({
        parentId: ps.parentId,
        fullName: ps.parent.fullName,
        phone: ps.parent.user?.phone ?? null,
        email: ps.parent.user?.email ?? null,
        isActive: ps.parent.user?.isActive ?? null,
        lastLogin: ps.parent.user?.lastLogin ?? null,
      })),
    };
  }

  // ─────────────────────────────────────────────
  // UPDATE STUDENT
  // ─────────────────────────────────────────────
  async update(schoolId: string, studentId: string, dto: UpdateStudentDto) {
    const student = await this.prisma.student.findFirst({
      where: { id: studentId, schoolId },
    });
    if (!student) throw new NotFoundException('Student not found.');

    if (dto.phone && dto.phone !== student.userId) {
      const existing = await this.prisma.user.findFirst({
        where: { phone: dto.phone, schoolId },
      });
      if (existing) {
        throw new ConflictException(
          'A user with this phone number already exists in this school.',
        );
      }
    }

    const updated = await this.prisma.$transaction(async (tx) => {
      if (dto.phone !== undefined || dto.email !== undefined) {
        await tx.user.update({
          where: { id: student.userId! },
          data: {
            ...(dto.phone !== undefined && { phone: dto.phone }),
            ...(dto.email !== undefined && { email: dto.email }),
          },
        });
      }

      return tx.student.update({
        where: { id: studentId },
        data: {
          ...(dto.fullName && { fullName: dto.fullName }),
          ...(dto.dateOfBirth && { dob: new Date(dto.dateOfBirth) }), // dob not dateOfBirth
          ...(dto.gender && { gender: dto.gender }),
          ...(dto.guardianName !== undefined && {
            guardianName: dto.guardianName,
          }),
          ...(dto.photoUrl !== undefined && { photoUrl: dto.photoUrl }),
        },
        include: {
          user: { select: { phone: true, email: true, isActive: true } },
          currentClass: { select: { id: true, name: true } },
        },
      });
    });

    return this.helperService.formatStudent(updated, updated.user);
  }

  // ─────────────────────────────────────────────
  // DEACTIVATE STUDENT (soft delete)
  // ─────────────────────────────────────────────
  async deactivate(schoolId: string, studentId: string) {
    const student = await this.prisma.student.findFirst({
      where: { id: studentId, schoolId },
    });
    if (!student) throw new NotFoundException('Student not found.');

    // ClassEnrollment has no status field — just delete the active enrollment
    await this.prisma.$transaction([
      this.prisma.student.update({
        where: { id: studentId },
        data: { isActive: false },
      }),
      this.prisma.user.update({
        where: { id: student.userId! },
        data: { isActive: false },
      }),
      this.prisma.classEnrollment.deleteMany({
        where: { studentId },
      }),
    ]);

    this.logger.log(`Deactivated student ${studentId} in school ${schoolId}`);
  }

  // ─────────────────────────────────────────────
  // BULK PROMOTE
  // ─────────────────────────────────────────────
  async bulkPromote(schoolId: string, dto: BulkPromoteDto) {
    const targetClass = await this.prisma.class.findFirst({
      where: { id: dto.targetClassId, schoolId }, // no isActive on Class
    });
    if (!targetClass) {
      throw new NotFoundException('Target class not found in this school.');
    }

    const promoted: string[] = [];
    const failed: Array<{ id: string; reason: string }> = [];

    await Promise.allSettled(
      (dto.studentIds ?? []).map(async (studentId) => {
        // dto.studentIds.map(async (studentId) => {
        try {
          await this.prisma.$transaction(async (tx) => {
            const student = await tx.student.findFirst({
              where: { id: studentId, schoolId, isActive: true },
            });
            if (!student) throw new Error('Student not found or inactive');

            // Remove old enrollment, create new one
            await tx.classEnrollment.deleteMany({ where: { studentId } });

            await tx.classEnrollment.create({
              data: {
                studentId,
                classId: dto.targetClassId!,
                enrolledAt: new Date(),
              },
            });

            // Update student's current class
            await tx.student.update({
              where: { id: studentId },
              data: { classId: dto.targetClassId }, // classId not currentClassId
            });
          });

          promoted.push(studentId);
        } catch (err) {
          failed.push({
            id: studentId,
            reason: err instanceof Error ? err.message : String(err),
          });
        }
      }),
    );

    this.logger.log(
      `Bulk promote in school ${schoolId}: ${promoted.length} promoted, ${failed.length} failed`,
    );

    return {
      promotedCount: promoted.length,
      promotedIds: promoted,
      failed,
    };
  }
}
