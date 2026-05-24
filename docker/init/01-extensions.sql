-- docker/init/01-extensions.sql
-- Runs automatically on first postgres container boot.
-- Creates the extensions our schema needs.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";