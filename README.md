# ai-customizations

Infraestructura personal de IA: skills, agentes, hooks y comandos versionados en un solo repo, con instalacion reproducible y arquitectura agnostica de agente.

## Arquitectura

```text
skills/                     # skills instalables con npx skills (cross-agent)
commands/                   # comandos markdown reutilizables
hooks/                      # hooks reutilizables
scripts/                    # scripts de bootstrap/instalacion
```

## Skills disponibles

### `interactive-bug` - Debug interactivo

**Que hace:**
- Debug interactivo de bugs con preguntas adaptativas
- La IA te pregunta lo que necesita (multiple choice o abiertas)
- Arregla en un solo intento sin back-and-forth

**Cuando usarlo:**
- Encontraste un bug pero no queres escribir un reporte detallado
- Queres que la IA te guíe con preguntas específicas
- Necesitas arreglar algo rapido sin pensar en el contexto

**Como usarlo:**
```
/bug "descripcion corta del problema"
```

**Ejemplo:**
```
/bug "el boton de logout no anda"
```

La IA te va a preguntar:
- ¿Qué pasa exactamente cuando haces click?
- ¿Dónde está el botón?
- ¿Funcionaba antes?

Vos respondes (elegis opciones o escribis), y la IA investiga y arregla.

---

### `interactive-task` - Tareas interactivas

**Que hace:**
- Tareas interactivas (features, cambios, refactors) con preguntas adaptativas
- La IA identifica el tipo de tarea y hace las preguntas correctas
- Ejecuta correctamente en un solo intento

**Cuando usarlo:**
- Queres agregar/modificar/refactorizar algo
- No queres escribir especificaciones detalladas
- Preferis que la IA te pregunte lo que necesita

**Como usarlo:**
```
/task "descripcion de la tarea"
```

**Ejemplos:**
```
/task "agregar dark mode"
/task "refactorizar el componente de login"
/task "cambiar el orden de las columnas en la tabla"
```

La IA identifica si es NUEVO, CAMBIO, REFACTOR, CONFIG o MEJORA, y hace preguntas adaptadas.

---

### `prd-creator` - Generador de PRDs interactivo

**Que hace:**
- Genera Product Requirements Documents (PRDs) completos a partir de una conversacion interactiva
- Clasifica la complejidad del problema y adapta la cantidad de preguntas (0 a 20)
- Output orientado a problemas de negocio y requisitos (NO tecnico, sin stacks especificos)
- Guarda el PRD en `docs/prd/YYYY-MM-DD-<nombre>.md`

**Cuando usarlo:**
- Queres documentar requisitos antes de empezar a construir
- Tenes una idea o problema y queres un PRD estructurado
- Necesitas alinear equipo sobre que se va a construir y por que

**Como usarlo:**
```
/prd "descripcion del problema o idea"
```

**Ejemplo:**
```
/prd "necesito un sistema de notificaciones para mi app"
```

La IA explora el contexto del proyecto, te hace preguntas adaptativas segun la complejidad, y genera un PRD completo en `docs/prd/`.

---

### `project-starter` - Definicion tecnica y bootstrap de proyectos

**Que hace:**
- Guia interactiva para definir tecnica y funcionalmente un proyecto desde cero
- Recorre desde la vision del producto hasta el bootstrap de la estructura inicial
- Usa preguntas adaptativas organizadas en 6 fases progresivas
- Integra Context7 MCP para recomendar librerias y herramientas actualizadas
- Genera documento de decisiones tecnicas y estructura inicial del proyecto

**Cuando usarlo:**
- Queres arrancar un proyecto nuevo desde cero con criterio
- Necesitas definir stack tecnico con trade-offs claros
- Queres que la IA actue como arquitecto tecnico guiandote paso a paso
- Necesitas generar la estructura base respetando las decisiones tomadas

**Como usarlo:**
```
/project-starter "descripcion corta del proyecto"
```

**Ejemplos:**
```
/project-starter "SaaS de gestion de inventario para PyMEs"
/project-starter "API REST para sistema de reservas de hotel"
/project-starter "aplicacion mobile-first para delivery de comida"
```

**Flujo:**
1. Descubrimiento del proyecto (vision, usuarios, complejidad)
2. Arquitectura de alto nivel (monorepo/multirepo, patron, despliegue)
3. Stack principal (frameworks, DB, ORM, auth, testing) — con Context7
4. Implementacion detallada (UI, seguridad, logging, CI/CD) — con Context7
5. Generacion del documento de decisiones tecnicas
6. Bootstrap / inicializacion de la estructura del proyecto

