import {
  Controller,
  Get,
  Post,
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
import { AnnouncementsService } from './announcements.service';
import { CreateAnnouncementDto } from './dto/announcements.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import * as jwtStrategy from '../auth/strategies/jwt.strategy';

@ApiTags('Announcements')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('schools/:schoolId/announcements')
export class AnnouncementsController {
  constructor(private readonly announcementsService: AnnouncementsService) {}

  // ─────────────────────────────────────────────
  // POST /schools/:schoolId/announcements
  // Create + fan-out notifications
  // ─────────────────────────────────────────────
  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create announcement and fan out notifications to target audience',
    description:
      'Notifications are fanned out asynchronously after creation. Audience: all | parents | teachers | class (requires classId).',
  })
  @ApiResponse({
    status: 201,
    description: 'Announcement created, notifications queued',
  })
  @ApiResponse({
    status: 400,
    description: 'classId required for class audience',
  })
  create(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Body() dto: CreateAnnouncementDto,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    this.assertCanAnnounce(user);
    return this.announcementsService.create(schoolId, user.userId, dto);
  }

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/announcements
  // List — scoped to user's role and class
  // ─────────────────────────────────────────────
  @Get()
  @ApiOperation({
    summary: "List announcements scoped to the current user's audience",
  })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Paginated announcements' })
  findAll(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);

    // Resolve the user's classId for class-specific announcements
    // Students have a classId on their profile — fetched in service
    // const userClassId = null; // resolved in service via studentId if needed

    return this.announcementsService.findAll(
      schoolId,
      user.userId,
      user.role,
      // userClassId,
      {
        page: page ? parseInt(page) : undefined,
        limit: limit ? parseInt(limit) : undefined,
      },
    );
  }

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/announcements/:announcementId
  // ─────────────────────────────────────────────
  @Get(':announcementId')
  @ApiOperation({ summary: 'Get a single announcement' })
  @ApiResponse({ status: 200, description: 'Announcement returned' })
  @ApiResponse({ status: 404, description: 'Announcement not found' })
  findOne(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('announcementId', ParseUUIDPipe) announcementId: string,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    return this.announcementsService.findOne(schoolId, announcementId);
  }

  // ─────────────────────────────────────────────
  // DELETE /schools/:schoolId/announcements/:announcementId
  // ─────────────────────────────────────────────
  @Delete(':announcementId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete an announcement (admin/teacher)' })
  @ApiResponse({ status: 204, description: 'Announcement deleted' })
  remove(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('announcementId', ParseUUIDPipe) announcementId: string,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    this.assertCanAnnounce(user);
    return this.announcementsService.remove(schoolId, announcementId);
  }

  // ─────────────────────────────────────────────
  // GUARDS
  // ─────────────────────────────────────────────
  private assertSameSchool(schoolId: string, userSchoolId: string) {
    if (schoolId !== userSchoolId) {
      throw new ForbiddenException('You do not have access to this school.');
    }
  }

  private assertCanAnnounce(user: jwtStrategy.ValidatedUser) {
    const allowed = [
      'admin',
      'principal',
      'vice_principal',
      'class_teacher',
      'subject_teacher',
    ];
    if (!allowed.includes(user.role)) {
      throw new ForbiddenException(
        'You do not have permission to create announcements.',
      );
    }
  }
}
