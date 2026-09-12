# Banco de Preguntas — prd-creator

Banco organizado por pilares y rondas. El agente selecciona las preguntas relevantes según la complejidad y las respuestas previas del usuario. **Máximo 4 preguntas por ronda.**

Todas las preguntas se hacen con la herramienta `question`. Mezclar preguntas con opciones y abiertas.

---

## Regla de foco (OBLIGATORIA)

Antes de elegir preguntas, construir `brief de foco` con:

- Pedido exacto del usuario.
- In-scope (qué parte del sistema sí entra).
- Out-of-scope (qué no entra salvo pedido explícito).
- Gaps reales de información.

Solo se permiten preguntas que cierren un gap real del brief.

### Filtro rápido por pregunta

Una pregunta entra solo si cumple TODO:

1. Está directamente conectada con el pedido.
2. No está ya respondida por el usuario o por la exploración del codebase.
3. Cambia una decisión del PRD (alcance, requisito o criterio de éxito).
4. No abre un frente lateral que el usuario no pidió.

Si falla un punto, se descarta.

---

## Modo sistema existente — Preguntas delta (prioridad alta)

Si ya hay producto funcionando, priorizar estas preguntas sobre las genéricas.

| # | Pregunta | Tipo | Cuándo usar |
|---|----------|------|-------------|
| D1 | Hoy en `[flujo/módulo detectado]` pasa `[comportamiento actual]`. ¿Qué querés que cambie exactamente? | Abierta | Siempre en sistema existente |
| D2 | ¿Qué parte del comportamiento actual debe mantenerse igual sí o sí? | Abierta | Siempre en sistema existente |
| D3 | ¿Qué usuarios/roles se ven afectados por este cambio puntual? | Con opciones + abierta | Si hay múltiples actores |
| D4 | ¿Cuál es el dolor principal del flujo actual que este cambio tiene que resolver primero? | Abierta | Siempre si hay flujo actual |
| D5 | Para esta versión, ¿qué dejamos explícitamente afuera en este módulo/flujo? | Abierta | Siempre recomendado |
| D6 | ¿Hay alguna regla de negocio existente que no podamos romper con este cambio? | Abierta | Si se detectan reglas actuales |

---

## Pilar 1 — Problema y Contexto (Ronda 1)

Preguntas para entender el "por qué".

| # | Pregunta | Tipo | Cuándo usar |
|---|----------|------|-------------|
| 1.1 | ¿Qué problema concreto resuelve esto para el usuario? | Abierta | Siempre si el usuario fue vago |
| 1.2 | ¿Cómo se resuelve hoy sin esta solución? | Con opciones | Siempre |
| | - Manualmente (planillas, papel, verbal) | | |
| | - Con una herramienta que no funciona bien | | |
| | - No se resuelve, se tolera el problema | | |
| 1.3 | ¿Por qué es importante resolverlo ahora? | Abierta | Si no es obvio del contexto |
| 1.4 | ¿Hay alguna restricción de negocio que debas respetar? (regulaciones, contratos, deadlines) | Con opciones | Si el dominio lo sugiere |
| | - Sí, hay regulaciones/compliance | | |
| | - Sí, hay un deadline específico | | |
| | - Sí, hay restricciones de presupuesto | | |
| | - No, sin restricciones especiales | | |

---

## Pilar 2 — Usuarios y Alcance (Ronda 1)

Preguntas para entender "para quién" y "qué tanto".

| # | Pregunta | Tipo | Cuándo usar |
|---|----------|------|-------------|
| 2.1 | ¿Quién es el usuario principal de esto? | Con opciones + abierta | Siempre si no quedó claro |
| | - Usuarios finales (clientes) | | |
| | - Equipo interno (empleados) | | |
| | - Administradores/gerencia | | |
| | - Múltiples tipos de usuario | | |
| 2.2 | ¿Hay otros actores involucrados además del usuario principal? | Con opciones | Si la complejidad >= media |
| | - Sí, otros roles que interactúan | | |
| | - Sí, sistemas/servicios externos | | |
| | - No, solo el usuario principal | | |
| 2.3 | ¿Qué es lo mínimo que debe hacer para tener valor real? | Abierta | Siempre |
| 2.4 | ¿Hay algo que explícitamente NO debería incluir en esta versión? | Abierta | Siempre recomendado |

