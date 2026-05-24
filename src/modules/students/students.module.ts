import { Module } from '@nestjs/common';
import { StudentsController } from './students.controller';
import { StudentsService } from './students.service';
import { DatabaseModule } from '../../infrastructure/database/database.module';
import { StudentsHelperService } from './services/index.service';

@Module({
  imports: [DatabaseModule],
  controllers: [StudentsController],
  providers: [StudentsService, StudentsHelperService],
  exports: [StudentsService],
})
export class StudentsModule {}
