---
description: Generar AGENTS.md jerarquico para el proyecto
---

Usa la skill `agentmd-generator` con `$ARGUMENTS`.

Seguí el protocolo exactamente: analizá la estructura del repositorio (simple,
monorepo o multi-proyecto), detectá stack y fronteras entre componentes, hacé
preguntas adaptativas para entender necesidades, buscá y reutilizá skills
existentes antes de proponer nuevas, y generá el AGENTS.md raíz + locales
optimizados para que cada sesión cargue solo el contexto que necesita.
