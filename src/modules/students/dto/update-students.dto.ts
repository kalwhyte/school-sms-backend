import { PartialType, OmitType } from '@nestjs/swagger';
import { CreateStudentDto } from './create-students.dto';
// import { IsOptional, IsUUID } from 'class-validator';
// import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateStudentDto extends PartialType(
  OmitType(CreateStudentDto, ['classId'] as const),
) {
  // classId is intentionally excluded — use bulk-promote or a dedicated
  // transfer endpoint to move students between classes
}
