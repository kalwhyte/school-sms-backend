import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { IAuthenticatedUser } from '../../modules/auth/interfaces/index.interface';
import { Request as ExpressRequest } from 'express';

/**
 * Extracts the authenticated user (or a specific field) from the request.
 * This decorator assumes that the authentication guard (e.g., JwtAuthGuard) has already run and attached the user object to the request.
 *
 * @param data Optional key of IAuthenticatedUser to extract a specific property.
 *             If not provided, the entire user object will be returned.
 * @returns The authenticated user object or the specified property, or undefined if not authenticated.
 *
 * Example:
 * ```typescript
 * @Get('profile')
 * getProfile(@CurrentUser() user: IAuthenticatedUser) {
 *   return user; // returns the entire user object
 * }
 *
 * Usage:
 * - To get the entire user object: `@CurrentUser() user: IAuthenticatedUser`
 * - To get a specific property (e.g., userId): `@CurrentUser('userId') userId: string`
 */
export const CurrentUser = createParamDecorator(
  (data: keyof IAuthenticatedUser | undefined, ctx: ExecutionContext) => {
    const request = ctx
      .switchToHttp()
      .getRequest<ExpressRequest & { user?: IAuthenticatedUser }>();
    const user = request.user;
    if (!user) {
      return undefined;
    }
    return data ? user[data] : user;
  },
);
