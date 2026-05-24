// export class CreateReport-cardsDto {}
import { IsEnum, IsString, IsNotEmpty, IsUUID } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Term } from '@prisma/client';

// ── Generate for a single student ────────────────────────────────────────────
export class GenerateReportCardDto {
  @ApiProperty({ example: 'uuid-of-student' })
  @IsUUID()
  studentId!: string;

  @ApiProperty({ enum: Term, example: Term.first })
  @IsEnum(Term)
  term!: Term;

  @ApiProperty({ example: '2025/2026' })
  @IsString()
  @IsNotEmpty()
  academicYear!: string;
}

// ── Generate for an entire class ─────────────────────────────────────────────
export class GenerateClassReportCardsDto {
  @ApiProperty({ example: 'uuid-of-class' })
  @IsUUID()
  classId!: string;

  @ApiProperty({ enum: Term, example: Term.first })
  @IsEnum(Term)
  term!: Term;

  @ApiProperty({ example: '2025/2026' })
  @IsString()
  @IsNotEmpty()
  academicYear!: string;
}

// ── Publish ───────────────────────────────────────────────────────────────────
export class PublishReportCardsDto {
  @ApiProperty({ example: 'uuid-of-class' })
  @IsUUID()
  classId!: string;

  @ApiProperty({ enum: Term, example: Term.first })
  @IsEnum(Term)
  term!: Term;

  @ApiProperty({ example: '2025/2026' })
  @IsString()
  @IsNotEmpty()
  academicYear!: string;
}
