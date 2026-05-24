import { IsArray, IsUUID, ArrayNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class BulkPromoteDto {
  @ApiProperty({
    type: [String],
    description: 'Array of student UUIDs to promote',
    example: ['uuid-1', 'uuid-2'],
  })
  @IsArray()
  @ArrayNotEmpty()
  @IsUUID('4', { each: true })
  studentIds?: string[];

  @ApiProperty({
    example: 'uuid-of-target-class',
    description: 'The class to promote students into',
  })
  @IsUUID()
  targetClassId?: string;
}
