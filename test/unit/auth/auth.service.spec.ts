import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { AuthService } from '../../../src/modules/auth/auth.service';
import { AuthHelperService } from '../../../src/modules/auth/services/auth-helper.service';
import { PrismaService } from '../../../src/infrastructure/database/prisma.service';
import { CacheService } from '../../../src/infrastructure/cache/cache.service';
import { TermiiService } from '../../../src/infrastructure/sms/termii.service';

// ─── shared mock factory ──────────────────────────────────────────────────────

const mockUser = {
  id: 'user-001',
  schoolId: 'school-001',
  role: 'class_teacher',
  phone: '+2348012345678',
  isActive: true,
  staff: { fullName: 'Nosa Ade', photoUrl: 'https://example.com/photo.jpg' },
  parent: null,
  student: null,
};

const mockRefreshTokenRecord = {
  id: 'rt-001',
  tokenHash: 'hashed-token',
  expiresAt: new Date(Date.now() + 86_400_000), // tomorrow
  revokedAt: null,
  user: mockUser,
};

function buildMocks() {
  const prisma = {
    user: {
      findFirst: jest.fn(),
      findUnique: jest.fn(),
    },
    refreshToken: {
      create: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
      updateMany: jest.fn(),
    },
  };

  const cache = {
    get: jest.fn(),
    set: jest.fn(),
    del: jest.fn(),
    ttl: jest.fn(),
  };

  const termii = { sendOtp: jest.fn() };

  const jwt = { sign: jest.fn().mockReturnValue('signed-access-token') };

  const config = { get: jest.fn() };

  const authHelper = {
    generateOtp: jest.fn().mockReturnValue('123456'),
    hashValue: jest.fn().mockImplementation((v: string) => `hashed:${v}`),
    generateRandomToken: jest.fn().mockReturnValue('raw-refresh-token'),
  };

  return { prisma, cache, termii, jwt, config, authHelper };
}

// ─── test suite ──────────────────────────────────────────────────────────────

