---
name: interactive-work
description: >
  Resolver pedidos de desarrollo con preguntas adaptativas usando `question`
  (multiple choice + respuesta libre) para ejecutar en un solo intento.
  Dos modos: BUG (diagnosticar y corregir algo que no funciona: UI/API/datos/infra)
  y TAREA (aclarar y ejecutar algo no-bug: agregar, cambiar, refactorizar,
  configurar, optimizar). Usar cuando el pedido llega con poco contexto o ambiguo.
  Triggers: "/bug", "/task", "no funciona", "arreglar", "agregar", "cambiar", "refactorizar".
---

# Interactive Work

Objetivo: convertir un pedido vago o un bug con poco contexto en una ejecución
correcta en un solo intento, con mínimo ida y vuelta.

## Modo de entrada (router)

Clasificar el pedido antes de preguntar:

- **BUG**: algo no funciona, hay errores o comportamiento inesperado.
  Subtipos: UI/UX, API/backend, datos/estado, infra/config.
- **TAREA**: trabajo no-bug.
  Subtipos: NUEVO (agregar/crear), CAMBIO (modificar), REFACTOR (limpiar),
  CONFIG (variables/entornos), MEJORA (UX/performance/confiabilidad).

Si el comando fue `/bug` → modo BUG. Si fue `/task` → modo TAREA.

## Protocolo operativo

1) Clasificar en modo + subtipo (silenciosamente, sin preguntar lo obvio).
2) Ejecutar ronda 1 de preguntas (OBLIGATORIO con `question`)
   - 2-4 preguntas en un único llamado.
   - Mezclar cerradas (opciones) y abiertas (texto libre).
   - No repetir información que el usuario ya dio.
   - Recordar: `question` ya incluye respuesta libre (no agregar "Otro").
3) Confirmar resumen corto y pedir validación
   - BUG: problema observado + comportamiento esperado + hipótesis inicial.
     "¿Este resumen representa bien el problema?"
   - TAREA: lo que voy a hacer + lo que NO voy a tocar + criterio de listo.
     "¿Te sirve este alcance?"
   - Si no valida, segunda ronda breve (máximo 2 preguntas).
4) Investigar y ejecutar
   - Leer código relevante / buscar patrones existentes en el repo.
   - BUG: encontrar causa raíz, aplicar fix mínimo y seguro (sin refactors de paso).
   - TAREA: implementar con la mínima complejidad necesaria (sin sobre-ingeniería).

## Plantillas de preguntas

### BUG · UI/UX

- Cerrada: "¿Dónde ocurre?" (header, modal, tabla, formulario, otro)
- Abierta: "¿Qué debería pasar y qué pasa realmente?"
- Cerrada: "¿Ves errores en consola?" (sí/no/no sé)

### BUG · API/backend

- Cerrada: "¿Cómo falla?" (timeout, 4xx/5xx, respuesta inválida, intermitente)
- Abierta: "Pegá status/mensaje/stack trace"
- Cerrada: "¿Antes funcionaba?" (sí/no/no sé)

### BUG · Datos/estado

- Cerrada: "¿Qué falla?" (no guarda, guarda mal, no lee, inconsistente)
- Abierta: "Dá un ejemplo concreto de dato afectado"
- Cerrada: "¿Pasa siempre o con ciertos casos?"

### TAREA · NUEVO

- Cerrada: "¿Dónde debe aparecer?" (header/sidebar/página X/modal/otro)
- Abierta: "¿Cómo debe comportarse exactamente?"
- Cerrada: "¿Reusar patrón existente o crear variante nueva?"

### TAREA · CAMBIO

- Abierta: "¿Qué comportamiento actual querés cambiar?"
- Abierta: "¿Cómo debe quedar?"
- Cerrada: "¿Afecta solo este módulo o varios?"

### TAREA · REFACTOR

- Cerrada: "¿Objetivo principal?" (legibilidad, performance, mantenibilidad)
- Cerrada: "¿Restricciones?" (sin cambios funcionales, sin tocar API, etc.)
- Abierta: "¿Hay una zona puntual del código que te preocupe?"

### TAREA · CONFIG

- Cerrada: "¿Entorno?" (dev, staging, prod, todos)
- Abierta: "¿Qué variables/ajustes exactos necesitás?"
- Cerrada: "¿Solo documentar o también aplicar cambios?"

### TAREA · MEJORA

- Cerrada: "¿Qué mejorar?" (UX, velocidad, estabilidad, DX)
- Abierta: "¿Cómo medimos que mejoró?"
- Cerrada: "¿Prioridad?" (rápido, balanceado, profundo)

## Reglas duras

1. Usar `question` para preguntar, nunca texto plano.
2. Máximo 4 preguntas por ronda y 2 rondas totales.
3. Incluir al menos 1 pregunta abierta si faltan datos críticos.
4. Si hay contexto suficiente, saltar preguntas y pasar a ejecución.
5. En TAREA, definir alcance IN/OUT explícito antes de ejecutar.
6. Cambio mínimo: no refactorizar al arreglar un bug, no sobre-diseñar una tarea.

## Salida mínima esperada

Antes de editar:

- Modo + subtipo detectado
- BUG: causa raíz probable · TAREA: alcance IN/OUT
- Archivos probables a tocar
- BUG: estrategia de fix (1-3 líneas) · TAREA: criterio de listo

Después de editar:

- Qué se cambió y por qué resuelve el pedido
- Cómo validar rápido que quedó bien
