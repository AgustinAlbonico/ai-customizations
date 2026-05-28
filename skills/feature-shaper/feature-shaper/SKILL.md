---
name: feature-shaper
description: >
  Transforma ideas vagas en definiciones estructuradas de features mediante conversación adaptativa.
  Usa 6 fases (contexto, alcance, funcional, casos borde, técnico, review) para convertir una idea
  en un PRD de negocio y un Plan técnico con arquitectura. Genera dos documentos: <slug>-prd.md y
  <slug>-plan.md. El caso de uso es "quiero un..." o "/shape mi idea".
---

# Skill: feature-shaper

Transforma ideas vagas en definiciones estructuradas de features.

## Trigger

`/shape "mi idea"` — Inicia el flujo de descubrimiento conversacional.

## Output

Dos documentos en `docs/features/<slug>/`:

- `<slug>-prd.md` — Requerimientos de negocio (PRD)
- `<slug>-plan.md` — Plan técnico con arquitectura

Slug: `YYYY-MM-DD-HH-MM-SS-slug-normalizado`

---

## Flujo de 6 fases

```
┌─────────────────────────────────────────────────────────────┐
│ FASE 1: CONTEXTO (breve - 2 preguntas)                     │
│ ¿Qué problema resuelve? ¿A quién le sirve?                 │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ FASE 2: ALCANCE (breve - 2 preguntas)                      │
│ ¿Qué está dentro? ¿Qué está fuera?                         │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ FASE 3: FUNCIONAL (IMPORTANTE - varias preguntas)          │
│ RF detallados, flujos, pantallas, roles                      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ FASE 4: CASOS BORDE (MUY IMPORTANTE - varias preguntas)   │
│ ¿Qué pasa si X falla? ¿Y si Y en medio del flujo?         │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ FASE 5: TÉCNICO (subagente + preguntas ciblées)           │
│ Explora codebase → preguntas técnicas basadas en findings   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ FASE 6: REVIEW (resumen ejecutivo + confirmación)          │
│ Genera los documentos .md                                  │
└─────────────────────────────────────────────────────────────┘
```

**Flujo es adaptativo**: si en Fase 3 surge un edge case, ir a Fase 4 y volver. No строго orden.

---

## Reglas de conversación

1. **Una pregunta a la vez** — nunca múltiples en un mismo mensaje
2. **Opción múltiple cuando sea posible** — facilita respuesta rápida
3. **Fase 3 y 4 son priority** — invertir tiempo ahí
4. **Fase 5 delega subagente** para explorar codebase
5. **Fase 6 resume** — nadie quiere leer 50 páginas en la review
6. **Sub-preguntas siempre bienvenidas** — si algo suma contexto, preguntar
7. **Graceful degradation** — si no hay respuesta, asumir camino seguro y documentar como "ASUMIDO"

---

## Detalle por fase

### Fase 1 — Contexto (breve)

**Objetivo:** Entender el problema y para quién.

**Preguntas:**
1. "¿Qué problema concreto resuelve esta feature?"
   - Opciones: paneles distintos por rol / permisos diferenciados / control de acceso / otro
2. "¿A quién le sirve principalmente?"
   - Opciones: Socio / Nutricionista / Admin / Mixto / Otro

**Respuesta esperada:** 1-2 oraciones.

---

### Fase 2 — Alcance (breve)

**Objetivo:** Definir qué entra y qué NO entra.

**Preguntas:**
1. "¿Qué funcionalidades específicas tiene esta feature?"
   - Respuesta abierta: 1-3 oraciones
2. "¿Qué cosas parecen que deberían estar pero NO están en esta versión?"
   - Opciones: recuperación de contraseña / multi-sesión / 2FA / otro / nada
3. "¿Hay algo que otro módulo necesita y todavía no existe?"
   - Opciones: sí (describir) / no

---

### Fase 3 — Funcional (IMPORTANTE)

**Objetivo:** Detallar todos los RF, flujos, pantallas, roles.

**Estructura por RF:**
```
RF-01: [Nombre]
- Descripción: [...]
- Actor: [...]
- Datos requeridos: [...]
- Comportamiento: 1) paso 1 → 2) paso 2 → ...
- Validaciones: [...]
- Errores: [...]
- Estados: [si aplica]
```

**Inventario:**
- ¿Cuántos roles hay y qué puede hacer cada uno?
- ¿Qué pantallas/vistas necesita la feature?
- ¿Qué operaciones CRUD hay?
- ¿Qué integraciones externas se necesitan?
- ¿Hay estados que transicionan?
- ¿Se notifica a alguien de algo?

**Técnica:** Si el usuario dice algo vago como "un panel de admin", insistir hasta que detalle qué puede hacer el admin ahí.

---

### Fase 4 — Casos Borde (MUY IMPORTANTE)

**Objetivo:** Descubrir escenarios que romperían la feature.

**Patrones de preguntas:**

