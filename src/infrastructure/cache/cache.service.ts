import { Injectable } from '@nestjs/common';
import { RedisService } from './redis.service';

@Injectable()
export class CacheService {
  constructor(private readonly redisService: RedisService) {}

  async get(key: string): Promise<string | null> {
    return this.redisService.get(key);
  }

  async set(key: string, value: string, ttlSeconds?: number): Promise<void> {
    await this.redisService.set(key, value, ttlSeconds);
  }

  async del(key: string): Promise<void> {
    await this.redisService.del(key);
  }

  async ttl(key: string): Promise<number> {
    return this.redisService.ttl(key);
  }

  async getJSON<T>(key: string): Promise<T | null> {
    const value = await this.get(key);
    return value ? (JSON.parse(value) as T) : null;
  }

  async setJSON<T>(key: string, value: T, ttlSeconds?: number): Promise<void> {
    await this.set(key, JSON.stringify(value), ttlSeconds);
  }
}
