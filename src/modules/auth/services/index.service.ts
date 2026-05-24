export * from './auth-helper.service';
import * as crypto from 'crypto';
import { Injectable } from '@nestjs/common';

@Injectable()
export class AuthHelperService {
  /**
   * Generates a cryptographically secure 6-digit OTP
   */
  generateOtp(): string {
    const bytes = crypto.randomBytes(4);
    const num = bytes.readUInt32BE(0) % 1_000_000;
    return num.toString().padStart(6, '0');
  }

  /**
   * Hashes a string value using SHA-256
   */
  hashValue(value: string): string {
    return crypto.createHash('sha256').update(value).digest('hex');
  }

  /**
   * Generates a random opaque token for refresh tokens
   */
  generateRandomToken(): string {
    return crypto.randomBytes(64).toString('hex');
  }
}
