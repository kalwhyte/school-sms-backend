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
import { ExpenseCategory } from '@prisma/client';
import { Type } from 'class-transformer';

// ── Fee Structure ─────────────────────────────────────────────────────────────

export class CreateFeeStructureDto {
  @ApiProperty({ example: 'uuid-of-class' })
  @IsUUID()
  classId!: string;

  @ApiProperty({ enum: Term, example: 'first' })
  @IsEnum(Term)
  term!: Term;

  @ApiProperty({ example: '2024/2025' })
  @IsString()
  @Matches(/^\d{4}\/\d{4}$/, {
    message: 'academicYear must be in format YYYY/YYYY',
  })
  academicYear!: string;

  @ApiProperty({
    example: 75000,
    description: 'Amount in base currency unit (kobo or naira)',
  })
  @IsNumber()
  @IsPositive()
  @Type(() => Number)
  amount!: number;

  @ApiPropertyOptional({ example: 'Includes development levy and PTA dues' })
  @IsOptional()
  @IsString()
  description?: string;
}

export class UpdateFeeStructureDto {
  @ApiPropertyOptional({ example: 80000 })
  @IsOptional()
  @IsNumber()
  @IsPositive()
  @Type(() => Number)
  amount?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;
}

export class FeeStructureQueryDto {
  @ApiPropertyOptional({ enum: Term })
  @IsOptional()
  @IsEnum(Term)
  term?: Term;

  @ApiPropertyOptional({ example: '2024/2025' })
  @IsOptional()
  @IsString()
  academicYear?: string;

  @ApiPropertyOptional({ example: 'uuid-of-class' })
  @IsOptional()
  @IsUUID()
  classId?: string;

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

// ── Bursary Approval (discount) ───────────────────────────────────────────────

export class CreateBursaryApprovalDto {
  @ApiProperty({ example: 'uuid-of-student' })
  @IsUUID()
  studentId!: string;

  @ApiProperty({ example: 10000, description: 'Discount amount' })
  @IsNumber()
  @IsPositive()
  @Type(() => Number)
  discountAmount!: number;

  @ApiProperty({ example: 'Scholarship award — top 5% academic performance' })
  @IsString()
  reason!: string;

  @ApiPropertyOptional({ enum: Term })
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

export class BursaryQueryDto {
  @ApiPropertyOptional({ example: 'uuid-of-student' })
  @IsOptional()
  @IsUUID()
  studentId?: string;

  @ApiPropertyOptional({ enum: Term })
  @IsOptional()
  @IsEnum(Term)
  term?: Term;

  @ApiPropertyOptional({ example: '2024/2025' })
  @IsOptional()
  @IsString()
  academicYear?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @Min(1)
  page?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @Min(1)
  limit?: number;
}

// ── Expense ───────────────────────────────────────────────────────────────────

export class CreateExpenseDto {
  @ApiProperty({ example: 'Generator fuel — November' })
  @IsString()
  description?: string;

  @ApiProperty({ example: 25000 })
  @IsNumber()
  @IsPositive()
  @Type(() => Number)
  amount?: number;

  @ApiProperty({ enum: ExpenseCategory, example: 'utilities' })
  @IsEnum(ExpenseCategory)
  category?: ExpenseCategory;

  @ApiProperty({ example: '2024-11-15', description: 'ISO date string' })
  @IsString()
  date?: string;
}

export class ExpenseQueryDto {
  @ApiPropertyOptional({ enum: ExpenseCategory })
  @IsOptional()
  @IsEnum(ExpenseCategory)
  category?: ExpenseCategory;

  @ApiPropertyOptional({
    example: '2024-11-01',
    description: 'Filter from date (ISO)',
  })
  @IsOptional()
  @IsString()
  from?: string;

  @ApiPropertyOptional({ example: '2024-11-30' })
  @IsOptional()
  @IsString()
  to?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @Min(1)
  page?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @Min(1)
  limit?: number;
}
