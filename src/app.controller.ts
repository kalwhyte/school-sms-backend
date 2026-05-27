import { Controller, Get, VERSION_NEUTRAL } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';
import { AppService } from './app.service';
import { Public } from './common/decorators/public.decorator';

@ApiTags('System')
@Controller({ version: VERSION_NEUTRAL }) // health responds at /api/health, no version prefix
export class AppController {
  constructor(private readonly appService: AppService) {}

  // ── GET /api/health ────────────────────────────────────────────────────────
  // Public so the load balancer / uptime monitor never needs a token.
  @Public()
  @Get('health')
  @ApiOperation({ summary: 'Health check endpoint to verify API is running' })
  health(): { status: string; timestamp: string } {
    return this.appService.healthCheck();
  }
}
