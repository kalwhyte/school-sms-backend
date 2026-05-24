#!/bin/sh
# docker/start.sh
# Runs inside the container on every startup.
# Waits for postgres, runs migrations, then starts the app.

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  School SMS Backend — Starting"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Wait for postgres to be ready ────────────────────────────────────────────
echo "⏳  Waiting for PostgreSQL..."
until npx prisma migrate status > /dev/null 2>&1; do
  echo "   PostgreSQL not ready — retrying in 2s..."
  sleep 2
done
echo "✅  PostgreSQL ready"

# ── Run migrations ────────────────────────────────────────────────────────────
echo "🔄  Running database migrations..."
npx prisma migrate deploy
echo "✅  Migrations complete"

# ── Generate Prisma client (safety net) ──────────────────────────────────────
echo "⚙️   Generating Prisma client..."
npx prisma generate
echo "✅  Prisma client ready"

# ── Start the app ─────────────────────────────────────────────────────────────
echo "🚀  Starting NestJS..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$NODE_ENV" = "production" ]; then
  node dist/main.js
else
  # Hot reload in development
  npm run start:dev
fi
EOF
chmod +x /start.sh
echo "done"