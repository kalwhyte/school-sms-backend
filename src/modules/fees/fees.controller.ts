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
import * as JWTStrategy from '../auth/strategies/jwt.strategy';
import { FeesService } from './fees.service';
import { FeesPermissionsGuard } from './guards/permissions.guard';
import {
  CreateFeeStructureDto,
  UpdateFeeStructureDto,
  FeeStructureQueryDto,
  CreateBursaryApprovalDto,
  BursaryQueryDto,
  CreateExpenseDto,
  ExpenseQueryDto,
} from './dto/create-fees.dto';
import { Term } from '@prisma/client';

@ApiTags('Fees')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, FeesPermissionsGuard)
@Controller('schools/:schoolId')
export class FeesController {
  constructor(
    private readonly feesService: FeesService,
    private readonly guard: FeesPermissionsGuard,
  ) {}

  // ═══════════════════════════════════════════════════════════
  // FEE STRUCTURES
  // ═══════════════════════════════════════════════════════════

  @Post('fee-structures')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create a fee structure for a class/term (admin/bursar)',
  })
  @ApiParam({ name: 'schoolId', type: String })
  @ApiResponse({ status: 201, description: 'Fee structure created.' })
  createFeeStructure(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Body() dto: CreateFeeStructureDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.guard.assertBursarOrAdmin(user);
    return this.feesService.createFeeStructure(schoolId, dto);
  }

  @Get('fee-structures')
  @ApiOperation({ summary: 'List fee structures (admin/bursar)' })
  @ApiParam({ name: 'schoolId', type: String })
  @ApiQuery({
    name: 'term',
    required: false,
    enum: ['first', 'second', 'third'],
  })
  @ApiQuery({ name: 'academicYear', required: false, type: String })
  @ApiQuery({ name: 'classId', required: false, type: String })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  findAllFeeStructures(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Query() query: FeeStructureQueryDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.guard.assertBursarOrAdmin(user);
    return this.feesService.findAllFeeStructures(schoolId, query);
  }

  @Patch('fee-structures/:feeStructureId')
  @ApiOperation({ summary: 'Update a fee structure (admin/bursar)' })
  @ApiParam({ name: 'schoolId', type: String })
  @ApiParam({ name: 'feeStructureId', type: String })
  updateFeeStructure(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('feeStructureId', ParseUUIDPipe) feeStructureId: string,
    @Body() dto: UpdateFeeStructureDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.guard.assertBursarOrAdmin(user);
    return this.feesService.updateFeeStructure(schoolId, feeStructureId, dto);
  }

  // ═══════════════════════════════════════════════════════════
  // STUDENT FEE LEDGER
  // ═══════════════════════════════════════════════════════════

  @Get('fee-ledger/:studentId')
  @ApiOperation({ summary: "Get student's fee ledger with balance summary" })
  @ApiParam({ name: 'schoolId', type: String })
  @ApiParam({ name: 'studentId', type: String })
  getStudentLedger(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('studentId', ParseUUIDPipe) studentId: string,
    // No extra guard — FeesPermissionsGuard allows student/parent/bursar/admin
  ) {
    return this.feesService.getStudentLedger(schoolId, studentId);
  }

  // ═══════════════════════════════════════════════════════════
  // BURSARY APPROVALS
  // ═══════════════════════════════════════════════════════════

  @Post('bursary-approvals')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create a bursary discount for a student (bursar/admin)',
  })
  @ApiParam({ name: 'schoolId', type: String })
  createBursaryApproval(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Body() dto: CreateBursaryApprovalDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.guard.assertBursarOrAdmin(user);
    return this.feesService.createBursaryApproval(schoolId, user.userId, dto);
  }

  @Get('bursary-approvals')
  @ApiOperation({ summary: 'List bursary approvals (bursar/admin)' })
  @ApiParam({ name: 'schoolId', type: String })
  @ApiQuery({ name: 'studentId', required: false, type: String })
  @ApiQuery({
    name: 'term',
    required: false,
    enum: ['first', 'second', 'third'],
  })
  @ApiQuery({ name: 'academicYear', required: false, type: String })
  findAllBursaryApprovals(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Query() query: BursaryQueryDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.guard.assertBursarOrAdmin(user);
    return this.feesService.findAllBursaryApprovals(schoolId, query);
  }

  // ═══════════════════════════════════════════════════════════
  // EXPENSES
  // ═══════════════════════════════════════════════════════════

  @Post('expenses')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Record a school expense (bursar/admin)' })
  @ApiParam({ name: 'schoolId', type: String })
  createExpense(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Body() dto: CreateExpenseDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.guard.assertBursarOrAdmin(user);
    return this.feesService.createExpense(schoolId, user.userId, dto);
  }

  @Get('expenses')
  @ApiOperation({ summary: 'List school expenses (bursar/admin)' })
  @ApiParam({ name: 'schoolId', type: String })
  @ApiQuery({ name: 'category', required: false })
  @ApiQuery({ name: 'from', required: false, type: String })
  @ApiQuery({ name: 'to', required: false, type: String })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  findAllExpenses(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Query() query: ExpenseQueryDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.guard.assertBursarOrAdmin(user);
    return this.feesService.findAllExpenses(schoolId, query);
  }

  // ═══════════════════════════════════════════════════════════
  // FINANCE SUMMARY
  // ═══════════════════════════════════════════════════════════

  @Get('finance/summary')
  @ApiOperation({
    summary:
      'School-wide finance summary — totals, collection rate, expense breakdown (bursar/admin)',
  })
  @ApiParam({ name: 'schoolId', type: String })
  @ApiQuery({ name: 'academicYear', required: false, type: String })
  @ApiQuery({
    name: 'term',
    required: false,
    enum: ['first', 'second', 'third'],
  })
  getFinanceSummary(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
    @Query('academicYear') academicYear?: string,
    @Query('term') term?: Term,
  ) {
    this.guard.assertBursarOrAdmin(user);
    return this.feesService.getFinanceSummary(schoolId, academicYear, term);
  }
}
