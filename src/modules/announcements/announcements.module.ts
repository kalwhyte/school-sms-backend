import { Module } from '@nestjs/common';
import { AnnouncementsController } from './announcements.controller';
import { AnnouncementsService } from './announcements.service';
import { DatabaseModule } from '../../infrastructure/database/database.module';
import { AnnouncementsHelperService } from './services/index.service';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [DatabaseModule, NotificationsModule],
  controllers: [AnnouncementsController],
  providers: [AnnouncementsService, AnnouncementsHelperService],
  exports: [AnnouncementsService],
})
export class AnnouncementsModule {}
