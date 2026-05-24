import { Module } from '@nestjs/common';
import { MulterModule } from '@nestjs/platform-express';
import type { Request } from 'express';

import { SchoolsController } from './schools.controller';
import { SchoolsService } from './schools.service';
import { DatabaseModule } from '../../infrastructure/database/database.module';
import { StorageService } from '../../infrastructure/storage/storage.service';
import type { MulterFile } from '../../infrastructure/storage/storage.service';

// Extracted + typed so ESLint can verify every parameter.
// MulterFile is our local interface — never touches Express.Multer.File
// or multer's StorageEngine, so no unresolved-namespace errors.
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
    // No `storage` field → multer defaults to MemoryStorage internally.
    // Explicitly setting storage: memoryStorage() would require importing
    // multer, whose types resolve as `any` before prisma generate runs.
    MulterModule.register({
      limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB
      fileFilter: imageFileFilter,
    }),
  ],
  controllers: [SchoolsController],
  providers: [SchoolsService, StorageService],
  exports: [SchoolsService],
})
export class SchoolsModule {}
