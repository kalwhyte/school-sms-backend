import { Module } from '@nestjs/common';
import { PaymentsService } from './payments.service';
import {
  PaymentsController,
  PaystackWebhookController,
} from './payments.controller';
import { FeesModule } from '../fees/fees.module';
import { DatabaseModule } from '../../infrastructure/database/database.module';
import { PaymentsHelper } from './services/index.service';

@Module({
  imports: [
    DatabaseModule,
    FeesModule, // for syncLedger after charge.success
  ],
  controllers: [PaymentsController, PaystackWebhookController],
  providers: [PaymentsService, PaymentsHelper],
  exports: [PaymentsService],
})
export class PaymentsModule {}
