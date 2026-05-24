import {
  CanActivate,
  ExecutionContext,
  Injectable,
  ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import * as JWTStrategy from '../../auth/strategies/jwt.strategy';

@Injectable()
export class FeesPermissionsGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<{
      user: JWTStrategy.ValidatedUser;
      params: { schoolId?: string };
    }>();

    const user = request.user;
    const schoolId = request.params.schoolId;

    if (schoolId) this.assertSameSchool(schoolId, user.schoolId);
    this.assertCanViewFees(user);

    return true;
  }

  assertSameSchool(schoolId: string, userSchoolId: string) {
    if (schoolId !== userSchoolId) {
      throw new ForbiddenException('You do not have access to this school.');
    }
  }

  // Students and parents can view ledger/fees; teachers cannot
  assertCanViewFees(user: JWTStrategy.ValidatedUser) {
    const allowed = [
      'admin',
      'principal',
      'vice_principal',
      'bursar',
      'parent',
      'student',
    ];
    if (!allowed.includes(user.role)) {
      throw new ForbiddenException('You do not have permission to view fees.');
    }
  }

  assertBursarOrAdmin(user: JWTStrategy.ValidatedUser) {
    const allowed = ['admin', 'principal', 'vice_principal', 'bursar'];
    if (!allowed.includes(user.role)) {
      throw new ForbiddenException('Bursar or admin access required.');
    }
  }

  assertAdmin(user: JWTStrategy.ValidatedUser) {
    const allowed = ['admin', 'principal', 'vice_principal'];
    if (!allowed.includes(user.role)) {
      throw new ForbiddenException('Admin access required.');
    }
  }
}