La IA adapta la profundidad de preguntas segun la clasificacion: MVP (8-12 preguntas), producto interno (12-18), producto escalable (18-28).

---

### `project-foundation` - Pipeline idea → proyecto listo para SDD

**Que hace:**
- Orquestador liviano con estado persistente (`.project-foundation/state.yaml`)
- Recorre 12 fases: intake → research → producto → dominio → requisitos → use cases → UX/UI → system design → roadmap → auditoría → bootstrap → agent setup → sdd-init
- Dos gates de congelamiento (product freeze / design freeze)
- Carga UN contrato de fase por vez y delega el trabajo pesado a subagentes
- Reanudable en sesiones nuevas sin historial conversacional
- `/project-foundation feature FEAT-XXX` compila briefs del roadmap para iniciar SDD

**Cuando usarlo:**
- Queres arrancar un proyecto de software desde cero y dejarlo perfectamente definido
- Antes de empezar a implementar features con Gentle AI + SDD

**Como usarlo:**
```text
/project-foundation "mi idea"     # arranca el pipeline
/project-foundation                # reanuda desde el estado
/project-foundation status         # dashboard
/project-foundation feature FEAT-001  # brief para SDD
```

Requiere (fases 10-11): `project-starter` (modo technical-only) + `agentmd-generator`

---

### `project-onboarding` - Skills para proyectos existentes

**Que hace:**
- Escanea un proyecto existente y detecta stack, componentes y scopes reales
- Busca skills en skills.sh con `npx skills find` segun backend, frontend, shared, SDK o MCP
- Audita candidatos y bloquea señales peligrosas antes de instalar
- Muestra una lista final y espera aprobacion humana
- Instala skills localmente en `.agents/skills/` con `npx skills add`
- Ejecuta `skill-sync` para mantener `AGENTS.md` actualizado

**Cuando usarlo:**
- Ya tenes un proyecto empezado y queres configurarlo para trabajar con IA
- Necesitas un setup reusable para repos con estructuras distintas
- Queres evitar mantener tablas de skills a mano

**Como usarlo:**
```text
"hace onboarding del proyecto"
"configura skills para este repo"
```

Manual completo: [`docs/project-onboarding-skill-sync.md`](docs/project-onboarding-skill-sync.md)

---

### `agentmd-generator` - Generador de AGENTS.md jerarquico

**Que hace:**
- Analiza la estructura del repositorio (simple, monorepo, multi-proyecto)
- Detecta stack, frameworks, fronteras naturales entre componentes
- Hace preguntas adaptativas (multiple choice con opcion libre) para entender necesidades
- Busca y reutiliza skills existentes antes de proponer nuevos
- Genera AGENTS.md raiz + locales optimizados para consumo minimo de contexto

**Cuando usarlo:**
- Estas configurando un proyecto nuevo para desarrollo con IA
- Tu AGENTS.md crecio demasiado y necesita reestructurarse
- Tenes un monorepo que necesita contexto separado por componente
- Queres que cada sesion de IA cargue solo el contexto que necesita

**Como usarlo:**
```
/agentmd
```

---

### `sonarqube-quality-gate-playbook` - SonarQube

Playbook iterativo para llevar proyectos Node y TypeScript (NestJS + React en monorepo) a cumplir Quality Gates de SonarQube.

---

### `playwright-spec-verifier` - Verificacion visual de specs

**Que hace:**
- Lee un spec funcional y lo prueba con Playwright MCP contra el frontend.
- Verifica flujo feliz, alternativos, network requests, consola y snapshots.
- Documenta automaticamente errores en `iteracion 1/errores/<spec>.md`.

**Cuando usarlo:**
- Queres probar un archivo de iteracion contra el sistema real.
- Necesitas comparar spec vs comportamiento visible sin revisar codigo.
- Queres dejar un reporte reusable de errores funcionales y UI/UX.

**Como usarlo:**
```text
/verificar-spec 01-registrar-nutricionista.md
```

---

### `skill-sync` - Auto-sync de AGENTS.md

**Que hace:**
- Mantiene las tablas de Skill Routing en AGENTS.md actualizadas automaticamente
- Lee todos los `SKILL.md` y extrae `metadata.scope` + `metadata.auto_invoke`
- Genera las secciones `### Auto-invoke Skills` sin intervencion manual
- Inspirado en el sistema de Prowler Cloud

**Cuando usarlo:**
- Agreaste un skill nuevo y queres que aparezca en AGENTS.md
- Modificaste el `metadata.auto_invoke` de un skill
- Queres regenerar todas las tablas de routing

