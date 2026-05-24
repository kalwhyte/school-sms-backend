import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../../infrastructure/database/prisma.service';

export interface JwtPayload {
  sub: string; // userId
  schoolId: string;
  role: string;
  iat?: number;
  exp?: number;
}

export interface OtpPayload {
  phone: string;
  schoolCode: string;
  iat?: number;
  exp?: number;
}

export interface ValidatedUser {
  userId: string;
  schoolId: string;
  role: string;
  phone: string | null;
  fullName: string;
  photoUrl?: string | null;
}

interface UserRow {
  id: string;
  schoolId: string;
  phone: string | null;
  role: string;
  staff: {
    fullName: string;
    photoUrl: string | null;
  } | null;
  parent: {
    fullName: string;
  } | null;
  student: {
    fullName: string;
    photoUrl: string | null;
  } | null;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    config: ConfigService,
    private readonly prisma: PrismaService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: (() => {
        const secret = config.get<string>('AUTH_JWT_SECRET');
        if (!secret) {
          throw new Error('JWT secret is not set in configuration');
        }
        return secret;
      })(),
    });
  }

  async validate(payload: JwtPayload): Promise<ValidatedUser> {
    // Confirm user still exists and is active in this school
    const user = (await this.prisma.user.findFirst({
      where: {
        id: payload.sub,
        schoolId: payload.schoolId,
        isActive: true,
      },
      select: {
        id: true,
        schoolId: true,
        phone: true,
        staff: {
          select: {
            fullName: true,
            photoUrl: true,
          },
        },
        parent: {
          select: {
            fullName: true,
          },
        },
        student: {
          select: {
            fullName: true,
            photoUrl: true,
          },
        },
        role: true,
      },
    })) as UserRow | null;
    if (!user) {
      throw new UnauthorizedException('User account is inactive or not found');
    }

    return {
      userId: user.id,
      schoolId: user.schoolId,
      role: user.role,
      phone: user.phone,
      fullName:
        user.staff?.fullName ??
        user.parent?.fullName ??
        user.student?.fullName ??
        '',
      photoUrl: user.staff?.photoUrl ?? user.student?.photoUrl ?? null,
    };
  }
}
