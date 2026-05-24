export const ALLOWED_PARENT_ROLES = ['parent'] as const;
export type ParentRole = (typeof ALLOWED_PARENT_ROLES)[number];
