// prisma.config.ts  (project root — same level as package.json)
import path from 'node:path';
import { defineConfig } from 'prisma/config';

export default defineConfig({
  schema: path.join('prisma', 'schema.prisma'),

  datasource: {
    url: process.env.DATABASE_URL,
  },
});
