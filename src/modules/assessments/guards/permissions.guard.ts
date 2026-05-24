import {
  CanActivate,
  ExecutionContext,
  Injectable,
  ForbiddenException,
} from '@nestjs/common';
import * as JWTStrategy from '../../auth/strategies/jwt.strategy';

@Injectable()
export class AssessmentsPermissionsGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<{
      user: JWTStrategy.ValidatedUser;
      params: { schoolId?: string };
    }>();
    const user = request.user;

    // Extract schoolId from route params (if present)
    const schoolId = request.params.schoolId;

    // If schoolId is in route, check it matches user's school
    if (schoolId) {
      this.assertSameSchool(schoolId, user.schoolId);
    }

    // Check if user has permission to manage assessments
    this.assertCanManageAssessments(user);

    return true;
  }
  // ──────────────────────────
  // GUARDS
  // ──────────────────────────
  assertSameSchool(schoolId: string, userSchoolId: string) {
    if (schoolId !== userSchoolId) {
      throw new ForbiddenException('You do not have access to this school.');
    }
  }

  assertCanManageAssessments(user: JWTStrategy.ValidatedUser) {
    const allowed = [
      'admin',
      'principal',
      'vice_principal',
      'class_teacher',
      'subject_teacher',
    ];
    if (!allowed.includes(user.role)) {
      throw new ForbiddenException(
        'You do not have permission to manage assessments.',
      );
    }
  }

  assertAdmin(user: JWTStrategy.ValidatedUser) {
    const allowed = ['admin', 'principal', 'vice_principal'];
    if (!allowed.includes(user.role)) {
      throw new ForbiddenException('Admin access required.');
    }
  }
}
