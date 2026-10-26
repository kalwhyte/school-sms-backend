import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  UseGuards,
  Get,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
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
  // POST /auth/register
  // ─────────────────────────────────────────────
  @Post('register')
  @Public()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Register a school and its first administrator',
  })
  @ApiResponse({
    status: 201,
    description: 'School and administrator created; verification initiated',
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid registration details',
  })
  @ApiResponse({
    status: 409,
    description: 'Phone or email is already registered',
  })
  register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  // ─────────────────────────────────────────────
  // POST /auth/request-otp
  // ─────────────────────────────────────────────
  @Post('request-otp')
  @Public()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Request a login OTP using school code and phone or email',
  })
  @ApiResponse({ status: 200, description: 'OTP request processed' })
  @ApiResponse({ status: 400, description: 'Invalid input or rate-limited' })
  requestOtp(@Body() dto: RequestOtpDto) {
    return this.authService.requestOtp(dto);
  }

  // POST /auth/verify-otp — verify login OTP
  @Post('verify-otp')
  @Public()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Verify login OTP and receive access and refresh tokens',
  })
  @ApiResponse({ status: 200, description: 'Tokens issued' })
  @ApiResponse({ status: 401, description: 'Invalid or expired OTP' })
  verifyOtp(@Body() dto: VerifyOtpDto) {
    return this.authService.verifyOtp(dto);
  }

  // POST /auth/refresh
  @Post('refresh')
  @Public()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Rotate the refresh token and issue a new token pair',
  })
  refresh(@Body() dto: RefreshTokenDto) {
    return this.authService.refreshTokens(dto);
  }

  // GET /auth/me
  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get the authenticated user profile' })
  getCurrentUser(@CurrentUser('userId') userId: string) {
    return this.authService.getCurrentUser(userId);
  }

  // POST /auth/logout
  @Post('logout')
  @Public()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Revoke a refresh token' })
  logout(@Body() dto: RefreshTokenDto) {
    return this.authService.logout(dto);
  }

  // POST /auth/logout-all
  @Post('logout-all')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Revoke all sessions for the current user' })
  logoutAll(@CurrentUser('userId') userId: string) {
    return this.authService.logoutAll(userId);
  }
}
