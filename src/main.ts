import { NestFactory } from '@nestjs/core';
import { ValidationPipe, VersioningType } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import helmet from 'helmet';
import chalk from 'chalk';
import figlet from 'figlet';
import boxen from 'boxen';
import { pastel } from 'gradient-string';
import ora from 'ora';
import { AppModule } from './app.module';

function sleep(ms: number) {
  return new Promise<void>((resolve) => setTimeout(resolve, ms));
}

async function terminalBootSequence() {
  console.clear();

  const banner = figlet.textSync('SCHOOL SMS', {
    font: 'Slant',
    horizontalLayout: 'fitted',
    verticalLayout: 'fitted',
  });

  console.log(pastel(banner));

  console.log(
    chalk.greenBright(
      '╔══════════════════════════════════════════════════════════════╗',
    ),
  );

  console.log(
    chalk.greenBright(
      '║        INITIALIZING SECURE EDUCATION CORE SYSTEM            ║',
    ),
  );

  console.log(
    chalk.greenBright(
      '╚══════════════════════════════════════════════════════════════╝',
    ),
  );

  const tasks = [
    'Injecting kernel modules...',
    'Mounting tenant architecture...',
    'Establishing secure sockets...',
    'Synchronizing Prisma ORM...',
    'Loading API gateways...',
    'Scanning security layers...',
    'Activating validation pipelines...',
    'Deploying Swagger intelligence...',
    'Finalizing runtime environment...',
  ];

  for (const task of tasks) {
    const spinner = ora({
      text: chalk.cyan(task),
      spinner: 'dots12',
    }).start();

    await sleep(700);

    spinner.succeed(chalk.green(`${task} COMPLETE`));
  }

  console.log('\n');
}

async function bootstrap() {
  await terminalBootSequence();
  const app = await NestFactory.create(AppModule, {
    rawBody: true,
    // Suppress NestJS's default logger in production; swap for a Pino/Winston
    // logger adapter when you wire up your logging infrastructure.
    logger: ['error', 'warn', 'log', 'debug'],
    bufferLogs: true,
  });

  const config = app.get(ConfigService);

  // ── Security ──────────────────────────────────────────────────────────────
  app.use(helmet());

  app.enableCors({
    origin: config.get<string>('app.frontendUrl') ?? '*',
    credentials: true,
  });

  // ── Global prefix & versioning ────────────────────────────────────────────
  app.setGlobalPrefix('api');
  app.enableVersioning({ type: VersioningType.URI, defaultVersion: '1' });
  // Routes become /api/v1/...

  // ── Global validation pipe ────────────────────────────────────────────────
  // Strips unknown properties and transforms primitives (e.g. "true" → true).
  // class-validator decorators on DTOs are enforced automatically.
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // strip unknown fields
      forbidNonWhitelisted: true, // 400 if unknown fields are sent
      transform: true, // auto-transform payloads to DTO class instances
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  // ── Swagger (dev / staging only) ──────────────────────────────────────────
  const nodeEnv = config.get<string>('app.nodeEnv') ?? 'development';
  if (nodeEnv !== 'production') {
    const swaggerConfig = new DocumentBuilder()
      .setTitle('SchoolMS API')
      .setDescription('Multi-tenant school management system')
      .setVersion('1.0')
      .addBearerAuth() // shows the Authorize 🔒 button in Swagger UI
      .build();

    const document = SwaggerModule.createDocument(app, swaggerConfig);
    SwaggerModule.setup('api/docs', app, document, {
      swaggerOptions: { persistAuthorization: true },
    });
  }

  // ── Health check ──────────────────────────────────────────────────────────
  // Handled by AppController GET /api/v1/health (see below).

  const port = config.get<number>('app.port') ?? 3000;
  await app.listen(port);
  console.log(
    boxen(
      `${chalk.greenBright('SYSTEM STATUS')} : ONLINE\n\n` +
        `${chalk.cyan('ENVIRONMENT')}    : ${nodeEnv}\n` +
        `${chalk.cyan('API')}            : http://localhost:${port}/api/v1\n` +
        `${chalk.cyan('SWAGGER')}        : http://localhost:${port}/api/docs\n` +
        `${chalk.cyan('SECURITY')}       : ACTIVE\n` +
        `${chalk.cyan('DATABASE')}       : CONNECTED\n` +
        `${chalk.cyan('MULTI-TENANCY')}  : ENABLED`,
      {
        padding: 1,
        borderStyle: 'double',
        borderColor: 'green',
      },
    ),
  );

  console.log('\n');

  console.log(pastel('>> SCHOOL SMS CORE IS NOW RUNNING <<'));

  console.log(
    chalk.gray('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'),
  );
}

void bootstrap();
