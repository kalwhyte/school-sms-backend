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
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';

import { ParentsService } from './parents.service';
import { CreateParentDto } from './dto/create-parents.dto';
import { UpdateParentDto, LinkStudentDto } from './dto/update-parents.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import * as jwtStrategy from '../auth/strategies/jwt.strategy';

@ApiTags('Parents')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('parents')
export class ParentsController {
  constructor(private readonly parentsService: ParentsService) {}

  // POST /parents
  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a parent and their User account' })
  create(
    @Body() dto: CreateParentDto,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    return this.parentsService.create(user.schoolId, dto);
  }

  // GET /parents
  @Get()
  @ApiOperation({ summary: 'List parents (paginated, searchable)' })
  findAll(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('search') search?: string,
    @CurrentUser() user?: jwtStrategy.ValidatedUser,
  ) {
    return this.parentsService.findAll(user!.schoolId, { page, limit, search });
  }

  // GET /parents/:id
  @Get(':id')
  @ApiOperation({ summary: 'Get parent with linked students' })
  @ApiResponse({ status: 404, description: 'Parent not found' })
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    return this.parentsService.findOne(user.schoolId, id);
  }

  // PATCH /parents/:id
  @Patch(':id')
  @ApiOperation({ summary: 'Update parent profile' })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateParentDto,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    return this.parentsService.update(user.schoolId, id, dto);
  }

  // POST /parents/:id/students  — link a student
  @Post(':id/students')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Link a student to this parent' })
  linkStudent(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: LinkStudentDto,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    return this.parentsService.linkStudent(user.schoolId, id, dto);
  }

  // DELETE /parents/:id/students/:studentId  — unlink
  @Delete(':id/students/:studentId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Unlink a student from this parent' })
  unlinkStudent(
    @Param('id', ParseUUIDPipe) id: string,
    @Param('studentId', ParseUUIDPipe) studentId: string,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    return this.parentsService.unlinkStudent(user.schoolId, id, studentId);
  }

  // DELETE /parents/:id
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Deactivate a parent (soft delete)' })
  remove(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: jwtStrategy.ValidatedUser,
  ) {
    return this.parentsService.remove(user.schoolId, id);
  }
}
