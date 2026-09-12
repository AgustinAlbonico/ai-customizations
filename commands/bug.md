---
description: Debug interactivo de bugs con preguntas adaptativas
---

Activa el skill "interactive-work" en modo BUG y ayuda al usuario a debuggear.

El usuario te ha dado una descripción inicial del bug. Tu trabajo:

1. **Usar el skill interactive-work (modo BUG)** para hacer preguntas adaptativas
2. **Usar la herramienta `question`** para las preguntas (NO preguntes en texto plano)
3. **Mezclar preguntas con opciones y abiertas**:
   - Opciones cuando hay respuestas comunes/predecibles
   - Abiertas cuando necesitás info específica (error exacto, pasos específicos)
4. **Recordar**: la herramienta `question` SIEMPRE agrega "Type your own answer" - el usuario nunca está limitado a las opciones
5. **Clasificar el subtipo** (UI/UX, API/backend, datos/estado, infra/config) y adaptar las preguntas
6. **Investigar el codebase** después de tener las respuestas
7. **Diagnosticar y arreglar** con cambios mínimos (sin refactors de paso)

**Objetivo**: Obtener contexto suficiente para arreglar en UN SOLO intento. Máximo 4 preguntas, máximo 2 rondas.
