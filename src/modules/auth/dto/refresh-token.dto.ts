import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RefreshTokenDto {
  @ApiProperty({ description: 'The refresh token issued on login' })
  @IsString()
  @IsNotEmpty()
  refreshToken!: string;
}
