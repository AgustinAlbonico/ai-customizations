# GUIA - Skill tauri-react-nest-lan-migration

Esta guia explica como usar el skill de migracion Web -> Desktop (Tauri) para proyectos React + NestJS + Postgres en LAN.

## 1) Que instala este skill

### Skills
- `.opencode/skills/tauri-react-nest-lan-migration/SKILL.md`
- `.opencode/skills/tauri-migration/SKILL.md` (alias corto)

### Comandos
- `.opencode/command/tauri-migrate.md`
- `.opencode/command/tauri-migrate-plan.md`
- `.opencode/command/tauri-migrate-implement.md`
- `.opencode/command/tauri-migrate-verify.md`
- `.opencode/command/tauri-migrate-release.md`

## 2) Flujo recomendado de uso

Ejecutar en este orden:

1. `/tauri-migrate-plan`
   - audita logs, rutas, sidecar y setup
   - genera plan tecnico

2. `/tauri-migrate-implement`
   - aplica cambios en backend/frontend/tauri
   - corrige sidecar, setup, config, encoding, guards

3. `/tauri-migrate-verify`
   - valida setup, login y CRUD
   - revisa logs y define Go/No-Go

4. `/tauri-migrate-release`
   - genera instalador final y checklist de entrega

## 3) Regla LAN (clave)

- Backend desktop siempre local: `127.0.0.1`.
- Base de datos remota: IP fija de la PC servidor en `database.host`.

No usar `localhost` como host de DB en clientes LAN.

## 4) Logs que SIEMPRE hay que revisar primero

- `%APPDATA%/sistema-caja/debug_startup.log`
- `%APPDATA%/sistema-caja/logs/error-YYYY-MM-DD.log`
- `%APPDATA%/sistema-caja/logs/application-YYYY-MM-DD.log`

## 5) Errores comunes y significado

- `Cannot POST /api/config/test`
  - backend en modo normal, no en setup.

- `failed to fetch`
  - backend caido o en restart race.

- `Unexpected token` al parsear config
  - BOM en `config.json`.

- `os error 2`
  - path/nombre de sidecar mal resuelto.

- `os error 32`
  - archivos bloqueados durante extraccion.

- `Nest can't resolve JwtAuthGuard (JwtService)`
  - falta importar/exportar modulo de auth en el modulo afectado.

## 6) Si no aparecen los comandos

Si `/tauri-migrate-*` no aparece en el listado:

1. cerrar OpenCode
2. volver a abrir OpenCode
3. ejecutar de nuevo `/tauri-migrate-plan`

## 7) Llevarlo a Claude Code

Se puede reutilizar en Claude Code, pero no hay un marketplace universal compartido entre OpenCode y Claude Code.

Forma practica:

1. Publicar este skill/command pack en un repo GitHub.
2. Copiar comandos equivalentes a la estructura de Claude Code (por ejemplo comandos markdown del proyecto).
3. Copiar reglas base al contexto del agente (archivo de instrucciones del proyecto).
4. Versionar cambios por tags/releases (v1, v1.1, etc.).

## 8) Recomendacion de distribucion

Para compartirlo con otros proyectos/equipos:

- crear repo: `tauri-react-nest-lan-migration-skill`
- incluir:
  - `skills/.../SKILL.md`
  - `command/tauri-migrate-*.md`
  - `README.md` con instalacion
  - `CHANGELOG.md`

Asi lo podes usar en OpenCode y portar facil a Claude Code.
