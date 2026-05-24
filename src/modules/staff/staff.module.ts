import { Module } from '@nestjs/common';
import { MulterModule } from '@nestjs/platform-express';
import type { Request } from 'express';
import type { MulterFile } from '../../infrastructure/storage/storage.service';

import { StaffController } from './staff.controller';
import { StaffService } from './staff.service';
import { StaffHelperService } from './services/index.service';
import { DatabaseModule } from '../../infrastructure/database/database.module';
import { StorageService } from '../../infrastructure/storage/storage.service';

type FileFilterCb = (error: Error | null, acceptFile: boolean) => void;

const imageFileFilter = (
  _req: Request,
  file: MulterFile,
  cb: FileFilterCb,
): void => {
  if (!file.mimetype.startsWith('image/')) {
    cb(new Error('Only image files are allowed'), false);
  } else {
    cb(null, true);
  }
};

@Module({
  imports: [
    DatabaseModule,
    MulterModule.register({
      limits: { fileSize: 5 * 1024 * 1024 },
      fileFilter: imageFileFilter,
    }),
  ],
  controllers: [StaffController],
  providers: [StaffService, StaffHelperService, StorageService],
  exports: [StaffService],
})
export class StaffModule {}
