import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsUUID,
  IsEnum,
  IsOptional,
  MinLength,
  Matches,
} from 'class-validator';
import { Type } from 'class-transformer';
import { LeaveStatus } from '@prisma/client';

export class CreateLeaveRequestDto {
  @ApiProperty({ example: 'uuid-of-student' })
  @IsUUID()
  studentId!: string;

  @ApiProperty({ example: 'Family emergency — bereavement' })
  @IsString()
  @MinLength(10, { message: 'Reason must be at least 10 characters.' })
  reason!: string;

  @ApiProperty({ example: '2025-01-13', description: 'ISO date string' })
  @IsString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'fromDate must be YYYY-MM-DD' })
  fromDate!: string;

  @ApiProperty({ example: '2025-01-14', description: 'ISO date string' })
  @IsString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, { message: 'toDate must be YYYY-MM-DD' })
  toDate!: string;
}

export class DecideLeaveRequestDto {
  @ApiProperty({ enum: LeaveStatus, example: 'approved' })
  @IsEnum(LeaveStatus)
  status!: LeaveStatus;

  @ApiPropertyOptional({ example: 'Approved. Condolences to the family.' })
  @IsOptional()
  @IsString()
  decisionNote?: string;
}

export class LeaveRequestQueryDto {
  @ApiPropertyOptional({ enum: LeaveStatus })
  @IsOptional()
  @IsEnum(LeaveStatus)
  status?: LeaveStatus;

  @ApiPropertyOptional({ example: 'uuid-of-student' })
  @IsOptional()
  @IsUUID()
  studentId?: string;

  @ApiPropertyOptional({ example: 1 })
  @IsOptional()
  @Type(() => Number)
  page?: number;

  @ApiPropertyOptional({ example: 20 })
  @IsOptional()
  @Type(() => Number)
  limit?: number;
}
