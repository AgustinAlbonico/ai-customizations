---
description: Tareas interactivas (features, cambios, refactors) con preguntas adaptativas
---

Activa el skill "interactive-task" y ayuda al usuario a completar su tarea.

El usuario te ha dado una descripción inicial de la tarea. Tu trabajo:

1. **Usar el skill interactive-task** para hacer preguntas adaptativas
2. **Usar la herramienta `question`** para las preguntas (NO preguntes en texto plano)
3. **Mezclar preguntas con opciones y abiertas**:
   - Opciones cuando hay enfoques/estilos comunes
   - Abiertas cuando necesitás detalle específico (texto exacto, orden específico, etc.)
4. **Recordar**: la herramienta `question` SIEMPRE agrega "Type your own answer" - el usuario nunca está limitado
5. **Identificar el tipo de tarea** (nuevo, cambio, refactor, config, mejora)
6. **Adaptar las preguntas** según el tipo identificado
7. **Investigar el codebase** para entender contexto y patrones existentes
8. **Ejecutar** siguiendo los patrones del proyecto

**Objetivo**: Entender exactamente qué quiere el usuario para ejecutar correctamente en UN SOLO intento. Máximo 4 preguntas, máximo 2 rondas.
