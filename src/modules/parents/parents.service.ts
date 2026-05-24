import {
  Injectable,
  ConflictException,
  NotFoundException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { CreateParentDto } from './dto/create-parents.dto';
import { UpdateParentDto, LinkStudentDto } from './dto/update-parents.dto';
import { ParentRow } from './interfaces/index.interface';
import { ParentsHelper } from './services/index.service';

@Injectable()
export class ParentsService {
  private readonly logger = new Logger(ParentsService.name);
  private readonly parentSelect = () => ({
    id: true,
    userId: true,
    schoolId: true,
    fullName: true,
    phone: true,
    email: true,
    occupation: true,
    createdAt: true,
    updatedAt: true,
    user: {
      select: {
        id: true,
        role: true,
        isActive: true,
        lastLogin: true,
      },
    },
    students: {
      select: {
        relationship: true,
        student: {
          select: {
            id: true,
            fullName: true,
            admissionNumber: true,
          },
        },
      },
    },
  });

  constructor(
    private readonly prisma: PrismaService,
    private readonly helper: ParentsHelper,
  ) {}

  // ─────────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────────

  async create(schoolId: string, dto: CreateParentDto) {
    const existingUser = await this.prisma.user.findUnique({
      where: { schoolId_phone: { schoolId, phone: dto.phone! } },
    });
    if (existingUser) {
      throw new ConflictException(
        'A user with this phone number already exists in this school.',
      );
    }

    const result = await this.prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: {
          schoolId,
          phone: dto.phone!,
          role: 'parent',
          isActive: true,
        },
      });

      const parent = await tx.parent.create({
        data: {
          userId: user.id,
          schoolId,
          fullName: dto.fullName!,
          phone: dto.phone!,
          email: dto.email ?? null,
          occupation: dto.occupation ?? null,
        },
        select: this.parentSelect(),
      });

      return parent;
    });

    this.logger.log(`Parent created: ${result.id} in school ${schoolId}`);
    return this.helper.formatParent(result);
  }

  // ─────────────────────────────────────────────
  // LIST
  // ─────────────────────────────────────────────

  async findAll(
    schoolId: string,
    query: { page?: number; limit?: number; search?: string },
  ) {
    const { page = 1, limit = 20, search } = query;
    const skip = (page - 1) * limit;

    const where = {
      schoolId,
      ...(search && {
        OR: [
          { fullName: { contains: search, mode: 'insensitive' as const } },
          { phone: { contains: search } },
        ],
      }),
    };

    const [data, total] = await Promise.all([
      this.prisma.parent.findMany({
        where,
        skip,
        take: limit,
        orderBy: { fullName: 'asc' },
        select: this.parentSelect(),
      }),
      this.prisma.parent.count({ where }),
    ]);

    return {
      data: (data as unknown as ParentRow[]).map((p) =>
        this.helper.formatParent(p),
      ),
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  // ─────────────────────────────────────────────
  // GET ONE
  // ─────────────────────────────────────────────

  async findOne(schoolId: string, parentId: string) {
    const parent = (await this.prisma.parent.findFirst({
      where: { id: parentId, schoolId },
      select: this.parentSelect(),
    })) as unknown as ParentRow | null;

    if (!parent) throw new NotFoundException('Parent not found.');
    return this.helper.formatParent(parent);
  }

  // ─────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────

  async update(schoolId: string, parentId: string, dto: UpdateParentDto) {
    await this.helper.assertExists(schoolId, parentId);

    const updated = (await this.prisma.parent.update({
      where: { id: parentId },
      data: {
        ...(dto.fullName !== undefined && { fullName: dto.fullName }),
        ...(dto.email !== undefined && { email: dto.email }),
        ...(dto.occupation !== undefined && { occupation: dto.occupation }),
      },
      select: this.parentSelect(),
    })) as unknown as ParentRow;

    return this.helper.formatParent(updated);
  }

  // ─────────────────────────────────────────────
  // LINK STUDENT
  // ─────────────────────────────────────────────

  async linkStudent(schoolId: string, parentId: string, dto: LinkStudentDto) {
    await this.helper.assertExists(schoolId, parentId);

    // Confirm student belongs to same school
    const student = await this.prisma.student.findFirst({
      where: { id: dto.studentId, schoolId },
      select: { id: true, fullName: true },
    });
    if (!student)
      throw new NotFoundException('Student not found in this school.');

    // Upsert — safe to call multiple times
    await this.prisma.parentStudent.upsert({
      where: {
        parentId_studentId: { parentId, studentId: dto.studentId! },
      },
      create: {
        parentId,
        studentId: dto.studentId!,
        relationship: dto.relationship ?? 'guardian',
      },
      update: {
        relationship: dto.relationship ?? 'guardian',
      },
    });

    return {
      message: `${student.fullName} linked successfully.`,
      relationship: dto.relationship ?? 'guardian',
    };
  }

  // ─────────────────────────────────────────────
  // UNLINK STUDENT
  // ─────────────────────────────────────────────

  async unlinkStudent(schoolId: string, parentId: string, studentId: string) {
    await this.helper.assertExists(schoolId, parentId);

    const link = await this.prisma.parentStudent.findUnique({
      where: { parentId_studentId: { parentId, studentId } },
    });
    if (!link)
      throw new NotFoundException('This student is not linked to the parent.');

    await this.prisma.parentStudent.delete({
      where: { parentId_studentId: { parentId, studentId } },
    });

    return { message: 'Student unlinked from parent.' };
  }

  // ─────────────────────────────────────────────
  // SOFT DELETE
  // ─────────────────────────────────────────────

  async remove(schoolId: string, parentId: string) {
    const parent = await this.prisma.parent.findFirst({
      where: { id: parentId, schoolId },
      select: { userId: true },
    });
    if (!parent) throw new NotFoundException('Parent not found.');

    await this.prisma.user.update({
      where: { id: parent.userId },
      data: { isActive: false },
    });

    return { message: 'Parent deactivated.' };
  }
}
