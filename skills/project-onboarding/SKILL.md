---
name: project-onboarding
description: >
  Onboarding automático de proyectos existentes. Escanea el stack tecnológico,
  detecta componentes (backend, frontend, etc.), recomienda skills de skills.sh,
  las instala y las rutea a AGENTS.md automáticamente.
  Trigger: "onboarding del proyecto", "setup del proyecto", "configurar skills",
  "instalar skills para este proyecto".
license: MIT
metadata:
  author: AgustinAlbonico
  version: "1.0"
  scope: [root]
  auto_invoke:
    - "Onboarding de proyecto existente"
    - "Setup inicial de skills"
    - "Configurar skills del proyecto"
    - "Instalar skills recomendadas"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, question
---

# Protocolo project-onboarding

## Propósito

Automatizar el setup de skills en proyectos existentes mediante:
1. Detección automática del stack tecnológico
2. Recomendación de skills relevantes desde skills.sh
3. Instalación y ruteo automático a AGENTS.md

## Flujo general

```
FASE 1: Escaneo del Proyecto
    | detecta archivos de config, dependencias, estructura
    v
FASE 2: Detección de Stack
    | mapea tecnologías a componentes (backend, frontend, etc.)
    v
FASE 3: Recomendación de Skills
    | sugiere skills de skills.sh según stack detectado
    v
FASE 4: Instalación
    | instala skills seleccionadas con npx skills.sh install
    v
FASE 5: Ruteo
    | ejecuta skill-sync para actualizar AGENTS.md
```

---

## Reglas CRÍTICAS

1. **SIEMPRE usar herramienta `question`** para confirmar acciones — nunca asumir
2. **NO instalar sin confirmación** — siempre mostrar lista y pedir approval
3. **Detectar scopes dinámicos** — basados en carpetas reales del proyecto
4. **Usar skill-sync local** — copiar de ai-customizations si no existe
5. **Respetar estructura existente** — no reorganizar carpetas del proyecto
6. **Mostrar progreso** — feedback visual en cada fase

---

## FASE 1 — Escaneo del Proyecto

**Objetivo**: Detectar tecnologías y estructura del proyecto.

### Archivos a buscar

| Archivo | Qué detecta |
|---------|-------------|
| `package.json` | Node.js + dependencias |
| `tsconfig.json` | TypeScript |
| `pyproject.toml` / `requirements.txt` | Python |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `tailwind.config.*` | Tailwind CSS |
| `vite.config.*` | Vite |
| `next.config.*` | Next.js |
| `nest-cli.json` | NestJS |
| `docker-compose.yml` | Docker |

### Carpetas a detectar (componentes)

| Patrón | Componente |
|--------|------------|
| `backend/`, `api/`, `server/`, `apps/backend/`, `apps/api/` | Backend |
| `frontend/`, `web/`, `client/`, `apps/frontend/`, `apps/web/` | Frontend |
| `packages/shared/`, `shared/`, `common/` | Shared |
| `mcp_server/`, `mcp/` | MCP Server |
| `sdk/`, `lib/` | SDK/Library |

### Script de detección

Ejecutar: `./assets/detect-stack.ps1` (Windows) o `./assets/detect-stack.sh` (Linux/Mac)

El script genera un JSON con:
```json
{
  "components": {
    "backend": {
      "path": "apps/backend",
      "stack": ["Node.js", "TypeScript", "NestJS", "TypeORM", "MySQL"]
    },
    "frontend": {
      "path": "apps/frontend",
      "stack": ["Node.js", "TypeScript", "React", "Vite", "Tailwind CSS"]
    }
  },
  "tools": ["Docker", "TypeScript"],
  "scopes": ["backend", "frontend"]
}
```

### Presentación al usuario

```
Stack detectado:

Backend (apps/backend):
  ✓ Node.js + TypeScript
  ✓ NestJS
  ✓ TypeORM + MySQL

Frontend (apps/frontend):
  ✓ Node.js + TypeScript
  ✓ React + Vite
  ✓ Tailwind CSS

Herramientas:
  ✓ Docker
  ✓ TypeScript

Scopes detectados: backend, frontend

¿Es correcto? (si/no)
```

Si el usuario dice "no", preguntar qué falta o está mal y ajustar manualmente.

---

## FASE 2 — Recomendación de Skills

**Objetivo**: Sugerir skills relevantes desde skills.sh.

### Tabla de mapeo Stack → Skills

Ver [references/stack-mapping.md](references/stack-mapping.md) para la tabla completa.

Ejemplos:

| Tecnología | Skills recomendadas |
|------------|---------------------|
| React | `vercel-react-best-practices`, `frontend-design` |
| Next.js | `vercel-react-best-practices` |
| NestJS | `nestjs-best-practices` |
| Tailwind CSS | `tailwind-v4-shadcn`, `tailwind-css-patterns` |
| Vite | `vite`, `vitest` |
| TypeScript | `typescript-advanced-types` |
| shadcn/ui | `shadcn` |
| Django | `django-drf` |
| PostgreSQL | `postgresql-expert-best-practices-code-review` |

### Agrupación por componente

