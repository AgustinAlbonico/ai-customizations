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
| `frontend` | `apps/frontend/AGENTS.md` |
| `backend` | `apps/backend/AGENTS.md` |

Scopes can be combined: `scope: [frontend, backend]`

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
.\skills\skill-sync\assets\sync.ps1
.\skills\skill-sync\assets\sync.ps1 -DryRun
.\skills\skill-sync\assets\sync.ps1 -Scope root
```

### macOS / Linux

```bash
./skills/skill-sync/assets/sync.sh
./skills/skill-sync/assets/sync.sh --dry-run
./skills/skill-sync/assets/sync.sh --scope root
```

## What it does

1. Scans all `skills/*/SKILL.md`
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
- [ ] Ran `sync.ps1` or `sync.sh`
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
