import { PartialType, OmitType } from '@nestjs/swagger';
import { CreateStaffDto } from './create-staff.dto';

// phone is immutable — it's the login credential tied to the User record
export class UpdateStaffDto extends PartialType(
  OmitType(CreateStaffDto, ['phone'] as const),
) {}
