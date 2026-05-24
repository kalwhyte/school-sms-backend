import { PartialType, OmitType } from '@nestjs/swagger';
import { CreateSchoolDto } from './create-schools.dto';

// schoolCode is immutable after creation — excluded from updates
export class UpdateSchoolDto extends PartialType(
  OmitType(CreateSchoolDto, ['schoolCode'] as const),
) {}
