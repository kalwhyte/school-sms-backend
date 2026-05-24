import {
  Injectable,
  CanActivate,
  ForbiddenException,
  ExecutionContext,
} from '@nestjs/common';
import * as JWTStrategy from '../../auth/strategies/jwt.strategy';
import { Observable } from 'rxjs';

@Injectable()
export class AttendanceGuard implements CanActivate {
  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {
    const request = context.switchToHttp().getRequest<{
      params: { schoolId?: string };
      user?: JWTStrategy.ValidatedUser;
      method: string;
    }>();
    const user = request.user;
    const schoolId = request.params.schoolId;

    if (!user) return false;

    this.assertSameSchool(schoolId ?? '', user.schoolId);

    // If it's a POST request (marking attendance), check specific roles
    if (request.method === 'POST') {
      if (!this.assertCanMarkAttendance(user)) {
        throw new ForbiddenException(
          'You do not have permission to mark attendance.',
        );
      }
    }

    return true;
  }
  assertSameSchool(schoolId: string, userSchoolId: string) {
    if (schoolId !== userSchoolId) {
      throw new ForbiddenException('You do not have access to this school.');
    }
  }

  assertCanMarkAttendance(user: JWTStrategy.ValidatedUser) {
    const allowed = [
      'admin',
      'principal',
      'vice_principal',
      'class_teacher',
      'subject_teacher',
    ];
    return allowed.includes(user.role);
  }
}
