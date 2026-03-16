---
name: prd-creator
description: >
  Genera Product Requirements Documents (PRDs) completos a partir de una conversación interactiva
  con el usuario. Usa preguntas adaptativas con la herramienta `question` para entender el problema,
  clasificar su complejidad, y recopilar requisitos de negocio. El output es un .md orientado a
  problemas de negocio y requisitos (NO técnico). Usar cuando el usuario quiere crear un PRD,
  documentar requisitos de producto, definir un problema a resolver, o dice "quiero un PRD",
  "documentar requisitos", "definir qué vamos a construir".
---

# Protocolo prd-creator

## Flujo general

```
FASE 0: Detección de modo + Exploración profunda del contexto
    ↓ mapa de alcance inicial (in-scope, out-of-scope, supuestos)
FASE 1: Recepción del Problema
    ↓ clasificación de complejidad
FASE 2: Entrevista Adaptativa (preguntas con `question` tool)
    ↓ checkpoint — usuario confirma que se entendió bien
FASE 3: Generación del PRD
    ↓ checkpoint — usuario aprueba el .md
FASE 4: Persistencia
```

---

## FASE 0 — Exploración del Contexto del Proyecto (obligatoria)

**Objetivo**: Entender el estado real del sistema ANTES de preguntar, para no abrir frentes irrelevantes.

### 0.1 Detectar modo del proyecto

El agente (silenciosamente, sin preguntar) clasifica primero:

- **Sistema existente**: hay codebase funcional (módulos, flujos, entidades, rutas, casos de uso, etc.).
- **Greenfield**: no hay producto implementado todavía (solo docs, idea, o scaffold mínimo).

Si hay duda, asumir **sistema existente** y explorar igual.

### 0.2 Exploración profunda (si es sistema existente)

El agente DEBE explorar TODO el codebase relevante (no solo README):

1. Recorrer la estructura de carpetas completa, excluyendo ruido (`node_modules`, `dist`, `build`, `.git`, etc.).
2. Identificar módulos de negocio y superficies funcionales existentes.
3. Leer puntos de entrada y orquestación (rutas/controladores/use-cases/servicios equivalentes según stack).
4. Localizar dónde impacta el pedido del usuario (módulos, flujo actual, datos y reglas involucradas).
5. Armar un **mapa delta** interno:
   - Qué existe hoy.
   - Qué debería cambiar con el pedido.
   - Qué explícitamente NO está en alcance.
6. Buscar `docs/prd/` para ver PRDs existentes y entender estilo.

### 0.3 Exploración mínima (si es greenfield)

Si no hay sistema existente, hacer la exploración base:

1. Leer `README.md` (si existe) para entender dominio.
2. Leer manifiestos (`package.json`, `go.mod`, `pyproject.toml`, `Cargo.toml`) si existen.
3. Buscar `docs/prd/` para reutilizar estilo si ya hay documentos.

**IMPORTANTE**: Este contexto es interno. El PRD de salida sigue siendo de negocio y requisitos (sin stack técnico).

Luego mostrar un resumen breve y enfocado:

```
Entendí el contexto del proyecto:
- Modo: [sistema existente | greenfield]
- Alcance inicial detectado para este pedido: [módulo/flujo concreto]
- Fuera de foco (no voy a preguntar sobre esto salvo que lo pidas): [lista breve]
- PRDs existentes: [lista o "ninguno"]

[Si todavía no hay problema definido]
Contame: ¿qué problema querés resolver o qué necesitás construir?
```

Si el usuario ya proporcionó el problema en su mensaje inicial, saltar directamente a FASE 1.

---

## FASE 1 — Recepción del Problema y Clasificación

**Objetivo**: Recibir el input del usuario y clasificar la complejidad para determinar cuántas preguntas hacer.

**Regla clave**: clasificar la complejidad sobre el alcance del pedido (delta), NO sobre todo el sistema.

### Clasificación de complejidad

Basándose en el input del usuario, clasificar:

| Complejidad | Señales | Rondas de preguntas | Total preguntas aprox |
|-------------|---------|---------------------|-----------------------|
| **simple** | Cambio puntual en un flujo/módulo concreto, alcance claro | 0-1 rondas | 0-4 |
| **media** | Feature o mejora que toca varios casos del mismo dominio | 1-2 rondas | 4-8 |
| **alta** | Cambio transversal en múltiples flujos/roles con reglas complejas | 2-3 rondas | 8-15 |
| **muy alta** | Cambio transversal con múltiples módulos, dependencias externas o compliance | 3-4 rondas | 15-20 |

**Si el usuario ya dio suficiente contexto** (descripción detallada >150 palabras con problema claro, usuarios, alcance): reducir preguntas a solo lo que falta clarificar.

**Si el input es vago** (<30 palabras): empezar con preguntas amplias de descubrimiento.

Antes de entrar a la entrevista, construir internamente un **brief de foco**:

