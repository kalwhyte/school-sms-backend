import {
  IsOptional,
  IsEnum,
  IsBoolean,
  IsInt,
  IsString,
  Min,
  Max,
} from 'class-validator';
import { Transform, Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';

export enum UserRoleEnum {
  admin = 'admin',
  class_teacher = 'class_teacher',
  subject_teacher = 'subject_teacher',
  parent = 'parent',
  student = 'student',
}

export class UserQueryDto {
  @ApiPropertyOptional({ example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ example: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;

  @ApiPropertyOptional({ enum: UserRoleEnum })
  @IsOptional()
  @IsEnum(UserRoleEnum)
  role?: UserRoleEnum;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @Transform(({ value }: { value: string }) => value === 'true')
  @IsBoolean()
  isActive?: boolean;

  @ApiPropertyOptional({ example: '+2348012345678' })
  @IsOptional()
  @IsString()
  phone?: string;
}
