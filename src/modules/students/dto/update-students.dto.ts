import { PartialType, OmitType } from '@nestjs/swagger';
import { CreateStudentDto } from './create-students.dto';
import { IsOptional, IsUUID } from 'class-validator';
// import { IsOptional, IsUUID } from 'class-validator';
// import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateStudentDto extends PartialType(
  OmitType(CreateStudentDto, ['classId'] as const),
) {
  @IsOptional()
  @IsUUID()
  classId?: string | null;
}
