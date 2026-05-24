#!/bin/bash

echo "🚀 Creating starter files in existing directories..."

# =========================================================
# COMMON DIRECTORY
# =========================================================

declare -A COMMON_FILES=(
  ["src/common/constants"]="app.constants.ts auth.constants.ts"
  ["src/common/decorators"]="roles.decorator.ts permissions.decorator.ts current-user.decorator.ts"
  ["src/common/dto"]="pagination.dto.ts response.dto.ts"
  ["src/common/enums"]="roles.enum.ts status.enum.ts"
  ["src/common/exceptions"]="app.exception.ts"
  ["src/common/filters"]="http-exception.filter.ts prisma-exception.filter.ts"
  ["src/common/guards"]="jwt-auth.guard.ts roles.guard.ts permissions.guard.ts"
  ["src/common/helpers"]="date.helper.ts response.helper.ts"
  ["src/common/interceptors"]="logging.interceptor.ts transform.interceptor.ts"
  ["src/common/interfaces"]="api-response.interface.ts"
  ["src/common/middleware"]="logger.middleware.ts"
  ["src/common/pipes"]="validation.pipe.ts"
  ["src/common/serializers"]="user.serializer.ts"
  ["src/common/services"]="token.service.ts"
  ["src/common/types"]="common.types.ts"
  ["src/common/utils"]="generate-id.util.ts"
)

# =========================================================
# INFRASTRUCTURE DIRECTORY
# =========================================================

declare -A INFRA_FILES=(
  ["src/infrastructure/cache"]="redis.service.ts cache.service.ts"
  ["src/infrastructure/database"]="prisma.service.ts database.module.ts"
  ["src/infrastructure/events"]="event-emitter.service.ts"
  ["src/infrastructure/jobs"]="job.service.ts"
  ["src/infrastructure/notifications"]="notification.service.ts"
  ["src/infrastructure/pdf"]="pdf.service.ts"
  ["src/infrastructure/queues"]="queue.service.ts bull.config.ts"
  ["src/infrastructure/sms"]="termii.service.ts"
  ["src/infrastructure/storage"]="storage.service.ts"
)

# =========================================================
# QUEUE PROCESSORS
# =========================================================

QUEUE_PROCESSORS=(
  "src/queue-processors/email.processor.ts"
  "src/queue-processors/sms.processor.ts"
  "src/queue-processors/export.processor.ts"
)

# =========================================================
# FUNCTION TO CREATE FILE
# =========================================================

create_file() {
  local file=$1

  if [ ! -f "$file" ]; then
    touch "$file"

    echo "✅ Created: $file"

    # ----------------------------------------
    # AUTO BOILERPLATE CONTENT
    # ----------------------------------------

    filename=$(basename "$file")

    case "$filename" in

      *.service.ts)
cat > "$file" <<EOF
import { Injectable } from '@nestjs/common';

@Injectable()
export class ${filename%%.*}Service {}
EOF
;;

      *.guard.ts)
cat > "$file" <<EOF
import {
  CanActivate,
  ExecutionContext,
  Injectable,
} from '@nestjs/common';

@Injectable()
export class ${filename%%.*}Guard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    return true;
  }
}
EOF
;;

      *.filter.ts)
cat > "$file" <<EOF
import {
  Catch,
  ExceptionFilter,
  ArgumentsHost,
} from '@nestjs/common';

@Catch()
export class ${filename%%.*}Filter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {}
}
EOF
;;

      *.interceptor.ts)
cat > "$file" <<EOF
import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';

@Injectable()
export class ${filename%%.*}Interceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler) {
    return next.handle();
  }
}
EOF
;;

      *.middleware.ts)
cat > "$file" <<EOF
import { Injectable, NestMiddleware } from '@nestjs/common';

@Injectable()
export class ${filename%%.*}Middleware implements NestMiddleware {
  use(req: any, res: any, next: () => void) {
    next();
  }
}
EOF
;;

      *.decorator.ts)
cat > "$file" <<EOF
export const ${filename%%.*} = () => {};
EOF
;;

      *.dto.ts)
cat > "$file" <<EOF
export class ${filename%%.*}Dto {}
EOF
;;

      *.enum.ts)
cat > "$file" <<EOF
export enum ${filename%%.*}Enum {}
EOF
;;

      *.interface.ts)
cat > "$file" <<EOF
export interface ${filename%%.*}Interface {}
EOF
;;

      *.processor.ts)
cat > "$file" <<EOF
import { Processor, Process } from '@nestjs/bull';

@Processor('default')
export class ${filename%%.*}Processor {

  @Process()
  async handleJob(job: any) {
    console.log(job.data);
  }
}
EOF
;;

      *)
echo "// ${filename}" > "$file"
;;

    esac

  else
    echo "⏭️ Skipped existing: $file"
  fi
}

# =========================================================
# CREATE COMMON FILES
# =========================================================

for dir in "${!COMMON_FILES[@]}"; do
  for file in ${COMMON_FILES[$dir]}; do
    create_file "$dir/$file"
  done
done

# =========================================================
# CREATE INFRASTRUCTURE FILES
# =========================================================

for dir in "${!INFRA_FILES[@]}"; do
  for file in ${INFRA_FILES[$dir]}; do
    create_file "$dir/$file"
  done
done

# =========================================================
# CREATE QUEUE PROCESSORS
# =========================================================

for processor in "${QUEUE_PROCESSORS[@]}"; do
  create_file "$processor"
done

echo ""
echo "🎉 All starter files generated successfully."