import { SetMetadata } from '@nestjs/common';
import { PERMISSIONS_KEY } from '../constants/auth.constants';

/**
 * Decorator to specify required permissions for a route.
 * @param permissions List of permission strings required to access the resource.
 */
export const Permissions = (...permissions: string[]) =>
  SetMetadata(PERMISSIONS_KEY, permissions);
