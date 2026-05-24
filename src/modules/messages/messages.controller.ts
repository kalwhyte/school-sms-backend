import {
  Controller,
  Get,
  Post,
  Patch,
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
import { MessagesService } from './messages.service';
import { CreateThreadDto, SendMessageDto } from './dto/messages.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import * as jwtStrategy from '../auth/strategies/jwt.strategy';

@ApiTags('Messages')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('schools/:schoolId/messages/threads')
export class MessagesController {
  constructor(private readonly messagesService: MessagesService) {}

  // ─────────────────────────────────────────────
  // POST /schools/:schoolId/messages/threads
  // Start a thread (parent only)
  // ─────────────────────────────────────────────
  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Start a message thread (parent only)',
    description:
      'Creates a thread between the calling parent and a teacher regarding a student. Idempotent — returns existing thread if one already exists.',
  })
  @ApiResponse({
    status: 201,
    description: 'Thread created with first message',
  })
  @ApiResponse({ status: 403, description: 'Only parents can start threads' })
  createThread(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Body() dto: CreateThreadDto,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    return this.messagesService.createThread(schoolId, user.userId, dto);
  }

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/messages/threads
  // List threads for current user
  // ─────────────────────────────────────────────
  @Get()
  @ApiOperation({ summary: 'List message threads for the current user' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({
    status: 200,
    description: 'Paginated thread list with last message preview',
  })
  findThreads(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    return this.messagesService.findThreads(schoolId, user.userId, user.role, {
      page: page ? parseInt(page) : undefined,
      limit: limit ? parseInt(limit) : undefined,
    });
  }

  // ─────────────────────────────────────────────
  // POST /schools/:schoolId/messages/threads/:threadId
  // Send a message (must be declared before GET :threadId)
  // ─────────────────────────────────────────────
  @Post(':threadId')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Send a message in a thread',
    description: 'Students cannot send messages — read only.',
  })
  @ApiResponse({ status: 201, description: 'Message sent' })
  @ApiResponse({
    status: 403,
    description: 'Not a participant or student role',
  })
  sendMessage(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('threadId', ParseUUIDPipe) threadId: string,
    @Body() dto: SendMessageDto,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    return this.messagesService.sendMessage(
      schoolId,
      threadId,
      user.userId,
      user.role,
      dto,
    );
  }

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/messages/threads/:threadId
  // Get messages in a thread (paginated)
  // ─────────────────────────────────────────────
  @Get(':threadId')
  @ApiOperation({
    summary: 'Get messages in a thread (paginated, newest first)',
  })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({
    status: 200,
    description: 'Paginated messages with sender info',
  })
  findMessages(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('threadId', ParseUUIDPipe) threadId: string,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    return this.messagesService.findMessages(
      schoolId,
      threadId,
      user.userId,
      user.role,
      {
        page: page ? parseInt(page) : undefined,
        limit: limit ? parseInt(limit) : undefined,
      },
    );
  }

  // ─────────────────────────────────────────────
  // PATCH /schools/:schoolId/messages/threads/:threadId/read
  // Mark all messages in thread as read
  // ─────────────────────────────────────────────
  @Patch(':threadId/read')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Mark all unread messages in thread as read' })
  @ApiResponse({ status: 200, description: 'Messages marked as read' })
  markThreadRead(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('threadId', ParseUUIDPipe) threadId: string,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    return this.messagesService.markThreadRead(
      schoolId,
      threadId,
      user.userId,
      user.role,
    );
  }

  private assertSameSchool(schoolId: string, userSchoolId: string) {
    if (schoolId !== userSchoolId) {
      throw new ForbiddenException('You do not have access to this school.');
    }
  }
}
