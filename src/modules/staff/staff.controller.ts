import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  ParseUUIDPipe,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  HttpCode,
  HttpStatus,
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

import { StaffService } from './staff.service';
import type { MulterFile } from '../../infrastructure/storage/storage.service';
import { CreateStaffDto } from './dto/create-staff.dto';
import { UpdateStaffDto } from './dto/update-staff.dto';
import { StaffQueryDto } from './dto/staff-query.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import * as jwtStrategy from '../auth/strategies/jwt.strategy';

@ApiTags('Staff')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('staff')
export class StaffController {
  constructor(private readonly staffService: StaffService) {}

  // POST /staff
  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new staff member and their User account' })
  @ApiResponse({ status: 201, description: 'Staff created' })
  @ApiResponse({
    status: 409,
    description: 'Phone already registered in this school',
  })
  create(
    @Body() dto: CreateStaffDto,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    return this.staffService.create(user.schoolId, dto);
  }

  // GET /staff
  @Get()
  @ApiOperation({
    summary: 'List staff (paginated, filterable by role / name)',
  })
  findAll(
    @Query() query: StaffQueryDto,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    return this.staffService.findAll(user.schoolId, query);
  }

  // GET /staff/:id
  @Get(':id')
  @ApiOperation({ summary: 'Get a single staff member' })
  @ApiResponse({ status: 404, description: 'Staff not found' })
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    return this.staffService.findOne(user.schoolId, id);
  }

  // PATCH /staff/:id
  @Patch(':id')
  @ApiOperation({ summary: 'Update staff profile or role' })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateStaffDto,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    return this.staffService.update(user.schoolId, id, dto);
  }

  // PATCH /staff/:id/photo
  @Patch(':id/photo')
  @UseInterceptors(FileInterceptor('file'))
  @ApiConsumes('multipart/form-data')
  @ApiOperation({ summary: 'Upload staff profile photo (Cloudinary)' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: { file: { type: 'string', format: 'binary' } },
    },
  })
  uploadPhoto(
    @Param('id', ParseUUIDPipe) id: string,
    @UploadedFile() file: MulterFile,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    return this.staffService.uploadPhoto(user.schoolId, id, file);
  }

  // DELETE /staff/:id
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Deactivate a staff member (soft delete)' })
  remove(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    return this.staffService.remove(user.schoolId, id);
  }
}
