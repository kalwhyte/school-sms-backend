import { Module } from '@nestjs/common';
import { ReportCardsController } from './report-cards.controller';
import { ReportCardsService } from './report-cards.service';
import { ReportCardHelperService } from './services/index.service';
import { DatabaseModule } from '../../infrastructure/database/database.module';

@Module({
  imports: [DatabaseModule],
  controllers: [ReportCardsController],
  providers: [ReportCardsService, ReportCardHelperService],
  exports: [ReportCardsService],
})
export class ReportCardsModule {}
