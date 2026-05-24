import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import { CacheService } from '../../infrastructure/cache/cache.service';
import { TermiiService } from '../../infrastructure/sms/termii.service';
import { RequestOtpDto } from './dto/request-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { JwtPayload } from './strategies/jwt.strategy';
import { AuthHelperService } from './services/auth-helper.service';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  // Redis key prefixes
  private readonly OTP_PREFIX = 'otp:';
  // private readonly OTP_ATTEMPT_PREFIX = 'otp_attempts:';

  // Limits
  private readonly OTP_TTL_SECONDS = 300; // 5 minutes
  private readonly OTP_MAX_ATTEMPTS = 5; // per window
  private readonly OTP_RESEND_COOLDOWN = 60; // 1 minute between resends
  private readonly REFRESH_TOKEN_TTL_DAYS = 30;

  constructor(
    private readonly prisma: PrismaService,
    private readonly cache: CacheService,
    private readonly termii: TermiiService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
    private readonly authHelperService: AuthHelperService, // Inject AuthHelperService
  ) {}

  // ─────────────────────────────────────────────
  // REQUEST OTP
  // ─────────────────────────────────────────────

  async requestOtp(dto: RequestOtpDto): Promise<{ message: string }> {
    const { phone } = dto;

    // Rate-limit: prevent hammering before cooldown expires
    const cooldownKey = `${this.OTP_PREFIX}cooldown:${phone}`;
    const onCooldown = await this.cache.get(cooldownKey);
    if (onCooldown) {
      throw new BadRequestException(
        'Please wait 60 seconds before requesting another OTP.',
      );
    }

    // Ensure a User record exists for this phone (school lookup via phone)
    const user = await this.prisma.user.findFirst({
      where: { phone, isActive: true },
      select: { id: true, schoolId: true, isActive: true },
    });

    const maskedPhone = this.maskPhone(phone);

    if (!user) {
      // We don't leak whether the number exists — always return same message
      this.logger.warn(`OTP requested for unregistered phone: ${maskedPhone}`);
      return { message: 'If this number is registered, an OTP has been sent.' };
    }

    // Generate 6-digit OTP
    const otp = this.authHelperService.generateOtp(); // Use AuthHelperService
    console.log(`Generated OTP for ${maskedPhone}: ${otp}`); // Log full OTP for debugging (remove in production!)
    // Store hashed OTP in Redis: key → hash, value → userId (for fast lookup)
    const otpHash = this.authHelperService.hashValue(otp); // Use AuthHelperService
    const otpKey = `${this.OTP_PREFIX}${phone}`;

    const storedValue = JSON.stringify({
      hash: otpHash,
      userId: user.id,
      schoolId: user.schoolId,
      attempts: 0,
    });

    await this.cache.set(otpKey, storedValue, this.OTP_TTL_SECONDS);

    // Set resend cooldown
    await this.cache.set(cooldownKey, '1', this.OTP_RESEND_COOLDOWN);

    // Send via Termii
    await this.termii.sendOtp(phone, otp);

    this.logger.log(`OTP sent to ${phone}`);
    return { message: 'If this number is registered, an OTP has been sent.' };
  }

  // ─────────────────────────────────────────────
  // VERIFY OTP → issue tokens
  // ─────────────────────────────────────────────

  async verifyOtp(dto: VerifyOtpDto): Promise<{
    accessToken: string;
    refreshToken: string;
    user: Record<string, unknown>;
  }> {
    const { phone, otp } = dto;
    const otpKey = `${this.OTP_PREFIX}${phone}`;

    const raw = await this.cache.get(otpKey);
    if (!raw) {
      throw new UnauthorizedException('OTP has expired or is invalid.');
    }

    const stored: {
      hash: string;
      userId: string;
      schoolId: string;
      attempts: number;
    } = JSON.parse(raw) as {
      hash: string;
      userId: string;
      schoolId: string;
      attempts: number;
    };

    // Brute-force guard
    if (stored.attempts >= this.OTP_MAX_ATTEMPTS) {
      await this.cache.del(otpKey);
      throw new UnauthorizedException(
        'Too many failed attempts. Please request a new OTP.',
      );
    }

    const inputHash = this.authHelperService.hashValue(otp); // Use AuthHelperService
    if (inputHash !== stored.hash) {
      // Increment attempts
      stored.attempts += 1;
      const remaining = await this.cache.ttl(otpKey);
      await this.cache.set(
        otpKey,
        JSON.stringify(stored),
        remaining > 0 ? remaining : this.OTP_TTL_SECONDS,
      );
      throw new UnauthorizedException(
        `Invalid OTP. ${this.OTP_MAX_ATTEMPTS - stored.attempts} attempt(s) remaining.`,
      );
    }

    // OTP valid — delete it immediately (single-use)
    await this.cache.del(otpKey);

    // Load full user — names live on Staff | Parent | Student, not User
    const user = await this.prisma.user.findUnique({
      where: { id: stored.userId },
      select: {
        id: true,
        schoolId: true,
        role: true,
        phone: true,
        isActive: true,
        staff: { select: { fullName: true, photoUrl: true } },
        parent: { select: { fullName: true } },
        student: { select: { fullName: true, photoUrl: true } },
      },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedException('Account is inactive.');
    }

    // Resolve display name + avatar from whichever profile relation is populated
    const profile = user.staff ?? user.parent ?? user.student ?? null;
    const fullName: string = profile?.fullName ?? '';
    const photoUrl: string | null =
      user.staff?.photoUrl ?? user.student?.photoUrl ?? null;

    // Issue tokens
    const { accessToken, refreshToken } = await this.generateTokenPair(user);

    return {
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        schoolId: user.schoolId,
        role: user.role,
        phone: user.phone,
        fullName,
        photoUrl,
      },
    };
  }

  // ─────────────────────────────────────────────
  // REFRESH ACCESS TOKEN
  // ─────────────────────────────────────────────

  async refreshTokens(dto: RefreshTokenDto): Promise<{
    accessToken: string;
    refreshToken: string;
  }> {
    const tokenHash = this.authHelperService.hashValue(dto.refreshToken); // Use AuthHelperService

    const stored = await this.prisma.refreshToken.findUnique({
      where: { tokenHash },
      include: { user: true },
    });

    if (!stored || stored.expiresAt < new Date() || stored.revokedAt) {
      throw new UnauthorizedException('Refresh token is invalid or expired.');
    }

    if (!stored.user.isActive) {
      throw new UnauthorizedException('Account is inactive.');
    }

    // Rotate: revoke old, issue new pair
    await this.prisma.refreshToken.update({
      where: { id: stored.id },
      data: { revokedAt: new Date() },
    });

    const { accessToken, refreshToken } = await this.generateTokenPair(
      stored.user,
    );
    return { accessToken, refreshToken };
  }

  // ─────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────

  async logout(dto: RefreshTokenDto): Promise<{ message: string }> {
    const tokenHash = this.authHelperService.hashValue(dto.refreshToken); // Use AuthHelperService

    const stored = await this.prisma.refreshToken.findUnique({
      where: { tokenHash },
    });

    if (stored && !stored.revokedAt) {
      await this.prisma.refreshToken.update({
        where: { id: stored.id },
        data: { revokedAt: new Date() },
      });
    }

    return { message: 'Logged out successfully.' };
  }

  // ─────────────────────────────────────────────
  // LOGOUT ALL DEVICES
  // ─────────────────────────────────────────────

  async logoutAll(userId: string): Promise<{ message: string }> {
    await this.prisma.refreshToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
    return { message: 'Logged out from all devices.' };
  }

  // ─────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────

  private async generateTokenPair(user: {
    id: string;
    schoolId: string;
    role: string; // UserRole enum values are strings at runtime
  }): Promise<{ accessToken: string; refreshToken: string }> {
    const payload: JwtPayload = {
      sub: user.id,
      schoolId: user.schoolId,
      role: user.role,
    };

    const accessToken = this.jwt.sign(payload);

    // Opaque refresh token → store hash in DB
    const rawRefreshToken = crypto.randomBytes(64).toString('hex');
    const tokenHash = this.authHelperService.hashValue(rawRefreshToken); // Use AuthHelperService
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + this.REFRESH_TOKEN_TTL_DAYS);

    // RefreshToken schema: only userId, tokenHash, expiresAt — no schoolId field
    await this.prisma.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash,
        expiresAt,
      },
    });

    return { accessToken, refreshToken: rawRefreshToken };
  }

  private maskPhone(phone: string): string {
    return phone.replace(/.(?=.{4})/g, '*');
  }
}
