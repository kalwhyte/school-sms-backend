import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsUrl,
  Length,
  Matches,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateSchoolDto {
  @ApiProperty({ example: 'WhyteCode Academy' })
  @IsString()
  @IsNotEmpty()
  @Length(2, 120)
  name?: string;

  @ApiProperty({ example: '12 Aba Road, Port Harcourt, Rivers State' })
  @IsString()
  @IsNotEmpty()
  @Length(5, 255)
  address?: string;

  @ApiProperty({
    example: 'GFA010',
    description: 'Unique short code used in OTP login flow',
  })
  @IsString()
  @IsNotEmpty()
  @Length(3, 20)
  @Matches(/^[A-Z0-9_-]+$/, {
    message:
      'schoolCode must be uppercase alphanumeric with hyphens/underscores only',
  })
  schoolCode?: string;

  @ApiPropertyOptional({ example: 'NGN' })
  @IsOptional()
  @IsString()
  @Length(3, 3, { message: 'currency must be a 3-letter ISO code e.g. NGN' })
  currency?: string;

  @ApiPropertyOptional({ example: 'https://res.cloudinary.com/demo/logo.png' })
  @IsOptional()
  @IsUrl({}, { message: 'logoUrl must be a valid URL' })
  logoUrl?: string;
}
