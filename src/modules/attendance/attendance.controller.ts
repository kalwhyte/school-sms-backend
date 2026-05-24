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
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
  ApiQuery,
} from '@nestjs/swagger';
import { AttendanceService } from './attendance.service';
import { BulkAttendanceDto } from './dto/attendanceEntry.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import * as JWTStrategy from '../auth/strategies/jwt.strategy';
import { AttendanceGuard } from './guards/roles.guard';

@ApiTags('Attendance')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('schools/:schoolId/attendance')
export class AttendanceController {
  constructor(
    private readonly attendanceService: AttendanceService,
    private readonly attendanceGuard: AttendanceGuard,
  ) {}

  // ─────────────────────────────────────────────
  // POST /schools/:schoolId/attendance
  // Bulk submit for a class on a date (idempotent)
  // ─────────────────────────────────────────────
  @Post()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Bulk submit attendance for a class (idempotent)',
    description:
      'Submits attendance for all students in a class on a given date. Re-submitting the same date overwrites existing records.',
  })
  @ApiResponse({ status: 200, description: 'Attendance submitted' })
  @ApiResponse({ status: 404, description: 'Class not found' })
  bulkSubmit(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Body() dto: BulkAttendanceDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.attendanceGuard.assertSameSchool(schoolId, user.schoolId);
    this.attendanceGuard.assertCanMarkAttendance(user);
    return this.attendanceService.bulkSubmit(schoolId, user.userId, dto);
  }

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/attendance/class/:classId
  // Get attendance by class — single date or range
  // ─────────────────────────────────────────────
  @Get('class/:classId')
  @ApiOperation({ summary: 'Get attendance for a class by date or date range' })
  @ApiQuery({
    name: 'date',
    required: false,
    description: 'Single date YYYY-MM-DD',
  })
  @ApiQuery({
    name: 'from',
    required: false,
    description: 'Range start YYYY-MM-DD',
  })
  @ApiQuery({
    name: 'to',
    required: false,
    description: 'Range end YYYY-MM-DD',
  })
  @ApiResponse({
    status: 200,
    description: 'Attendance records grouped by date',
  })
  findByClass(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('classId', ParseUUIDPipe) classId: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
    @Query('date') date?: string,
    @Query('from') from?: string,
    @Query('to') to?: string,
  ) {
    this.attendanceGuard.assertSameSchool(schoolId, user.schoolId);
    return this.attendanceService.findByClass(schoolId, classId, {
      date,
      from,
      to,
    });
  }

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/attendance/student/:studentId/summary
  // ─────────────────────────────────────────────
  @Get('student/:studentId/summary')
  @ApiOperation({ summary: 'Get attendance summary for a student' })
  @ApiQuery({
    name: 'from',
    required: false,
    description: 'Range start YYYY-MM-DD',
  })
  @ApiQuery({
    name: 'to',
    required: false,
    description: 'Range end YYYY-MM-DD',
  })
  @ApiResponse({ status: 200, description: 'Attendance summary returned' })
  getStudentSummary(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('studentId', ParseUUIDPipe) studentId: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
    @Query('from') from?: string,
    @Query('to') to?: string,
  ) {
    this.attendanceGuard.assertSameSchool(schoolId, user.schoolId);
    return this.attendanceService.getStudentSummary(schoolId, studentId, {
      from,
      to,
    });
  }
}