---

## Pilar 3 — Flujos y Comportamiento (Ronda 2)

Preguntas para entender "cómo funciona".

| # | Pregunta | Tipo | Cuándo usar |
|---|----------|------|-------------|
| 3.1 | Describí el camino principal: el usuario hace X → pasa Y → termina Z. ¿Cómo es el flujo ideal? | Abierta | Siempre si complejidad >= media |
| 3.2 | ¿Qué pasa si algo sale mal en el medio del proceso? | Con opciones | Si hay flujos transaccionales |
| | - El usuario puede reintentar | | |
| | - Se revierte todo automáticamente | | |
| | - Se guarda un borrador para continuar después | | |
| | - Se notifica a alguien para intervenir | | |
| 3.3 | ¿Hay caminos alternativos válidos además del flujo principal? | Abierta | Si complejidad >= media |
| 3.4 | ¿Qué pasa si el usuario abandona a mitad del proceso? | Con opciones | Si hay procesos multi-paso |
| | - Se pierde todo (aceptable) | | |
| | - Se guarda automáticamente como borrador | | |
| | - Se le avisa antes de salir | | |
| 3.5 | ¿Hay acciones que necesiten aprobación de otro usuario/rol? | Con opciones | Si hay múltiples actores |
| | - Sí, necesita aprobación antes de ejecutar | | |
| | - Sí, pero solo notificación (no bloquea) | | |
| | - No, cada usuario actúa de forma autónoma | | |

---

## Pilar 4 — Criterios de Éxito (Ronda 2-3)

Preguntas para entender "cuándo está bien".

| # | Pregunta | Tipo | Cuándo usar |
|---|----------|------|-------------|
| 4.1 | ¿Cómo sabés que esto funciona correctamente? Dame 2-3 escenarios concretos. | Abierta | Siempre |
| 4.2 | ¿Hay algún comportamiento que si no funciona, esto directamente no sirve? | Abierta | Siempre |
| 4.3 | ¿Qué métrica o indicador mostraría que tuvo el impacto esperado? | Con opciones | Si complejidad >= media |
| | - Reducción de tiempo en un proceso | | |
| | - Aumento de conversiones/ventas | | |
| | - Reducción de errores/reclamos | | |
| | - Adopción por parte de los usuarios | | |
| | - Satisfacción del usuario | | |
| 4.4 | ¿Hay restricciones de velocidad o disponibilidad que el negocio necesite? | Abierta | Si el usuario mencionó performance |

---

## Pilar 5 — Edge Cases y Restricciones (Ronda 3)

Solo si complejidad >= alta.

| # | Pregunta | Tipo | Cuándo usar |
|---|----------|------|-------------|
| 5.1 | ¿Qué pasa si dos personas hacen la misma acción al mismo tiempo? | Con opciones | Si hay datos compartidos |
| | - Gana el primero, el segundo ve error | | |
| | - Se fusionan los cambios | | |
| | - Se bloquea hasta que el primero termine | | |
| | - No aplica a mi caso | | |
| 5.2 | ¿Hay límites que debamos respetar? (máximos, cuotas, vencimientos) | Abierta | Siempre en complejidad alta |
| 5.3 | ¿Qué pasa con los datos existentes cuando se lance esto? | Con opciones | Si afecta datos existentes |
| | - Hay que migrar datos existentes | | |
| | - Arranca de cero, datos viejos no importan | | |
| | - Convivencia: datos viejos se ven pero no se modifican | | |
| 5.4 | ¿Hay casos donde esto debería bloquearse o restringirse? (permisos, horarios, estados) | Abierta | Si hay reglas de negocio complejas |

