---
id: intake
num: 00
deps: []
outputs: [".project-foundation/state.yaml", ".project-foundation/INTAKE.md"]
---

# Fase 00 — Intake

## Objetivo

Entender QUÉ se quiere construir, para quién y en qué nivel, sin profundizar en implementación.
Producir el estado inicial del pipeline y la captura cruda que alimenta a la fase product.

## Inputs permitidos

- Idea/descripción del usuario (argumento del comando).
- `README.md` y manifiestos (`package.json`, etc.) SOLO si ya existen, para detectar contexto.

## Prohibido

- Explorar codebases de otros proyectos.
- Preguntas de stack, tecnologías o arquitectura (eso es fases 07/10).
- Investigación competitiva (eso es fase 01).

## Proceso

1. Detectar modo: greenfield limpio vs repo con algo encima. Si hay archivos de proyecto,
   preguntar si se parte de cero o se respeta lo existente.
2. Ronda 1 (máx 4 preguntas, filtro F1–F4):
   - ¿Cuál es el problema principal a resolver? (abierta, si la idea es vaga)
   - ¿Quiénes son los primeros usuarios? (opciones + abierta)
   - ¿Qué tipo de sistema es? (app web / mobile / API / CLI / interno / e-commerce / SaaS / ...)
   - ¿Restricciones conocidas? (deadline, presupuesto, equipo, compliance) — solo si el usuario no las mencionó
3. Ronda 2 (máx 2 preguntas):
   - Proponer nivel esperado (prototype / mvp / production / internal) con justificación
     basada en las respuestas y pedir confirmación.
   - Si es relevante: "¿querés investigación de mercado/competencia?" → `research_mode`.
     Defaults por tipo: consumer/competitivo → needed; interno/herramienta propia → skipped.
4. Derivar `audit_depth` del nivel: prototype/internal → lite; mvp/production → full.
5. Confirmar en un checkpoint de 5 líneas (modo, problema, usuarios, nivel, research).
6. Escribir `.project-foundation/INTAKE.md` (captura cruda, no documento pulido):

```markdown
# Intake — <slug>
- Problema principal: ...
- Usuarios iniciales: ...
- Tipo de sistema: ...
- Contexto/plataformas: ...
- Restricciones: ... | ninguna declarada
- Nivel: <nivel> (razón breve)
- Research: needed|skipped (razón breve)
- Supuestos marcados ASUMIDO: [lista o ninguno]
- Open questions no bloqueantes: [lista o ninguno]
```

7. Inicializar `state.yaml` con la semilla de [../../references/state-schema.md](../../references/state-schema.md),
   completando slug/level/research_mode/audit_depth. Marcar intake `completed` con summary
   `{level, kind, research}` y `current_phase: research|product`.

## Exit criteria

- state.yaml existe, valida contra el schema y refleja las decisiones del intake.
- INTAKE.md tiene problema + usuarios + nivel definidos (ASUMIDO permitido y marcado).
- El usuario confirmó el checkpoint.

## Handoff → state.yaml

```yaml
phases.intake:
  status: completed
  outputs: [".project-foundation/INTAKE.md"]
  summary: {level: mvp, kind: saas, research: needed}
history += {event: "intake completed"}
```
