import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios, { AxiosInstance, AxiosError } from 'axios';

// Define a custom type guard for AxiosError to work around potential type resolution issues
function isAxiosErrorCustom(error: unknown): error is AxiosError {
  return (
    typeof error === 'object' &&
    error !== null &&
    'isAxiosError' in error &&
    (error as AxiosError).isAxiosError === true
  );
}

// Define an interface for the expected Termii API error response data
interface TermiiApiErrorData {
  message?: string;
  // Add other common Termii error fields if known, e.g., "code", "status"
}

@Injectable()
export class TermiiService {
  private readonly logger = new Logger(TermiiService.name);
  private readonly client: AxiosInstance;
  private readonly apiKey: string;
  private readonly senderId: string;

  constructor(private readonly config: ConfigService) {
    this.apiKey = this.config.get<string>('TERMII_API_KEY', '');
    this.senderId = this.config.get<string>('TERMII_SENDER_ID', 'N-Alert');
    this.client = axios.create({
      baseURL: 'https://api.ng.termii.com/api',
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }

  /**
   * Sends a one-time password to a Nigerian phone number.
   * @param phone The recipient phone number in E.164 format.
   * @param otp The 6-digit code to send.
   */
  async sendOtp(phone: string, otp: string): Promise<void> {
    const message = `Your verification code is ${otp}. Valid for 5 minutes.`;

    try {
      await this.client.post('/sms/send', {
        api_key: this.apiKey,
        to: phone,
        from: this.senderId,
        sms: message,
        type: 'plain',
        channel: 'generic',
      });
    } catch (error: unknown) {
      if (isAxiosErrorCustom(error)) {
        const termiiErrorData = error.response?.data as TermiiApiErrorData;
        this.logger.error(
          `Failed to send SMS to ${phone}: ${termiiErrorData?.message || error.message}`,
        );
      } else if (error instanceof Error) {
        this.logger.error(
          `An unexpected error occurred while sending SMS to ${phone}: ${error.message}`,
        );
      } else {
        this.logger.error(
          `An unknown error occurred while sending SMS to ${phone}`,
        );
      }
    }
  }

  /**
   * Sends a generic SMS message.
   * @param phone The recipient phone number.
   * @param message The message content.
   */
  async sendMessage(phone: string, message: string): Promise<void> {
    try {
      await this.client.post('/sms/send', {
        api_key: this.apiKey,
        to: phone,
        from: this.senderId,
        sms: message,
        type: 'plain',
        channel: 'generic',
      });
    } catch (error: unknown) {
      if (isAxiosErrorCustom(error)) {
        const termiiErrorData = error.response?.data as TermiiApiErrorData;
        this.logger.error(
          `Failed to send message to ${phone}: ${termiiErrorData?.message || error.message}`,
        );
      } else if (error instanceof Error) {
        this.logger.error(
          `An unexpected error occurred while sending message to ${phone}: ${error.message}`,
        );
      } else {
        this.logger.error(
          `An unknown error occurred while sending message to ${phone}`,
        );
      }
    }
  }
}
