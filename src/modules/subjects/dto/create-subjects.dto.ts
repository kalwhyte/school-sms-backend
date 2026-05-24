// export class CreateSubjectsDto {}
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsUUID,
  IsBoolean,
  Length,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateSubjectDto {
  @ApiProperty({ example: 'Mathematics' })
  @IsString()
  @IsNotEmpty()
  @Length(2, 80)
  name!: string;

  @ApiProperty({ example: 'class-uuid-001' })
  @IsUUID()
  classId!: string;

  @ApiPropertyOptional({ example: true, default: true })
  @IsOptional()
  @IsBoolean()
  isCore?: boolean = true;

  @ApiPropertyOptional({ example: 'staff-uuid-001' })
  @IsOptional()
  @IsUUID()
  teacherId?: string;
}
