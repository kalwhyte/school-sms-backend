import { registerAs } from '@nestjs/config';

export default registerAs('auth', () => ({
  secret: process.env.AUTH_JWT_SECRET,
  expires: process.env.AUTH_JWT_TOKEN_EXPIRES_IN || '1d',
  refreshSecret: process.env.AUTH_REFRESH_SECRET,
  refreshExpires: process.env.AUTH_REFRESH_TOKEN_EXPIRES_IN || '7d',
  forgotSecret: process.env.AUTH_FORGOT_SECRET,
  forgotExpires: process.env.AUTH_FORGOT_TOKEN_EXPIRES_IN || '30m',
  confirmEmailSecret: process.env.AUTH_CONFIRM_EMAIL_SECRET,
  confirmEmailExpires: process.env.AUTH_CONFIRM_EMAIL_TOKEN_EXPIRES_IN || '1d',
}));
