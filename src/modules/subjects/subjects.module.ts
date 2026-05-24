import { Module } from '@nestjs/common';
import { SubjectsController } from './subjects.controller';
import { SubjectsService } from './subjects.service';
import { DatabaseModule } from '../../infrastructure/database/database.module';
import { SubjectsHelperService } from './services/index.service';

@Module({
  imports: [DatabaseModule],
  controllers: [SubjectsController],
  providers: [SubjectsService, SubjectsHelperService],
  exports: [SubjectsService],
})
export class SubjectsModule {}
