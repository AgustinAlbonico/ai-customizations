---
name: project-onboarding
description: >
  Onboarding automático de proyectos existentes. Escanea el stack tecnológico,
  detecta componentes (backend, frontend, etc.), busca skills con `npx skills find`,
  audita seguridad, pide aprobación, instala y rutea a AGENTS.md automáticamente.
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
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch, question
---

# Protocolo project-onboarding

## Propósito

Automatizar el setup de skills en proyectos existentes mediante:
1. Detección automática del stack tecnológico
2. Discovery global de skills con `npx skills find`
3. Auditoría de seguridad antes de instalar
4. Instalación y ruteo a AGENTS.md después de aprobación humana (el agente actualiza
   las tablas de ruteo manualmente según la metadata de cada skill)

## Flujo general

```
FASE 1: Escaneo y Detección de Stack
    | detecta archivos, dependencias, componentes y scopes
    v
FASE 2: Discovery y Auditoría de Skills
    | busca con npx skills find, deduplica, filtra y rankea
    v
FASE 3: Aprobación e Instalación
    | muestra lista final, espera aprobación explícita e instala
    v
FASE 4: Ruteo
    | el agente actualiza AGENTS.md según metadata scope/auto_invoke
    v
FASE 5: Post-instalación
    | verifica instalación, metadata y AGENTS.md
```

---

## Reglas CRÍTICAS

1. **SIEMPRE usar herramienta `question`** para confirmar acciones — nunca asumir
2. **NO instalar sin confirmación** — siempre mostrar lista y pedir approval
3. **Detectar scopes dinámicos** — basados en carpetas reales del proyecto
4. **Rutear manualmente** — el agente lee `metadata.scope` + `metadata.auto_invoke` de cada skill instalada y actualiza las tablas de los AGENTS.md correspondientes (sin scripts externos)
5. **Respetar estructura existente** — no reorganizar carpetas del proyecto
6. **Mostrar progreso** — feedback visual en cada fase
7. **NO instalar durante discovery** — `npx skills find` solo recopila candidatos
8. **Bloquear skills peligrosas** — aplicar la política de seguridad antes de mostrar recomendadas
9. **Aplicar el patrón de `find-skills`** — buscar, evaluar, presentar opciones e instalar solo tras aprobación

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

## FASE 2 — Discovery, Auditoría y Recomendación

**Objetivo**: Buscar skills relevantes en el índice global de skills.sh usando `npx skills find`, no solo en repos conocidos.

### 1. Generar queries desde el stack detectado

Usar el stack de FASE 1 para crear queries específicas por componente y combinadas.

Ejemplo para NestJS + React + Vite + Tailwind + TypeScript + MySQL:

```text
frontend:
  - "react vite tailwind"
  - "react typescript"
  - "vite testing"

backend:
  - "nestjs backend"
  - "typeorm mysql"
  - "typescript testing"

root:
  - "agent workflows"
  - "code review"
  - "software architecture"
```

Ver [references/stack-mapping.md](references/stack-mapping.md) para semillas de queries por tecnología.

### 2. Ejecutar discovery global

Ejecutar `npx skills find` para cada query. Esto busca en skills.sh y puede devolver skills de cualquier source indexado, no solamente de repos hardcodeados.

```bash
npx skills find "react vite tailwind"
npx skills find "nestjs backend"
npx skills find "typescript testing"
```

Si una query tarda demasiado o falla, reintentar una vez con una query más específica. Si vuelve a fallar, registrar el timeout y continuar con las demás queries; no bloquear todo el onboarding por una sola búsqueda.

Capturar resultados con este formato:

```text
<owner>/<repo>@<skill> <installs> installs
```

Si la salida contiene ANSI colors, ignorarlos visualmente o limpiarlos antes de parsear.

PowerShell 5.1 puede limpiar ANSI así:

```powershell
$raw = npx skills find "nestjs backend"
$clean = [regex]::Replace(($raw -join "`n"), "$([char]27)\[[0-9;]*m", "")
$lines = $clean -split "`r?`n"

for ($i = 0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match "^([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)@([A-Za-z0-9_.-]+)\s+([0-9.]+[KkMm]?) installs") {
    $source = $Matches[1]
    $skill = $Matches[2]
    $installs = $Matches[3]
    $url = ""

    if (($i + 1) -lt $lines.Count -and $lines[$i + 1] -match "https://skills\.sh/[^\s]+") {
      $url = $Matches[0]
    }

    "$source@$skill | $installs installs | $url"
  }
}
```

### 3. Deduplicar y enriquecer candidatos

Por cada candidato guardar:

```json
{
  "id": "owner/repo@skill-name",
  "source": "owner/repo",
  "skill": "skill-name",
  "installCommand": "npx skills add owner/repo --skill skill-name --agent opencode -y",
  "matchedQuery": "react vite tailwind",
  "component": "frontend",
  "installs": 5000
}
```

Deduplicar por `source + skill`. Si aparece en varias queries, acumular `matchedQueries` y subir relevancia.

### 4. Auditoría de seguridad

Antes de recomendar una skill, aplicar [references/security-filter.md](references/security-filter.md).

Clasificar cada candidato como:

| Estado | Qué significa | Acción |
|--------|---------------|--------|
| `SAFE` | Se revisó el contenido disponible, no hay señales peligrosas y tiene al menos una señal fuerte de confianza | Puede recomendarse |
| `REVIEW` | Hay dudas de calidad, baja adopción o source poco conocido | Mostrar separado, no preseleccionar |
| `BLOCKED` | Contiene patrones peligrosos o instrucciones sospechosas | No instalar |

### 5. Rankear

Priorizar por:

1. Match exacto con stack/componente
2. Cantidad de queries donde apareció
3. Installs
4. Source confiable o conocido
5. Ausencia de señales de riesgo

No recomendar más de 10 skills por componente salvo que el usuario lo pida.

### Agrupación por componente

```
Skills recomendadas para Backend:
  [1] owner/repo@nestjs-best-practices
      Motivo: match NestJS + backend
      Riesgo: SAFE
      Installs: 12K

