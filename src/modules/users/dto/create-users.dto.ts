import {
  IsOptional,
  IsEnum,
  IsBoolean,
  IsEmail,
  IsMobilePhone,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
// import { UserRoleEnum } from './user-query.dto';

enum UserRoleEnum {
  admin = 'admin',
  class_teacher = 'class_teacher',
  subject_teacher = 'subject_teacher',
  parent = 'parent',
  student = 'student',
}
export class UpdateUserDto {
  @ApiPropertyOptional({ example: '+2348099887766' })
  @IsOptional()
  @IsMobilePhone(
    'en-NG',
    {},
    { message: 'phone must be a valid Nigerian mobile number' },
  )
  phone?: string;

  @ApiPropertyOptional({ example: 'user@school.ng' })
  @IsOptional()
  @IsEmail({}, { message: 'email must be a valid email address' })
  email?: string;

  @ApiPropertyOptional({ enum: UserRoleEnum })
  @IsOptional()
  @IsEnum(UserRoleEnum)
  role?: UserRoleEnum;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