| Categoría | Pregunta |
|-----------|----------|
| Error | "¿Qué pasa si falla [X]?" / "¿Y si [X] timeout?" |
| Límite | "¿Y si no hay ningún registro?" / "¿Y si hay 10.000?" |
| Permisos | "¿Y si el usuario no tiene permisos?" / "¿Y si accede a URL de otro rol?" |
| Navegación | "¿Y si hace click rápido 5 veces?" / "¿Y si cierra el tab en medio?" |
| Concurrencia | "¿Y si dos admins editan lo mismo al mismo tiempo?" |
| Integridad | "¿Y si se pierde conexión a mitad del envío?" / "¿Y si los datos vienen corruptos?" |
| Degradación | "¿Y si el servicio externo está caído?" / "¿Y si la DB no responde?" |

**Técnica de layering:** Cuando el usuario responde un edge case, preguntar:
"¿Y si eso ocurre DENTRO del paso 3 del flujo?" → crea árbol de edge cases.

**Regla:** Si el usuario no tiene respuesta, asumir camino seguro y documentar como "ASUMIDO: si [X] ocurre, se [Y]".

---

### Fase 5 — Técnico

**Paso 1:** Invocar subagente para explorar codebase

```
task {
  subagent_type: "sdd-design",
  prompt: "Explora el codebase actual en apps/backend/src/ y apps/frontend/src/. 
Identifica:
1. Stack tecnológico exacto (versiones, librerías)
2. Patrones de arquitectura (Clean Architecture, hexagonal, capas)
3. Convenciones de código (nombres, imports, estructura)
4. Módulos backend existentes y cómo se organizan
5. APIs REST existentes (formato, auth)
6. Modelo de datos (TypeORM/Prisma, entidades principales)
7. Integraciones externas (Redis, BullMQ, Socket.IO, etc.)
8. Shared package (@nutrifit/shared)
9. Frontend: store (Zustand/Redux?), API layer (RTK Query?), routing
10. Cualquier cosa relevante para diseñar un módulo de auth/login

Return resumen estructurado con suficiente detalle para tomar decisiones técnicas."
}
```

**Paso 2:** Con el output del subagente, hacer PREGUNTAS TÉCNICAS al usuario:
- "¿Confirmamos el stack existente o hay variante?"
- "¿El backend ya tiene módulo de auth o se crea de cero?"
- "¿Hay preferencia por JWT vs sesiones?"
- "¿Los portales son subdominios, carpetas, o qué?"
- "¿Modelo de datos: qué entidades principales?"
- "¿Orden de implementación sugerido?"

**No preguntar lo que ya respondió el subagente.** Llenar gaps.

---

### Fase 6 — Review

**Objetivo:** Mostrar resumen executivo y pedir confirmación para generar docs.

**Formato del resumen (NO dump):**

```
## Resumen: [Nombre de Feature]

### Problema que resuelve
[1-3 oraciones]

### Alcance
- Dentro: [lista breve]
- Fuera: [lista breve]

### RF principales
| # | Requerimiento | Actor |
|---|---------------|-------|
| RF-01 | [Nombre] | [Actor] |
| RF-02 | [Nombre] | [Actor] |

### Edge cases manejados
| Edge case | Comportamiento |
|-----------|---------------|
| [condición] | [qué pasa] |

### Stack y arquitectura
- Backend: [stack confirmado]
- Frontend: [stack confirmado]
- DB: [modelo de datos]
- Externos: [integraciones]

### Fases de implementación
1. [Fase 1]
2. [Fase 2]
3. [Fase 3]

### Archivos a crear / modificar
- Crear: [lista]
- Modificar: [lista]

---
¿Procedemos a generar los documentos?
```

**Si confirma:**
1. Crear directorio `docs/features/<slug>/`
2. Generar `<slug>-prd.md` usando `templates/prd-template.md`
3. Generar `<slug>-plan.md` usando `templates/plan-template.md`
4. Mostrar confirmación con paths

**Si pide ajustes:** hacer solo los cambios solicitados, no regenerar todo.

---

## Templates

- `phases/1-context.ts` — guía de preguntas Fase 1
- `phases/2-scope.ts` — guía de preguntas Fase 2
- `phases/3-functional.ts` — guía de preguntas Fase 3
- `phases/4-edge-cases.ts` — guía de preguntas Fase 4
- `phases/5-technical.ts` — guía preguntas técnicas + subagente
- `phases/6-review.ts` — formato del resumen
- `templates/prd-template.md` — estructura del PRD
- `templates/plan-template.md` — estructura del Plan técnico

---

## Reglas de output

- PRD: `docs/features/<slug>/<slug>-prd.md`
- Plan: `docs/features/<slug>/<slug>-plan.md`
- Se generan al final de Fase 6, luego de confirmación del usuario
- Cambios post-review: ajustar solo lo afectado, no regenerar todo