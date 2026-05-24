import {
  Controller,
  Get,
  Patch,
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
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import * as jwtStrategy from '../auth/strategies/jwt.strategy';

@ApiTags('Notifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('schools/:schoolId/notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/notifications
  // ─────────────────────────────────────────────
  @Get()
  @ApiOperation({ summary: 'List notifications for the current user' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'unreadOnly', required: false, type: Boolean })
  @ApiResponse({
    status: 200,
    description: 'Paginated notifications with unread count',
  })
  findAll(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('unreadOnly') unreadOnly?: string,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    return this.notificationsService.findAll(schoolId, user.userId, {
      page: page ? parseInt(page) : undefined,
      limit: limit ? parseInt(limit) : undefined,
      unreadOnly: unreadOnly === 'true',
    });
  }

  // ─────────────────────────────────────────────
  // PATCH /schools/:schoolId/notifications/:notificationId/read
  // ─────────────────────────────────────────────
  @Patch(':notificationId/read')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark a single notification as read' })
  @ApiResponse({ status: 200, description: 'Notification marked as read' })
  markRead(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('notificationId', ParseUUIDPipe) notificationId: string,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    return this.notificationsService.markRead(
      schoolId,
      user.userId,
      notificationId,
    );
  }

  // ─────────────────────────────────────────────
  // PATCH /schools/:schoolId/notifications/read-all
  // ─────────────────────────────────────────────
  @Patch('read-all')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark all notifications as read' })
  @ApiResponse({ status: 200, description: 'All notifications marked as read' })
  markAllRead(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    return this.notificationsService.markAllRead(schoolId, user.userId);
  }

  private assertSameSchool(schoolId: string, userSchoolId: string) {
    if (schoolId !== userSchoolId) {
      throw new ForbiddenException('You do not have access to this school.');
    }
  }
}
