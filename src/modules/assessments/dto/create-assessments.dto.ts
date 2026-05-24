// export class CreateAssessmentsDto {}
import {
  IsString,
  IsNotEmpty,
  IsUUID,
  IsEnum,
  IsDateString,
  IsNumber,
  IsOptional,
  IsBoolean,
  IsArray,
  ArrayNotEmpty,
  ValidateNested,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { AssessmentType, Term } from '@prisma/client';

// ── Create Assessment ─────────────────────────────────────────────────────────
export class CreateAssessmentDto {
  @ApiProperty({ example: 'uuid-of-subject' })
  @IsUUID()
  subjectId?: string;

  @ApiProperty({ example: 'CA Test 1' })
  @IsString()
  @IsNotEmpty()
  title!: string;

  @ApiProperty({ enum: AssessmentType, example: AssessmentType.CA })
  @IsEnum(AssessmentType)
  type!: AssessmentType;

  @ApiProperty({ example: 20, description: 'Maximum obtainable score' })
  @IsNumber()
  @Min(1)
  maxScore!: number;

  @ApiPropertyOptional({ example: 10, description: 'Minimum passing score' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  passingScore!: number;

  @ApiProperty({ example: '2026-05-20' })
  @IsDateString()
  date!: string;
}

// ── Update Assessment ─────────────────────────────────────────────────────────
export class UpdateAssessmentDto {
  @ApiPropertyOptional({ example: 'CA Test 1 (Updated)' })
  @IsOptional()
  @IsString()
  @IsNotEmpty()
  title!: string;

  @ApiPropertyOptional({ enum: AssessmentType })
  @IsOptional()
  @IsEnum(AssessmentType)
  type!: AssessmentType;

  @ApiPropertyOptional({ example: 20 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  maxScore!: number;

  @ApiPropertyOptional({ example: 10 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  passingScore!: number;

  @ApiPropertyOptional({ example: '2026-05-21' })
  @IsOptional()
  @IsDateString()
  date!: string;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  isPublished!: boolean;

  @ApiProperty({ enum: Term, example: Term.first })
  @IsEnum(Term)
  term!: Term;

  @ApiProperty({ example: '2025/2026' })
  @IsString()
  @IsNotEmpty()
  academicYear!: string;
}

// ── Single score entry within bulk submit ─────────────────────────────────────
export class ScoreEntryDto {
  @ApiProperty({ example: 'uuid-of-student' })
  @IsUUID()
  studentId!: string;

  @ApiProperty({
    example: 17.5,
    description: 'Raw score — must not exceed assessment maxScore',
  })
  @IsNumber()
  @Min(0)
  score!: number;
}

// ── Bulk submit scores ────────────────────────────────────────────────────────
export class BulkScoresDto {
  @ApiProperty({ type: [ScoreEntryDto] })
  @IsArray()
  @ArrayNotEmpty()
  @ValidateNested({ each: true })
  @Type(() => ScoreEntryDto)
  scores!: ScoreEntryDto[];
}
