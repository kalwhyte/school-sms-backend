import {
  CanActivate,
  ExecutionContext,
  Injectable,
  ForbiddenException,
} from '@nestjs/common';
import * as JWTStrategy from '../../auth/strategies/jwt.strategy';

@Injectable()
export class LeaveRequestsPermissionsGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<{
      user: JWTStrategy.ValidatedUser;
      params: { schoolId?: string };
    }>();

    const user = request.user;
    const schoolId = request.params.schoolId;

    if (schoolId) this.assertSameSchool(schoolId, user.schoolId);

    return true;
  }

  assertSameSchool(schoolId: string, userSchoolId: string) {
    if (schoolId !== userSchoolId) {
      throw new ForbiddenException('You do not have access to this school.');
    }
  }

  assertCanSubmit(user: JWTStrategy.ValidatedUser) {
    // Parents submit; admin/teachers can also submit on behalf
    const allowed = [
      'admin',
      'principal',
      'vice_principal',
      'class_teacher',
      'parent',
    ];
    if (!allowed.includes(user.role)) {
      throw new ForbiddenException(
        'Only parents or admins can submit leave requests.',
      );
    }
  }

  assertCanDecide(user: JWTStrategy.ValidatedUser) {
    const allowed = ['admin', 'principal', 'vice_principal', 'class_teacher'];
    if (!allowed.includes(user.role)) {
      throw new ForbiddenException(
        'Only admins or class teachers can approve/reject leave requests.',
      );
    }
  }

  assertCanView(user: JWTStrategy.ValidatedUser) {
    // All roles can view — parents see their child's, teachers see their class's
    // Scoping is handled in the service
    const allowed = [
      'admin',
      'principal',
      'vice_principal',
      'class_teacher',
      'subject_teacher',
      'parent',
      'student',
    ];
    if (!allowed.includes(user.role)) {
      throw new ForbiddenException(
        'You do not have permission to view leave requests.',
      );
    }
  }
}
