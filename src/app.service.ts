import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  healthCheck(): { status: string; timestamp: string } {
    console.log('Health check called');
    return { status: 'ok', timestamp: new Date().toISOString() };
  }
  // getHello(): string {
  //   return 'Hello World!';
  // }
}