```
Skills recomendadas para Backend:
  [1] nestjs-best-practices
  [2] typescript-advanced-types

Skills recomendadas para Frontend:
  [3] vercel-react-best-practices
  [4] tailwind-v4-shadcn
  [5] vite
  [6] vitest

Skills transversales (scope: root):
  [7] docker-expert

¿Cuáles instalás?
  - Todas (1-7)
  - Solo backend (1-2)
  - Solo frontend (3-6)
  - Selección personalizada (ej: 1,3,5)
```

### Confirmación

Usar `question` tool:
```
question: "¿Qué skills querés instalar?"
options:
  - "Todas las recomendadas"
  - "Solo backend"
  - "Solo frontend"
  - "Selección personalizada"
```

---

## FASE 3 — Instalación

**Objetivo**: Instalar skills seleccionadas desde skills.sh.

### Pre-requisitos

1. Verificar que `.agents/scripts/sync.ps1` exista
   - Si no existe, copiar desde `ai-customizations/skills/skill-sync/assets/sync.ps1`
2. Verificar que `.agents/skills/skill-sync/` exista
   - Si no existe, copiar desde `ai-customizations/skills/skill-sync/`

### Proceso de instalación

Para cada skill seleccionada:

```bash
npx skills.sh install <skill-name>
```

Esto descarga la skill a `.agents/skills/<skill-name>/`.

### Asignación de scopes

Después de instalar, el agente:

1. Lee el `SKILL.md` de cada skill instalada
2. Detecta a qué componente pertenece según la tabla de mapeo
3. Agrega metadata si no existe:

```yaml
metadata:
  scope: [backend]  # o frontend, root, etc.
  auto_invoke:
    - "Acción relevante"
```

### Ejemplo

```bash
# Instalar skill
npx skills.sh install nestjs-best-practices

# Agregar metadata (el agente edita el SKILL.md)
metadata:
  scope: [backend]
  auto_invoke:
    - "Writing NestJS modules"
    - "Creating API endpoints"
```

---

## FASE 4 — Ruteo

**Objetivo**: Actualizar AGENTS.md con las skills instaladas.

### Ejecutar skill-sync

```powershell
# Windows
.\.agents\scripts\sync.ps1 -AutoAddMetadata

# Linux/Mac
./.agents/scripts/sync.sh --auto-add-metadata
```

### Verificación

Mostrar al usuario:

```
Skills instaladas y ruteadas:

Backend:
  ✓ nestjs-best-practices → apps/backend/AGENTS.md
  ✓ typescript-advanced-types → apps/backend/AGENTS.md

Frontend:
  ✓ vercel-react-best-practices → apps/frontend/AGENTS.md
  ✓ tailwind-v4-shadcn → apps/frontend/AGENTS.md
  ✓ vite → apps/frontend/AGENTS.md

Transversales:
  ✓ docker-expert → AGENTS.md

AGENTS.md actualizados:
  ✓ AGENTS.md (root)
  ✓ apps/backend/AGENTS.md
  ✓ apps/frontend/AGENTS.md

¿Querés revisar los AGENTS.md generados?
```

---

## FASE 5 — Post-instalación

**Objetivo**: Verificar que todo funcione correctamente.

### Checklist

- [ ] Todas las skills instaladas en `.agents/skills/`
- [ ] Metadata agregada a cada skill (scope + auto_invoke)
- [ ] skill-sync ejecutado sin errores
- [ ] AGENTS.md actualizados con tablas Auto-invoke
- [ ] Scopes dinámicos detectados correctamente

### Problemas comunes

| Problema | Solución |
|----------|----------|
| Skill no aparece en AGENTS.md | Verificar que tenga metadata (scope + auto_invoke) |
| Scope no detectado | Verificar que la carpeta exista y tenga package.json |
| skill-sync falla | Ejecutar con `-DryRun` para ver qué haría |
| Duplicados en tabla | Limpiar metadata duplicada en SKILL.md |

### Comando de diagnóstico

```powershell
# Ver skills sin metadata
.\.agents\scripts\sync.ps1 -DryRun

# Ver qué actualizaría
.\.agents\scripts\sync.ps1 -DryRun -AutoAddMetadata
```

---

## Casos de uso

### Caso 1: Proyecto nuevo con stack definido

```
Usuario: "hacé onboarding del proyecto"
Agente: escanea → detecta React + NestJS → recomienda 5 skills → instala → rutea
```

### Caso 2: Proyecto existente sin skills

```
Usuario: "configurá skills para este proyecto"
Agente: escanea → detecta Django + PostgreSQL → recomienda 3 skills → instala → rutea
```

### Caso 3: Agregar skills a componente específico

```
Usuario: "instalá skills solo para el frontend"
Agente: detecta frontend → recomienda 4 skills → instala solo esas → rutea
```

---

## Integración con project-starter

Si el usuario está creando un proyecto desde cero:

1. Usar `project-starter` para definir stack y hacer bootstrap
2. Después del bootstrap, usar `project-onboarding` para instalar skills

```
project-starter → define stack + bootstrap → project-onboarding → instala skills
```

---

## Recursos

- **Tabla de mapeo**: Ver [references/stack-mapping.md](references/stack-mapping.md)
- **Script de detección**: Ver [assets/detect-stack.ps1](assets/detect-stack.ps1)
- **Skill-sync**: Ver [../skill-sync/SKILL.md](../skill-sync/SKILL.md)
