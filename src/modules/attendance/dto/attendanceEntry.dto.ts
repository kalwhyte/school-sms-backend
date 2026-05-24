import {
  IsUUID,
  IsEnum,
  IsDateString,
  IsArray,
  ArrayNotEmpty,
  ValidateNested,
  IsNotEmpty,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { AttendanceStatus } from '@prisma/client';

// ── Single entry within a bulk submit ────────────────────────────────────────
export class AttendanceEntryDto {
  @ApiProperty({ example: 'uuid-of-student' })
  @IsUUID()
  studentId!: string;

  @ApiProperty({ enum: AttendanceStatus, example: AttendanceStatus.present })
  @IsEnum(AttendanceStatus)
  status?: AttendanceStatus;

  @ApiPropertyOptional({
    example: 'Medical appointment, arrived late at 10:30am',
  })
  @IsNotEmpty()
  @ApiProperty({ example: 'Medical appointment, arrived late at 10:30am' })
  reason?: string;
}

// ── Bulk submit for a class on a date ────────────────────────────────────────
export class BulkAttendanceDto {
  @ApiProperty({ example: 'uuid-of-class' })
  @IsUUID()
  classId!: string;

  @ApiProperty({
    example: '2026-05-20',
    description: 'ISO date string YYYY-MM-DD',
  })
  @IsDateString()
  @IsNotEmpty()
  date!: string;

  @ApiProperty({ type: [AttendanceEntryDto] })
  @IsArray()
  @ArrayNotEmpty()
  @ValidateNested({ each: true })
  @Type(() => AttendanceEntryDto)
  records!: AttendanceEntryDto[];
}
