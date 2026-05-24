# Makefile — shortcuts for common docker commands
# Usage: make <target>

.PHONY: up down restart logs shell db-shell migrate studio clean

## Start all services (postgres + redis + api)
up:
	docker compose -f docker/docker-compose.yml --env-file .env up --build

## Start in background
up-detached:
	docker compose -f docker/docker-compose.yml --env-file .env up --build -d

## Stop all services
down:
	docker compose -f docker/docker-compose.yml down

## Stop and remove volumes (wipes DB — use carefully)
clean:
	docker compose -f docker/docker-compose.yml down -v

## Restart the API only (after code changes without hot reload)
restart-api:
	docker compose -f docker/docker-compose.yml restart api

## Tail logs
logs:
	docker compose -f docker/docker-compose.yml logs -f

## API logs only
logs-api:
	docker compose -f docker/docker-compose.yml logs -f api

## Shell into the API container
shell:
	docker exec -it school_sms_api sh

## Postgres shell
db-shell:
	docker exec -it school_sms_postgres psql -U whyte_user -d school_sms_db

## Run migrations manually (inside container)
migrate:
	docker exec school_sms_api npx prisma migrate dev --name $(name)

## Open Prisma Studio (runs on host, connects to dockerised DB)
studio:
	DATABASE_URL=postgres://whyte_user:school_pass_2024@localhost:5433/school_sms_db npx prisma studio