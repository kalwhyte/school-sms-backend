// ── Paystack types ────────────────────────────────────────────────────────────
export interface PaystackInitResponse {
  status: boolean;
  message: string;
  data: {
    authorization_url: string;
    access_code: string;
    reference: string;
  };
}

export interface PaystackWebhookPayload {
  event: string;
  data: {
    reference: string;
    amount: number;
    status: string;
    paid_at: string;
    customer: {
      email: string;
    };
    metadata?: Record<string, unknown>;
  };
}
