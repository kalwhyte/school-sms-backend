import { Module } from '@nestjs/common';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { DatabaseModule } from '../../infrastructure/database/database.module';
import { UsersHelperService } from './services/index.service';

@Module({
  imports: [DatabaseModule],
  controllers: [UsersController],
  providers: [UsersService, UsersHelperService],
  exports: [UsersService],
})
export class UsersModule {}
