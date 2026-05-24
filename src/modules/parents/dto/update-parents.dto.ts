import { PartialType, OmitType } from '@nestjs/swagger';
import { IsUUID, IsString, IsOptional, Length } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { CreateParentDto } from './create-parents.dto';

export class UpdateParentDto extends PartialType(
  OmitType(CreateParentDto, ['phone'] as const),
) {}

export class LinkStudentDto {
  @ApiProperty({ example: 'student-uuid-001' })
  @IsUUID()
  studentId?: string;

  @ApiPropertyOptional({ example: 'mother', default: 'guardian' })
  @IsOptional()
  @IsString()
  @Length(2, 40)
  relationship?: string;
}
