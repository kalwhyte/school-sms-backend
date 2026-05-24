# Use an official Node.js runtime as a parent image
FROM node:20-alpine AS base

# Install openssl for Prisma binary
RUN apk add --no-cache openssl

WORKDIR /app

# ── Dependencies ──────────────────────────────────────────────────────────────
FROM base AS deps
COPY package*.json ./
RUN npm ci

# ── Development image (used by docker-compose) ────────────────────────────────
FROM base AS development
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Generate Prisma client
RUN npx prisma generate

EXPOSE 3000
CMD ["sh", "/app/docker/start.sh"]

# ── Build ─────────────────────────────────────────────────────────────────────
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npx prisma generate
RUN npm run build

# ── Production image ──────────────────────────────────────────────────────────
FROM base AS production
ENV NODE_ENV=production

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/package*.json ./
COPY docker/start.sh ./docker/start.sh

RUN npm prune --production

EXPOSE 3000
CMD ["sh", "/app/docker/start.sh"]