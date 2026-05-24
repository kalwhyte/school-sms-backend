import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
  ParseUUIDPipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiParam,
  ApiQuery,
  ApiResponse,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import * as jwtStrategy from '../auth/strategies/jwt.strategy';
import { LeaveRequestsService } from './leave-requests.service';
import { LeaveRequestsPermissionsGuard } from './guards/permissions.guard';
import {
  CreateLeaveRequestDto,
  DecideLeaveRequestDto,
  LeaveRequestQueryDto,
} from './dto/leave-requests.dto';

@ApiTags('Leave Requests')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, LeaveRequestsPermissionsGuard)
@Controller('schools/:schoolId/leave-requests')
export class LeaveRequestsController {
  constructor(
    private readonly service: LeaveRequestsService,
    private readonly guard: LeaveRequestsPermissionsGuard,
  ) {}

  // ─────────────────────────────────────────────
  // POST /schools/:schoolId/leave-requests
  // ─────────────────────────────────────────────
  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Submit a leave request (parent)',
    description:
      'Creates a pending leave request for a student. On approval, attendance is automatically marked excused.',
  })
  @ApiParam({ name: 'schoolId', type: String })
  @ApiResponse({ status: 201, description: 'Leave request submitted.' })
  @ApiResponse({
    status: 400,
    description: 'Overlapping request exists or invalid date range.',
  })
  create(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Body() dto: CreateLeaveRequestDto,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    this.guard.assertCanSubmit(user);
    return this.service.create(schoolId, user.userId, dto);
  }

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/leave-requests
  // ─────────────────────────────────────────────
  @Get()
  @ApiOperation({
    summary: 'List leave requests (filter by status, studentId)',
  })
  @ApiParam({ name: 'schoolId', type: String })
  @ApiQuery({
    name: 'status',
    required: false,
    enum: ['pending', 'approved', 'rejected'],
  })
  @ApiQuery({ name: 'studentId', required: false, type: String })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  findAll(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Query() query: LeaveRequestQueryDto,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    this.guard.assertCanView(user);
    return this.service.findAll(schoolId, query);
  }

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/leave-requests/:id
  // ─────────────────────────────────────────────
  @Get(':leaveRequestId')
  @ApiOperation({ summary: 'Get a single leave request' })
  @ApiParam({ name: 'schoolId', type: String })
  @ApiParam({ name: 'leaveRequestId', type: String })
  findOne(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('leaveRequestId', ParseUUIDPipe) leaveRequestId: string,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    this.guard.assertCanView(user);
    return this.service.findOne(schoolId, leaveRequestId);
  }

  // ─────────────────────────────────────────────
  // POST /schools/:schoolId/leave-requests/:id/decide
  // ─────────────────────────────────────────────
  @Post(':leaveRequestId/decide')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Approve or reject a leave request (admin / class teacher)',
    description:
      'On approval, attendance records in the date range are automatically set to excused.',
  })
  @ApiParam({ name: 'schoolId', type: String })
  @ApiParam({ name: 'leaveRequestId', type: String })
  @ApiResponse({ status: 200, description: 'Decision recorded.' })
  @ApiResponse({ status: 400, description: 'Request already decided.' })
  decide(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('leaveRequestId', ParseUUIDPipe) leaveRequestId: string,
    @Body() dto: DecideLeaveRequestDto,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    this.guard.assertCanDecide(user);
    return this.service.decide(schoolId, leaveRequestId, user.userId, dto);
  }
}
