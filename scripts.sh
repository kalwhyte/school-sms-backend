#!/bin/bash

# ============================================
# School SMS Backend Boilerplate Generator
# Stack: NestJS + TypeScript + Prisma
# ============================================

PROJECT_NAME="school-sms-backend"

echo "🚀 Creating $PROJECT_NAME boilerplate..."

# Root Structure
mkdir -p $PROJECT_NAME/{apps/{api,worker},prisma/{migrations},src,test,docker}

# Root Files
touch $PROJECT_NAME/{.env,.env.example,nest-cli.json,tsconfig.json,package.json,README.md}

# ============================================
# Prisma
# ============================================

touch $PROJECT_NAME/prisma/schema.prisma
touch $PROJECT_NAME/prisma/seed.ts

# ============================================
# SRC ROOT
# ============================================

touch $PROJECT_NAME/src/main.ts
touch $PROJECT_NAME/src/app.module.ts

# ============================================
# COMMON
# ============================================

COMMON_DIRS=(
constants
decorators
dto
enums
exceptions
filters
guards
helpers
interceptors
interfaces
middleware
pipes
serializers
services
types
utils
)

for dir in "${COMMON_DIRS[@]}"
do
  mkdir -p $PROJECT_NAME/src/common/$dir
done

# ============================================
# CONFIG
# ============================================

mkdir -p $PROJECT_NAME/src/config

CONFIG_FILES=(
app.config.ts
auth.config.ts
database.config.ts
paystack.config.ts
redis.config.ts
storage.config.ts
termii.config.ts
)

for file in "${CONFIG_FILES[@]}"
do
  touch $PROJECT_NAME/src/config/$file
done

# ============================================
# INFRASTRUCTURE
# ============================================

INFRA_DIRS=(
cache
database
events
jobs
notifications
queues
sms
storage
pdf
)

for dir in "${INFRA_DIRS[@]}"
do
  mkdir -p $PROJECT_NAME/src/infrastructure/$dir
done

# ============================================
# MODULES
# ============================================

MODULES=(
auth
schools
users
students
parents
staff
classes
subjects
attendance
assessments
scores
report-cards
fees
payments
announcements
messages
notifications
documents
leave-requests
)

for module in "${MODULES[@]}"
do
  mkdir -p $PROJECT_NAME/src/modules/$module

  mkdir -p $PROJECT_NAME/src/modules/$module/{controllers,dto,guards,strategies,services,interfaces}

  touch $PROJECT_NAME/src/modules/$module/$module.module.ts
  touch $PROJECT_NAME/src/modules/$module/$module.controller.ts
  touch $PROJECT_NAME/src/modules/$module/$module.service.ts
done

# ============================================
# QUEUE PROCESSORS
# ============================================

mkdir -p $PROJECT_NAME/src/queue-processors

PROCESSORS=(
payment.processor.ts
report-card.processor.ts
notification.processor.ts
)

for file in "${PROCESSORS[@]}"
do
  touch $PROJECT_NAME/src/queue-processors/$file
done

# ============================================
# TEMPLATES
# ============================================

mkdir -p $PROJECT_NAME/src/templates/{pdf,sms,email}

# ============================================
# DOCKER
# ============================================

touch $PROJECT_NAME/docker/Dockerfile
touch $PROJECT_NAME/docker/docker-compose.yml

echo "✅ Boilerplate structure created successfully!"
echo ""
echo "📦 Next Steps:"
echo "1. cd $PROJECT_NAME"
echo "2. npm install"
echo "3. nest new ."
echo "4. prisma init"
echo "5. Start building like a machine 🛠️"