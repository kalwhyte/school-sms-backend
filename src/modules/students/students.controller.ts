import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
  ParseUUIDPipe,
  ForbiddenException,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
  ApiQuery,
} from '@nestjs/swagger';
import { StudentsService } from './students.service';
import { CreateStudentDto } from './dto/create-students.dto';
import { UpdateStudentDto } from './dto/update-students.dto';
import { BulkPromoteDto } from './dto/bulk-promote.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import * as jwtStrategy from '../auth/strategies/jwt.strategy';

@ApiTags('Students')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('schools/:schoolId/students')
export class StudentsController {
  constructor(private readonly studentsService: StudentsService) {}

  // ─────────────────────────────────────────────
  // POST /schools/:schoolId/students
  // ─────────────────────────────────────────────
  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Enrol a new student (admin only)' })
  @ApiResponse({ status: 201, description: 'Student enrolled successfully' })
  @ApiResponse({ status: 409, description: 'Phone number already in use' })
  create(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Body() dto: CreateStudentDto,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    this.assertAdmin(user);
    return this.studentsService.create(schoolId, dto);
  }

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/students
  // ─────────────────────────────────────────────
  @Get()
  @ApiOperation({ summary: 'List students (paginated)' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'classId', required: false, type: String })
  @ApiQuery({ name: 'isActive', required: false, type: Boolean })
  @ApiQuery({
    name: 'search',
    required: false,
    type: String,
    description: 'Search by name or admission number',
  })
  @ApiResponse({ status: 200, description: 'Paginated student list' })
  findAll(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('classId') classId?: string,
    @Query('isActive') isActive?: string,
    @Query('search') search?: string,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    return this.studentsService.findAll(schoolId, {
      page: page ? parseInt(page) : undefined,
      limit: limit ? parseInt(limit) : undefined,
      classId,
      isActive: isActive !== undefined ? isActive === 'true' : undefined,
      search,
    });
  }

  // ─────────────────────────────────────────────
  // POST /schools/:schoolId/students/bulk-promote
  // Must be defined BEFORE :studentId to avoid route conflict
  // ─────────────────────────────────────────────
  @Post('bulk-promote')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Bulk promote students to a new class (admin only)',
  })
  @ApiResponse({ status: 200, description: 'Promotion results' })
  bulkPromote(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Body() dto: BulkPromoteDto,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    this.assertAdmin(user);
    return this.studentsService.bulkPromote(schoolId, dto);
  }

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/students/:studentId
  // ─────────────────────────────────────────────
  @Get(':studentId')
  @ApiOperation({ summary: 'Get a single student profile' })
  @ApiResponse({ status: 200, description: 'Student profile returned' })
  @ApiResponse({ status: 404, description: 'Student not found' })
  findOne(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('studentId', ParseUUIDPipe) studentId: string,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    return this.studentsService.findOne(schoolId, studentId);
  }

  // ─────────────────────────────────────────────
  // PATCH /schools/:schoolId/students/:studentId
  // ─────────────────────────────────────────────
  @Patch(':studentId')
  @ApiOperation({ summary: 'Update a student (admin only)' })
  @ApiResponse({ status: 200, description: 'Student updated' })
  update(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('studentId', ParseUUIDPipe) studentId: string,
    @Body() dto: UpdateStudentDto,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    this.assertAdmin(user);
    return this.studentsService.update(schoolId, studentId, dto);
  }

  // ─────────────────────────────────────────────
  // DELETE /schools/:schoolId/students/:studentId
  // ─────────────────────────────────────────────
  @Delete(':studentId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Deactivate a student (soft delete, admin only)' })
  @ApiResponse({ status: 204, description: 'Student deactivated' })
  deactivate(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('studentId', ParseUUIDPipe) studentId: string,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    this.assertAdmin(user);
    return this.studentsService.deactivate(schoolId, studentId);
  }

  // ─────────────────────────────────────────────
  // PRIVATE GUARDS
  // ─────────────────────────────────────────────
  private assertSameSchool(schoolId: string, userSchoolId: string) {
    if (schoolId !== userSchoolId) {
      throw new ForbiddenException('You do not have access to this school.');
    }
  }

  private assertAdmin(user: jwtStrategy.ValidatedUser) {
    const adminRoles = ['admin', 'principal', 'vice_principal'];
    if (!adminRoles.includes(user.role)) {
      throw new ForbiddenException('Admin access required.');
    }
  }
}
