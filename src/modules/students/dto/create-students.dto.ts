import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsUUID,
  IsEnum,
  IsDateString,
  IsMobilePhone,
  IsEmail,
  Length,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export enum Gender {
  MALE = 'male',
  FEMALE = 'female',
}

export class CreateStudentDto {
  @ApiProperty({ example: 'Emeka Okafor' })
  @IsString()
  @IsNotEmpty()
  @Length(2, 120)
  fullName?: string;

  @ApiPropertyOptional({ example: '2008-04-15' })
  @IsOptional()
  @IsDateString()
  dateOfBirth?: string;

  @ApiPropertyOptional({ enum: Gender, example: Gender.MALE })
  @IsOptional()
  @IsEnum(Gender)
  gender?: Gender;

  @ApiProperty({ example: 'uuid-of-class' })
  @IsUUID()
  classId?: string;

  @ApiPropertyOptional({ example: 'Mrs. Ngozi Okafor' })
  @IsOptional()
  @IsString()
  @Length(2, 120)
  guardianName?: string;

  @ApiPropertyOptional({ example: '+2348012345678' })
  @IsOptional()
  @IsMobilePhone(
    'en-NG',
    {},
    { message: 'phone must be a valid Nigerian mobile number' },
  )
  phone?: string;

  @ApiPropertyOptional({ example: 'emeka@gmail.com' })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiPropertyOptional({ example: 'https://res.cloudinary.com/demo/photo.png' })
  @IsOptional()
  @IsString()
  photoUrl?: string;
}
