import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '../constants/auth.constants';
import { Role } from '../../modules/auth/enums/role.enum';

/**
 * Decorator to specify required roles for a route.
 * @param roles List of roles required to access the resource.
 */

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<Role[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!requiredRoles) {
      return true;
    }
    const request = context
      .switchToHttp()
      .getRequest<{ user?: { role?: { name: string } } }>();
    const user = request.user;

    return requiredRoles.some((role) => user?.role?.name === role);
  }
}
