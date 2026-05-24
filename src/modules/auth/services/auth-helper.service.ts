import { Injectable } from '@nestjs/common';
import * as crypto from 'crypto';

@Injectable()
export class AuthHelperService {
  generateRandomToken(): string {
    return crypto.randomBytes(32).toString('hex');
  }
  generateSecureToken(): string {
    return crypto.randomBytes(64).toString('hex');
  }
  /**
   * Generates a cryptographically random 6-digit OTP.
   * @returns {string} The 6-digit OTP.
   */
  generateOtp(): string {
    const bytes = crypto.randomBytes(4);
    const num = bytes.readUInt32BE(0) % 1_000_000;
    return num.toString().padStart(6, '0');
  }

  /**
   * Hashes a given string value using SHA256.
   * @param {string} value The string to hash.
   * @returns {string} The SHA256 hash of the value.
   */
  hashValue(value: string): string {
    return crypto.createHash('sha256').update(value).digest('hex');
  }
}
