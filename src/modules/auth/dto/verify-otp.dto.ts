import { IsString, IsNotEmpty, Length, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class VerifyOtpDto {
  @ApiProperty({ example: 'GFA001' })
  @IsString()
  @IsNotEmpty()
  @Length(3, 20)
  @Matches(/^[A-Za-z0-9_-]+$/)
  schoolCode!: string;

  @ApiProperty({
    example: '+2348012345678',
    description: 'The same phone number or email used to request the OTP',
  })
  @IsString()
  @IsNotEmpty()
  @Length(3, 254)
  identifier!: string;

  @ApiProperty({ example: '482910' })
  @IsString()
  @IsNotEmpty()
  @Length(6, 6)
  @Matches(/^\d{6}$/, {
    message: 'otp must contain exactly 6 digits',
  })
  otp!: string;
}
