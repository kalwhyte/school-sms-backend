import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  ParseUUIDPipe,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  HttpCode,
  HttpStatus,
  ForbiddenException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiConsumes,
  ApiBody,
} from '@nestjs/swagger';

import { SchoolsService } from './schools.service';
import { OnboardSchoolDto } from './dto/onboard-school.dto';
import { UpdateSchoolDto } from './dto/update-schools.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Public } from '../../common/decorators/public.decorator';
// import * as jwtStrategy from '../auth/strategies/jwt.strategy';
import type { ValidatedUser } from '../auth/strategies/jwt.strategy';

@ApiTags('Schools')
@Controller('schools')
export class SchoolsController {
  constructor(private readonly schoolsService: SchoolsService) {}

  // ─────────────────────────────────────────────
  // POST /schools/onboard  (public — first-time setup)
  // ─────────────────────────────────────────────
  @Post('onboard')
  @Public()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Onboard a new school and create the first admin user',
    description:
      'Public endpoint. Creates School + User + Staff atomically. Returns school profile and admin credentials.',
  })
  @ApiResponse({ status: 201, description: 'School onboarded successfully' })
  @ApiResponse({ status: 409, description: 'schoolCode already taken' })
  onboard(@Body() dto: OnboardSchoolDto) {
    return this.schoolsService.onboard(dto);
  }

  // ─────────────────────────────────────────────
  // GET /schools/:id
  // ─────────────────────────────────────────────
  @Get(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get school profile with stats' })
  @ApiResponse({ status: 200, description: 'School profile returned' })
  @ApiResponse({ status: 403, description: 'Cannot access another school' })
  @ApiResponse({ status: 404, description: 'School not found' })
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: ValidatedUser,
  ) {
    this.assertSameSchool(id, user.schoolId);
    return this.schoolsService.findOne(id);
  }

  // ─────────────────────────────────────────────
  // PATCH /schools/:id
  // ─────────────────────────────────────────────
  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update school name, address or currency' })
  @ApiResponse({ status: 200, description: 'School updated' })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateSchoolDto,
    @CurrentUser() user: ValidatedUser,
  ) {
    this.assertSameSchool(id, user.schoolId);
    this.assertAdmin(user);
    return this.schoolsService.update(id, dto);
  }

  // ─────────────────────────────────────────────
  // PATCH /schools/:id/logo  (multipart upload)
  // ─────────────────────────────────────────────
  @Patch(':id/logo')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @UseInterceptors(FileInterceptor('file'))
  @ApiConsumes('multipart/form-data')
  @ApiOperation({ summary: 'Upload or replace school logo (Cloudinary)' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: { type: 'string', format: 'binary' },
      },
    },
  })
  @ApiResponse({ status: 200, description: 'Logo URL updated' })
  uploadLogo(
    @Param('id', ParseUUIDPipe) id: string,
    @UploadedFile() file: any,
    @CurrentUser() user: ValidatedUser,
  ) {
    this.assertSameSchool(id, user.schoolId);
    this.assertAdmin(user);
    return this.schoolsService.uploadLogo(id, file);
  }

  // ─────────────────────────────────────────────
  // DELETE /schools/:id  (soft deactivate)
  // ─────────────────────────────────────────────
  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Deactivate school (soft delete, admin only)' })
  @ApiResponse({ status: 200, description: 'School deactivated' })
  deactivate(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: ValidatedUser,
  ) {
    this.assertSameSchool(id, user.schoolId);
    this.assertAdmin(user);
    return this.schoolsService.deactivate(id);
  }

  // ─────────────────────────────────────────────
  // PRIVATE GUARDS
  // ─────────────────────────────────────────────

  private assertSameSchool(schoolId: string, userSchoolId: string): void {
    if (schoolId !== userSchoolId) {
      throw new ForbiddenException('You do not have access to this school.');
    }
  }

  private assertAdmin(user: ValidatedUser): void {
    if (user.role !== 'admin') {
      throw new ForbiddenException('Only admins can perform this action.');
    }
  }
}
