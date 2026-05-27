import { Module } from '@nestjs/common';
import { ClassesController } from './classes.controller';
import { ClassesService } from './classes.service';
// import { DatabaseModule } from '../../infrastructure/database/database.module';
import { ClassHelperService } from './services/index.service';
import { PrismaService } from '../../infrastructure/database/prisma.service';

@Module({
  // imports: [DatabaseModule],
  controllers: [ClassesController],
  providers: [ClassesService, ClassHelperService, PrismaService],
  exports: [ClassesService],
})
export class ClassesModule {}
