import { registerAs } from '@nestjs/config';

export default registerAs('storage', () => ({
  driver: process.env.STORAGE_DRIVER || 'local',
  accessKeyId: process.env.STORAGE_ACCESS_KEY_ID,
  secretAccessKey: process.env.STORAGE_SECRET_ACCESS_KEY,
  region: process.env.STORAGE_REGION,
  bucket: process.env.STORAGE_BUCKET,
  endpoint: process.env.STORAGE_ENDPOINT,
}));
