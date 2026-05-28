# Tabla de Mapeo: Stack → Skills

Este documento define qué skills se recomiendan según las tecnologías detectadas en el proyecto. Antes de instalar, validar que la skill exista en el source elegido con `npx skills add <owner/repo> --list`.

## Frontend

| Tecnología | Skills recomendadas | Scope |
|------------|---------------------|-------|
| React | `vercel-react-best-practices`, `frontend-design` | frontend |
| Next.js | `vercel-react-best-practices` | frontend |
| Vue | `vue-best-practices` | frontend |
| Nuxt | `vue-best-practices` | frontend |
| Angular | `angular-best-practices` | frontend |
| Svelte | `svelte-best-practices` | frontend |
| Vite | `vite`, `vitest` | frontend |
| Tailwind CSS | `tailwind-v4-shadcn`, `tailwind-css-patterns` | frontend |
| shadcn/ui | `shadcn` | frontend |
| Radix UI | `shadcn` | frontend |
| Material-UI | `mui-best-practices` | frontend |
| Ant Design | `antd-best-practices` | frontend |

## Backend

| Tecnología | Skills recomendadas | Scope |
|------------|---------------------|-------|
| NestJS | `nestjs-best-practices` | backend |
| Express | `express-best-practices` | backend |
| Fastify | `fastify-best-practices` | backend |
| Django | `django-drf` | backend |
| FastAPI | `fastapi-best-practices` | backend |
| Flask | `flask-best-practices` | backend |
| Gin (Go) | `go-best-practices` | backend |
| Actix Web (Rust) | `rust-best-practices` | backend |

## Base de Datos

| Tecnología | Skills recomendadas | Scope |
|------------|---------------------|-------|
| PostgreSQL | `postgresql-expert-best-practices-code-review` | backend |
| MySQL | `mysql-best-practices` | backend |
| MongoDB | `mongodb-best-practices` | backend |
| TypeORM | `typeorm-best-practices` | backend |
| Prisma | `prisma-best-practices` | backend |
| Drizzle | `drizzle-best-practices` | backend |
| Mongoose | `mongoose-best-practices` | backend |

## Testing

| Tecnología | Skills recomendadas | Scope |
|------------|---------------------|-------|
| Vitest | `vitest` | frontend, backend |
| Jest | `jest-best-practices` | frontend, backend |
| Playwright | `playwright-e2e-testing` | root |
| Cypress | `cypress-best-practices` | root |
| pytest | `pytest` | backend |

## TypeScript

| Tecnología | Skills recomendadas | Scope |
|------------|---------------------|-------|
| TypeScript | `typescript-advanced-types` | frontend, backend |

## DevOps / Infraestructura

| Tecnología | Skills recomendadas | Scope |
|------------|---------------------|-------|
| Docker | `docker-expert` | root |
| GitHub Actions | `github-actions-best-practices` | root |
| GitLab CI | `gitlab-ci-best-practices` | root |

## Autenticación

| Tecnología | Skills recomendadas | Scope |
|------------|---------------------|-------|
| Auth.js | `authjs-best-practices` | backend |
| Clerk | `clerk-best-practices` | backend |
| JWT (custom) | `jwt-security-best-practices` | backend |

## State Management

| Tecnología | Skills recomendadas | Scope |
|------------|---------------------|-------|
| Zustand | `zustand-best-practices` | frontend |
| Redux | `redux-best-practices` | frontend |
| TanStack Query | `tanstack-query-best-practices` | frontend |

## Validación

| Tecnología | Skills recomendadas | Scope |
|------------|---------------------|-------|
| Zod | `zod-best-practices` | frontend, backend |
| Yup | `yup-best-practices` | frontend, backend |

## MCP (Model Context Protocol)

| Tecnología | Skills recomendadas | Scope |
|------------|---------------------|-------|
| MCP Server | `mcp-server-best-practices` | mcp |

## Transversales (siempre recomendadas)

Estas skills se recomiendan para cualquier proyecto:

| Skill | Scope | Descripción |
|-------|-------|-------------|
| `sonarqube-quality-gate-playbook` | root | Mejora calidad de código |

| `interactive-bug` | root | Diagnóstico de bugs |
| `interactive-task` | root | Clarificación de tareas |

## Lógica de recomendación

### Por componente

1. **Backend**: Skills de framework + base de datos + testing backend
2. **Frontend**: Skills de framework + UI + testing frontend
3. **Shared**: Skills de TypeScript + validación
4. **MCP**: Skills de MCP server
5. **SDK**: Skills de testing + documentación

### Prioridad

1. **Alta**: Framework principal (NestJS, React, Django, etc.)
2. **Media**: Herramientas de build (Vite, Tailwind, etc.)
3. **Baja**: Librerías auxiliares (Zustand, Zod, etc.)

### Reglas

- **Máximo 10 skills por componente** para no sobrecargar
- **Skills transversales** siempre van a scope `root`
- **Si hay testing**, recomendar skill de testing específica
- **Si hay TypeScript**, siempre recomendar `typescript-advanced-types`

## Ejemplos

### Proyecto NestJS + React + Tailwind

```
Backend:
  - nestjs-best-practices
  - typescript-advanced-types
  - postgresql-expert-best-practices-code-review

Frontend:
  - vercel-react-best-practices
  - frontend-design
  - tailwind-v4-shadcn
  - vite
  - vitest
  - typescript-advanced-types

Root:
  - docker-expert
  - playwright-e2e-testing
```

### Proyecto Django + Vue

```
Backend:
  - django-drf
  - postgresql-expert-best-practices-code-review
  - pytest

Frontend:
  - vue-best-practices
  - vite
  - vitest

Root:
  - docker-expert
```

### Proyecto Next.js fullstack

```
Frontend:
  - vercel-react-best-practices
  - frontend-design
  - tailwind-v4-shadcn
  - typescript-advanced-types
  - vitest

Root:
  - docker-expert
  - playwright-e2e-testing
```
