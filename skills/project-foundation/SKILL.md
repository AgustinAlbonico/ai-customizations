---
name: project-foundation
description: >
  Pipeline reutilizable que transforma una idea de software en un proyecto perfectamente
  definido y preparado para ejecutar features con SDD. Orquestador liviano con estado
  persistente (.project-foundation/state.yaml): recorre 12 fases (intake, research,
  producto, dominio, requisitos, casos de uso, UX/UI, system design, roadmap, auditoría,
  bootstrap técnico, setup de agentes) con dos gates de congelamiento, delegando el trabajo
  pesado a subagentes y cargando un único contrato de fase por vez. Su responsabilidad
  termina donde empieza el SDD de features.
  Trigger: "nuevo proyecto", "project foundation", "arrancar proyecto desde cero",
  "definir el producto", "preparar proyecto para SDD", "/project-foundation".
license: Apache-2.0
metadata:
  author: AgustinAlbonico
  version: "1.0"
  scope: [root]
  auto_invoke:
    - "Iniciar un proyecto de software desde cero"
    - "Definir producto, dominio y requisitos antes de implementar"
    - "Preparar un proyecto para desarrollo con SDD"
    - "Compilar el contexto de una feature del roadmap"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch, WebSearch, question, Task
---

# Protocolo project-foundation

Orquestador liviano de una pipeline de definición de proyecto. **Vos (el agente) sos solo el
coordinador**: mantenés estado, cargás UN contrato de fase a la vez, delegás el trabajo pesado
a subagentes, validás resultados y persistís el avance.

## Qué NO es este skill

- NO reimplementa Spec Driven Development. La responsabilidad termina donde empieza el SDD.
- NO hace trabajo pesado en esta ventana de contexto: eso va a subagentes (fase por fase).
- NO depende del historial conversacional: toda fase debe poder correr en una sesión nueva.

## Comandos

```text
/project-foundation "idea o descripción"   # arranca nuevo pipeline (fase 0)
/project-foundation                        # reanuda desde state.yaml
/project-foundation status                 # solo dashboard, no ejecuta nada
/project-foundation review <fase>          # reabre una fase completada (cascada stale)
/project-foundation feature FEAT-006       # compila feature brief → .scratch/feature-briefs/
/project-foundation install-pack           # instala pack curado de superpoderes (UX/UI, arquitectura, grill-me)
```

## Mapa del pipeline

| # | Fase (id) | Contrato | Depende de | Output principal |
|---|-----------|----------|------------|------------------|
| 00 | intake | [phases/00-intake.md](phases/00-intake.md) | — | state inicial + nivel |
| 01 | research | [phases/01-research.md](phases/01-research.md) | intake | docs/research/COMPETITIVE-ANALYSIS.md |
| 02 | product | [phases/02-product.md](phases/02-product.md) | research* | PROJECT.md |
| 03 | domain | [phases/03-domain.md](phases/03-domain.md) | product | docs/product/DOMAIN.md |
| 04 | requirements | [phases/04-requirements.md](phases/04-requirements.md) | product, domain | docs/product/REQUIREMENTS.md |
| 05 | use_cases | [phases/05-use-cases.md](phases/05-use-cases.md) | domain, requirements | docs/product/USE-CASE-MAP.md + use-cases/ |
| — | GATE | [phases/checkpoints/product-freeze.md](phases/checkpoints/product-freeze.md) | 00–05 | checkpoints.product_freeze |
| 06 | ux_ui | [phases/06-ux-ui.md](phases/06-ux-ui.md) | product_freeze | docs/product/UX-UI.md |
| 07 | system_design | [phases/07-system-design.md](phases/07-system-design.md) | product_freeze | docs/architecture/SYSTEM-DESIGN.md + adr/ |
| 08 | roadmap | [phases/08-roadmap.md](phases/08-roadmap.md) | requirements, use_cases, system_design | docs/product/ROADMAP.md |
| — | GATE | [phases/checkpoints/design-freeze.md](phases/checkpoints/design-freeze.md) | 06–08 | checkpoints.design_freeze |
| 09 | audit | [phases/09-audit.md](phases/09-audit.md) | design_freeze | docs/audit/FOUNDATION-AUDIT.md + TRACEABILITY.md |
| 10 | bootstrap | [phases/10-bootstrap.md](phases/10-bootstrap.md) | audit aprobado | estructura técnica inicial |
| 11 | agent_setup | [phases/11-agent-setup.md](phases/11-agent-setup.md) | bootstrap | AGENTS.md + routing |
| 12 | sdd_init | [phases/12-sdd-init.md](phases/12-sdd-init.md) | agent_setup | handoff a SDD |

\* research es condicional (`research_mode: needed|skipped`, decidido en intake).

## Perfiles de profundidad (decididos en intake, respetados por cada contrato)

| Nivel | research | UCs individuales | UX/UI | ADRs | Audit |
|-------|----------|------------------|-------|------|-------|
| prototype | skip (default) | solo flujo principal | mínimo (1 sección) | casi nunca | lite |
| mvp | corta | narrativos | estándar | solo decisiones caras | full |
| production | completa | narrativos + bordes | completa | regla de 3 condiciones | full |
| internal | skip (default) | narrativos | mínimo | solo decisiones caras | lite |

## Protocolo de ejecución (pasos fijos de cada fase)

1. Leer `.project-foundation/state.yaml`. Si no existe y hay args → fase 00. Si no existe y no
   hay args → explicar cómo arrancar. Si existe → continuar.
2. Verificar gates y dependencias de la fase destino (según el mapa). Si un gate no pasó,
   ejecutar su checkpoint antes de seguir.
