import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsEmail,
  IsMobilePhone,
  Length,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateParentDto {
  role() {
    throw new Error('Method not implemented.');
  }
  @ApiProperty({ example: '+2348098765432' })
  @IsString()
  @IsNotEmpty()
  @IsMobilePhone(
    'en-NG',
    {},
    { message: 'phone must be a valid Nigerian mobile number' },
  )
  phone?: string;

  @ApiProperty({ example: 'Mrs. Amaka Okonkwo' })
  @IsString()
  @IsNotEmpty()
  @Length(2, 120)
  fullName?: string;

  @ApiPropertyOptional({ example: 'amaka@example.com' })
  @IsOptional()
  @IsEmail({}, { message: 'email must be a valid email address' })
  email?: string;

  @ApiPropertyOptional({ example: 'Business Owner' })
  @IsOptional()
  @IsString()
  @Length(2, 80)
  occupation?: string;
}
