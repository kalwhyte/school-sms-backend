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
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
} from '@nestjs/swagger';
import { ClassesService } from './classes.service';
import { CreateClassDto } from './dto/create-classes.dto';
import { UpdateClassDto } from './dto/update-classes.dto';
import { ClassQueryDto } from './dto/class-query.dto';

// Decorator helpers — adjust to match your actual auth guards/decorators
import { CurrentSchool } from '../../common/decorators/current-school.decorator';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '@prisma/client';

@ApiTags('Classes')
@ApiBearerAuth()
@Controller('classes')
export class ClassesController {
  constructor(private readonly classesService: ClassesService) {}

  // ─── POST /classes ────────────────────────────────────────────────────────

  @Post()
  @Roles(UserRole.admin, UserRole.principal, UserRole.vice_principal)
  @ApiOperation({ summary: 'Create a class' })
  @ApiResponse({ status: 201, description: 'Class created.' })
  @ApiResponse({ status: 409, description: 'Class already exists.' })
  create(@CurrentSchool() schoolId: string, @Body() dto: CreateClassDto) {
    return this.classesService.create(schoolId, dto);
  }

  // ─── GET /classes ─────────────────────────────────────────────────────────

  @Get()
  @ApiOperation({
    summary: 'List classes (filterable by year, term, level, stream)',
  })
  @ApiResponse({ status: 200, description: 'Paginated list of classes.' })
  findAll(@CurrentSchool() schoolId: string, @Query() query: ClassQueryDto) {
    return this.classesService.findAll(schoolId, query);
  }

  // ─── GET /classes/:id ────────────────────────────────────────────────────

  @Get(':id')
  @ApiOperation({ summary: 'Get a single class with teacher and counts' })
  @ApiParam({ name: 'id', description: 'Class UUID' })
  @ApiResponse({ status: 200, description: 'Class detail.' })
  @ApiResponse({ status: 404, description: 'Class not found.' })
  findOne(
    @CurrentSchool() schoolId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.classesService.findOne(schoolId, id);
  }

  // ─── PATCH /classes/:id ──────────────────────────────────────────────────

  @Patch(':id')
  @Roles(UserRole.admin, UserRole.principal, UserRole.vice_principal)
  @ApiOperation({
    summary: 'Update class name, arm, stream or assigned teacher',
  })
  @ApiParam({ name: 'id', description: 'Class UUID' })
  @ApiResponse({ status: 200, description: 'Class updated.' })
  @ApiResponse({ status: 404, description: 'Class not found.' })
  @ApiResponse({ status: 409, description: 'Name/arm collision.' })
  update(
    @CurrentSchool() schoolId: string,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateClassDto,
  ) {
    return this.classesService.update(schoolId, id, dto);
  }

  // ─── DELETE /classes/:id ─────────────────────────────────────────────────

  @Delete(':id')
  @Roles(UserRole.admin, UserRole.principal)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete a class (blocked if students enrolled)' })
  @ApiParam({ name: 'id', description: 'Class UUID' })
  @ApiResponse({ status: 200, description: 'Class deleted.' })
  @ApiResponse({ status: 400, description: 'Students still enrolled.' })
  @ApiResponse({ status: 404, description: 'Class not found.' })
  remove(
    @CurrentSchool() schoolId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.classesService.remove(schoolId, id);
  }
}
