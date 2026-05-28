---
name: skill-sync
description: >
  Automatically syncs skill metadata to AGENTS.md Auto-invoke sections.
  Trigger: Adding new skills, updating skill metadata, or regenerating skill routing tables.
license: Apache-2.0
metadata:
  author: AgustinAlbonico
  version: "1.0"
  scope: [root]
  auto_invoke:
    - "Adding a new skill"
    - "Updating skill metadata"
    - "Regenerating AGENTS.md skill routing tables"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash
---

# Skill Sync

Automatically keeps AGENTS.md Skill Routing tables in sync with skill metadata.

## Purpose

When working with multiple skills across projects, manual maintenance of skill routing tables becomes error-prone and tedious. This skill provides automation: run one script and all AGENTS.md files update automatically based on the metadata in each SKILL.md.

## Concept

Inspired by Prowler's skill-sync system. Each skill file contains metadata that describes:

1. **scope** — which AGENTS.md file(s) to update
2. **auto_invoke** — what actions trigger this skill

A sync script reads all SKILL.md files, extracts this metadata, and generates the Skill Routing tables automatically.

## Required Metadata

Each skill that should appear in Auto-invoke sections needs this in its frontmatter:

```yaml
---
name: mi-skill
description: What this skill does
metadata:
  author: user
  version: "1.0"
  scope: [root]                    # Which AGENTS.md to update
  auto_invoke:
    - "Creating API endpoints"
    - "Adding database queries"
---
```

### Scope Values

| Scope | Updates |
|-------|---------|
| `root` | `AGENTS.md` (repo root) |
| `frontend` | First existing path among `frontend`, `web`, `client`, `apps/frontend`, `apps/web`, `apps/client` |
| `backend` | First existing path among `backend`, `api`, `server`, `apps/backend`, `apps/api`, `apps/server` |
| `shared` | First existing path among `packages/shared`, `shared`, `common`, `packages/common` |
| `mcp` / `mcp_server` | First existing path among `mcp_server`, `mcp`, `mcp-server` |
| `sdk` | First existing path among `sdk`, `lib`, `packages/sdk`, `packages/lib` |

Scopes can be combined: `scope: [frontend, backend]`. Custom scopes are also supported when a matching directory exists or when `.agents/skill-scopes.json` defines it.

Example custom scope file:

```json
{
  "scopes": {
    "admin": "apps/admin",
    "mobile": "apps/mobile"
  }
}
```

### Auto_invoke Format

Single action or list:

```yaml
# Single
auto_invoke: "Creating React components"

# Multiple
auto_invoke:
  - "Creating React components"
  - "Adding Tailwind CSS"
```

## Usage

### Windows

```powershell
.\.agents\skills\skill-sync\assets\sync.ps1
.\.agents\skills\skill-sync\assets\sync.ps1 -DryRun
.\.agents\skills\skill-sync\assets\sync.ps1 -AutoAddMetadata
.\.agents\skills\skill-sync\assets\sync.ps1 -Scope root
.\.agents\skills\skill-sync\assets\sync.ps1 -ProjectRoot C:\ruta\proyecto
```

If the repo stores skills at `skills/` instead of `.agents/skills/`, run the equivalent `skills/skill-sync/assets/sync.ps1` path.

### macOS / Linux

```bash
./.agents/skills/skill-sync/assets/sync.sh
./.agents/skills/skill-sync/assets/sync.sh --dry-run
./.agents/skills/skill-sync/assets/sync.sh --auto-add-metadata
./.agents/skills/skill-sync/assets/sync.sh --scope root
```

If the repo stores skills at `skills/` instead of `.agents/skills/`, run the equivalent `skills/skill-sync/assets/sync.sh` path.

## What it does

1. Scans all `.agents/skills/*/SKILL.md` or `skills/*/SKILL.md`
2. Extracts `metadata.scope` and `metadata.auto_invoke` from each
3. Groups skills by scope
4. Generates the `### Auto-invoke Skills` table for each AGENTS.md
5. Updates or inserts the section

## Workflow

```
Create/edit SKILL.md
    ↓
Add metadata.scope + metadata.auto_invoke
    ↓
Run sync script
    ↓
AGENTS.md auto-invoke table updates automatically
```

## Checklist

- [ ] Added `metadata.scope` to skill
- [ ] Added `metadata.auto_invoke` with action description
- [ ] Ran `sync.ps1` or `sync.sh` with `-DryRun` / `--dry-run` first
- [ ] Verified AGENTS.md updated correctly

## File Structure

```
skills/skill-sync/
├── SKILL.md              # This file
└── assets/
    ├── sync.ps1          # Windows PowerShell script
    └── sync.sh           # macOS/Linux bash script
```

## Credits

Pattern inspired by Prowler's [skill-sync](https://github.com/prowler-cloud/prowler) system.
