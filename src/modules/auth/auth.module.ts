import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { SignOptions } from 'jsonwebtoken'; // Import SignOptions

import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './strategies/jwt.strategy';
import { AuthHelperService } from './services/auth-helper.service';

import { DatabaseModule } from '../../infrastructure/database/database.module';
import { CacheService } from '../../infrastructure/cache/cache.service';
import { TermiiService } from '../../infrastructure/sms/termii.service';

@Module({
  imports: [
    ConfigModule,
    DatabaseModule, // provides PrismaService
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const expiresInValue =
          config.get<string>('AUTH_JWT_TOKEN_EXPIRES_IN') || '15m';
        return {
          secret: config.get<string>('AUTH_JWT_SECRET'),
          signOptions: {
            expiresIn: expiresInValue as SignOptions['expiresIn'], // Apply type assertion
          },
        };
      },
    }),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    JwtStrategy,
    CacheService,
    TermiiService,
    AuthHelperService,
  ],
  exports: [AuthService, JwtStrategy, PassportModule],
})
export class AuthModule {}