describe('AuthService', () => {
  let service: AuthService;
  let mocks: ReturnType<typeof buildMocks>;

  beforeEach(async () => {
    mocks = buildMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: PrismaService, useValue: mocks.prisma },
        { provide: CacheService, useValue: mocks.cache },
        { provide: TermiiService, useValue: mocks.termii },
        { provide: JwtService, useValue: mocks.jwt },
        { provide: ConfigService, useValue: mocks.config },
        { provide: AuthHelperService, useValue: mocks.authHelper },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  // ─── requestOtp ────────────────────────────────────────────────────────────

  describe('requestOtp', () => {
    const dto = { phone: '+2348012345678' };

    it('should throw BadRequestException when phone is on cooldown', async () => {
      mocks.cache.get.mockResolvedValueOnce('1'); // cooldown key hit

      await expect(service.requestOtp(dto)).rejects.toThrow(
        BadRequestException,
      );
      expect(mocks.prisma.user.findFirst).not.toHaveBeenCalled();
    });

    it('should return the generic message for an unregistered phone', async () => {
      mocks.cache.get.mockResolvedValueOnce(null); // no cooldown
      mocks.prisma.user.findFirst.mockResolvedValueOnce(null); // unknown number

      const result = await service.requestOtp(dto);

      expect(result.message).toBe(
        'If this number is registered, an OTP has been sent.',
      );
      expect(mocks.termii.sendOtp).not.toHaveBeenCalled();
    });

    it('should store hashed OTP in cache and send SMS for a registered phone', async () => {
      mocks.cache.get.mockResolvedValueOnce(null); // no cooldown
      mocks.prisma.user.findFirst.mockResolvedValueOnce({
        id: 'user-001',
        schoolId: 'school-001',
        isActive: true,
      });

      const result = await service.requestOtp(dto);

      // Cache should have been written twice: OTP entry + cooldown
      expect(mocks.cache.set).toHaveBeenCalledTimes(2);

      // First set call stores the OTP payload
      const [otpKey, otpValue] = mocks.cache.set.mock.calls[0] as [
        string,
        string,
      ];
      expect(otpKey).toBe(`otp:${dto.phone}`);
      const parsed = JSON.parse(otpValue) as { hash: string; attempts: number };
      expect(parsed.hash).toBe('hashed:123456');
      expect(parsed.attempts).toBe(0);

      // SMS must be sent with raw OTP
      expect(mocks.termii.sendOtp).toHaveBeenCalledWith(dto.phone, '123456');
      expect(result.message).toBe(
        'If this number is registered, an OTP has been sent.',
      );
    });
  });

  // ─── verifyOtp ─────────────────────────────────────────────────────────────

  describe('verifyOtp', () => {
    const VerifyOtpDto = {
      phone: '+2348012345678',
      otp: '123456',
      schoolCode: 'sch-001',
    };

    const storedOtp = JSON.stringify({
      hash: 'hashed:123456',
      userId: 'user-001',
      schoolId: 'school-001',
      attempts: 0,
    });

    it('should throw UnauthorizedException when no OTP exists in cache', async () => {
      mocks.cache.get.mockResolvedValueOnce(null);

      await expect(service.verifyOtp(VerifyOtpDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should throw and increment attempts on a wrong OTP', async () => {
      mocks.cache.get.mockResolvedValueOnce(storedOtp);
      mocks.cache.ttl.mockResolvedValueOnce(200);
      // hashValue returns 'hashed:123456' for any input by default — override for wrong OTP
      mocks.authHelper.hashValue.mockReturnValueOnce('hashed:WRONG');

      await expect(
        service.verifyOtp({ ...VerifyOtpDto, otp: 'WRONG' }),
      ).rejects.toThrow(UnauthorizedException);

      const [, updatedValue] = mocks.cache.set.mock.calls[0] as [
        string,
        string,
      ];
      expect((JSON.parse(updatedValue) as { attempts: number }).attempts).toBe(
        1,
      );
    });

    it('should delete OTP and lock out after max attempts are reached', async () => {
      const exhausted = JSON.stringify({
        hash: 'hashed:123456',
        userId: 'user-001',
        schoolId: 'school-001',
        attempts: 5, // already at max
      });
      mocks.cache.get.mockResolvedValueOnce(exhausted);

      await expect(service.verifyOtp(VerifyOtpDto)).rejects.toThrow(
        UnauthorizedException,
      );
      expect(mocks.cache.del).toHaveBeenCalledWith(`otp:${VerifyOtpDto.phone}`);
    });

    it('should return tokens and user data on a correct OTP', async () => {
      mocks.cache.get.mockResolvedValueOnce(storedOtp);
      mocks.prisma.user.findUnique.mockResolvedValueOnce(mockUser);
      mocks.prisma.refreshToken.create.mockResolvedValueOnce({});

      const result = await service.verifyOtp(VerifyOtpDto);

      // OTP deleted after successful verify
      expect(mocks.cache.del).toHaveBeenCalledWith(`otp:${VerifyOtpDto.phone}`);

      expect(result.accessToken).toBe('signed-access-token');
      expect(result.refreshToken).toBeDefined();
      expect(result.user).toMatchObject({
        id: 'user-001',
        role: 'class_teacher',
        fullName: 'Nosa Ade',
        photoUrl: 'https://example.com/photo.jpg',
      });
    });

    it('should throw UnauthorizedException when account is inactive', async () => {
      mocks.cache.get.mockResolvedValueOnce(storedOtp);
      mocks.prisma.user.findUnique.mockResolvedValueOnce({
        ...mockUser,
        isActive: false,
      });

      await expect(service.verifyOtp(VerifyOtpDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should fall back to parent/student name when staff profile is absent', async () => {
      mocks.cache.get.mockResolvedValueOnce(storedOtp);
      mocks.prisma.user.findUnique.mockResolvedValueOnce({
        ...mockUser,
        staff: null,
        parent: { fullName: 'Mrs. Ngozi Okafor' },
      });
      mocks.prisma.refreshToken.create.mockResolvedValueOnce({});

      const result = await service.verifyOtp(VerifyOtpDto);

      expect(result.user.fullName).toBe('Mrs. Ngozi Okafor');
      expect(result.user.photoUrl).toBeNull();
    });
  });

  // ─── refreshTokens ─────────────────────────────────────────────────────────

  describe('refreshTokens', () => {
    const dto = { refreshToken: 'raw-token' };

    it('should throw when token is not found in DB', async () => {
      mocks.prisma.refreshToken.findUnique.mockResolvedValueOnce(null);

      await expect(service.refreshTokens(dto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should throw when token is already revoked', async () => {
      mocks.prisma.refreshToken.findUnique.mockResolvedValueOnce({
        ...mockRefreshTokenRecord,
        revokedAt: new Date(),
      });

      await expect(service.refreshTokens(dto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should throw when token is expired', async () => {
      mocks.prisma.refreshToken.findUnique.mockResolvedValueOnce({
        ...mockRefreshTokenRecord,
        expiresAt: new Date(Date.now() - 1000), // in the past
      });

      await expect(service.refreshTokens(dto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should throw when the user account is inactive', async () => {
      mocks.prisma.refreshToken.findUnique.mockResolvedValueOnce({
        ...mockRefreshTokenRecord,
        user: { ...mockUser, isActive: false },
      });

      await expect(service.refreshTokens(dto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should revoke the old token and issue a new pair', async () => {
      mocks.prisma.refreshToken.findUnique.mockResolvedValueOnce(
        mockRefreshTokenRecord,
      );
      mocks.prisma.refreshToken.update.mockResolvedValueOnce({});
      mocks.prisma.refreshToken.create.mockResolvedValueOnce({});

      const result = await service.refreshTokens(dto);

      // Old token must be revoked
      expect(mocks.prisma.refreshToken.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: 'rt-001' },
          data: expect.objectContaining({
            revokedAt: expect.any(Object) as Date,
          }) as Record<string, unknown>,
        }),
      );

      expect(result.accessToken).toBe('signed-access-token');
      expect(result.refreshToken).toBeDefined();
    });
  });

  // ─── logout ────────────────────────────────────────────────────────────────

  describe('logout', () => {
    const dto = { refreshToken: 'raw-token' };

    it('should revoke the token when it exists and is active', async () => {
      mocks.prisma.refreshToken.findUnique.mockResolvedValueOnce(
        mockRefreshTokenRecord,
      );

      const result = await service.logout(dto);

      expect(mocks.prisma.refreshToken.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: 'rt-001' },
          data: expect.objectContaining({
            revokedAt: expect.any(Date) as Date,
          }) as Record<string, unknown>,
        }) as Record<string, unknown>,
      );
      expect(result.message).toBe('Logged out successfully.');
    });

    it('should return success silently when token does not exist', async () => {
      mocks.prisma.refreshToken.findUnique.mockResolvedValueOnce(null);

      const result = await service.logout(dto);

      expect(mocks.prisma.refreshToken.update).not.toHaveBeenCalled();
      expect(result.message).toBe('Logged out successfully.');
    });

    it('should not revoke an already-revoked token', async () => {
      mocks.prisma.refreshToken.findUnique.mockResolvedValueOnce({
        ...mockRefreshTokenRecord,
        revokedAt: new Date(),
      });

      await service.logout(dto);

      expect(mocks.prisma.refreshToken.update).not.toHaveBeenCalled();
    });
  });

  // ─── logoutAll ─────────────────────────────────────────────────────────────

  describe('logoutAll', () => {
    it('should revoke all active tokens for the user', async () => {
      mocks.prisma.refreshToken.updateMany.mockResolvedValueOnce({ count: 3 });

      const result = await service.logoutAll('user-001');

      expect(mocks.prisma.refreshToken.updateMany).toHaveBeenCalledWith({
        where: { userId: 'user-001', revokedAt: null },
        data: { revokedAt: expect.any(Date) as Date },
      });
      expect(result.message).toBe('Logged out from all devices.');
    });
  });
});
