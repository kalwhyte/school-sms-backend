import { Module } from '@nestjs/common';
import { FeesService } from './fees.service';
import { FeesController } from './fees.controller';
import { FeesPermissionsGuard } from './guards/permissions.guard';
import { DatabaseModule } from '../../infrastructure/database/database.module';

@Module({
  imports: [DatabaseModule],
  controllers: [FeesController],
  providers: [FeesService, FeesPermissionsGuard],
  exports: [FeesService], // exported — Payments module calls syncLedger
})
export class FeesModule {}
