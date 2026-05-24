// export class CreatePaymentsDto {}
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEnum,
  IsString,
  IsUUID,
  IsNumber,
  IsPositive,
  IsOptional,
  Min,
  Matches,
} from 'class-validator';
import { Term } from '@prisma/client';
import { Type } from 'class-transformer';

export class InitiatePaymentDto {
  @ApiProperty({ example: 'uuid-of-student' })
  @IsUUID()
  studentId!: string;

  @ApiProperty({ example: 75000, description: 'Amount in kobo (NGN × 100)' })
  @IsNumber()
  @IsPositive()
  @Type(() => Number)
  amount!: number;

  @ApiPropertyOptional({ enum: Term, example: 'first' })
  @IsOptional()
  @IsEnum(Term)
  term?: Term;

  @ApiPropertyOptional({ example: '2024/2025' })
  @IsOptional()
  @IsString()
  @Matches(/^\d{4}\/\d{4}$/, {
    message: 'academicYear must be in format YYYY/YYYY',
  })
  academicYear?: string;
}

export class PaymentQueryDto {
  @ApiPropertyOptional({ example: 'uuid-of-student' })
  @IsOptional()
  @IsUUID()
  studentId?: string;

  @ApiPropertyOptional({ enum: ['pending', 'success', 'failed'] })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({ enum: Term })
  @IsOptional()
  @IsEnum(Term)
  term?: Term;

  @ApiPropertyOptional({ example: '2024/2025' })
  @IsOptional()
  @IsString()
  academicYear?: string;

  @ApiPropertyOptional({ example: 1 })
  @IsOptional()
  @Type(() => Number)
  @Min(1)
  page?: number;

  @ApiPropertyOptional({ example: 20 })
  @IsOptional()
  @Type(() => Number)
  @Min(1)
  limit?: number;
}