**Como usarlo:**
```powershell
# Windows
.\skills\skill-sync\assets\sync.ps1

# macOS/Linux
./skills/skill-sync/assets/sync.sh

# Preview sin modificar
.\skills\skill-sync\assets\sync.ps1 -DryRun
```

**Como funciona:**

1. Cada skill tiene metadata en su `SKILL.md`:
```yaml
metadata:
  scope: [root]
  auto_invoke:
    - "Creating API endpoints"
    - "Adding database queries"
```

2. El script escanea todos los skills y genera las tablas automaticamente

3. Se crea/actualiza la seccion `### Auto-invoke Skills` en los AGENTS.md correspondientes

**Scopes disponibles:**

| Scope | Actualiza |
|-------|-----------|
| `root` | `AGENTS.md` (raiz del repo) |
| `frontend` | `frontend`, `web`, `client`, `apps/frontend`, `apps/web`, `apps/client` |
| `backend` | `backend`, `api`, `server`, `apps/backend`, `apps/api`, `apps/server` |
| `shared` | `packages/shared`, `shared`, `common`, `packages/common` |
| custom | Directorio definido en `.agents/skill-scopes.json` |

**Instalacion:**
```powershell
npx skills add AgustinAlbonico/ai-customizations --skill skill-sync --agent opencode -y
```

---

## Instalacion

### Opcion 1: Instalar skills individuales

```powershell
# Bug interactivo
npx skills add AgustinAlbonico/ai-customizations --skill interactive-bug --agent opencode -y

# Task interactivo
npx skills add AgustinAlbonico/ai-customizations --skill interactive-task --agent opencode -y

# PRD Creator
npx skills add AgustinAlbonico/ai-customizations --skill prd-creator --agent opencode -y

# Init Deep (AGENTS.md jerarquico)
npx skills add AgustinAlbonico/ai-customizations --skill agentmd-generator --agent opencode -y

# Project Starter
npx skills add AgustinAlbonico/ai-customizations --skill project-starter --agent opencode -y

# Project Foundation (pipeline completo; requiere project-starter y agentmd-generator)
npx skills add AgustinAlbonico/ai-customizations --skill project-foundation --agent opencode -y

# Skill Sync
npx skills add AgustinAlbonico/ai-customizations --skill skill-sync --agent opencode -y

# Project Onboarding
npx skills add AgustinAlbonico/ai-customizations --skill project-onboarding --agent opencode -y

# Playwright Spec Verifier
npx skills add AgustinAlbonico/ai-customizations --skill playwright-spec-verifier --agent opencode -y
```

### Opcion 2: Instalar todas las skills

```powershell
# Para un agente especifico
npx skills add AgustinAlbonico/ai-customizations --skill '*' --agent opencode -y

# Para multiples agentes
npx skills add AgustinAlbonico/ai-customizations --skill '*' --agent opencode --agent claude-code -y

# Para todos los agentes detectados
npx skills add AgustinAlbonico/ai-customizations --all
```

### Opcion 3: Listar skills disponibles

```powershell
npx skills add AgustinAlbonico/ai-customizations --list
```

### Agentes soportados

`opencode`, `codex`, `claude-code`, `cursor`, `antigravity`

## Uso rapido

Despues de instalar, usa los comandos:

```text
/bug "el carrito no actualiza el total"
/task "agregar dark mode"
/prd "necesito un sistema de notificaciones"  # Genera un PRD interactivo
/agentmd                                      # Genera AGENTS.md jerarquico
/project-starter "descripcion"                # Bootstrap de proyecto nuevo
/project-foundation "mi idea"                  # Pipeline completo idea → SDD-ready
/verificar-spec 01-registrar-nutricionista.md # Prueba un spec y documenta errores
```

La IA va a hacerte preguntas interactivas con opciones multiple choice o abiertas según lo que necesite saber.

## Script de instalacion agnostico

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-skills.ps1 -Source AgustinAlbonico/ai-customizations -Agents opencode,codex,claude-code
```

Para instalar todas las skills de todos los agentes en modo global:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-skills.ps1 -Source AgustinAlbonico/ai-customizations -AllAgents -GlobalSkills
```

## Bootstrap opcional de proyecto

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-project.ps1 -ProjectPath "C:\ruta\tu-proyecto"
```

## Validacion local

```powershell
npx skills add . --list
```

## Notas

- Cada skill debe tener `SKILL.md` con frontmatter YAML valido (`name` + `description`)
- Este repo guarda customizaciones de IA, no codigo de producto
