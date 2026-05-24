import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
  ParseUUIDPipe,
  Req,
  Headers,
} from '@nestjs/common';
import type { RawBodyRequest } from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiParam,
  ApiQuery,
  ApiResponse,
  ApiExcludeEndpoint,
} from '@nestjs/swagger';
import type { Request } from 'express';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import * as JWTStrategy from '../auth/strategies/jwt.strategy';
import { PaymentsService } from './payments.service';
import { InitiatePaymentDto, PaymentQueryDto } from './dto/create-payments.dto';
import { ForbiddenException } from '@nestjs/common';
import { Public } from '../../common/decorators/public.decorator';

// ── School-scoped payments controller ────────────────────────────────────────
@ApiTags('Payments')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('schools/:schoolId/payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  private assertSameSchool(schoolId: string, userSchoolId: string) {
    console.log('Checking if user belongs to the same school:', userSchoolId);
    if (schoolId !== userSchoolId) {
      console.log('User does not belong to the same school.');
      throw new ForbiddenException('You do not have access to this school.');
    }
  }

  private assertCanPay(user: JWTStrategy.ValidatedUser) {
    console.log('Checking if user role allows initiating payments:', user.role);
    const allowed = [
      'admin',
      'principal',
      'vice_principal',
      'bursar',
      'parent',
      'student',
    ];
    console.log('Checking if user role allows initiating payments:', user.role);
    if (!allowed.includes(user.role)) {
      console.log(
        'User with this role is not allowed to initiate payments:',
        user.role,
      );
      throw new ForbiddenException(
        'You do not have permission to initiate payments.',
      );
    }
  }

  private assertBursarOrAdmin(user: JWTStrategy.ValidatedUser) {
    console.log(
      'Checking if user has bursar or admin role for payments access',
    );
    const allowed = ['admin', 'principal', 'vice_principal', 'bursar'];
    if (!allowed.includes(user.role)) {
      console.log('User role:', user.role);
      throw new ForbiddenException('Bursar or admin access required.');
    }
  }

  // ─────────────────────────────────────────────
  // POST /schools/:schoolId/payments/initiate
  // ─────────────────────────────────────────────
  @Post('initiate')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Initiate a Paystack payment',
    description:
      'Returns authorization_url — redirect user to this URL to complete payment.',
  })
  @ApiParam({ name: 'schoolId', type: String })
  @ApiResponse({
    status: 201,
    description: 'Payment initiated, authorization URL returned.',
  })
  initiate(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Body() dto: InitiatePaymentDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    this.assertCanPay(user);
    console.log('Initiating payment for student', dto.studentId);
    return this.paymentsService.initiate(schoolId, dto);
  }

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/payments
  // ─────────────────────────────────────────────
  @Get()
  @ApiOperation({ summary: 'List payments for a school (bursar/admin)' })
  @ApiParam({ name: 'schoolId', type: String })
  @ApiQuery({ name: 'studentId', required: false, type: String })
  @ApiQuery({
    name: 'status',
    required: false,
    enum: ['pending', 'success', 'failed'],
  })
  @ApiQuery({
    name: 'term',
    required: false,
    enum: ['first', 'second', 'third'],
  })
  @ApiQuery({ name: 'academicYear', required: false, type: String })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  findAll(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Query() query: PaymentQueryDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    console.log('User role for payments access:', user.role);
    this.assertBursarOrAdmin(user);
    console.log('Query:', query);
    return this.paymentsService.findAll(schoolId, query);
  }

  // ─────────────────────────────────────────────
  // GET /schools/:schoolId/payments/:id/receipt
  // ─────────────────────────────────────────────
  @Get(':paymentId/receipt')
  @ApiOperation({ summary: 'Get payment receipt details (redirects to PDF)' })
  @ApiParam({ name: 'schoolId', type: String })
  @ApiParam({ name: 'paymentId', type: String })
  getReceipt(
    @Param('schoolId', ParseUUIDPipe) schoolId: string,
    @Param('paymentId', ParseUUIDPipe) paymentId: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.assertSameSchool(schoolId, user.schoolId);
    console.log('Getting receipt for payment', paymentId);
    return this.paymentsService.getReceipt(schoolId, paymentId);
  }
}

// ── Webhook controller — NO auth, public endpoint ────────────────────────────
@ApiTags('Webhooks')
@Controller('webhooks')
export class PaystackWebhookController {
  constructor(private readonly paymentsService: PaymentsService) {}

  // ─────────────────────────────────────────────
  // POST /api/v1/webhooks/paystack
  // ─────────────────────────────────────────────
  @Public()
  @Post('paystack')
  @HttpCode(HttpStatus.OK)
  @ApiExcludeEndpoint() // hide from Swagger — Paystack calls this, not clients
  async handleWebhook(
    @Req() req: RawBodyRequest<Request>,
    @Headers('x-paystack-signature') signature: string,
  ) {
    // rawBody is available because we enable rawBody in main.ts:
    // app = await NestFactory.create(AppModule, { rawBody: true })
    const rawBody = req.rawBody;

    if (!rawBody) {
      console.log('No raw body');
      return { received: false, reason: 'No raw body' };
    }

    console.log('Received Paystack webhook with signature:', signature);
    return this.paymentsService.handleWebhook(rawBody, signature);
  }

  // Get endpoint for testing webhook reception (not used by Paystack)
  @Public()
  @Get('paystack')
  @HttpCode(HttpStatus.OK)
  @ApiExcludeEndpoint()
  testWebhook() {
    console.log('Received test GET request to Paystack webhook endpoint');
    return { received: true, message: 'Webhook endpoint is reachable' };
  }
}
