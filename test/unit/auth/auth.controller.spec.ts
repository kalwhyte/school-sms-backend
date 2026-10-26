import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from '../../../src/modules/auth/auth.controller';
import { AuthService } from '../../../src/modules/auth/auth.service';
import { VerifyOtpDto } from '../../../src/modules/auth/dto/verify-otp.dto';

// ─── mock service ─────────────────────────────────────────────────────────────

const mockAuthService = {
  requestOtp: jest.fn(),
  verifyOtp: jest.fn(),
  refreshTokens: jest.fn(),
  logout: jest.fn(),
  logoutAll: jest.fn(),
};

// ─── test suite ──────────────────────────────────────────────────────────────

describe('AuthController', () => {
  let controller: AuthController;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [{ provide: AuthService, useValue: mockAuthService }],
    }).compile();

    controller = module.get<AuthController>(AuthController);
  });

  // ─── requestOtp ────────────────────────────────────────────────────────────

  describe('requestOtp', () => {
    it('should delegate to authService.requestOtp and return its result', async () => {
      const dto = { phone: '+2348012345678' };
      const expected = {
        message: 'If this number is registered, an OTP has been sent.',
      };
      mockAuthService.requestOtp.mockResolvedValueOnce(expected);

      const result = await controller.requestOtp(dto);

      expect(mockAuthService.requestOtp).toHaveBeenCalledWith(dto);
      expect(result).toEqual(expected);
    });

    it('should propagate exceptions from the service', async () => {
      mockAuthService.requestOtp.mockRejectedValueOnce(
        new Error('Rate limited'),
      );

      await expect(
        controller.requestOtp({ phone: '+2348012345678' }),
      ).rejects.toThrow('Rate limited');
    });
  });

  // ─── verifyOtp ─────────────────────────────────────────────────────────────

  describe('verifyOtp', () => {
    it('should delegate to authService.verifyOtp and return tokens', async () => {
      const dto: VerifyOtpDto = {
        phone: '+2348012345678',
        otp: '123456',
        schoolCode: 'SCHOOL123',
      };
      const expected = {
        accessToken: 'at',
        refreshToken: 'rt',
        user: { id: 'user-001', role: 'class_teacher', fullName: 'Nosa Ade' },
      };
      mockAuthService.verifyOtp.mockResolvedValueOnce(expected);

      const result = await controller.verifyOtp(dto);

      expect(mockAuthService.verifyOtp).toHaveBeenCalledWith(dto);
      expect(result).toEqual(expected);
    });
  });

  // ─── refresh ───────────────────────────────────────────────────────────────

  describe('refresh', () => {
    it('should delegate to authService.refreshTokens and return new tokens', async () => {
      const dto = { refreshToken: 'raw-rt' };
      const expected = { accessToken: 'new-at', refreshToken: 'new-rt' };
      mockAuthService.refreshTokens.mockResolvedValueOnce(expected);

      const result = await controller.refresh(dto);

      expect(mockAuthService.refreshTokens).toHaveBeenCalledWith(dto);
      expect(result).toEqual(expected);
    });
  });

  // ─── logout ────────────────────────────────────────────────────────────────

  describe('logout', () => {
    it('should delegate to authService.logout and return the message', async () => {
      const dto = { refreshToken: 'raw-rt' };
      const expected = { message: 'Logged out successfully.' };
      mockAuthService.logout.mockResolvedValueOnce(expected);

      const result = await controller.logout(dto);

      expect(mockAuthService.logout).toHaveBeenCalledWith(dto);
      expect(result).toEqual(expected);
    });
  });

  // ─── logoutAll ─────────────────────────────────────────────────────────────

  describe('logoutAll', () => {
    it('should delegate to authService.logoutAll with the extracted userId', async () => {
      const expected = { message: 'Logged out from all devices.' };
      mockAuthService.logoutAll.mockResolvedValueOnce(expected);

      // @CurrentUser('userId') extracts the userId from the JWT — in the
      // controller method it is just a plain string parameter, so we pass it directly
      const result = await controller.logoutAll('user-001');

      expect(mockAuthService.logoutAll).toHaveBeenCalledWith('user-001');
      expect(result).toEqual(expected);
    });

    it('should propagate exceptions from the service', async () => {
      mockAuthService.logoutAll.mockRejectedValueOnce(new Error('DB error'));

      await expect(controller.logoutAll('user-001')).rejects.toThrow(
        'DB error',
      );
    });
  });
});