Skills recomendadas para Frontend:
  [2] secondsky/claude-skills@tailwind-v4-shadcn
      Motivo: match React + Tailwind
      Riesgo: SAFE
      Installs: 5K

Skills para revisar manualmente:
  [3] unknown/repo@react-helper
      Motivo: baja adopción
      Riesgo: REVIEW

Skills bloqueadas:
  [x] random/repo@dangerous-skill
      Motivo: contiene `curl | sh`
      Riesgo: BLOCKED

¿Cuáles instalás?
  - Todas las SAFE
  - Solo backend
  - Solo frontend
  - Selección personalizada (ej: 1,3,5)
  - Ninguna
```

### Confirmación

Usar `question` tool:
```
question: "¿Qué skills querés instalar?"
options:
  - "Todas las SAFE"
  - "Solo backend"
  - "Solo frontend"
  - "Selección personalizada"
  - "Ninguna"
```

Si el usuario elige una skill `REVIEW`, pedir confirmación explícita mencionando el motivo de riesgo. Nunca instalar una `BLOCKED`.

---

## FASE 3 — Aprobación e Instalación

**Objetivo**: Validar que las skills aprobadas sigan disponibles e instalarlas solo después de aprobación humana.

### Proceso de instalación

Para cada skill aprobada por el usuario:

```bash
npx skills add <owner/repo> --skill <skill-name> --agent opencode -y
```

Esto descarga la skill a `.agents/skills/<skill-name>/`.

Si la skill pertenece a este repositorio:

```bash
npx skills add AgustinAlbonico/ai-customizations --skill <skill-name> --agent opencode -y
```

Antes de instalar, validar que el source siga resolviendo:

```bash
npx skills add <owner/repo> --list
```

Si falla la validación, remover esa skill del lote e informar al usuario antes de continuar.

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
# Instalar skill desde un source compatible con npx skills
npx skills add <owner/repo> --skill nestjs-best-practices --agent opencode -y

# Agregar metadata (el agente edita el SKILL.md)
metadata:
  scope: [backend]
  auto_invoke:
    - "Writing NestJS modules"
    - "Creating API endpoints"
```

---

## FASE 4 — Ruteo

**Objetivo**: Actualizar AGENTS.md con las skills instaladas, manualmente.

### Cómo rutear (sin scripts externos)

Para cada skill instalada, el agente:

1. Lee su `SKILL.md` y extrae `metadata.scope` + `metadata.auto_invoke`.
   Si no tiene metadata, la propone según el componente instalado y la agrega.
2. Resuelve el AGENTS.md destino según el scope:
   `root` → `AGENTS.md` raíz; `frontend`/`backend`/`shared` → el AGENTS.md del
   componente (o el raíz si el proyecto no tiene jerarquía); scopes propios →
   `.agents/skill-scopes.json` si existe.
3. Agrega o actualiza la sección `### Auto-invoke Skills` con una fila por skill:
   trigger (de `auto_invoke`) + ruta de la skill. No duplicar filas existentes.

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
- [ ] Discovery ejecutado con `npx skills find` para queries por componente
- [ ] Candidatos deduplicados y auditados antes de instalar
- [ ] Usuario aprobó explícitamente la lista final
- [ ] Metadata agregada a cada skill (scope + auto_invoke)
- [ ] AGENTS.md actualizados con tablas Auto-invoke (sin duplicados)
- [ ] Scopes dinámicos detectados correctamente

### Problemas comunes

| Problema | Solución |
|----------|----------|
| Skill no aparece en AGENTS.md | Verificar que tenga metadata (scope + auto_invoke) y agregarla manualmente |
| Scope no detectado | Verificar que la carpeta exista y tenga manifiesto (package.json, etc.) |
| Duplicados en tabla | Limpiar filas duplicadas en el AGENTS.md |

### Comando de diagnóstico

```bash
# Ver skills instaladas sin metadata scope/auto_invoke
grep -L "scope:" .agents/skills/*/SKILL.md
```

---

## Casos de uso

### Caso 1: Proyecto nuevo con stack definido

```
Usuario: "hacé onboarding del proyecto"
Agente: escanea → detecta React + NestJS → busca con npx skills find → audita → pide aprobación → instala → rutea
```

### Caso 2: Proyecto existente sin skills

```
Usuario: "configurá skills para este proyecto"
Agente: escanea → detecta Django + PostgreSQL → busca skills globales → filtra riesgo → pide aprobación → instala → rutea
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
- **Filtro de seguridad**: Ver [references/security-filter.md](references/security-filter.md)
- **Script de detección**: Ver [assets/detect-stack.ps1](assets/detect-stack.ps1)
