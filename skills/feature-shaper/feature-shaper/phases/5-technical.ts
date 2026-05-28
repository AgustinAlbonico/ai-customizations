# Fase 5 — Técnico

## Regla

INVOCAR subagente primero. Solo después hacer preguntas técnicas.

## Paso 1 — Subagente exploratorio (OBLIGATORIO)

```
task {
  subagent_type: "sdd-design",
  prompt: "Explora el codebase actual. Prioriza apps/backend/src/ y apps/frontend/src/. Identifica:\n1. Stack tecnológico exacto (versiones, librerías clave)\n2. Patrones de arquitectura (Clean Architecture? Hexagonal? Capas?)\n3. Convenciones de código (nombres, imports, estructura de carpetas)\n4. Estructura de módulos backend (qué módulos existen, cómo se organizan)\n5. APIs REST existentes (versión, formato, auth)\n6. Modelo de datos (TypeORM/Prisma, entidades principales)\n7. Integraciones externas (Redis, BullMQ, Socket.IO, Telegram, etc.)\n8. Shared package (@nutrifit/shared) — qué contiene\n9. Frontend: store (Zustand/Redux?), API layer (RTK Query?), routing, components\n10. Cualquier cosa relevante para diseñar un módulo de auth/login\n\nReturn un resumen estructurado con suficiente detalle para tomar decisiones técnicas."
}
```

## Paso 2 — Preguntas técnicas ciblées

Con el output del subagente, preguntar SOLO lo necesario:

### 1. Stack confirmar
"¿Confirmamos [stack del subagente] o hay variante?"
- Confirmar
- Cambiar a: ___

### 2. Auth a implementar
"¿El backend ya tiene módulo de auth o se crea de cero?"
- Se crea de cero
- Se extiende algo existente (describir)

### 3. Mecanismo de auth
"¿Hay preferencia por JWT vs sesiones?"
- JWT (stateless)
- Sesiones (stateful con cookie)
- Otro: ___

### 4. Estructura de URLs
"¿Los portales son subdominios, carpetas, o qué?"
- subdominios: app.socio.nutrifit.com
- carpetas: /socio, /nutri, /admin
- otro: ___

### 5. Modelo de datos
"¿Qué entidades principales necesita esta feature?"
- Lista basada en los RF de Fase 3
- usuario confirma o ajusta

### 6. Orden de implementación
"¿En qué orden sugiero implementar?"
- Basado en dependencias de los RF
- usuario confirma o reorganiza

## No preguntar lo que ya respondió el subagente

Si el subagente dijo "usa NestJS con TypeORM", no preguntar eso de nuevo.
Solo llenar gaps que el subagente no pudo responder.