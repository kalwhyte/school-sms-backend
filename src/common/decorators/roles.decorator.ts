import { SetMetadata } from '@nestjs/common';
import { ROLES_KEY } from '../constants/auth.constants';
import { UserRole } from '@prisma/client';

/**
 * Decorator to specify required roles for a route.
 * @param roles List of roles required to access the resource.
 */
export const Roles = (...roles: UserRole[]) => SetMetadata(ROLES_KEY, roles);
