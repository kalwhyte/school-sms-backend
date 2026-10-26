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
import { EmailService } from '../../infrastructure/email/email.service';
import { SchoolsService } from '../schools/schools.service';
import { RegisterDto } from './dto/register.dto';
import { RequestOtpDto } from './dto/request-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { JwtPayload } from './strategies/jwt.strategy';
import { AuthHelperService } from './services/auth-helper.service';
import { NotFoundException } from '@nestjs/common/exceptions/not-found.exception';
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
    private readonly email: EmailService, // Inject EmailService
    private readonly authHelperService: AuthHelperService, // Inject AuthHelperService
    private readonly schoolsService: SchoolsService, // Inject SchoolsService
  ) {}

  // ─────────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────────
  async register(dto: RegisterDto) {
    if (!dto.school?.schoolCode || !dto.admin?.phone) {
      throw new BadRequestException(
        'School code and administrator phone are required.',
      );
    }

    // Reuse the existing transactional onboarding implementation.
    const result = await this.schoolsService.onboard(dto);

    const schoolCode = dto.school.schoolCode.trim().toUpperCase();

    // Prefer email when provided; otherwise verify the phone.
    const identifier =
      dto.admin.email?.trim().toLowerCase() || dto.admin.phone.trim();

    try {
      await this.requestOtp({ schoolCode, identifier });

      return {
        message:
          'Registration created. Check your contact for the verification OTP.',
        school: result.school,
        admin: {
          ...result.admin,
          verified: false,
        },
        verification: {
          required: true,
          endpoint: '/api/v1/auth/verify-otp',
          schoolCode,
          identifier,
        },
      };
    } catch {
      // The school transaction has already committed. Do not imply
      // registration failed or create a duplicate school on retry.
      this.logger.warn(
        'Registration created, but verification delivery could not be completed.',
      );

      return {
        message:
          'Registration created, but the verification OTP could not be sent. Request a new OTP to continue.',
        school: result.school,
        admin: {
          ...result.admin,
          verified: false,
        },
        verification: {
          required: true,
          endpoint: '/api/v1/auth/request-otp',
          schoolCode,
          identifier,
          deliveryPending: true,
        },
      };
    }
  }

  // ─────────────────────────────────────────────
  // REQUEST OTP
  // ─────────────────────────────────────────────

  async requestOtp(dto: RequestOtpDto): Promise<{ message: string }> {
    const schoolCode = dto.schoolCode.trim().toUpperCase();
    const identifier = dto.identifier.trim();
    const isEmail = identifier.includes('@');

    if (isEmail) {
      if (
        identifier.length > 254 ||
        !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(identifier)
      ) {
        throw new BadRequestException('Enter a valid email address.');
      }
    } else if (!/^\+[1-9]\d{7,14}$/.test(identifier)) {
      throw new BadRequestException(
        'Enter a phone number in international E.164 format.',
      );
    }

    const normalizedIdentifier = isEmail
      ? identifier.toLowerCase()
      : identifier;

    const school = await this.prisma.school.findFirst({
      where: { schoolCode, isActive: true, deletedAt: null },
      select: { id: true },
    });

    const genericMessage =
      'If the account is registered, an OTP has been sent.';
    this.logger.log(
      `[OTP DEBUG] School lookup: ${schoolCode} | Found: ${school ? 'Yes' : 'No'} | Identifier: ${normalizedIdentifier}`,
    );

    if (!school) return { message: genericMessage };

    const channel = isEmail ? 'email' : 'phone';
    const identifierHash = crypto
      .createHash('sha256')
      .update(`${channel}:${normalizedIdentifier}`)
      .digest('hex');

    this.logger.debug(`[OTP DEBUG] Preparing ${channel} delivery`);

    const otpKey = `${this.OTP_PREFIX}challenge:${school.id}:${identifierHash}`;
    const cooldownKey = `${this.OTP_PREFIX}cooldown:${school.id}:${identifierHash}`;

    if (await this.cache.get(cooldownKey)) {
      throw new BadRequestException(
        'Please wait 60 seconds before requesting another OTP.',
      );
    }

    const user = await this.prisma.user.findFirst({
      where: {
        schoolId: school.id,
        isActive: true,
        ...(isEmail
          ? { email: normalizedIdentifier }
          : { phone: normalizedIdentifier }),
      },
      select: {
        id: true,
        schoolId: true,
        phone: true,
        email: true,
      },
    });
    this.logger.debug(
      `[OTP DEBUG] User lookup: ${user ? 'FOUND' : 'NOT FOUND'}`,
    );

    // Do not reveal whether an account exists.
    if (!user) {
      await this.cache.set(cooldownKey, '1', this.OTP_RESEND_COOLDOWN);
      return { message: genericMessage };
    }

    const otp = this.authHelperService.generateOtp();
    if (this.config.get<string>('NODE_ENV') !== 'production') {
      this.logger.debug(`[OTP DEBUG] Channel: ${channel} | Code: ${otp}`);
    }
    const otpHash = this.authHelperService.hashValue(otp);

    const storedValue = JSON.stringify({
      hash: otpHash,
      userId: user.id,
      schoolId: user.schoolId,
      channel,
      attempts: 0,
    });

    await this.cache.set(otpKey, storedValue, this.OTP_TTL_SECONDS);

    try {
      if (isEmail) {
        await this.email.sendOtp(normalizedIdentifier, otp);
      } else {
        await this.termii.sendOtp(normalizedIdentifier, otp);
      }

      await this.cache.set(cooldownKey, '1', this.OTP_RESEND_COOLDOWN);
    } catch (error) {
      await this.cache.del(otpKey);
      await this.cache.del(cooldownKey);
      throw error;
    }

    this.logger.log(`OTP delivery initiated via ${channel}`);
    return { message: genericMessage };
  }

  async verifyOtp(dto: VerifyOtpDto): Promise<{
    accessToken: string;
    refreshToken: string;
    user: Record<string, unknown>;
  }> {
    const schoolCode = dto.schoolCode.trim().toUpperCase();
    const identifier = dto.identifier.trim();
    const isEmail = identifier.includes('@');
    const channel = isEmail ? 'email' : 'phone';

    if (
      isEmail
        ? !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(identifier)
        : !/^\+[1-9]\d{7,14}$/.test(identifier)
    ) {
      throw new UnauthorizedException('OTP has expired or is invalid.');
    }

    const normalizedIdentifier = isEmail
      ? identifier.toLowerCase()
      : identifier;

    const school = await this.prisma.school.findFirst({
      where: { schoolCode, isActive: true, deletedAt: null },
      select: { id: true },
    });

    if (!school) {
      throw new UnauthorizedException('OTP has expired or is invalid.');
    }

    const identifierHash = crypto
      .createHash('sha256')
      .update(`${channel}:${normalizedIdentifier}`)
      .digest('hex');

    const otpKey = `${this.OTP_PREFIX}challenge:${school.id}:${identifierHash}`;

    const raw = await this.cache.get(otpKey);

    if (!raw) {
      throw new UnauthorizedException('OTP has expired or is invalid.');
    }

    const stored = JSON.parse(raw) as {
      hash: string;
      userId: string;
      schoolId: string;
      channel: 'phone' | 'email';
      attempts: number;
    };

    if (
      stored.schoolId !== school.id ||
      stored.channel !== channel ||
      stored.attempts >= this.OTP_MAX_ATTEMPTS
    ) {
      await this.cache.del(otpKey);
      throw new UnauthorizedException(
        'Too many failed attempts or invalid OTP.',
      );
    }

    const inputHash = this.authHelperService.hashValue(dto.otp);
    const expected = Buffer.from(stored.hash, 'hex');
    const actual = Buffer.from(inputHash, 'hex');

    const validHash =
      expected.length === actual.length &&
      crypto.timingSafeEqual(expected, actual);

    if (!validHash) {
      stored.attempts += 1;

      const remaining = await this.cache.ttl(otpKey);
      if (stored.attempts >= this.OTP_MAX_ATTEMPTS) {
        await this.cache.del(otpKey);
      } else {
        await this.cache.set(
          otpKey,
          JSON.stringify(stored),
          remaining > 0 ? remaining : this.OTP_TTL_SECONDS,
        );
      }

      throw new UnauthorizedException('OTP is invalid or expired.');
    }

    // Consume the challenge before issuing tokens.
    await this.cache.del(otpKey);

    const user = await this.prisma.user.findFirst({
      where: {
        id: stored.userId,
        schoolId: stored.schoolId,
        isActive: true,
        ...(isEmail
          ? { email: normalizedIdentifier }
          : { phone: normalizedIdentifier }),
      },
      select: {
        id: true,
        schoolId: true,
        role: true,
        phone: true,
        email: true,
        isActive: true,
        staff: { select: { fullName: true, photoUrl: true } },
        parent: { select: { fullName: true } },
        student: { select: { fullName: true, photoUrl: true } },
      },
    });

    if (!user) {
      throw new UnauthorizedException('Account is inactive or unavailable.');
    }

    // Successful OTP verification confirms the channel used.
    await this.prisma.user.update({
      where: { id: user.id },
      data: isEmail
        ? { emailVerifiedAt: new Date(), lastLogin: new Date() }
        : { phoneVerifiedAt: new Date(), lastLogin: new Date() },
    });

    const profile = user.staff ?? user.parent ?? user.student ?? null;
    const fullName = profile?.fullName ?? '';
    const photoUrl = user.staff?.photoUrl ?? user.student?.photoUrl ?? null;

    const { accessToken, refreshToken } = await this.generateTokenPair(user);

    return {
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        schoolId: user.schoolId,
        role: user.role,
        phone: user.phone,
        email: user.email,
        fullName,
        photoUrl,
        verifiedVia: channel,
      },
    };
  }

  // async requestOtp(dto: RequestOtpDto): Promise<{ message: string }> {
  //   const { phone } = dto;

  //   // Rate-limit: prevent hammering before cooldown expires
  //   const cooldownKey = `${this.OTP_PREFIX}cooldown:${phone}`;
  //   const onCooldown = await this.cache.get(cooldownKey);
  //   if (onCooldown) {
  //     throw new BadRequestException(
  //       'Please wait 60 seconds before requesting another OTP.',
  //     );
  //   }

  //   // Ensure a User record exists for this phone (school lookup via phone)
  //   const user = await this.prisma.user.findFirst({
  //     where: { phone, isActive: true },
  //     select: { id: true, schoolId: true, isActive: true },
  //   });

  //   const maskedPhone = this.maskPhone(phone);

  //   this.logger.debug(
  //     `OTP request for phone: ${maskedPhone}: ${user ? 'active user found' : 'no active user found'}`,
  //   );
  //   if (!user) {
  //     this.logger.warn(
  //       `OTP flow initiated for unregistered or inactive phone: ${maskedPhone}`,
  //     );
  //     // Still return success message to avoid revealing user existence
  //     return { message: 'If this number is registered, an OTP has been sent.' };
  //   }

  //   // if (!user) {
  //   //   this.logger.warn(`OTP requested for unregistered phone: ${maskedPhone}`);
  //   //   return { message: 'If this number is registered, an OTP has been sent.' };
  //   // }

  //   // Generate 6-digit OTP
  //   const otp = this.authHelperService.generateOtp(); // Use AuthHelperService
  //   if (process.env.NODE_ENV !== 'production') {
  //     this.logger.debug(`Generated OTP for ${maskedPhone}: ${otp}`);
  //   }

  //   // Store hashed OTP in Redis: key → hash, value → userId (for fast lookup)
  //   const otpHash = this.authHelperService.hashValue(otp); // Use AuthHelperService
  //   const otpKey = `${this.OTP_PREFIX}${phone}`;

  //   const storedValue = JSON.stringify({
  //     hash: otpHash,
  //     userId: user.id,
  //     schoolId: user.schoolId,
  //     attempts: 0,
  //   });

  //   await this.cache.set(otpKey, storedValue, this.OTP_TTL_SECONDS);

  //   // Set resend cooldown
  //   await this.cache.set(cooldownKey, '1', this.OTP_RESEND_COOLDOWN);

  //   // Send via Termii
  //   await this.termii.sendOtp(phone, otp);

  //   this.logger.log(`OTP sent to ${phone}`);
  //   return { message: 'If this number is registered, an OTP has been sent.' };
  // }

  // // ─────────────────────────────────────────────
  // // VERIFY OTP → issue tokens
  // // ─────────────────────────────────────────────

  // async verifyOtp(dto: VerifyOtpDto): Promise<{
  //   accessToken: string;
  //   refreshToken: string;
  //   user: Record<string, unknown>;
  // }> {
  //   const { phone, otp } = dto;
  //   const otpKey = `${this.OTP_PREFIX}${phone}`;

  //   const raw = await this.cache.get(otpKey);
  //   if (!raw) {
  //     throw new UnauthorizedException('OTP has expired or is invalid.');
  //   }

  //   const stored: {
  //     hash: string;
  //     userId: string;
  //     schoolId: string;
  //     attempts: number;
  //   } = JSON.parse(raw) as {
  //     hash: string;
  //     userId: string;
  //     schoolId: string;
  //     attempts: number;
  //   };

  //   // Brute-force guard
  //   if (stored.attempts >= this.OTP_MAX_ATTEMPTS) {
  //     await this.cache.del(otpKey);
  //     throw new UnauthorizedException(
  //       'Too many failed attempts. Please request a new OTP.',
  //     );
  //   }

  //   const inputHash = this.authHelperService.hashValue(otp); // Use AuthHelperService
  //   if (inputHash !== stored.hash) {
  //     // Increment attempts
  //     stored.attempts += 1;
  //     const remaining = await this.cache.ttl(otpKey);
  //     await this.cache.set(
  //       otpKey,
  //       JSON.stringify(stored),
  //       remaining > 0 ? remaining : this.OTP_TTL_SECONDS,
  //     );
  //     throw new UnauthorizedException(
  //       `Invalid OTP. ${this.OTP_MAX_ATTEMPTS - stored.attempts} attempt(s) remaining.`,
  //     );
  //   }

  //   // OTP valid — delete it immediately (single-use)
  //   await this.cache.del(otpKey);

  //   // Load full user — names live on Staff | Parent | Student, not User
  //   const user = await this.prisma.user.findUnique({
  //     where: { id: stored.userId },
  //     select: {
  //       id: true,
  //       schoolId: true,
  //       role: true,
  //       phone: true,
  //       isActive: true,
  //       staff: { select: { fullName: true, photoUrl: true } },
  //       parent: { select: { fullName: true } },
  //       student: { select: { fullName: true, photoUrl: true } },
  //     },
  //   });

  //   if (!user || !user.isActive) {
  //     throw new UnauthorizedException('Account is inactive.');
  //   }

  //   // Resolve display name + avatar from whichever profile relation is populated
  //   const profile = user.staff ?? user.parent ?? user.student ?? null;
  //   const fullName: string = profile?.fullName ?? '';
  //   const photoUrl: string | null =
  //     user.staff?.photoUrl ?? user.student?.photoUrl ?? null;

  //   // Issue tokens
  //   const { accessToken, refreshToken } = await this.generateTokenPair(user);

  //   return {
  //     accessToken,
  //     refreshToken,
  //     user: {
  //       id: user.id,
  //       schoolId: user.schoolId,
  //       role: user.role,
  //       phone: user.phone,
  //       fullName,
  //       photoUrl,
  //     },
  //   };
  // }

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
    const revoked = await this.prisma.refreshToken.updateMany({
      where: {
        id: stored.id,
        revokedAt: null,
        expiresAt: { gt: new Date() },
      },
      data: { revokedAt: new Date() },
    });

    if (revoked.count === 0) {
      throw new UnauthorizedException(
        'Refresh token has already been used or revoked.',
      );
    }

    const { accessToken, refreshToken } = await this.generateTokenPair(
      stored.user,
    );
    return { accessToken, refreshToken };
  }

  // ─────────────────────────────────────────────
  // GET CURRENT USER
  // ─────────────────────────────────────────────

  async getCurrentUser(userId: string) {
    const user = await this.prisma.user.findFirst({
      where: {
        id: userId,
        isActive: true,
        school: {
          isActive: true,
          deletedAt: null,
        },
      },
      include: {
        staff: true,
      },
    });

    if (!user) {
      throw new NotFoundException('User account not found or inactive.');
    }

    return {
      id: user.id,
      schoolId: user.schoolId,
      role: user.role,
      phone: user.phone,
      email: user.email,
      fullName: user.staff?.fullName ?? null,
      photoUrl: user.staff?.photoUrl ?? null,
      lastLogin: user.lastLogin,
      verifiedVia: user.phoneVerifiedAt
        ? 'phone'
        : user.emailVerifiedAt
          ? 'email'
          : null,
    };
  }

  // ─────────────────────────────────────────────
  // GET CURRENT USER FROM REFRESH TOKEN
  // ─────────────────────────────────────────────

  async getCurrentUserFromRefreshToken(dto: RefreshTokenDto): Promise<{
    id: string;
    schoolId: string;
    role: string;
    phone: string;
    fullName: string;
    photoUrl: string | null;
  }> {
    const tokenHash = this.authHelperService.hashValue(dto.refreshToken); // Use AuthHelperService

    const stored = await this.prisma.refreshToken.findUnique({
      where: { tokenHash },
      include: {
        user: {
          include: {
            staff: true,
            parent: true,
            student: true,
          },
        },
      },
    });

    if (!stored || stored.expiresAt < new Date() || stored.revokedAt) {
      throw new UnauthorizedException('Refresh token is invalid or expired.');
    }

    if (!stored.user.isActive) {
      throw new UnauthorizedException('Account is inactive.');
    }

    const user = stored.user;

    // Resolve display name + avatar from whichever profile relation is populated
    const profile = user.staff ?? user.parent ?? user.student ?? null;
    const fullName: string = profile?.fullName ?? '';
    const photoUrl: string | null =
      user.staff?.photoUrl ?? user.student?.photoUrl ?? null;

    return {
      id: user.id,
      schoolId: user.schoolId,
      role: user.role,
      phone: user.phone,
      fullName,
      photoUrl,
    };
  }

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
