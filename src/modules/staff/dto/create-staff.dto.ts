import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsUrl,
  IsMobilePhone,
  Length,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateStaffDto {
  @ApiProperty({ example: '+2348012345678' })
  @IsString()
  @IsNotEmpty()
  @IsMobilePhone(
    'en-NG',
    {},
    { message: 'phone must be a valid Nigerian mobile number' },
  )
  phone?: string;

  @ApiProperty({ example: 'Ngozi Adeyemi' })
  @IsString()
  @IsNotEmpty()
  @Length(2, 120)
  fullName?: string;

  @ApiProperty({
    example: 'class_teacher',
    enum: ['admin', 'class_teacher', 'subject_teacher'],
  })
  @IsString()
  @IsNotEmpty()
  role?: string;

  @ApiProperty({ example: 'Class Teacher' })
  @IsString()
  @IsNotEmpty()
  @Length(2, 80)
  roleTitle?: string;

  @ApiPropertyOptional({ example: 'Mathematics' })
  @IsOptional()
  @IsString()
  @Length(2, 80)
  subjectSpecialty?: string;

  @ApiPropertyOptional({ example: 'https://res.cloudinary.com/demo/photo.jpg' })
  @IsOptional()
  @IsUrl({}, { message: 'photoUrl must be a valid URL' })
  photoUrl?: string;
}