3. Leer SOLO el contrato de la fase actual (`phases/NN-*.md`). No leer otros contratos.
4. Leer SOLO los inputs whitelisted que el contrato declara. Nunca leer el proyecto completo.
5. Ejecutar la fase según su contrato (entrevista, delegación o mixto).
6. Validar outputs contra las exit criteria del contrato. Si no pasan, no avanzar.
7. Actualizar `state.yaml` (status, outputs, summary, history) según
   [references/state-schema.md](references/state-schema.md).
8. Checkpoint corto al usuario (máx 10 líneas): qué se produjo, decisión clave, qué sigue.
9. Si el contexto acumulado es alto (entrevistas largas, varios subagentes), proponer cerrar
   la sesión y continuar en una nueva: el estado persiste y la fase siguiente arranca sola.

## Reglas de contexto (críticas)

1. El orquestador nunca lee todo el proyecto salvo necesidad explícita del contrato.
2. Cada fase declara sus inputs; los subagentes reciben SOLO esos inputs.
3. Los outputs extensos se escriben a archivos, nunca al chat.
4. Los subagentes devuelven solo un handoff YAML compacto (≤30 líneas).
5. Toda fase corre desde una sesión nueva: nunca asumir historial disponible.
6. Una información importante tiene una única fuente de verdad (el documento que la define).
7. No cargar documentos históricos si el contrato no los pide.

## Reglas de interacción

1. Usar la herramienta de preguntas interactiva del entorno si existe (`question`,
   `ask_user_question`); si no, opciones letradas. Nunca interrogatorio en texto plano.
2. Máximo 4 preguntas por ronda. Preguntas adaptativas, no un cuestionario fijo.
3. Filtro F1–F4 antes de cada pregunta: ligada al objetivo de la fase / no respondida /
   cambia una decisión real / no abre frentes laterales.
4. No preguntar lo que se puede inferir o delegar a exploración. Proponer defaults con
   justificación y pedir confirmación en lugar de inventar preguntas.
5. Si el usuario no responde algo no crítico: asumir el camino seguro, marcarlo `ASUMIDO`
   en el documento y seguir. Solo bloquear si la decisión es estructural.
6. Permitir volver atrás en cualquier momento (`review <fase>`).

## Delegación

- Los prompts de subagentes viven como data en [agents/](agents/) — se renderizan con los
  inputs whitelisted de la fase y el mapping por entorno está en
  [references/delegation-adapter.md](references/delegation-adapter.md).
- Contrato de handoff de todo subagente (≤30 líneas):

```yaml
phase: <fase>
status: completed | partial | failed
outputs: [rutas escritas]
summary: {métricas mínimas}
important_decisions: [máx 5, una línea c/u]
open_questions: [máx 5, solo las que bloquean]
```

- Un subagente NUNCA devuelve documentos enteros al orquestador: escribe su output a su
  archivo y devuelve este handoff.

## Inyección de Skills Potenciadoras (Pack Curado)

Para evitar la "regresión a la media" de la IA (interfaces genéricas, arquitecturas de tutorial),
`project-foundation` soporta inyección de skills de alta reputación (>100K installs):
- **UX/UI (Fase 06)**: `design-taste-frontend`, `impeccable`, `web-design-guidelines`.
- **Intake / Producto (Fases 00, 02)**: `grill-me` (interrogatorio socrático de Matt Pocock).
- **Arquitectura (Fase 07)**: `improve-codebase-architecture` (modularidad y boundaries).

Instalación automática:
1. Durante la **Fase 00**, el orquestador pregunta una sola vez si querés instalarlas en lote.
2. O ejecutando en cualquier momento `/project-foundation install-pack`.
3. O en **Fase 06 (JIT)**: si falta la skill de diseño, el orquestador la instala al vuelo con
   `npx -y skills add leonxlnx/taste-skill@design-taste-frontend -g -y`.
Detalles completos en [references/curated-skills-pack.md](references/curated-skills-pack.md).

## Gates, rework y cascada stale

- Los gates (`product_freeze`, `design_freeze`) son checklists del orquestador + confirmación
  del usuario. NO son inmutables: reabrir una fase marcada atrás del gate invalida hacia
  adelante (`stale: true` en cascada según el mapa de dependencias) y el usuario decide si
  re-ejecutar o re-validar las fases afectadas.
- El audit (fase 09) es la verificación independiente final. Sus hallazgos pueden reabrir
  fases específicas. Máximo 2 ciclos de re-audit; al tercero, decisión humana explícita
  (seguir con gaps documentados o reabrir).

## Preflight de skills hermanas (fases 10 y 11)

La fase 10 reusa `project-starter` (modo technical-only) y la 11 reusa `agentmd-generator`.
Antes de esas fases, verificar presencia en `.agents/skills/`, `skills/` o `~/.agents/skills/`.
Si falta, sugerir: `npx skills add AgustinAlbonico/ai-customizations --skill <skill> --agent <agente> -y`
y esperar a que el usuario instale. Nunca reimplementar su lógica.

## Estado y herramientas

- Esquema, reglas de escritura y semántica de stale: [references/state-schema.md](references/state-schema.md).
- Validador opcional: `assets/state-tool.sh` / `assets/state-tool.ps1` (`validate` | `integrity` | `show`).
  Usarlo tras cada escritura de estado si está disponible; si no, respetar el schema a mano.

## Cierre del pipeline

Al completar la fase 12, `project-foundation` se retira: las features se trabajan con el flujo
SDD del entorno (p. ej. Gentle AI: `sdd-explore → sdd-new → spec → design → tasks → apply → verify`),
alimentadas por `/project-foundation feature FEAT-XXX` (ver
[references/feature-intake.md](references/feature-intake.md)).
