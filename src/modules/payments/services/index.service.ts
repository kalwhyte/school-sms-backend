import { Injectable, Logger, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHmac } from 'crypto';
import { PrismaService } from '../../../infrastructure/database/prisma.service';
import { Payment } from '@prisma/client';

@Injectable()
export class PaymentsHelper {
  private readonly logger = new Logger(PaymentsHelper.name);
  private readonly paystackSecretKey: string;

  constructor(
    private readonly prisma: PrismaService,
    configService: ConfigService,
  ) {
    this.paystackSecretKey = configService.getOrThrow<string>(
      'PAYSTACK_SECRET_KEY',
    );
  }
  // ═══════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════

  verifySignature(rawBody: Buffer, signature: string) {
    const hash = createHmac('sha512', this.paystackSecretKey)
      .update(rawBody)
      .digest('hex');

    if (hash !== signature) {
      this.logger.warn('Paystack webhook signature verification failed.');
      throw new UnauthorizedException('Invalid webhook signature.');
    }
  }

  async sendPaymentNotification(
    studentId: string,
    payment: Payment, // Change type to Payment
  ) {
    // Find parent user IDs linked to this student
    const parentLinks = await this.prisma.parentStudent.findMany({
      where: { studentId },
      include: { parent: { select: { userId: true } } },
    });

    // Also notify the student's own user account if they have one
    const student = await this.prisma.student.findUnique({
      where: { id: studentId },
      select: { userId: true, fullName: true },
    });

    const recipientUserIds: string[] = parentLinks.map(
      (pl) => pl.parent.userId,
    );
    if (student?.userId) recipientUserIds.push(student.userId);

    if (recipientUserIds.length === 0) return;

    // Construct the body message more robustly
    const termPart = payment.term ? `${payment.term} term` : '';
    const academicYearPart = payment.academicYear
      ? `${payment.academicYear}`
      : '';

    const descriptionParts: string[] = [];
    if (termPart) descriptionParts.push(termPart);
    if (academicYearPart) descriptionParts.push(academicYearPart);

    const description =
      descriptionParts.length > 0 ? `for ${descriptionParts.join(' ')}` : '';
    const bodyMessage = `Payment of ₦${Number(payment.amount).toLocaleString()} received ${description}.`;

    await this.prisma.notification.createMany({
      data: recipientUserIds.map((userId) => ({
        userId,
        schoolId: payment.schoolId,
        title: '✅ Payment Confirmed',
        body: bodyMessage,
        type: 'payment_success',
        data: {
          paymentId: payment.id,
          studentId,
          term: payment.term,
          academicYear: payment.academicYear,
        },
      })),
    });
  }
}
