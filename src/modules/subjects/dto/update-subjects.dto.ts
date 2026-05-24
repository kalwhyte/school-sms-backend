// export class UpdateSubjectsDto {}
import { PartialType, OmitType } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsString, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { CreateSubjectDto } from './create-subjects.dto';

export class UpdateSubjectDto extends PartialType(
  OmitType(CreateSubjectDto, ['classId'] as const),
) {}

// ── Timetable period ──────────────────────────────────────────────────────────

export enum DayOfWeekEnum {
  monday = 'monday',
  tuesday = 'tuesday',
  wednesday = 'wednesday',
  thursday = 'thursday',
  friday = 'friday',
}

export class CreateTimetablePeriodDto {
  @ApiProperty({ enum: DayOfWeekEnum, example: DayOfWeekEnum.monday })
  @IsEnum(DayOfWeekEnum, { message: 'dayOfWeek must be monday–friday' })
  dayOfWeek?: DayOfWeekEnum;

  @ApiProperty({ example: '08:00', description: 'HH:mm 24-hour time' })
  @IsString()
  @IsNotEmpty()
  @Matches(/^([01]\d|2[0-3]):[0-5]\d$/, { message: 'startTime must be HH:mm' })
  startTime?: string;

  @ApiProperty({ example: '09:00' })
  @IsString()
  @IsNotEmpty()
  @Matches(/^([01]\d|2[0-3]):[0-5]\d$/, { message: 'endTime must be HH:mm' })
  endTime?: string;
}
