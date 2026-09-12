# Project Onboarding

Este flujo configura skills locales para un proyecto existente y deja sus
`AGENTS.md` ruteados sin depender de una estructura fija como `apps/frontend`
o `apps/backend`.

## Quick Path

1. Instala `project-onboarding` en el proyecto destino.
2. Ejecuta onboarding para detectar stack, componentes y scopes reales.
3. Deja que `project-onboarding` busque skills con `npx skills find`, las audite y te muestre el listado final.
4. Confirma las skills aprobadas antes de instalar.
5. El agente actualiza cada `AGENTS.md` con la tabla `### Auto-invoke Skills` según la metadata de cada skill.
6. Verifica que cada `AGENTS.md` tenga la tabla correcta y sin duplicados.

## Install

```powershell
npx skills add AgustinAlbonico/ai-customizations --skill project-onboarding --agent opencode -y
```

La instalacion esperada es local al proyecto, en `.agents/skills/`. No uses instalacion global para este flujo si queres que el repo sea reproducible.

## Project Onboarding

`project-onboarding` guia al agente para:

| Phase | Output |
|-------|--------|
| Scan | Detecta `package.json`, `tsconfig.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, Docker y carpetas conocidas |
| Stack | Genera componentes como `backend`, `frontend`, `shared`, `mcp`, `sdk` o `root` |
| Discovery | Ejecuta `npx skills find "<query>"` por tecnología y componente |
| Audit | Deduplica candidatos y aplica `references/security-filter.md` |
| Approval | Muestra `SAFE`, `REVIEW` y `BLOCKED`; espera aprobación humana |
| Install | Usa `npx skills add <owner/repo> --skill <skill-name> --agent opencode -y` solo para aprobadas |
| Route | El agente lee `metadata.scope` + `metadata.auto_invoke` y actualiza los `AGENTS.md` manualmente |

## Detection Scripts

Windows:

```powershell
.\.agents\skills\project-onboarding\assets\detect-stack.ps1 -ProjectPath .
```

macOS/Linux:

```bash
./.agents/skills/project-onboarding/assets/detect-stack.sh .
```

Salida esperada:

```json
{
  "components": {
    "backend": {
      "path": "apps/backend",
      "stack": ["Node.js", "TypeScript", "NestJS"]
    },
    "frontend": {
      "path": "apps/frontend",
      "stack": ["Node.js", "TypeScript", "React", "Vite"]
    }
  },
  "tools": ["Docker"],
  "scopes": ["backend", "frontend"]
}
```

## Discovery Seguro

`project-onboarding` no instala durante la búsqueda. Primero genera queries desde el stack detectado:

```powershell
npx skills find "react vite tailwind"
npx skills find "nestjs backend"
npx skills find "typescript testing"
```

Luego clasifica candidatos:

| Estado | Acción |
|--------|--------|
| `SAFE` | Puede incluirse en la lista recomendada |
| `REVIEW` | Se muestra separado y requiere selección explícita |
| `BLOCKED` | No se instala; se muestra el motivo |

La política completa vive en `.agents/skills/project-onboarding/references/security-filter.md`.

## Ruteo a AGENTS.md

Sin scripts externos. Para cada skill instalada, el agente lee su metadata:

```yaml
metadata:
  scope: [backend]
  auto_invoke:
    - "Creating API endpoints"
    - "Writing NestJS modules"
```

Y actualiza la sección `### Auto-invoke Skills` del `AGENTS.md` correspondiente
(raíz para `root`, componente para `frontend`/`backend`/`shared`, u
`.agents/skill-scopes.json` para scopes propios). Si la skill no trae metadata,
el agente la propone según el componente y la agrega al `SKILL.md`.

## Dynamic Scopes

| Scope | Known Paths |
|-------|-------------|
| `root` | Repo root |
| `frontend` | `frontend`, `web`, `client`, `apps/frontend`, `apps/web`, `apps/client` |
| `backend` | `backend`, `api`, `server`, `apps/backend`, `apps/api`, `apps/server` |
| `shared` | `packages/shared`, `shared`, `common`, `packages/common` |
| `mcp` / `mcp_server` | `mcp_server`, `mcp`, `mcp-server` |
| `sdk` | `sdk`, `lib`, `packages/sdk`, `packages/lib` |

Para scopes propios, agrega `.agents/skill-scopes.json`:

```json
{
  "scopes": {
    "admin": "apps/admin",
    "mobile": "apps/mobile"
  }
}
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `npx skills find` falla con 404 | Revisa el nombre del source y la conexión |
| Skill no aparece en `AGENTS.md` | Verifica `metadata.scope` y `metadata.auto_invoke`, agregalos a mano |
| Scope no encuentra carpeta | Usa un path conocido o `.agents/skill-scopes.json` |

## Verification Checklist

- [ ] `detect-stack` devuelve JSON valido.
- [ ] `npx skills find` devuelve candidatos para queries del stack.
- [ ] Las skills candidatas fueron deduplicadas y auditadas antes de instalar.
- [ ] El usuario aprobó explícitamente el listado final.
- [ ] Las skills elegidas existen en el source antes de instalar.
- [ ] Cada `AGENTS.md` tiene su tabla `### Auto-invoke Skills` actualizada.
- [ ] No hay filas duplicadas en `### Auto-invoke Skills`.
