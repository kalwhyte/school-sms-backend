// export class CreateMessagesDto {}
import { IsUUID, IsString, IsNotEmpty, Length } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

// ── Start a new thread ────────────────────────────────────────────────────────
export class CreateThreadDto {
  @ApiProperty({ example: 'uuid-of-teacher-staff-record' })
  @IsUUID()
  teacherId!: string;

  @ApiProperty({ example: 'uuid-of-student' })
  @IsUUID()
  studentId!: string;

  @ApiProperty({ example: "Regarding Emeka's performance in Mathematics" })
  @IsString()
  @IsNotEmpty()
  @Length(1, 500)
  firstMessage!: string;
}

// ── Send a message in an existing thread ─────────────────────────────────────
export class SendMessageDto {
  @ApiProperty({
    example: 'Thank you for reaching out. Emeka has been improving.',
  })
  @IsString()
  @IsNotEmpty()
  @Length(1, 2000)
  body!: string;
}