- Pedido del usuario en una oración.
- Qué parte del sistema toca.
- Qué parte NO toca (out-of-scope).
- Qué información falta para redactar el PRD sin inventar.

Mostrar clasificación al usuario:

```
Clasifiqué tu solicitud como complejidad [X] para este alcance específico.
Voy a hacerte [N] preguntas enfocadas solo en este pedido.
```

---

## FASE 2 — Entrevista Adaptativa

**Objetivo**: Recopilar toda la información de negocio necesaria para el PRD.

### Reglas absolutas

1. **SIEMPRE usar la herramienta `question`** — nunca preguntas en texto plano
2. **Máximo 4 preguntas por ronda** — nunca más
3. **Mezclar preguntas con opciones y abiertas** según el tipo de información necesaria
4. La herramienta `question` agrega "Type your own answer" automáticamente
5. Si una respuesta anterior ya cubre una pregunta → saltarla
6. Si una respuesta genera nueva ambigüedad → agregarla a la siguiente ronda
7. **NUNCA preguntar sobre stack técnico, tecnologías, o implementación** — el PRD es de negocio
8. Cada pregunta debe cerrar un gap del **brief de foco**
9. Si una pregunta no cambia alcance/requisitos/criterios de éxito, eliminarla
10. En sistemas existentes, formular preguntas en modo **delta** (estado actual vs cambio pedido)
11. No abrir módulos u objetivos no pedidos por el usuario
12. Preguntas amplias de descubrimiento solo si el input es realmente vago y el contexto no alcanza

### Filtro de relevancia (obligatorio antes de cada ronda)

Cada pregunta candidata debe pasar todos estos checks:

| Check | Pregunta de control |
|-------|---------------------|
| **F1** | ¿Está directamente ligada al pedido del usuario? |
| **F2** | ¿No fue respondida ya por el usuario o por la exploración del codebase? |
| **F3** | ¿Su respuesta cambia una decisión real del PRD (alcance, requisito o criterio de éxito)? |
| **F4** | ¿Está redactada en términos de negocio del flujo específico, sin abrir temas laterales? |

Si falla cualquier check, **NO se pregunta**.

### Estructura de rondas

El banco de preguntas completo está en [references/question-bank.md](references/question-bank.md). Consultar ese archivo para elegir las preguntas adecuadas según la complejidad y el tipo de problema.

**Resumen de la estructura**:

```
Ronda 1 → Alineación de alcance + gaps críticos del pedido
           máx 4 preguntas, priorizar preguntas específicas del flujo afectado
           (usar preguntas amplias solo si el input es muy vago)

Ronda 2 → Flujos y Comportamiento + Criterios de Éxito
            máx 4 preguntas, adaptadas a respuestas de Ronda 1
            (solo si complejidad >= media)

Ronda 3 → Edge Cases + Priorización
           máx 4 preguntas del MISMO alcance definido
           (solo si complejidad >= alta)

Ronda 4 → Restricciones de Negocio + Métricas de Impacto
           máx 4 preguntas solo sobre el alcance definido
           (solo si complejidad = muy alta)
```

### Al final de cada ronda (excepto la última)

```
Hasta ahora entiendo:
- [bullet resumen]
- [bullet resumen]
- [bullet resumen]

¿Hay algo incorrecto o querés agregar algo antes de continuar?
```

### Checkpoint final de la entrevista

Después de la última ronda, presentar un resumen completo:

```
Resumen de lo que entendí:

**Problema**: [resumen en 1-2 oraciones]
**Usuarios**: [quiénes]
**Alcance**: [qué incluye y qué no]
**Flujos principales**: [resumen]
**Criterios de éxito**: [resumen]

¿Está completo? ¿Falta algo importante antes de generar el PRD?
```

El usuario confirma o hace correcciones.

---

## FASE 3 — Generación del PRD

**Objetivo**: Generar el documento .md completo orientado a negocio.

Usar el template definido en [references/prd-template.md](references/prd-template.md).

### Reglas de generación

| Sección | Regla |
|---------|-------|
| **Problema** | Máx 2 párrafos. Lenguaje de negocio, cero jerga técnica. |
| **Usuarios** | Describir personas con pain points reales, no perfiles genéricos. |
| **Objetivos** | Medibles cuando sea posible. Usar métricas de negocio, no técnicas. |
| **Alcance — fuera de alcance** | Obligatorio con al menos 2 items fuera de alcance. Si el usuario no los mencionó, el agente los propone. |
| **Requisitos funcionales** | Priorizados P0/P1/P2. Cada uno con criterio de aceptación. |
| **Requisitos no funcionales** | Solo si surgieron en la entrevista. Expresados en términos de negocio ("el usuario no debe esperar más de 2 segundos") no técnicos ("latencia < 200ms"). |
| **Flujos** | Solo los que surgieron en la entrevista. Omitir sección si no aplica. |
| **Criterios de éxito** | Formato Gherkin simplificado (Dado/Cuando/Entonces). Siempre se genera — el agente los deriva de los flujos si el usuario no los mencionó. |
| **Riesgos** | Solo si la complejidad es alta o muy alta. |
| **Preguntas abiertas** | Cualquier decisión pendiente o ambigüedad detectada durante la entrevista. |

