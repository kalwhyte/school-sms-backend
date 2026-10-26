import {
  Injectable,
  InternalServerErrorException,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';

@Injectable()
export class EmailService {
  private readonly logger = new Logger(EmailService.name);
  private readonly transporter: nodemailer.Transporter;
  private readonly from: string;

  constructor(private readonly config: ConfigService) {
    const user = this.config.getOrThrow<string>('SMTP_USER');
    const pass = this.config.getOrThrow<string>('SMTP_PASS');
    const host = this.config.get<string>('SMTP_HOST', 'smtp.gmail.com');
    const port = Number(this.config.get<string>('SMTP_PORT', '587'));
    const secure = this.config.get<string>('SMTP_SECURE', 'false') === 'true';

    this.from = this.config.get<string>('SMTP_FROM', user);

    this.transporter = nodemailer.createTransport({
      host,
      port,
      secure,
      auth: { user, pass },
    });
  }

  async verifyConnection(): Promise<boolean> {
    try {
      await this.transporter.verify();
      this.logger.log('Gmail SMTP connection verified');
      return true;
    } catch (error) {
      this.logger.error(
        `Gmail SMTP verification failed: ${
          error instanceof Error ? error.message : 'Unknown error'
        }`,
      );
      return false;
    }
  }

  async sendEmail(options: {
    to: string;
    subject: string;
    text: string;
    html?: string;
  }): Promise<void> {
    try {
      await this.transporter.sendMail({
        from: this.from,
        to: options.to,
        subject: options.subject,
        text: options.text,
        html: options.html,
      });

      this.logger.log(`Email accepted for delivery to ${options.to}`);
    } catch (error) {
      this.logger.error(
        `Email delivery failed: ${
          error instanceof Error ? error.message : 'Unknown error'
        }`,
      );

      throw new InternalServerErrorException(
        'Unable to send email. Please try again later.',
      );
    }
  }

  async sendOtp(to: string, otp: string): Promise<void> {
    await this.sendEmail({
      to,
      subject: 'Your School SMS verification code',
      text: `Your verification code is ${otp}. It expires in 10 minutes. Do not share this code with anyone.`,
      html: `
        <div style="font-family:Arial,sans-serif;max-width:520px;margin:auto;padding:24px">
          <h2>School SMS</h2>
          <p>Use the verification code below to continue:</p>
          <div style="font-size:32px;font-weight:bold;letter-spacing:8px;padding:16px 0">
            ${otp.replace(/[&<>"']/g, '')}
          </div>
          <p>This code expires in 10 minutes.</p>
          <p>If you did not request this code, you can ignore this email.</p>
        </div>
      `,
    });
  }
}
