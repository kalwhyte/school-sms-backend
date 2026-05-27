// import {
//   IsString,
//   IsNotEmpty,
//   IsOptional,
//   IsUUID,
//   IsEnum,
//   Length,
//   Matches,
// } from 'class-validator';
// import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

// export enum TermEnum {
//   first = 'first',
//   second = 'second',
//   third = 'third',
// }

// export enum ClassLevel {
//   nursery = 'Nursery',
//   primary = 'Primary',
//   jss1 = 'JSS',
//   sss1 = 'SSS',
// }

// export enum ClassStream {
//   science = 'Science',
//   arts = 'Arts',
//   commercial = 'Commercial',
// }

// export class CreateClassDto {
//   @ApiProperty({ example: 'JSS 1' })
//   @IsString()
//   @IsNotEmpty()
//   @Length(1, 60)
//   name?: string;

//   @ApiProperty({ example: 'A' })
//   @IsString()
//   @IsNotEmpty()
//   @Length(1, 10)
//   arm?: string;

//   @ApiProperty({ enum: ClassLevel, example: ClassLevel.jss1 })
//   @IsString()
//   @IsNotEmpty()
//   @Matches(/^(Nursery|Primary|JSS|SSS)$/, {
//     message: 'level must be Nursery | Primary | JSS | SSS',
//   })
//   level!: ClassLevel;

//   @ApiProperty({ enum: ClassStream, example: ClassStream.science })
//   @IsString()
//   @IsNotEmpty()
//   @Length(1, 30)
//   stream?: string;

//   @ApiProperty({ example: '2024/2025' })
//   @IsString()
//   @IsNotEmpty()
//   @Matches(/^\d{4}\/\d{4}$/, {
//     message: 'academicYear must be in format YYYY/YYYY',
//   })
//   academicYear?: string;

//   @ApiProperty({ enum: TermEnum, example: TermEnum.first })
//   @IsEnum(TermEnum, { message: 'term must be first | second | third' })
//   term?: TermEnum;

//   @ApiPropertyOptional({ example: 'staff-uuid-001' })
//   @IsOptional()
//   @IsUUID()
//   teacherId?: string | null;
// }

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
import { ClassLevel, ClassStream, Term } from '@prisma/client';

export { ClassLevel, ClassStream, Term };

export class CreateClassDto {
  @ApiProperty({ example: 'JSS 1', description: 'Class name' })
  @IsString()
  @IsNotEmpty()
  @Length(1, 60)
  name!: string;

  @ApiProperty({ example: 'A', description: 'Class arm/section' })
  @IsString()
  @IsNotEmpty()
  @Length(1, 10)
  arm!: string;

  @ApiProperty({
    enum: ClassLevel,
    example: ClassLevel.jss1,
    description: 'Class level (jss1–ss3)',
  })
  @IsEnum(ClassLevel, {
    message: 'level must be one of: jss1, jss2, jss3, ss1, ss2, ss3',
  })
  level!: ClassLevel;

  @ApiPropertyOptional({
    enum: ClassStream,
    example: ClassStream.science,
    description: 'Stream — required for SS classes',
  })
  @IsOptional()
  @IsEnum(ClassStream, {
    message: 'stream must be one of: science, commercial, arts, general',
  })
  stream?: ClassStream | null;

  @ApiProperty({
    example: '2024/2025',
    description: 'Academic year in YYYY/YYYY format',
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^\d{4}\/\d{4}$/, {
    message: 'academicYear must be in format YYYY/YYYY',
  })
  academicYear!: string;

  @ApiProperty({
    enum: Term,
    example: Term.first,
    description: 'School term',
  })
  @IsEnum(Term, { message: 'term must be: first | second | third' })
  term!: Term;

  @ApiPropertyOptional({
    example: 'uuid-of-staff',
    description: 'ID of the class teacher (staff)',
  })
  @IsOptional()
  @IsUUID()
  teacherId?: string | null;
}
