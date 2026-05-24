import { Module } from '@nestjs/common';
import { ParentsController } from './parents.controller';
import { ParentsService } from './parents.service';
import { DatabaseModule } from '../../infrastructure/database/database.module';
import { ParentsHelper } from './services/index.service';

@Module({
  imports: [DatabaseModule],
  controllers: [ParentsController],
  providers: [ParentsService, ParentsHelper],
  exports: [ParentsService],
})
export class ParentsModule {}
