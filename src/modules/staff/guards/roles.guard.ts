// import { CanActivate, ExecutionContext, Injectable } from '@nestjs/common';

// @Injectable()
// export class roles^guard implements CanActivate {
//   canActivate(context: ExecutionContext): boolean {
//     return true;
//   }
// }
export const ALLOWED_STAFF_ROLES = [
  'admin',
  'class_teacher',
  'subject_teacher',
] as const;
export type StaffRole = (typeof ALLOWED_STAFF_ROLES)[number];
