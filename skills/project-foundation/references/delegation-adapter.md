# Delegation adapter — project-foundation

Los subagentes de esta skill son **prompts como data** (`agents/*.md`), sin tipos de subagente
hardcodeados. El orquestador renderiza el prompt con los inputs whitelisted de la fase y lo
ejecuta con el mecanismo del entorno actual.

## Reglas de renderizado (todos los entornos)

1. Tomar el prompt base del archivo `agents/<nombre>.md`.
2. Reemplazar cada marcador `{{INPUT: <ruta>}}` con el CONTENIDO de ese input whitelisted
   (leer el archivo; nunca pasar "la ruta" esperando que el subagente adivine el alcance).
3. Reemplazar `{{OUTPUT: <ruta>}}` con la ruta donde el subagente debe escribir su resultado.
4. Mantener la regla de handoff: el subagente devuelve SOLO el YAML compacto (≤30 líneas),
   nunca el documento completo.
5. Si el entorno no tiene subagentes: ejecutar el prompt como "rol" dentro de la misma sesión,
   respetando igual la regla de output-a-archivo y handoff compacto.

## Mapping por entorno

| Necesidad | Pi (gentle-pi) | opencode | claude-code |
|---|---|---|---|
| Pregunta al usuario | `ask_user_question` / `ask_user_choice` | `question` | `AskUserQuestion` |
| Subagente de investigación (read-only) | subagent `gentle-ai-explore` | `Task` con agente genérico | `Task` (agent: explore/readonly) |
| Subagente escritor (bounded writer) | subagent `gentle-ai-worker` | `Task` con agente de código | `Task` |
| Subagente verificador (read-only) | subagent `gentle-ai-verify` | `Task` read-only | `Task` |
| Investigación web | subagent con acceso a web search / `WebFetch` | webfetch | WebSearch/WebFetch |

Asignación sugerida por prompt:

| Prompt en agents/ | Tipo de subagente |
|---|---|
| research-competitors, research-reviews, ux-reference-scan | explorador con acceso web |
| research-synthesis, requirements-drafter, use-case-writer, system-design-drafter, roadmap-drafter | escritor (bounded) |
| domain-consistency, foundation-auditor | verificador (read-only salvo escribir su report) |

## Límites duros para todo subagente

- Lee únicamente los inputs que el prompt renderizado incluye + archivos que el propio prompt
  autoriza explícitamente. Nada de "explorá el repo".
- Escribe únicamente en su `{{OUTPUT}}` (y archivos derivados que el prompt declare).
- No conversa con el usuario: si le falta información, la reporta en `open_questions` del
  handoff y termina con `status: partial`.
- No modifica `state.yaml`: eso es exclusivo del orquestador.
