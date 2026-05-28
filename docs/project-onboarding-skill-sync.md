# Project Onboarding + Skill Sync

Este flujo configura skills locales para un proyecto existente y mantiene sus `AGENTS.md` sincronizados sin depender de una estructura fija como `apps/frontend` o `apps/backend`.

## Quick Path

1. Instala `project-onboarding` y `skill-sync` en el proyecto destino.
2. Ejecuta onboarding para detectar stack, componentes y scopes reales.
3. Confirma las skills recomendadas antes de instalar.
4. Ejecuta `skill-sync` en dry-run y luego en modo escritura.
5. Verifica que cada `AGENTS.md` tenga la tabla `### Auto-invoke Skills` correcta.

## Install

```powershell
npx skills add AgustinAlbonico/ai-customizations --skill project-onboarding --agent opencode -y
npx skills add AgustinAlbonico/ai-customizations --skill skill-sync --agent opencode -y
```

La instalacion esperada es local al proyecto, en `.agents/skills/`. No uses instalacion global para este flujo si queres que el repo sea reproducible.

## Project Onboarding

`project-onboarding` guia al agente para:

| Phase | Output |
|-------|--------|
| Scan | Detecta `package.json`, `tsconfig.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, Docker y carpetas conocidas |
| Stack | Genera componentes como `backend`, `frontend`, `shared`, `mcp`, `sdk` o `root` |
| Recommend | Mapea tecnologias a skills sugeridas |
| Install | Usa `npx skills add <owner/repo> --skill <skill-name> --agent opencode -y` |
| Route | Ejecuta `skill-sync` para actualizar `AGENTS.md` |

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

## Skill Sync

`skill-sync` lee la metadata de cada `SKILL.md` y genera tablas de routing en el `AGENTS.md` correspondiente.

Metadata requerida:

```yaml
metadata:
  scope: [backend]
  auto_invoke:
    - "Creating API endpoints"
    - "Writing NestJS modules"
```

Windows:

```powershell
.\.agents\skills\skill-sync\assets\sync.ps1 -DryRun
.\.agents\skills\skill-sync\assets\sync.ps1 -AutoAddMetadata
```

macOS/Linux:

```bash
./.agents/skills/skill-sync/assets/sync.sh --dry-run
./.agents/skills/skill-sync/assets/sync.sh --auto-add-metadata
```

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
| `npx skills.sh` falla con 404 | Usa `npx skills add`, no `npx skills.sh install` |
| Skill no aparece en `AGENTS.md` | Verifica `metadata.scope` y `metadata.auto_invoke` |
| Scope no encuentra carpeta | Usa un path conocido o `.agents/skill-scopes.json` |
| No queres crear `AGENTS.md` automaticamente | Usa `-NoCreateAgents` o `--no-create-agents` |
| Queres revisar antes de escribir | Usa `-DryRun` o `--dry-run` |

## Difference From Prowler

| Prowler | This Repo |
|---------|-----------|
| Scopes fijos como `ui`, `api`, `sdk`, `mcp_server` | Scopes dinamicos por estructura real |
| `sync.sh` pensado para su repo | `sync.ps1` y `sync.sh` reutilizables |
| Skill hub `prowler` | `AGENTS.md` funciona como hub del proyecto |
| Metadata manual | `-AutoAddMetadata` / `--auto-add-metadata` puede completar defaults |

## Verification Checklist

- [ ] `detect-stack` devuelve JSON valido.
- [ ] Las skills elegidas existen en el source antes de instalar.
- [ ] `skill-sync` en dry-run muestra los `AGENTS.md` esperados.
- [ ] `skill-sync` en modo escritura actualiza o crea solo los `AGENTS.md` esperados.
- [ ] No hay filas duplicadas en `### Auto-invoke Skills`.
