import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PERMISSIONS_KEY } from '../constants/auth.constants';

/**
 * PermissionsGuard checks if the authenticated user has the required permissions to access a route.
 * It retrieves the required permissions from the route's metadata and compares them with the user's permissions.
 */
@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredPermissions = this.reflector.getAllAndOverride<string[]>(
      PERMISSIONS_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (!requiredPermissions || requiredPermissions.length === 0) {
      return true;
    }

    const request = context
      .switchToHttp()
      .getRequest<{ user?: { role?: { permissions?: { name: string }[] } } }>();
    const user = request.user;

    if (!user?.role?.permissions) {
      return false;
    }

    const userPermissions = user.role.permissions.map((p) => p.name);

    return requiredPermissions.some((permission) =>
      userPermissions.includes(permission),
    );
  }
}
