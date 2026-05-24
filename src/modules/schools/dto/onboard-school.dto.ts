import { Type } from 'class-transformer';
import {
  IsString,
  IsNotEmpty,
  IsMobilePhone,
  ValidateNested,
  Length,
  IsOptional,
  IsStrongPassword,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { CreateSchoolDto } from './create-schools.dto';

export class FirstAdminDto {
  @ApiProperty({ example: '+2348012345678' })
  @IsString()
  @IsNotEmpty()
  @IsMobilePhone(
    'en-NG',
    {},
    {
      message: 'phone must be a valid Nigerian mobile number',
    },
  )
  phone?: string;

  @ApiProperty({ example: 'Kal Whyte' })
  @IsString()
  @IsNotEmpty()
  @Length(2, 120)
  fullName?: string;

  @ApiPropertyOptional({ example: 'Principal' })
  @IsOptional()
  @IsString()
  @Length(2, 80)
  roleTitle?: string;

  @ApiProperty({ example: 'Admin@1234' })
  @IsString()
  @IsNotEmpty()
  @IsStrongPassword(
    { minLength: 8, minUppercase: 1, minNumbers: 1, minSymbols: 1 },
    {
      message:
        'password must be at least 8 chars with uppercase, number, and symbol',
    },
  )
  password?: string;
}

export class OnboardSchoolDto {
  @ApiProperty({ type: CreateSchoolDto })
  @ValidateNested()
  @Type(() => CreateSchoolDto)
  school?: CreateSchoolDto;

  @ApiProperty({ type: FirstAdminDto })
  @ValidateNested()
  @Type(() => FirstAdminDto)
  admin?: FirstAdminDto;
}
