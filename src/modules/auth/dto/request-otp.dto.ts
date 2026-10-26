import { IsString, IsNotEmpty, Length, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RequestOtpDto {
  @ApiProperty({
    example: 'GFA001',
    description: 'School code used to identify the school',
  })
  @IsString()
  @IsNotEmpty()
  @Length(3, 20)
  @Matches(/^[A-Za-z0-9_-]+$/)
  schoolCode!: string;

  @ApiProperty({
    example: '+2348012345678',
    description: 'Registered phone number in E.164 format or email address',
  })
  @IsString()
  @IsNotEmpty()
  @Length(3, 254)
  identifier!: string;
}
