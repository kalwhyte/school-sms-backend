import {
  Injectable,
  OnModuleInit,
  OnModuleDestroy,
  Logger,
} from '@nestjs/common';
import { PrismaClient, Prisma } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';

// Minimal structural interface for the Prisma event emitter.
// Avoids `any` casts while staying independent of the generated client types —
// so this compiles cleanly whether or not `prisma generate` has run yet.
// interface PrismaQueryEvent {
//   query: string;
//   params: string;
//   duration: number;
//   target: string;
// }

// interface PrismaLogEvent {
//   message: string;
//   target: string;
//   timestamp: Date;
// }

// interface PrismaEventEmitter {
//   $on(event: 'query', cb: (e: PrismaQueryEvent) => void): void;
//   $on(event: 'error', cb: (e: PrismaLogEvent) => void): void;
//   $on(event: 'warn', cb: (e: PrismaLogEvent) => void): void;
//   $on(event: 'info', cb: (e: PrismaLogEvent) => void): void;
// }

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(PrismaService.name);
  Prisma: any;

  constructor() {
    const dbUrl = process.env.DATABASE_URL;
    if (!dbUrl) {
      throw new Error('DATABASE_URL is not defined');
    }

    const adapter = new PrismaPg({
      connectionString: dbUrl,
    });

    super({
      adapter,
      log:
        process.env.NODE_ENV === 'development'
          ? ['query', 'error', 'warn']
          : ['error', 'warn'],
      // { emit: 'event', level: 'query' },
      // { emit: 'event', level: 'error' },
      // { emit: 'event', level: 'warn' },
    });
  }

  async onModuleInit() {
    // Cast to our typed interface — no `any` involved, no unsafe call lint error.
    // const emitter = this as unknown as PrismaEventEmitter;

    // if (process.env.NODE_ENV === 'development') {
    // emitter.$on('query', (e) => {
    //   this.logger.debug(`[${e.duration}ms] ${e.query} — ${e.params}`);
    // });

    // Log user role context if available in future extensions
    //   emitter.$on('info', (e) => {
    //     if (e.message.includes('role')) {
    //       this.logger.verbose(`Prisma Info: ${e.message}`);
    //     }
    //   });
    // }

    // emitter.$on('error', (e) => {
    //   this.logger.error(`Prisma error on ${e.target}: ${e.message}`);
    // });

    // emitter.$on('warn', (e) => {
    //   this.logger.warn(`${e.target}: ${e.message}`);
    // });

    await this.$connect();
    this.logger.log('Database connected');
  }

  async onModuleDestroy() {
    await this.$disconnect();
    this.logger.log('Database disconnected');
  }

  /**
   * Register a beforeExit hook for graceful shutdown on Railway / Docker.
   * Call from main.ts:  app.get(PrismaService).enableShutdownHooks()
   */
  enableShutdownHooks() {
    process.on('beforeExit', () => {
      void this.$disconnect();
    });
  }

  /**
   * Truncates every public-schema table via CASCADE.
   * Hard-throws in production — safe to ship.
   * Use in e2e beforeEach for a clean slate.
   */
  async cleanDatabase() {
    if (process.env.NODE_ENV === 'production') {
      throw new Error('cleanDatabase() must never run in production');
    }

    const tablenames = await this.$queryRaw<{ tablename: string }[]>(
      Prisma.sql`
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
          AND tablename != '_prisma_migrations'
      `,
    );

    const tables = tablenames
      .map(({ tablename }) => `"public"."${tablename}"`)
      .join(', ');

    if (tables) {
      await this.$executeRawUnsafe(`TRUNCATE TABLE ${tables} CASCADE`);
    }
  }
}
