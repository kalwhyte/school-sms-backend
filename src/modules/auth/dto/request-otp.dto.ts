import { IsString, IsMobilePhone, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RequestOtpDto {
  @ApiProperty({
    example: '+2348012345678',
    description: 'Nigerian phone number in E.164 format',
  })
  @IsString()
  @IsNotEmpty()
  @IsMobilePhone(
    'en-NG',
    {},
    { message: 'phone must be a valid Nigerian mobile number' },
  )
  phone!: string;
}
