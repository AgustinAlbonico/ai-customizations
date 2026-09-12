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

### `interactive-work` - Bugs y tareas con preguntas adaptativas

**Que hace:**
- Resuelve bugs Y tareas con un solo protocolo: preguntas adaptativas, confirmación corta, ejecución en un solo intento
- Modo BUG: diagnostica y corrige (UI, API, datos, infra) con fix mínimo
- Modo TAREA: aclara alcance IN/OUT y ejecuta (nuevo, cambio, refactor, config, mejora)
- La IA te pregunta lo que necesita (multiple choice o abiertas)

**Cuando usarlo:**
- Algo no funciona y no queres escribir un reporte detallado (`/bug`)
- Queres agregar/modificar/refactorizar sin escribir especificaciones (`/task`)
- Preferis que la IA te pregunte lo que necesita en vez de adivinar

**Como usarlo:**
```
/bug "el boton de logout no anda"
/task "agregar dark mode"
```

La IA clasifica el modo, hace hasta 4 preguntas, confirma el resumen/alcance y ejecuta.

---

### `feature-shaper` - Definidor de features (idea → PRD + Plan)

**Que hace:**
- Transforma ideas vagas en definiciones estructuradas mediante conversacion adaptativa (6 fases: contexto, alcance, funcional, casos borde, tecnico, review)
- Genera dos documentos en `docs/features/<slug>/`: `<slug>-prd.md` (negocio) y `<slug>-plan.md` (tecnico)
- Etapa intermedia ideal antes de OpenSpec/SDD

**Cuando usarlo:**
- Tenes una idea vaga ("quiero un...") y necesitas alcance, RF y edge cases bien definidos
- Queres un PRD de negocio + Plan tecnico listos para implementar

**Como usarlo:**
```
/shape "mi idea"   # Flow completo: PRD + Plan en docs/features/<slug>/
/prd "mi idea"      # Modo rápido: solo PRD de negocio en docs/prd/
```

**Modos:** `/shape` recorre las 6 fases y genera PRD + Plan técnico. `/prd` (absorbe al
viejo `prd-creator`) genera solo el PRD de negocio, con clasificación de complejidad
y banco de preguntas heredados (`references/question-bank.md`,
`references/prd-only-template.md`).

> Nota: la persistencia global `tools/feature-store/` (binario Go + MCP + TUI) descripta en `docs/plans/2026-03-04-feature-shaper-design.md` es roadmap y aun no esta implementada. El skill conversacional actual ya es usable sin ella.

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
/project-foundation "mi idea"         # arranca el pipeline
/project-foundation                    # reanuda desde el estado
/project-foundation status             # dashboard
/project-foundation install-pack       # instala pack curado de UX/UI y arquitectura
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
- Actualiza las tablas de ruteo de `AGENTS.md` según la metadata de cada skill

**Cuando usarlo:**
- Ya tenes un proyecto empezado y queres configurarlo para trabajar con IA
- Necesitas un setup reusable para repos con estructuras distintas
- Queres evitar mantener tablas de skills a mano

**Como usarlo:**
```text
"hace onboarding del proyecto"
"configura skills para este repo"
```

Manual completo: [`docs/project-onboarding.md`](docs/project-onboarding.md)

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

## Instalacion

### Opcion 1: Instalar skills individuales

```powershell
# Trabajo interactivo (bugs + tareas)
npx skills add AgustinAlbonico/ai-customizations --skill interactive-work --agent opencode -y

# Init Deep (AGENTS.md jerarquico)
npx skills add AgustinAlbonico/ai-customizations --skill agentmd-generator --agent opencode -y

# Project Starter
npx skills add AgustinAlbonico/ai-customizations --skill project-starter --agent opencode -y

# Project Foundation (pipeline completo; requiere project-starter y agentmd-generator)
npx skills add AgustinAlbonico/ai-customizations --skill project-foundation --agent opencode -y

# Feature Shaper (idea -> PRD + Plan)
npx skills add AgustinAlbonico/ai-customizations --skill feature-shaper --agent opencode -y

# Project Onboarding
npx skills add AgustinAlbonico/ai-customizations --skill project-onboarding --agent opencode -y

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
/prd "necesito un sistema de notificaciones"  # PRD de negocio (feature-shaper)
/agentmd                                      # Genera AGENTS.md jerarquico
/project-starter "descripcion"                # Bootstrap de proyecto nuevo
/project-foundation "mi idea"                  # Pipeline completo idea → SDD-ready
/shape "mi idea"                              # Define feature (PRD + Plan)
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

```bash
./scripts/bootstrap-project.sh /ruta/tu-proyecto
```

Copia `commands/*.md` a `.opencode/commands/` y `hooks/*.ps1` a `.opencode/hooks/` del proyecto destino.

## Validacion local

```powershell
npx skills add . --list
```

## Notas

- Cada skill debe tener `SKILL.md` con frontmatter YAML valido (`name` + `description`)
- Este repo guarda customizaciones de IA, no codigo de producto
