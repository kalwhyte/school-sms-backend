import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RequestOtpDto } from './dto/request-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { Public } from '../../common/decorators/public.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  // ─────────────────────────────────────────────
  // POST /auth/request-otp
  // ─────────────────────────────────────────────
  @Post('request-otp')
  @Public() // Explicitly mark the endpoint as public
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: "Send a 6-digit OTP to the user's phone via SMS",
    description:
      'Public endpoint. Accepts a phone number. If the number is registered, sends an OTP via SMS. Always returns 200 to prevent user enumeration.',
  })
  @ApiResponse({
    status: 200,
    description: 'OTP dispatched (or silently dropped for unknown numbers)',
  })
  @ApiResponse({ status: 400, description: 'Invalid phone or rate-limited' })
  requestOtp(@Body() dto: RequestOtpDto) {
    console.log('Requesting OTP for phone:', dto.phone);
    return this.authService.requestOtp(dto);
  }

  // ─────────────────────────────────────────────
  // POST /auth/verify-otp
  // ─────────────────────────────────────────────
  @Post('verify-otp')
  @Public()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify OTP and receive JWT + refresh token' })
  @ApiResponse({ status: 200, description: 'Tokens issued' })
  @ApiResponse({ status: 401, description: 'Invalid or expired OTP' })
  verifyOtp(@Body() dto: VerifyOtpDto) {
    console.log(dto);
    return this.authService.verifyOtp(dto);
  }

  // ─────────────────────────────────────────────
  // POST /auth/refresh
  // ─────────────────────────────────────────────
  @Post('refresh')
  @Public()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Exchange a refresh token for a new token pair (rotation)',
  })
  @ApiResponse({
    status: 200,
    description: 'New access + refresh tokens issued',
  })
  @ApiResponse({ status: 401, description: 'Refresh token invalid or expired' })
  refresh(@Body() dto: RefreshTokenDto) {
    console.log(dto);
    console.log(dto.refreshToken);
    console.log(dto.refreshToken.length);
    return this.authService.refreshTokens(dto);
  }

  // ─────────────────────────────────────────────
  // POST /auth/logout
  // ─────────────────────────────────────────────
  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Revoke a single refresh token (logout this device)',
  })
  @ApiResponse({ status: 200, description: 'Logged out' })
  logout(@Body() dto: RefreshTokenDto) {
    return this.authService.logout(dto);
  }

  // ─────────────────────────────────────────────
  // POST /auth/logout-all
  // ─────────────────────────────────────────────
  @Post('logout-all')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Revoke all refresh tokens for this user (logout all devices)',
  })
  @ApiResponse({ status: 200, description: 'All sessions revoked' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  logoutAll(@CurrentUser('userId') userId: string) {
    return this.authService.logoutAll(userId);
  }
}
