# Query Seeds: Stack -> Skills Discovery

Este documento ya no define una lista cerrada de skills. Define semillas de búsqueda para `npx skills find`, porque skills.sh indexa muchas fuentes distintas y una tabla hardcodeada se queda corta.

## Regla General

1. Detectar tecnologías reales del proyecto.
2. Generar queries específicas por componente.
3. Ejecutar `npx skills find "<query>"` para cada query.
4. Deduplicar por `owner/repo@skill`.
5. Aplicar `references/security-filter.md`.
6. Mostrar el listado final al usuario y esperar aprobación.

## Frontend

| Tecnología | Queries sugeridas | Scope |
|------------|-------------------|-------|
| React | `react typescript`, `react components`, `react performance` | frontend |
| Next.js | `nextjs best practices`, `next app router`, `next deployment` | frontend |
| Vue | `vue best practices`, `vue typescript` | frontend |
| Nuxt | `nuxt best practices`, `nuxt deployment` | frontend |
| Angular | `angular best practices`, `angular testing` | frontend |
| Svelte | `svelte best practices`, `sveltekit` | frontend |
| Vite | `vite react`, `vite testing`, `vite build` | frontend |
| Tailwind CSS | `tailwind v4`, `tailwind shadcn`, `tailwind design system` | frontend |
| shadcn/ui | `shadcn`, `shadcn ui`, `component library` | frontend |
| Radix UI | `radix ui`, `accessible components` | frontend |
| Material-UI | `mui material ui`, `react material ui` | frontend |
| Ant Design | `ant design react`, `antd` | frontend |

## Backend

| Tecnología | Queries sugeridas | Scope |
|------------|-------------------|-------|
| NestJS | `nestjs backend`, `nestjs best practices`, `nestjs testing` | backend |
| Express | `express backend`, `express api`, `node api` | backend |
| Fastify | `fastify backend`, `fastify api` | backend |
| Django | `django rest`, `django best practices`, `django testing` | backend |
| FastAPI | `fastapi`, `python api`, `fastapi testing` | backend |
| Flask | `flask api`, `python flask` | backend |
| Gin | `go gin`, `go backend`, `go api` | backend |
| Actix Web | `rust actix`, `rust backend` | backend |

## Base de Datos

| Tecnología | Queries sugeridas | Scope |
|------------|-------------------|-------|
| PostgreSQL | `postgresql`, `postgres performance`, `database migrations` | backend |
| MySQL | `mysql`, `mysql performance`, `database migrations` | backend |
| MongoDB | `mongodb`, `mongodb schema`, `mongoose` | backend |
| TypeORM | `typeorm`, `typeorm migrations`, `nestjs typeorm` | backend |
| Prisma | `prisma`, `prisma migrations`, `database orm` | backend |
| Drizzle | `drizzle orm`, `drizzle migrations` | backend |
| Mongoose | `mongoose`, `mongodb mongoose` | backend |

## Testing

| Tecnología | Queries sugeridas | Scope |
|------------|-------------------|-------|
| Vitest | `vitest`, `vite testing`, `typescript testing` | frontend, backend |
| Jest | `jest`, `javascript testing`, `nestjs testing` | frontend, backend |
| Playwright | `playwright testing`, `e2e testing`, `webapp testing` | root |
| Cypress | `cypress testing`, `e2e testing` | root |
| pytest | `pytest`, `python testing` | backend |

## TypeScript

| Tecnología | Queries sugeridas | Scope |
|------------|-------------------|-------|
| TypeScript | `typescript best practices`, `typescript types`, `typescript testing` | frontend, backend |

## DevOps / Infraestructura

| Tecnología | Queries sugeridas | Scope |
|------------|-------------------|-------|
| Docker | `docker`, `docker compose`, `containerization` | root |
| GitHub Actions | `github actions`, `ci cd`, `deployment workflow` | root |
| GitLab CI | `gitlab ci`, `ci cd` | root |

## Autenticación

| Tecnología | Queries sugeridas | Scope |
|------------|-------------------|-------|
| Auth.js | `authjs`, `next auth`, `authentication` | backend |
| Clerk | `clerk auth`, `authentication` | backend |
| JWT | `jwt security`, `authentication security` | backend |
| Better Auth | `better auth`, `authentication` | backend |

## State Management

| Tecnología | Queries sugeridas | Scope |
|------------|-------------------|-------|
| Zustand | `zustand`, `react state management` | frontend |
| Redux | `redux`, `redux toolkit`, `react state management` | frontend |
| TanStack Query | `tanstack query`, `react query`, `server state` | frontend |

## Validación

| Tecnología | Queries sugeridas | Scope |
|------------|-------------------|-------|
| Zod | `zod`, `typescript validation`, `schema validation` | frontend, backend |
| Yup | `yup validation`, `schema validation` | frontend, backend |

## MCP (Model Context Protocol)

| Tecnología | Queries sugeridas | Scope |
|------------|-------------------|-------|
| MCP Server | `mcp server`, `model context protocol`, `mcp builder` | mcp |

## Transversales

Estas queries pueden ejecutarse en cualquier proyecto:

| Objetivo | Queries sugeridas | Scope |
|----------|-------------------|-------|
| Debugging | `debugging`, `systematic debugging`, `diagnose` | root |
| Planning | `writing plans`, `brainstorming`, `product requirements` | root |
| Code review | `code review`, `requesting code review`, `pull request review` | root |
| Arquitectura | `software architecture`, `clean architecture`, `improve codebase architecture` | root |
| Seguridad | `security review`, `secure coding`, `dependency audit` | root |

## Ranking

Priorizar candidatos en este orden:

1. Match exacto con tecnología y componente.
2. Aparece en varias queries relacionadas.
3. Installs altos.
4. Source oficial o reconocido.
5. Auditoría local `SAFE`.

## Límites

- Máximo 10 skills `SAFE` por componente.
- Las `REVIEW` se muestran separadas y no se preseleccionan.
- Las `BLOCKED` se muestran con motivo, pero no se instalan.

## Ejemplo: NestJS + React + Tailwind

```text
Queries ejecutadas:
  frontend:
    - react typescript
    - react components
    - vite testing
    - tailwind shadcn

  backend:
    - nestjs backend
    - nestjs testing
    - typeorm mysql

  root:
    - code review
    - systematic debugging

Resultado:
  - Deduplicar owner/repo@skill
  - Auditar seguridad
  - Rankear
  - Pedir aprobación antes de instalar
```
