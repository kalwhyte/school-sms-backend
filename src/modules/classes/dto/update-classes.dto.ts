import { PartialType, OmitType } from '@nestjs/swagger';
import { CreateClassDto } from './create-classes.dto';

// academicYear + term are immutable — they define the class identity.
// Reassigning teacher or renaming arm is allowed.
export class UpdateClassDto extends PartialType(
  OmitType(CreateClassDto, ['academicYear', 'term'] as const),
) {}
