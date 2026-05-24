import { SetMetadata } from '@nestjs/common';
import { ROLES_KEY } from '../constants/auth.constants';
import { Role } from '../../modules/auth/enums/role.enum';

/**
 * Decorator to specify required roles for a route.
 * @param roles List of roles required to access the resource.
 */
export const Roles = (...roles: Role[]) => SetMetadata(ROLES_KEY, roles);
