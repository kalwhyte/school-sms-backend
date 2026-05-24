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

import { ClassesService } from './classes.service';
import { CreateClassDto } from './dto/create-classes.dto';
import { UpdateClassDto } from './dto/update-classes.dto';
import { ClassQueryDto } from './dto/class-query.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import * as JWTStrategy from '../auth/strategies/jwt.strategy';

@ApiTags('Classes')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('classes')
export class ClassesController {
  constructor(private readonly classesService: ClassesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a class' })
  @ApiResponse({
    status: 409,
    description: 'Class already exists for this term',
  })
  create(
    @Body() dto: CreateClassDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    return this.classesService.create(user.schoolId, dto);
  }

  @Get()
  @ApiOperation({ summary: 'List classes (filterable by academicYear / term)' })
  findAll(
    @Query() query: ClassQueryDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    return this.classesService.findAll(user.schoolId, query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a single class with teacher + counts' })
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    return this.classesService.findOne(user.schoolId, id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update class name, arm or assigned teacher' })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateClassDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    return this.classesService.update(user.schoolId, id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Delete a class (blocked if students enrolled)' })
  remove(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    return this.classesService.remove(user.schoolId, id);
  }
}
