# ai-customizations

Infraestructura personal de IA: skills, agentes, hooks y comandos versionados en un solo repo, con instalacion reproducible y arquitectura agnostica de agente.

## Arquitectura

```text
skills/                     # skills instalables con npx skills (cross-agent)
agents/                     # definiciones de agentes reutilizables
commands/                   # comandos markdown reutilizables
hooks/                      # hooks reutilizables
scripts/                    # scripts de bootstrap/instalacion
```

## Resumen rapido del skill

Skill principal: `tauri-react-nest-lan-migration`.

### Que hace

- Guia migraciones Web -> Desktop con Tauri para stack React + NestJS + Postgres en LAN.
- Estandariza setup, sidecar, validacion y salida a release.
- Reduce errores comunes de red local, auth y arranque.

### Como funciona

1. Planifica la migracion (`/tauri-migrate-plan`).
2. Implementa cambios (`/tauri-migrate-implement`).
3. Verifica setup/login/CRUD + logs (`/tauri-migrate-verify`).
4. Prepara entrega (`/tauri-migrate-release`).

Alias corto disponible: `tauri-migration`.

### Ejemplo practico

Instalar solo este skill para Claude Code:

```powershell
npx skills add AgustinAlbonico/ai-customizations --skill tauri-react-nest-lan-migration --agent claude-code -y
```

Luego usarlo con un prompt directo:

```text
Aplicar el skill tauri-react-nest-lan-migration para migrar mi app React + NestJS a Tauri en LAN. Empezar por plan, luego implementacion y verificacion.
```

## Instalacion de skills (cualquier agente)

Listar skills disponibles:

```powershell
npx skills add AgustinAlbonico/ai-customizations --list
```

Instalar todas las skills para un agente especifico:

```powershell
npx skills add AgustinAlbonico/ai-customizations --skill '*' --agent <agent-name> -y
```

Ejemplos de `<agent-name>`: `opencode`, `codex`, `claude-code`, `cursor`, `antigravity`.

Instalar skills para multiples agentes en un solo comando:

```powershell
npx skills add AgustinAlbonico/ai-customizations --skill '*' --agent opencode --agent codex --agent claude-code -y
```

Instalar skills para todos los agentes detectados:

```powershell
npx skills add AgustinAlbonico/ai-customizations --all
```

## Script de instalacion agnostico

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-skills.ps1 -Source AgustinAlbonico/ai-customizations -Agents opencode,codex,claude-code
```

Para instalar todas las skills de todos los agentes en modo global:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-skills.ps1 -Source AgustinAlbonico/ai-customizations -AllAgents -GlobalSkills
```

## Bootstrap opcional de proyecto

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\bootstrap-project.ps1 -ProjectPath "C:\ruta\tu-proyecto"
```

## Validacion local

```powershell
npx skills add . --list
```

## Notas

- Cada skill debe tener `SKILL.md` con frontmatter YAML valido (`name` + `description`).
- Este repo guarda customizaciones de IA, no codigo de producto.
