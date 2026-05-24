#!/bin/bash
# ─────────────────────────────────────────────────────────────────
# EduTrack — Sequential Commit & Push Script
# Usage: chmod +x commit-push.sh && ./commit-push.sh
# Pushes one commit at a time from the list below.
# Tracks progress in .commit_index so you can resume anytime.
# ─────────────────────────────────────────────────────────────────

BRANCH="main"
INDEX_FILE=".commit_index"
REMOTE="origin"

# ── All commit messages (chronological order) ─────────────────────
COMMITS=(
  # ── PLANNING STAGE ────────────────────────────────────────────
  "docs: initialise project — EduTrack school management system for Nigerian secondary schools"
  "docs: map full system architecture — 45 screens, 9 user roles, 3 platforms"
  "docs: define user roles and permissions matrix (student, parent, teacher, admin, principal, bursar)"
  "docs: document Nigerian 6-3-3-4 school journey — JSS1 enrollment to SS3 graduation"
  "docs: create screen inventory — 19 student, 15 parent, 10 teacher, 13 admin screens"
  "docs(proposal): build 10-slide sales deck — pricing tiers starter/school/enterprise"

  # ── SYSTEM DESIGN ─────────────────────────────────────────────
  "docs(erd): design core database schema — SCHOOLS, USERS, STUDENTS, PARENTS, STAFF"
  "docs(erd): design academic module schema — CLASSES, SUBJECTS, TIMETABLE, ATTENDANCE, SCORES"
  "docs(erd): design finance module schema — FEE_STRUCTURES, PAYMENTS, PAYSTACK_WEBHOOKS, LEDGER"
  "docs(erd): design communication module schema — NOTIFICATIONS, MESSAGES, ANNOUNCEMENTS, DOCUMENTS"
  "docs(api): write full OpenAPI 3.0 spec — 17 route groups, 60+ endpoints, all request/response schemas"
  "docs(api): define multi-tenancy strategy — school_id scoped on all tables and routes"
  "docs(api): document Paystack webhook flow and payment lifecycle"
  "docs(api): document authentication flow — phone OTP → Redis → JWT"

  # ── INFRASTRUCTURE ────────────────────────────────────────────
  "chore: initialise NestJS project with TypeScript, Prisma, PostgreSQL, Redis"
  "chore(docker): add docker-compose.yml with PostgreSQL 16 and Redis 7 services"
  "chore(docker): add Dockerfile with dev and production multi-stage build"
  "chore(docker): add start.sh — wait for postgres/redis then run Prisma migrations"
  "chore(docker): add Makefile with up/down/logs/shell/migrate/seed commands"
  "chore: add .env.example with all required environment variables"

  # ── ERRORS ENCOUNTERED AND FIXED ──────────────────────────────
  "fix(docker): resolve podman socket conflict on Kali Linux — unset DOCKER_HOST env var"
  "fix(docker): install real Docker Engine from download.docker.com/linux/debian bookworm repo"
  "fix(docker): add user to docker group — sudo usermod -aG docker \$USER && newgrp docker"
  "fix(redis): fix Redis 7.4 fatal config error — requirepass wrong number of arguments"
  "fix(redis): change command from folded scalar string to YAML list format for Redis flags"
  "fix(redis): fix healthcheck — use sh -c with double-dollar-sign for env var expansion"
  "fix(redis): change host port from 6379 to 6380 — local Redis service was occupying 6379"
  "fix(docker): fix Redis port conflict — stop local Redis with sudo systemctl stop redis"
  "fix(prisma): fix _prisma_migrations table does not exist on fresh DB — run prisma db push"
  "fix(start): update start.sh to auto-detect and run prisma migrate deploy or db push"
  "fix(auth): resolve 403 forbidden on GET /schools/:id — token schoolId mismatch"
  "fix(auth): school onboarded multiple times — token scoped to old school, use correct schoolCode"

  # ── AUTH MODULE ───────────────────────────────────────────────
  "feat(auth): implement POST /auth/request-otp — rate-limited, OTP hashed before Redis storage"
  "feat(auth): add resend cooldown — 60s between OTP requests using separate otp_cd: key prefix"
  "feat(auth): fix findFirst to findUnique for phone lookup — phone has unique constraint"
  "feat(auth): mask phone number in logs — +234****0145 format to avoid leaking numbers"
  "feat(auth): implement POST /auth/verify-otp — brute-force protection, 5 attempt ceiling"
  "feat(auth): add schoolCode cross-check in verifyOtp — prevents school A token working on school B"
  "feat(auth): consume OTP immediately after successful verify — one-time use enforced"
  "feat(auth): implement refresh token — opaque random string stored in Redis with 30-day TTL"
  "feat(auth): implement POST /auth/logout — delete refresh token from Redis on logout"
  "feat(auth): implement GET /auth/me — return validated user profile from JWT"
  "feat(auth): add JwtStrategy — validates token, loads full user from DB on every request"
  "feat(auth): add JwtAuthGuard with IS_PUBLIC_KEY bypass for public routes"
  "feat(auth): add @CurrentUser() decorator to extract validated user from request"
  "feat(auth): add OtpPayload interface — hash, userId, schoolId, attempts typed correctly"
  "feat(auth): separate Redis key prefixes — otp: for OTPs, otp_cd: for cooldowns"

  # ── SCHOOLS MODULE ────────────────────────────────────────────
  "feat(schools): implement POST /schools/onboard — creates school + admin user in one transaction"
  "feat(schools): implement GET /schools/:id — JWT guarded, assertSameSchool enforced"
  "feat(schools): implement PATCH /schools/:id — admin only, assertSameSchool + assertAdmin"
  "feat(schools): add assertSameSchool guard helper — throws 403 on school_id mismatch"
  "feat(schools): add assertAdmin guard helper — throws 403 for non-admin roles"
  "feat(schools): add school stats to GET response — student count, staff count, user count"
  "feat(schools): add Swagger decorators — @ApiBearerAuth, @ApiOperation, @ApiResponse"
  "feat(schools): add global Authorize button to Swagger — addBearerAuth() in DocumentBuilder"

  # ── TESTING ───────────────────────────────────────────────────
  "test: create WhyteWalker Academy — schoolId 5e17801d, schoolCode GFA001"
  "test: verify OTP flow end-to-end — request OTP, check logs, verify, receive JWT"
  "test: confirm assertSameSchool blocks cross-school access — 403 on wrong schoolId in URL"
  "test: confirm role guard blocks bursar from attendance — 403 on wrong role"
  "test: verify GET /schools/:id returns school with student/staff counts after auth"
  "test: verify PATCH /schools/:id updates name and address correctly"
  "test: confirm refresh token issues new access token without re-login"
  "test: confirm logout revokes refresh token — subsequent refresh returns 401"
)

