import { Module } from '@nestjs/common';
import { AttendanceController } from './attendance.controller';
import { AttendanceService } from './attendance.service';
import { AttendanceGuard } from './guards/roles.guard';
import { DatabaseModule } from '../../infrastructure/database/database.module';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [DatabaseModule, NotificationsModule],
  controllers: [AttendanceController],
  providers: [AttendanceService, AttendanceGuard],
  exports: [AttendanceService],
})
export class AttendanceModule {}
