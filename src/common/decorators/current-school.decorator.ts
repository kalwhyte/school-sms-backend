import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { IAuthenticatedUser } from '../../modules/auth/interfaces/index.interface';
import { Request as ExpressRequest } from 'express';

/**
 * Extracts the schoolId from the authenticated user object in the request.
 * This decorator assumes that the authentication guard (e.g., JwtAuthGuard) 
 * has already run and attached the user object to the request.
 *
 * @returns The schoolId string of the authenticated user, or undefined if not authenticated.
 *
 * Example:
 * ```typescript
 * @Get()
 * findAll(@CurrentSchool() schoolId: string) {
 *   return this.service.findAll(schoolId);
 * }
 * ```
 */
export const CurrentSchool = createParamDecorator(
  (data: unknown, ctx: ExecutionContext): string | undefined => {
    const request = ctx
      .switchToHttp()
      .getRequest<ExpressRequest & { user?: IAuthenticatedUser }>();
    return request.user?.schoolId;
  },
);
