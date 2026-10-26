import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(RedisService.name);
  private redis: Redis;

  constructor(config: ConfigService) {
    this.redis = new Redis({
      host: config.get<string>('REDIS_HOST', 'localhost'),
      port: Number(config.get<number>('REDIS_PORT', 6379)),
      password: config.get<string>('REDIS_PASSWORD'),
      keyPrefix: 'school_sms:',
      lazyConnect: true,
      maxRetriesPerRequest: 3,
    });

    this.redis.on('error', (e) =>
      this.logger.error(`Redis error: ${e.message}`, e.stack),
    );
    this.redis.on('reconnecting', () =>
      this.logger.warn('Reconnecting to Redis...'),
    );
  }

  async onModuleInit() {
    await this.redis.connect();
  }
  async onModuleDestroy() {
    await this.redis.quit();
  }

  async get(key: string): Promise<string | null> {
    return this.redis.get(key);
  }

  async set(key: string, value: string, ttlSeconds?: number): Promise<void> {
    if (ttlSeconds) {
      await this.redis.set(key, value, 'EX', ttlSeconds);
    } else {
      await this.redis.set(key, value);
    }
  }

  async del(key: string): Promise<void> {
    await this.redis.del(key);
  }

  async ttl(key: string): Promise<number> {
    return this.redis.ttl(key);
  }
}
