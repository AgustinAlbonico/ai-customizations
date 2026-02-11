# ai-customizations

Infraestructura personal de IA: skills, agentes, hooks y comandos versionados en un solo repo, con instalacion reproducible para OpenCode/Codex mediante `npx skills` y scripts de bootstrap.

## Arquitectura

```text
skills/                     # skills instalables con npx skills
agents/                     # instrucciones base por agente
  opencode/
  codex/
hooks/                      # hooks reutilizables
  opencode/
commands/                   # comandos markdown reutilizables
  opencode/
scripts/                    # scripts de bootstrap/instalacion
```

## Instalacion de skills con npx

Listar skills disponibles:

```powershell
npx skills add AgustinAlbonico/ai-customizations --list
```

Instalar todas las skills para OpenCode:

```powershell
npx skills add AgustinAlbonico/ai-customizations --skill '*' --agent opencode -y
```

Instalar todas las skills para Codex:

```powershell
npx skills add AgustinAlbonico/ai-customizations --skill '*' --agent codex -y
```

## Bootstrap de proyecto (OpenCode)

Para copiar comandos/hooks/instrucciones al proyecto actual y luego instalar skills locales:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-opencode-project.ps1 -ProjectPath "C:\ruta\tu-proyecto"
```

## Bootstrap de skills para Codex

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-codex-skills.ps1
```

## Validacion local

```powershell
npx skills add . --list
```

## Notas

- Cada skill debe tener `SKILL.md` con frontmatter YAML valido (`name` + `description`).
- Este repo guarda customizaciones de IA, no codigo de producto.