---

## Pilar 6 — Priorización y Fases (Ronda 3-4)

Solo si complejidad >= alta.

| # | Pregunta | Tipo | Cuándo usar |
|---|----------|------|-------------|
| 6.1 | Si tuvieras que lanzar una versión mínima en la mitad del tiempo, ¿qué sacrificarías? | Abierta | Siempre en complejidad alta |
| 6.2 | ¿Esto se entrega completo de una vez o tiene fases? | Con opciones | Si el scope es grande |
| | - Todo de una vez | | |
| | - Fase 1 (MVP) + Fase 2 (mejoras) | | |
| | - Múltiples fases planificadas | | |
| 6.3 | ¿Hay algún riesgo de negocio que te preocupe? | Abierta | Si complejidad >= alta |
| 6.4 | ¿Hay dependencias externas que puedan afectar los tiempos? (proveedores, otros equipos, aprobaciones) | Con opciones | Si hay integraciones |
| | - Sí, dependo de un proveedor externo | | |
| | - Sí, dependo de otro equipo interno | | |
| | - Sí, necesito aprobaciones legales/regulatorias | | |
| | - No, es autocontenido | | |

---

## Guía de selección de preguntas por complejidad

### Simple (0-4 preguntas, 0-1 rondas)
- Elegir 2-4 de Pilares 1+2 que no estén ya respondidas
- Saltar Pilares 3-6

### Media (4-8 preguntas, 1-2 rondas)
- **Ronda 1**: 3-4 preguntas de Pilares 1+2
- **Ronda 2**: 2-4 preguntas de Pilares 3+4

### Alta (8-15 preguntas, 2-3 rondas)
- **Ronda 1**: 3-4 preguntas de Pilares 1+2
- **Ronda 2**: 3-4 preguntas de Pilares 3+4
- **Ronda 3**: 2-4 preguntas de Pilares 5+6

### Muy Alta (15-20 preguntas, 3-4 rondas)
- **Ronda 1**: 4 preguntas de Pilares 1+2
- **Ronda 2**: 4 preguntas de Pilar 3+4
- **Ronda 3**: 4 preguntas de Pilar 5+6
- **Ronda 4**: 2-4 preguntas de seguimiento sobre gaps detectados

---

## Preguntas de descubrimiento (input vago)

Solo usar esta sección cuando el input es muy vago (<30 palabras) **y** no hay suficiente contexto del sistema para acotar.

Si ya existe sistema y el pedido apunta a un flujo concreto, usar primero preguntas delta (D1-D6).

Cuando aplica, usar estas preguntas para arrancar:

```
Pregunta 1: "¿Qué aspecto específico querés resolver?"
[opciones generadas a partir del dominio del proyecto]

Pregunta 2: "¿Cuál es el problema principal que tenés hoy?"
[ABIERTA]

Pregunta 3: "¿Cuántas personas van a usar esto?"
- Solo yo
- Un equipo pequeño (2-5)
- Un equipo mediano (5-20)
- Toda la organización (20+)

Pregunta 4: "¿Tenés una idea de qué debería hacer, o querés que exploremos juntos?"
- Tengo una idea clara, dejame contarte
- Tengo una idea vaga, ayudame a definirla
- Solo sé que hay un problema, exploremos
```

---

## Anti-patrón: preguntas demasiado amplias

Evitar preguntas genéricas que no cierran gaps del pedido.

| Evitar | Mejor (enfocada) |
|--------|------------------|
| "¿Qué querés construir?" | "En el flujo de checkout que detecté, ¿querés resolver abandono o errores de pago?" |
| "¿Quiénes usarían el sistema?" | "Para este cambio en notificaciones, ¿impacta solo cliente final o también soporte interno?" |
| "¿Qué restricciones tenés?" | "Para este módulo de facturación, ¿hay una fecha límite legal o contractual que condicione el alcance?" |
