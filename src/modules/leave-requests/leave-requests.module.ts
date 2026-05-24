import { Module } from '@nestjs/common';
import { LeaveRequestsService } from './leave-requests.service';
import { LeaveRequestsController } from './leave-requests.controller';
import { LeaveRequestsPermissionsGuard } from './guards/permissions.guard';
import { DatabaseModule } from '../../infrastructure/database/database.module';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [DatabaseModule, NotificationsModule],
  controllers: [LeaveRequestsController],
  providers: [LeaveRequestsService, LeaveRequestsPermissionsGuard],
  exports: [LeaveRequestsService],
})
export class LeaveRequestsModule {}
