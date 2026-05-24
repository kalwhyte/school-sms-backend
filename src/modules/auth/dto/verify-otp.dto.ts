import { IsString, IsNotEmpty, IsMobilePhone, Length } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class VerifyOtpDto {
  @ApiProperty({ example: '+2348012345678' })
  @IsString()
  @IsNotEmpty()
  @IsMobilePhone(
    'en-NG',
    {},
    { message: 'phone must be a valid Nigerian mobile number' },
  )
  phone!: string;

  @ApiProperty({ example: '482910', description: '6-digit OTP sent via SMS' })
  @IsString()
  @IsNotEmpty()
  @Length(6, 6, { message: 'otp must be exactly 6 digits' })
  otp!: string;

  @ApiProperty({ example: '482910', description: '6-digit OTP sent via SMS' })
  @IsString()
  @IsNotEmpty()
  @Length(6, 6, { message: 'otp must be exactly 6 digits' })
  schoolCode!: string;
}