### Presentación al usuario

Mostrar el PRD completo y preguntar:

```
¿Aprobás este PRD para guardarlo?
Podés pedirme ajustes antes de confirmar.
```

El usuario puede pedir ajustes. El agente los incorpora y vuelve a presentar.

**Checkpoint**: El usuario aprueba el PRD.

---

## FASE 4 — Persistencia

**Objetivo**: Guardar el PRD como archivo .md en el repositorio.

1. Crear el directorio `docs/prd/` si no existe
2. Generar nombre de archivo: `YYYY-MM-DD-<nombre-kebab-case>.md`
   - La fecha es la fecha actual
   - El nombre se deriva del título del PRD en kebab-case
   - Ejemplo: `2026-03-06-sistema-de-notificaciones.md`
3. Escribir el archivo
4. Mostrar confirmación:

```
PRD guardado: docs/prd/YYYY-MM-DD-nombre-del-prd.md

¿Necesitás algo más con este PRD?
```

---

## Ejemplos de uso

### Ejemplo 1: Solicitud simple

Usuario: `"quiero agregar notificaciones por email cuando un pedido cambia de estado"`

→ Complejidad: **simple** (scope claro, un flujo principal)
→ 1 ronda de 3-4 preguntas

```
Pregunta 1: "¿Qué cambios de estado deben disparar la notificación?"
- Todos los cambios
- Solo cambios críticos (cancelado, entregado, devuelto)
- Solo cuando pasa a "enviado" y "entregado"

Pregunta 2: "¿Quién recibe las notificaciones?"
- Solo el cliente que hizo el pedido
- El cliente + el vendedor
- Configurable por el usuario

Pregunta 3: "¿El usuario puede desactivar las notificaciones?"
- Sí, debe poder elegir cuáles recibir
- Sí, todo o nada
- No, siempre se envían
```

### Ejemplo 2: Solicitud compleja

Usuario: `"necesito un sistema de gestión de inventario para nuestros 3 almacenes"`

→ Complejidad: **alta** (múltiples ubicaciones, múltiples actores, reglas de negocio)
→ 3 rondas de 3-4 preguntas cada una

Ronda 1: Problema y contexto
```
Pregunta 1: "¿Cómo gestionan el inventario hoy?"
- Planillas de Excel
- Sistema actual que quieren reemplazar
- No hay sistema, todo manual/verbal

Pregunta 2: "¿Quiénes van a usar el sistema?"
- Solo encargados de almacén
- Encargados + vendedores + gerencia
- Todo el equipo

Pregunta 3: "¿Qué es lo más urgente o doloroso del proceso actual?"
[ABIERTA - que describa el pain point principal]

Pregunta 4: "¿Los 3 almacenes manejan los mismos productos o son independientes?"
- Mismos productos, stock compartido
- Productos distintos por almacén
- Mix: algunos compartidos, otros exclusivos
```

### Ejemplo 3: Solicitud vaga

Usuario: `"quiero mejorar cómo manejamos los clientes"`

→ Complejidad: **no determinada** — necesita preguntas amplias de descubrimiento

```
Pregunta 1: "¿Qué aspecto del manejo de clientes querés mejorar?"
- Seguimiento de conversaciones/contactos
- Gestión de ventas/oportunidades
- Soporte post-venta
- Registro y datos de clientes
- Todo lo anterior

Pregunta 2: "¿Cuál es el problema principal que tenés hoy?"
[ABIERTA - que describa su dolor]

Pregunta 3: "¿Cuántas personas van a usar esto?"
- Solo yo
- Un equipo pequeño (2-5 personas)
- Un equipo mediano (5-20 personas)
- Toda la organización (20+)
```

---

## Reglas CRÍTICAS

1. **SIEMPRE usar herramienta `question`** — nunca preguntas en texto plano
2. **Máximo 4 preguntas por ronda**
3. **FASE 0 es obligatoria** — detectar modo y explorar contexto antes de preguntar
4. **Si es sistema existente, explorar TODO el codebase relevante** antes de iniciar entrevista
5. **Cada pregunta debe estar atada al pedido del usuario** (brief de foco + filtro F1-F4)
6. **Preguntas amplias solo en input muy vago** — evitar amplitud innecesaria
7. **El PRD es de NEGOCIO** — nunca mencionar stack técnico, lenguajes, frameworks, bases de datos, APIs en el output
8. **Derivar lo que falta** — si el usuario no mencionó criterios de éxito o items fuera de alcance, el agente los propone
9. **El archivo va en `docs/prd/`** con formato `YYYY-MM-DD-<nombre>.md`
10. **Mezclar preguntas con opciones y abiertas** según el tipo de información
