import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { v2 as cloudinary, UploadApiResponse } from 'cloudinary';

export interface MulterFile {
  buffer: Buffer;
  fieldname: string;
  originalname: string;
  encoding: string;
  mimetype: string;
  size: number;
  destination: string;
  filename: string;
  path: string;
  stream: NodeJS.ReadableStream;
}

export interface UploadImageOptions {
  folder: string;
  publicId?: string;
  overwrite?: boolean;
  transformation?: Array<{
    width?: number;
    height?: number;
    crop?: string;
    gravity?: string;
    quality?: string | number;
    format?: string;
  }>;
}

@Injectable()
export class StorageService {
  private readonly logger = new Logger(StorageService.name);

  constructor(private readonly config: ConfigService) {
    cloudinary.config({
      cloud_name: this.config.get<string>('storage.cloudName'),
      api_key: this.config.get<string>('storage.apiKey'),
      api_secret: this.config.get<string>('storage.apiSecret'),
      secure: true,
    });
  }

  // ─────────────────────────────────────────────
  // UPLOAD IMAGE  (from Multer memory buffer)
  // ─────────────────────────────────────────────

  uploadImage(
    file: MulterFile,
    options: UploadImageOptions,
  ): Promise<UploadApiResponse> {
    return new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        {
          folder: options.folder,
          public_id: options.publicId,
          overwrite: options.overwrite ?? false,
          transformation: options.transformation,
          resource_type: 'image',
        },
        (error, result) => {
          if (error || !result) {
            this.logger.error('Cloudinary upload failed', error);
            if (error instanceof Error) {
              reject(error);
            } else {
              reject(new Error(error?.message || 'Upload returned no result'));
            }
          } else {
            resolve(result);
          }
        },
      );

      stream.end(file.buffer);
    });
  }

  // ─────────────────────────────────────────────
  // DELETE by public_id
  // ─────────────────────────────────────────────

  async deleteImage(publicId: string): Promise<void> {
    await cloudinary.uploader.destroy(publicId);
    this.logger.log(`Cloudinary image deleted: ${publicId}`);
  }

  // ─────────────────────────────────────────────
  // UPLOAD RAW FILE  (PDFs, documents)
  // ─────────────────────────────────────────────

  uploadFile(
    file: MulterFile,
    options: UploadImageOptions,
  ): Promise<UploadApiResponse> {
    return new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        {
          folder: options.folder,
          public_id: options.publicId,
          overwrite: options.overwrite ?? false,
          resource_type: 'raw',
        },
        (error, result) => {
          if (error || !result) {
            this.logger.error('Cloudinary raw file upload failed', error);
            if (error instanceof Error) {
              reject(error);
            } else {
              const message =
                typeof error === 'object' &&
                error !== null &&
                'message' in error
                  ? String((error as Record<string, unknown>).message)
                  : 'Upload returned no result';
              reject(new Error(message));
            }
          } else {
            resolve(result);
          }
        },
      );

      stream.end(file.buffer);
    });
  }
}
