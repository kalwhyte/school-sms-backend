import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsUUID,
  IsEnum,
  Length,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { ClassStream } from '@prisma/client';

export class UpdateClassDto {
  @ApiPropertyOptional({ example: 'JSS 2' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @Length(1, 60)
  name?: string;

  @ApiPropertyOptional({ example: 'B' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  @Length(1, 10)
  arm?: string;

  @ApiPropertyOptional({
    enum: ClassStream,
    example: ClassStream.arts,
    description: 'Update the class stream',
  })
  @IsOptional()
  @IsEnum(ClassStream, {
    message: 'stream must be one of: science, commercial, arts, general',
  })
  stream?: ClassStream | null;

  @ApiPropertyOptional({ example: 'uuid-of-staff' })
  @IsOptional()
  @IsUUID()
  teacherId?: string | null;
}
