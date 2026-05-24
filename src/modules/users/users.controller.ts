import {
  Controller,
  Get,
  Patch,
  Delete,
  Post,
  Body,
  Param,
  Query,
  ParseUUIDPipe,
  UseGuards,
  HttpCode,
  HttpStatus,
  ForbiddenException,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiResponse,
} from '@nestjs/swagger';

import { UsersService } from './users.service';
import { UserQueryDto } from './dto/user-query.dto';
import { UpdateUserDto } from './dto/update-users.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import * as JWTStrategy from '../auth/strategies/jwt.strategy';

@ApiTags('Users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  // GET /users/me
  @Get('me')
  @ApiOperation({ summary: 'Get current authenticated user profile' })
  getMe(@CurrentUser() user: JWTStrategy.ValidatedUser) {
    return this.usersService.getMe(user.userId);
  }

  // GET /users  (admin only)
  @Get()
  @ApiOperation({ summary: 'List all users in the school (admin only)' })
  findAll(
    @Query() query: UserQueryDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.assertAdmin(user);
    return this.usersService.findAll(user.schoolId, query);
  }

  // GET /users/:id  (admin or self)
  @Get(':id')
  @ApiOperation({ summary: 'Get a user by ID (admin or own profile)' })
  @ApiResponse({ status: 404, description: 'User not found' })
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    // Non-admins can only fetch themselves
    if (user.role !== 'admin' && user.userId !== id) {
      throw new ForbiddenException('You can only view your own profile.');
    }
    return this.usersService.findOne(user.schoolId, id);
  }

  // PATCH /users/:id
  @Patch(':id')
  @ApiOperation({ summary: 'Update user phone, email, role or status' })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateUserDto,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    return this.usersService.update(
      user.schoolId,
      id,
      dto,
      user.userId,
      user.role,
    );
  }

  // DELETE /users/:id  → soft deactivate (admin only)
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Deactivate a user (admin only, cannot self-deactivate)',
  })
  deactivate(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.assertAdmin(user);
    return this.usersService.deactivate(user.schoolId, id, user.userId);
  }

  // POST /users/:id/reactivate (admin only)
  @Post(':id/reactivate')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Reactivate a previously deactivated user (admin only)',
  })
  reactivate(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JWTStrategy.ValidatedUser,
  ) {
    this.assertAdmin(user);
    return this.usersService.reactivate(user.schoolId, id);
  }

  // ── Private guards ────────────────────────────────────────────────────────

  private assertAdmin(user: JWTStrategy.ValidatedUser): void {
    if (user.role !== 'admin') {
      throw new ForbiddenException('Only admins can perform this action.');
    }
  }
}