# ── Read current index ─────────────────────────────────────────────
if [ -f "$INDEX_FILE" ]; then
  CURRENT=$(cat "$INDEX_FILE")
else
  CURRENT=0
fi

TOTAL=${#COMMITS[@]}

if [ "$CURRENT" -ge "$TOTAL" ]; then
  echo ""
  echo "✅ All $TOTAL commits have been pushed."
  echo "   Delete $INDEX_FILE to start over."
  exit 0
fi

# ── Show progress ─────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  EduTrack — Sequential Commit Pusher"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Progress : $CURRENT / $TOTAL commits pushed"
echo "  Next     : commit $((CURRENT + 1)) of $TOTAL"
echo ""
echo "  Message  : ${COMMITS[$CURRENT]}"
echo ""

# ── Confirm before pushing ─────────────────────────────────────────
read -p "Push this commit? (y/n/q to quit): " choice

case "$choice" in
  y|Y)
    git add .
    git commit -m "${COMMITS[$CURRENT]}" || {
      echo "⚠️  Nothing to commit — skipping to next."
    }
    git push "$REMOTE" "$BRANCH" && {
      echo ""
      echo "✅ Pushed: ${COMMITS[$CURRENT]}"
      # Advance index
      echo $((CURRENT + 1)) > "$INDEX_FILE"
      REMAINING=$((TOTAL - CURRENT - 1))
      echo "   $REMAINING commits remaining."
    } || {
      echo "❌ Push failed. Fix the issue and run the script again."
      exit 1
    }
    ;;
  n|N)
    echo "⏭  Skipped. Run again to retry this commit."
    ;;
  q|Q)
    echo "👋 Quit. Progress saved at commit $CURRENT."
    exit 0
    ;;
  *)
    echo "❓ Unknown input. Run again."
    ;;
esac

echo ""
echo "Run ./commit-push.sh again for the next commit."