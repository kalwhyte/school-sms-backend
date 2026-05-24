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
import { AssessmentsService } from './assessments.service';
import {
  CreateAssessmentDto,
  UpdateAssessmentDto,
  BulkScoresDto,
} from './dto/create-assessments.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import * as JWTStrategy from '../auth/strategies/jwt.strategy';
import { AssessmentType } from '@prisma/client';
import { AssessmentsPermissionsGuard } from './guards/permissions.guard';

@ApiTags('Assessments')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, AssessmentsPermissionsGuard)
@Controller('schools/:schoolId/assessments')
export class AssessmentsController {
  constructor(private readonly assessmentsService: AssessmentsService) {}

  // ─────────────────────────────────────────────
  // POST /schools/:schoolId/assessments
  // ─────────────────────────────────────────────
  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create an assessment (teacher/admin)' })
  @ApiResponse({ status: 201, description: 'Assessment created' })
  create(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Body() dto: CreateAssessmentDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    return this.assessmentsService.create(schoolId, user.userId, dto);
  }

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/assessments
  // ─────────────────────────────────────────────
  @Get()
  @ApiOperation({
    summary: 'List assessments (filter by subject, class, type)',
  })
  @ApiQuery({ name: 'subjectId', required: false, type: String })
  @ApiQuery({ name: 'classId', required: false, type: String })
  @ApiQuery({ name: 'type', required: false, enum: AssessmentType })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Paginated assessment list' })
  findAll(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
    @Query('subjectId') subjectId?: string,
    @Query('classId') classId?: string,
    @Query('type') type?: AssessmentType,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    return this.assessmentsService.findAll(schoolId, {
      subjectId,
      classId,
      type,
      page: page ? parseInt(page) : undefined,
      limit: limit ? parseInt(limit) : undefined,
    });
  }

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/assessments/:assessmentId
  // ─────────────────────────────────────────────
  @Get(':assessmentId')
  @UseGuards(AssessmentsPermissionsGuard)
  @ApiOperation({ summary: 'Get a single assessment' })
  @ApiResponse({ status: 200, description: 'Assessment returned' })
  @ApiResponse({ status: 404, description: 'Assessment not found' })
  findOne(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('assessmentId', ParseUUIDPipe) assessmentId: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    return this.assessmentsService.findOne(schoolId, assessmentId);
  }

  // ─────────────────────────────────────────────
  // PATCH /schools/:schoolId/assessments/:assessmentId
  // ─────────────────────────────────────────────
  @Patch(':assessmentId')
  @UseGuards(AssessmentsPermissionsGuard)
  @ApiOperation({ summary: 'Update an assessment (teacher/admin)' })
  @ApiResponse({ status: 200, description: 'Assessment updated' })
  update(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('assessmentId', ParseUUIDPipe) assessmentId: string,
    @Body() dto: UpdateAssessmentDto,
    // @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    // this.assertSameSchool(schoolId, user.schoolId);
    // this.assertCanManageAssessments(user);
    return this.assessmentsService.update(schoolId, assessmentId, dto);
  }

  // ─────────────────────────────────────────────
  // DELETE /schools/:schoolId/assessments/:assessmentId
  // ─────────────────────────────────────────────
  @Delete(':assessmentId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete an assessment (admin only)' })
  @ApiResponse({ status: 204, description: 'Assessment deleted' })
  remove(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('assessmentId', ParseUUIDPipe) assessmentId: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    this.assertAdmin(user);
    return this.assessmentsService.remove(schoolId, assessmentId);
  }

  // ─────────────────────────────────────────────
  // POST /schools/:schoolId/assessments/:assessmentId/scores
  // ─────────────────────────────────────────────
  @Post(':assessmentId/scores')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Bulk submit scores for an assessment (idempotent)',
    description: 'Re-submitting overwrites existing scores for those students.',
  })
  @ApiResponse({ status: 200, description: 'Scores submitted' })
  bulkSubmitScores(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('assessmentId', ParseUUIDPipe) assessmentId: string,
    @Body() dto: BulkScoresDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    this.assertCanManageAssessments(user);
    return this.assessmentsService.bulkSubmitScores(
      schoolId,
      assessmentId,
      user.userId,
      dto,
    );
  }

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/assessments/:assessmentId/scores
  // ─────────────────────────────────────────────
  @Get(':assessmentId/scores')
  @ApiOperation({ summary: 'Get all scores for an assessment' })
  @ApiResponse({ status: 200, description: 'Scores with grade and ranking' })
  getScores(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('assessmentId', ParseUUIDPipe) assessmentId: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    return this.assessmentsService.getScores(schoolId, assessmentId);
  }

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/students/:studentId/results
  // ─────────────────────────────────────────────
  @Get('/students/:studentId/results')
  @ApiOperation({
    summary: 'Get full results for a student grouped by subject',
  })
  @ApiResponse({ status: 200, description: 'Student results returned' })
  getStudentResults(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('studentId', ParseUUIDPipe) studentId: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    return this.assessmentsService.getStudentResults(schoolId, studentId);
  }

  // ──────────────────────────
  // GUARDS
  // ──────────────────────────
  private assertSameSchool(schoolId: string, userSchoolId: string) {
    if (schoolId !== userSchoolId) {
      throw new ForbiddenException('You do not have access to this school.');
    }
  }

  private assertCanManageAssessments(user: JWTStrategy.ValidatedUser) {
    const allowed = [
      'admin',
      'principal',
      'vice_principal',
      'class_teacher',
      'subject_teacher',
    ];
    if (!allowed.includes(user.role)) {
      throw new ForbiddenException(
        'You do not have permission to manage assessments.',
      );
    }
  }

  private assertAdmin(user: JWTStrategy.ValidatedUser) {
    const allowed = ['admin', 'principal', 'vice_principal'];
    if (!allowed.includes(user.role)) {
      throw new ForbiddenException('Admin access required.');
    }
  }
}
