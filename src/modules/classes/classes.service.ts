import {
  Injectable,
  ConflictException,
  NotFoundException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { CreateClassDto } from './dto/create-classes.dto';
import { UpdateClassDto } from './dto/update-classes.dto';
import { ClassQueryDto } from './dto/class-query.dto';
import { ClassHelperService } from './services/index.service';
import { ClassRow } from './interfaces/index.interface';

@Injectable()
export class ClassesService {
  private readonly logger = new Logger(ClassesService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly helper: ClassHelperService,
  ) {}

  // ─────────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────────

  async create(schoolId: string, dto: CreateClassDto) {
    // Unique constraint: schoolId + name + arm + academicYear + term
    const existing = await this.prisma.class.findUnique({
      where: {
        schoolId_name_arm_academicYear_term: {
          schoolId,
          name: dto.name!,
          arm: dto.arm!,
          academicYear: dto.academicYear!,
          term: dto.term!,
        },
      },
    });
    if (existing) {
      throw new ConflictException(
        `Class "${dto.name} ${dto.arm}" already exists for ${dto.term} term ${dto.academicYear}.`,
      );
    }

    // Validate teacherId belongs to this school
    if (dto.teacherId) {
      await this.helper.validateStaff(schoolId, dto.teacherId);
    }

    const created = await this.prisma.class.create({
      data: {
        schoolId,
        name: dto.name!,
        arm: dto.arm!,
        academicYear: dto.academicYear!,
        term: dto.term!,
        teacherId: dto.teacherId ?? null,
      },
      select: this.helper.classSelect(),
    });

    this.logger.log(`Class created: ${created.id} in school ${schoolId}`);
    return this.helper.formatClass(created as unknown as ClassRow);
  }

  // ─────────────────────────────────────────────
  // LIST
  // ─────────────────────────────────────────────

  async findAll(schoolId: string, query: ClassQueryDto) {
    const { page = 1, limit = 20, academicYear, term } = query;
    const skip = (page - 1) * limit;

    const where = {
      schoolId,
      ...(academicYear && { academicYear }),
      ...(term && { term }),
    };

    const [data, total] = await Promise.all([
      this.prisma.class.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ name: 'asc' }, { arm: 'asc' }],
        select: this.helper.classSelect(),
      }),
      this.prisma.class.count({ where }),
    ]);

    return {
      data: (data as unknown as ClassRow[]).map((c) =>
        this.helper.formatClass(c),
      ),
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  // ─────────────────────────────────────────────
  // GET ONE
  // ─────────────────────────────────────────────

  async findOne(schoolId: string, classId: string) {
    const cls = (await this.prisma.class.findFirst({
      where: { id: classId, schoolId },
      select: this.helper.classSelect(),
    })) as unknown as ClassRow | null;

    if (!cls) throw new NotFoundException('Class not found.');
    return this.helper.formatClass(cls);
  }

  // ─────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────

  async update(schoolId: string, classId: string, dto: UpdateClassDto) {
    await this.helper.assertClassExists(schoolId, classId);

    if (dto.teacherId) {
      await this.helper.validateStaff(schoolId, dto.teacherId);
    }

    // Guard: renaming must not collide with existing class
    if (dto.name || dto.arm) {
      const current = await this.prisma.class.findFirst({
        where: { id: classId },
        select: { name: true, arm: true, academicYear: true, term: true },
      });

      if (current) {
        const collision = await this.prisma.class.findFirst({
          where: {
            schoolId,
            name: dto.name ?? current.name,
            arm: dto.arm ?? current.arm,
            academicYear: current.academicYear,
            term: current.term,
            NOT: { id: classId },
          },
        });
        if (collision) {
          throw new ConflictException(
            'Another class with this name/arm already exists for this term.',
          );
        }
      }
    }

    const updated = (await this.prisma.class.update({
      where: { id: classId },
      data: {
        ...(dto.name !== undefined && { name: dto.name }),
        ...(dto.arm !== undefined && { arm: dto.arm }),
        ...(dto.teacherId !== undefined && { teacherId: dto.teacherId }),
      },
      select: this.helper.classSelect(),
    })) as unknown as ClassRow;

    this.logger.log(`Class updated: ${classId}`);
    return this.helper.formatClass(updated);
  }

  // ─────────────────────────────────────────────
  // DELETE (hard — classes have no isActive; cascade handles children)
  // ─────────────────────────────────────────────

  async remove(schoolId: string, classId: string) {
    await this.helper.assertClassExists(schoolId, classId);

    // Block delete if students are currently enrolled
    const enrollmentCount = await this.prisma.classEnrollment.count({
      where: { classId },
    });
    if (enrollmentCount > 0) {
      throw new BadRequestException(
        `Cannot delete a class with ${enrollmentCount} enrolled student(s). Remove students first.`,
      );
    }

    await this.prisma.class.delete({ where: { id: classId } });
    this.logger.log(`Class deleted: ${classId}`);
    return { message: 'Class deleted.' };
  }
}
