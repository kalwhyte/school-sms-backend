import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsUUID,
  IsEnum,
  Length,
  Matches,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export enum TermEnum {
  first = 'first',
  second = 'second',
  third = 'third',
}

export class CreateClassDto {
  @ApiProperty({ example: 'JSS 1' })
  @IsString()
  @IsNotEmpty()
  @Length(1, 60)
  name?: string;

  @ApiProperty({ example: 'A' })
  @IsString()
  @IsNotEmpty()
  @Length(1, 10)
  arm?: string;

  @ApiProperty({ enum: ClassLevel, example: ClassLevel.jss1 })
  @IsString()
  @IsNotEmpty()
  @Matches(/^(Nursery|Primary|JSS|SSS)$/, {
    message: 'level must be Nursery | Primary | JSS | SSS',
  })
  level?: string;

  @ApiProperty({ enum: ClassStream, example: ClassStream.science })
  @IsString()
  @IsNotEmpty()
  @Length(1, 30)
  stream?: string;

  @ApiProperty({ example: '2024/2025' })
  @IsString()
  @IsNotEmpty()
  @Matches(/^\d{4}\/\d{4}$/, {
    message: 'academicYear must be in format YYYY/YYYY',
  })
  academicYear?: string;

  @ApiProperty({ enum: TermEnum, example: TermEnum.first })
  @IsEnum(TermEnum, { message: 'term must be first | second | third' })
  term?: TermEnum;

  @ApiPropertyOptional({ example: 'staff-uuid-001' })
  @IsOptional()
  @IsUUID()
  teacherId?: string;
}
