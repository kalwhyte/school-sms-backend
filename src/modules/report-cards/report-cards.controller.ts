import {
  Controller,
  Get,
  Post,
  Body,
  Param,
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
} from '@nestjs/swagger';
import { ReportCardsService } from './report-cards.service';
import {
  GenerateReportCardDto,
  GenerateClassReportCardsDto,
  PublishReportCardsDto,
} from './dto/report-card.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import * as JWTStrategy from '../auth/strategies/jwt.strategy';

@ApiTags('Report Cards')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('schools/:schoolId/report-cards')
export class ReportCardsController {
  constructor(private readonly reportCardsService: ReportCardsService) {}

  // ─────────────────────────────────────────────
  // POST /schools/:schoolId/report-cards/generate/student
  // Generate for a single student
  // ─────────────────────────────────────────────
  @Post('generate/student')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Generate report card for a single student (admin)',
  })
  @ApiResponse({
    status: 200,
    description: 'Report card generated with aggregated scores',
  })
  generateForStudent(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Body() dto: GenerateReportCardDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    this.assertAdmin(user);
    return this.reportCardsService.generateForStudent(schoolId, dto);
  }

  // ─────────────────────────────────────────────
  // POST /schools/:schoolId/report-cards/generate/class
  // Generate for an entire class
  // ─────────────────────────────────────────────
  @Post('generate/class')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Bulk generate report cards for an entire class (admin)',
  })
  @ApiResponse({
    status: 200,
    description: 'Bulk generation result with failed list',
  })
  generateForClass(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Body() dto: GenerateClassReportCardsDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    this.assertAdmin(user);
    return this.reportCardsService.generateForClass(schoolId, dto);
  }

  // ─────────────────────────────────────────────
  // POST /schools/:schoolId/report-cards/publish
  // Publish all report cards for a class+term
  // ─────────────────────────────────────────────
  @Post('publish')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Publish report cards for a class and term (admin)',
  })
  @ApiResponse({ status: 200, description: 'Report cards published' })
  publish(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Body() dto: PublishReportCardsDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    this.assertAdmin(user);
    return this.reportCardsService.publish(schoolId, dto);
  }

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/report-cards/student/:studentId
  // List all report cards for a student
  // ─────────────────────────────────────────────
  @Get('student/:studentId')
  @ApiOperation({ summary: "List a student's report cards" })
  @ApiResponse({ status: 200, description: 'Report card list returned' })
  findForStudent(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('studentId', ParseUUIDPipe) studentId: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    return this.reportCardsService.findForStudent(schoolId, studentId);
  }

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/report-cards/:reportCardId
  // Get full report card with scores
  // ─────────────────────────────────────────────
  @Get(':reportCardId')
  @ApiOperation({
    summary: 'Get full report card with aggregated subject scores',
  })
  @ApiResponse({ status: 200, description: 'Full report card returned' })
  @ApiResponse({ status: 404, description: 'Report card not found' })
  findOne(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('reportCardId', ParseUUIDPipe) reportCardId: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    return this.reportCardsService.findOne(schoolId, reportCardId);
  }

  // ─────────────────────────────────────────────
  // GUARDS
  // ─────────────────────────────────────────────
  private assertSameSchool(schoolId: string, userSchoolId: string) {
    if (schoolId !== userSchoolId) {
      throw new ForbiddenException('You do not have access to this school.');
    }
  }

  private assertAdmin(user: JWTStrategy.ValidatedUser) {
    const allowed = ['admin', 'principal', 'vice_principal'];
    if (!allowed.includes(user.role)) {
      throw new ForbiddenException('Admin access required.');
    }
  }
}
