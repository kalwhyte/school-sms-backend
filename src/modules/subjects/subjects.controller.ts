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
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';

import { SubjectsService } from './subjects.service';
import { CreateSubjectDto } from './dto/create-subjects.dto';
import {
  UpdateSubjectDto,
  CreateTimetablePeriodDto,
} from './dto/update-subjects.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import * as JWTStrategy from '../auth/strategies/jwt.strategy';

@ApiTags('Subjects')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('subjects')
export class SubjectsController {
  constructor(private readonly subjectsService: SubjectsService) {}

  // POST /subjects
  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a subject and assign to a class + teacher' })
  create(
    @Body() dto: CreateSubjectDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    return this.subjectsService.create(user.schoolId, dto);
  }

  // GET /subjects?classId=
  @Get()
  @ApiOperation({ summary: 'List subjects, optionally filtered by classId' })
  findAll(
    @CurrentUser() user: JWTStrategy.ValidatedUser,
    @Query('classId') classId?: string,
  ) {
    return this.subjectsService.findAll(user.schoolId, classId);
  }

  // GET /subjects/:id
  @Get(':id')
  @ApiOperation({ summary: 'Get a single subject' })
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    return this.subjectsService.findOne(user.schoolId, id);
  }

  // PATCH /subjects/:id
  @Patch(':id')
  @ApiOperation({ summary: 'Update subject name, isCore or assigned teacher' })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateSubjectDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    return this.subjectsService.update(user.schoolId, id, dto);
  }

  // DELETE /subjects/:id
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete a subject (blocked if assessments exist)' })
  remove(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    return this.subjectsService.remove(user.schoolId, id);
  }

  // ── Timetable ────────────────────────────────────────────────────────────────

  // POST /subjects/:id/timetable
  @Post(':id/timetable')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Add a timetable period for this subject' })
  createPeriod(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: CreateTimetablePeriodDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    return this.subjectsService.createTimetablePeriod(user.schoolId, id, dto);
  }

  // GET /subjects/:id/timetable
  @Get(':id/timetable')
  @ApiOperation({ summary: 'Get all timetable periods for this subject' })
  getTimetable(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    return this.subjectsService.getTimetable(user.schoolId, id);
  }

  // DELETE /subjects/:id/timetable/:periodId
  @Delete(':id/timetable/:periodId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Remove a timetable period' })
  deletePeriod(
    @Param('id', ParseUUIDPipe) id: string,
    @Param('periodId', ParseUUIDPipe) periodId: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    return this.subjectsService.deleteTimetablePeriod(
      user.schoolId,
      id,
      periodId,
    );
  }
}
