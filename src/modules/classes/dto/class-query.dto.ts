import { IsOptional, IsString, IsInt, IsEnum, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { TermEnum } from './create-classes.dto';

export class ClassQueryDto {
  @ApiPropertyOptional({ example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ example: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;

  @ApiPropertyOptional({ example: '2024/2025' })
  @IsOptional()
  @IsString()
  academicYear?: string;

  @ApiPropertyOptional({ enum: TermEnum })
  @IsOptional()
  @IsEnum(TermEnum)
  term?: TermEnum;
}
