// export class CreateAnnouncementsDto {}
import {
  IsString,
  IsNotEmpty,
  IsEnum,
  IsOptional,
  IsUUID,
  Length,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { AnnouncementAudience } from '@prisma/client';

export class CreateAnnouncementDto {
  @ApiProperty({ example: 'End of Term Examination Schedule' })
  @IsString()
  @IsNotEmpty()
  @Length(3, 200)
  title!: string;

  @ApiProperty({ example: 'Examinations will commence on Monday 2nd June...' })
  @IsString()
  @IsNotEmpty()
  body!: string;

  @ApiProperty({
    enum: AnnouncementAudience,
    example: AnnouncementAudience.all,
    description: 'all | parents | teachers | class',
  })
  @IsEnum(AnnouncementAudience)
  audience!: AnnouncementAudience;

  @ApiPropertyOptional({
    example: 'uuid-of-class',
    description: 'Required when audience = class',
  })
  @IsOptional()
  @IsUUID()
  classId?: string;
}
