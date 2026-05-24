import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PERMISSIONS_KEY } from '../decorators/permissions.decorator';

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
      .getRequest<{ user?: { role?: { permissions: { name: string }[] } } }>();
    const user = request.user;

    if (!user || !user.role || !user.role.permissions) {
      return false;
    }

    const userPermissions = user.role.permissions.map(
      (p: { name: string }) => p.name,
    );

    return requiredPermissions.every((permission) =>
      userPermissions.includes(permission),
    );
  }
}
