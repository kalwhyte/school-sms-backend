import { registerAs } from '@nestjs/config';

export default registerAs('paystack', () => ({
  secretKey: process.env.PAYSTACK_SECRET_KEY,
  publicKey: process.env.PAYSTACK_PUBLIC_KEY,
  callbackUrl: process.env.PAYSTACK_CALLBACK_URL,
  webhookUrl: process.env.PAYSTACK_WEBHOOK_URL,
}));
