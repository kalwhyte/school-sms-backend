// import { IsOptional, IsString, IsInt, IsEnum, Min, Max } from 'class-validator';
// import { Type } from 'class-transformer';
// import { ApiPropertyOptional } from '@nestjs/swagger';
// import { ClassLevel, ClassStream, TermEnum } from './create-classes.dto';

// export class ClassQueryDto {
//   @ApiPropertyOptional({ example: 1 })
//   @IsOptional()
//   @Type(() => Number)
//   @IsInt()
//   @Min(1)
//   page?: number = 1;

//   @ApiPropertyOptional({ example: 20 })
//   @IsOptional()
//   @Type(() => Number)
//   @IsInt()
//   @Min(1)
//   @Max(100)
//   limit?: number = 20;

//   @ApiPropertyOptional({ example: '2024/2025' })
//   @IsOptional()
//   @IsString()
//   academicYear?: string;

//   @ApiPropertyOptional({ enum: TermEnum })
//   @IsOptional()
//   @IsEnum(TermEnum)
//   term?: TermEnum;

//   @ApiPropertyOptional({ enum: ClassLevel })
//   @IsOptional()
//   @IsEnum(ClassLevel)
//   level?: ClassLevel;

//   @ApiPropertyOptional({ enum: ClassStream })
//   @IsOptional()
//   @IsEnum(ClassStream)
//   stream?: ClassStream;
// }

import {
  IsOptional,
  IsEnum,
  IsString,
  Matches,
  IsInt,
  Min,
  Max,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { ClassLevel, ClassStream, Term } from '@prisma/client';

export class ClassQueryDto {
  @ApiPropertyOptional({ example: '2024/2025' })
  @IsOptional()
  @IsString()
  @Matches(/^\d{4}\/\d{4}$/, { message: 'academicYear must be YYYY/YYYY' })
  academicYear?: string;

  @ApiPropertyOptional({ enum: Term })
  @IsOptional()
  @IsEnum(Term)
  term?: Term;

  @ApiPropertyOptional({ enum: ClassLevel })
  @IsOptional()
  @IsEnum(ClassLevel)
  level?: ClassLevel;

  @ApiPropertyOptional({ enum: ClassStream })
  @IsOptional()
  @IsEnum(ClassStream)
  stream?: ClassStream;

  @ApiPropertyOptional({ default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}
