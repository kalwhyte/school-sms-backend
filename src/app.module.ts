import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';

import { AppController } from './app.controller';
import { AppService } from './app.service';

import { AuthModule } from './modules/auth/auth.module';
import { AnnouncementsModule } from './modules/announcements/announcements.module';
import { AssessmentsModule } from './modules/assessments/assessments.module';
import { AttendanceModule } from './modules/attendance/attendance.module';
import { ClassesModule } from './modules/classes/classes.module';
import { FeesModule } from './modules/fees/fees.module';
import { LeaveRequestsModule } from './modules/leave-requests/leave-requests.module';
import { MessagesModule } from './modules/messages/messages.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { ParentsModule } from './modules/parents/parents.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { ReportCardsModule } from './modules/report-cards/report-cards.module';
import { SchoolsModule } from './modules/schools/schools.module';
import { StaffModule } from './modules/staff/staff.module';
import { StudentsModule } from './modules/students/students.module';
import { SubjectsModule } from './modules/subjects/subjects.module';
import { UsersModule } from './modules/users/users.module';

import { JwtAuthGuard } from './common/guards/jwt-auth.guard';

import appConfig from './config/app.config';
import authConfig from './config/auth.config';

@Module({
  imports: [
    // ── Config (global so every module can inject ConfigService) ─────────────
    ConfigModule.forRoot({
      isGlobal: true,
      load: [appConfig, authConfig],
      // Validates that required env vars are present at startup.
      // Add a Joi schema here once you add @hapi/joi / joi to dependencies.
      // validationSchema: appValidationSchema,
    }),

    // ── Feature modules ───────────────────────
    AuthModule,
    AnnouncementsModule,
    AssessmentsModule,
    ClassesModule,
    FeesModule,
    LeaveRequestsModule,
    MessagesModule,
    NotificationsModule,
    SubjectsModule,
    SchoolsModule,
    StudentsModule,
    StaffModule,
    ParentsModule,
    PaymentsModule,
    ReportCardsModule,
    AttendanceModule,
    UsersModule,
  ],

  controllers: [AppController],

  providers: [
    AppService,

    // ── Apply JwtAuthGuard globally ───────────────────────────────────────────
    // Every route is protected by default. Use @Public() decorator on any
    // endpoint that should be unauthenticated (e.g. /auth/request-otp).
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
  ],
})
export class AppModule {}
