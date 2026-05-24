import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { FeesService } from '../fees/fees.service';
import { InitiatePaymentDto, PaymentQueryDto } from './dto/create-payments.dto';
import { PaymentStatus } from '@prisma/client';
import {
  PaystackInitResponse,
  PaystackWebhookPayload,
} from './interfaces/index.interface';
import { PaymentsHelper } from './services/index.service';

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);
  private readonly paystackSecretKey: string;
  private readonly paystackBaseUrl = 'https://api.paystack.co';

  constructor(
    private readonly prisma: PrismaService,
    private readonly feesService: FeesService,
    private readonly config: ConfigService,
    private readonly helper: PaymentsHelper,
  ) {
    this.paystackSecretKey = this.config.getOrThrow<string>(
      'PAYSTACK_SECRET_KEY',
    );
  }

  // ═══════════════════════════════════════════════════════════
  // INITIATE PAYMENT
  // ═══════════════════════════════════════════════════════════

  async initiate(schoolId: string, dto: InitiatePaymentDto) {
    // Verify student belongs to school
    const student = await this.prisma.student.findFirst({
      where: { id: dto.studentId, schoolId },
      select: {
        id: true,
        fullName: true,
        admissionNumber: true,
        user: { select: { email: true, phone: true } },
      },
    });
    if (!student) throw new NotFoundException('Student not found.');

    // Need an email for Paystack — fall back to a generated one if none set
    const email =
      student.user?.email ??
      `${student.admissionNumber.toLowerCase().replace(/\//g, '.')}@edutrack.local`;

    // Create a pending payment record first — reference comes from Paystack
    const payment = await this.prisma.payment.create({
      data: {
        studentId: dto.studentId,
        schoolId,
        amount: dto.amount / 100, // store in naira, Paystack sends kobo
        status: PaymentStatus.pending,
        term: dto.term ?? null,
        academicYear: dto.academicYear ?? null,
        paymentMethod: 'paystack',
      },
    });

    // Call Paystack initialize
    const paystackRes = await fetch(
      `${this.paystackBaseUrl}/transaction/initialize`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${this.paystackSecretKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          email,
          amount: dto.amount, // kobo
          reference: payment.id, // use our payment UUID as the reference
          metadata: {
            paymentId: payment.id,
            studentId: dto.studentId,
            schoolId,
            term: dto.term,
            academicYear: dto.academicYear,
          },
        }),
      },
    );

    if (!paystackRes.ok) {
      // Clean up the pending record
      await this.prisma.payment.delete({ where: { id: payment.id } });
      throw new BadRequestException(
        'Failed to initialize payment with Paystack.',
      );
    }

    const paystackData = (await paystackRes.json()) as PaystackInitResponse;

    if (!paystackData.status) {
      await this.prisma.payment.delete({ where: { id: payment.id } });
      throw new BadRequestException(paystackData.message);
    }

    // Store the Paystack reference and access code
    await this.prisma.payment.update({
      where: { id: payment.id },
      data: {
        paystackReference: paystackData.data.reference,
        paystackAccessCode: paystackData.data.access_code,
      },
    });

    this.logger.log(
      `Payment initiated: ${payment.id} — ₦${dto.amount / 100} for student ${student.admissionNumber}`,
    );

    return {
      paymentId: payment.id,
      authorizationUrl: paystackData.data.authorization_url,
      accessCode: paystackData.data.access_code,
      reference: paystackData.data.reference,
      amount: dto.amount / 100,
      student: {
        id: student.id,
        fullName: student.fullName,
        admissionNumber: student.admissionNumber,
      },
    };
  }

  // ═══════════════════════════════════════════════════════════
  // PAYSTACK WEBHOOK
  // ═══════════════════════════════════════════════════════════

  async handleWebhook(rawBody: Buffer, signature: string) {
    // 1. Verify HMAC-SHA512 signature
    this.helper.verifySignature(rawBody, signature);

    const payload = JSON.parse(rawBody.toString()) as PaystackWebhookPayload;
    const { event, data } = payload;

    this.logger.log(
      `Paystack webhook received: ${event} — ref: ${data.reference}`,
    );

    // 2. Only handle charge.success
    if (event !== 'charge.success') {
      return { received: true };
    }

    // 3. Find payment by reference — idempotent check
    const payment = await this.prisma.payment.findUnique({
      where: { paystackReference: data.reference },
    });

    if (!payment) {
      this.logger.warn(
        `Webhook: no payment found for reference ${data.reference}`,
      );
      return { received: true };
    }

    // 4. Already processed — idempotent, ignore duplicate
    if (payment.status === PaymentStatus.success) {
      this.logger.log(
        `Webhook: payment ${payment.id} already processed, skipping.`,
      );
      console.log(payment);
      return { received: true };
    }

    // 5. Mark payment as success
    const updatedPayment = await this.prisma.payment.update({
      where: { id: payment.id },
      data: {
        status: PaymentStatus.success,
        paidAt: new Date(data.paid_at),
      },
    });

    // 6. Sync fee ledger
    if (updatedPayment.term && updatedPayment.academicYear) {
      await this.feesService.syncLedger(
        updatedPayment.studentId,
        updatedPayment.schoolId,
        updatedPayment.term,
        updatedPayment.academicYear,
      );
    }

    // 7. Generate receipt record (PDF generation stubbed — plug in PDFKit/Cloudinary)
    const receipt = await this.prisma.paymentReceipt.create({
      data: {
        paymentId: payment.id,
        pdfUrl: '', // TODO: generate PDF, upload to Cloudinary, store URL
        generatedAt: new Date(),
      },
    });

    // 8. Notify student/parent
    await this.helper.sendPaymentNotification(
      updatedPayment.studentId,
      updatedPayment,
    );

    this.logger.log(
      `Payment ${payment.id} marked success — receipt ${receipt.id} created`,
    );

    return { received: true };
  }

  // ═══════════════════════════════════════════════════════════
  // LIST PAYMENTS
  // ═══════════════════════════════════════════════════════════

  async findAll(schoolId: string, query: PaymentQueryDto) {
    const page = Math.max(1, query.page ?? 1);
    const limit = Math.min(100, Math.max(1, query.limit ?? 20));
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = { schoolId };
    if (query.studentId) where.studentId = query.studentId;
    if (query.status) where.status = query.status;
    if (query.term) where.term = query.term;
    if (query.academicYear) where.academicYear = query.academicYear;

    const [data, total] = await Promise.all([
      this.prisma.payment.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          student: {
            select: { id: true, fullName: true, admissionNumber: true },
          },
          receipt: { select: { id: true, pdfUrl: true, generatedAt: true } },
        },
      }),
      this.prisma.payment.count({ where }),
    ]);

    return {
      data: data.map((p) => ({
        ...p,
        amount: Number(p.amount),
      })),
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  // ═══════════════════════════════════════════════════════════
  // GET RECEIPT
  // ═══════════════════════════════════════════════════════════

  async getReceipt(schoolId: string, paymentId: string) {
    const payment = await this.prisma.payment.findFirst({
      where: { id: paymentId, schoolId },
      include: {
        receipt: true,
        student: {
          select: { id: true, fullName: true, admissionNumber: true },
        },
      },
    });

    if (!payment) throw new NotFoundException('Payment not found.');
    if (!payment.receipt) {
      throw new NotFoundException(
        'Receipt not yet generated for this payment.',
      );
    }
    if (payment.status !== PaymentStatus.success) {
      throw new BadRequestException(
        'Receipt only available for successful payments.',
      );
    }

    return {
      paymentId: payment.id,
      amount: Number(payment.amount),
      term: payment.term,
      academicYear: payment.academicYear,
      paidAt: payment.paidAt,
      student: payment.student,
      receipt: {
        id: payment.receipt.id,
        pdfUrl: payment.receipt.pdfUrl,
        generatedAt: payment.receipt.generatedAt,
      },
    };
  }
}
