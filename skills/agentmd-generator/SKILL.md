---
name: agentmd-generator
description: >
  Generate hierarchical AGENTS.md knowledge base for any repository.
  Analyzes codebase structure, discovers skills, asks adaptive questions,
  and generates optimized root + local AGENTS.md files that minimize
  context consumption while maximizing AI effectiveness.
  Trigger: When user says "generate agents", "setup AGENTS.md",
  "configure AI knowledge base", "agentmd", or wants to create/rebuild
  the AGENTS.md hierarchy for a project.
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## When to Use

- Setting up a new project for AI-assisted development
- Restructuring an existing AGENTS.md that grew too large
- Onboarding a monorepo that needs scoped AI context
- After significant architectural changes that invalidate existing AGENTS.md
- When AI agents consume too much context loading irrelevant instructions

## Overview

This skill implements a 6-phase workflow that produces a hierarchical AGENTS.md system. It does NOT dump everything into one file. It analyzes, asks, discovers, designs, and generates — in that order.

The goal: each AI session loads ONLY the context it needs, nothing more.

---

## Phase 1: Repository Analysis

### What to detect

Inspect the codebase systematically. Read directories, config files, and structure markers.

#### Repository Type Detection

| Signal | Type | Example |
|--------|------|---------|
| Single package.json/go.mod at root, no nested projects | `simple` | Standard API or SPA |
| Workspaces field in package.json, pnpm-workspace.yaml, nx.json, turbo.json, lerna.json | `monorepo` | Turborepo, Nx workspace |
| Multiple independent projects in subdirs, each with own package manager config | `multi-project` | Docker-compose based microservices |
| apps/ + packages/ or services/ + libs/ pattern | `monorepo` | Typical monorepo layout |

#### Structure Detection Checklist

- [ ] Root config files (package.json, go.mod, Cargo.toml, pyproject.toml, etc.)
- [ ] Workspace configuration (pnpm-workspace, nx.json, turbo.json)
- [ ] Directory layout: apps/, packages/, services/, libs/, src/
- [ ] Framework markers: next.config, angular.json, vite.config, nest-cli.json
- [ ] Existing AGENTS.md files (anywhere in tree)
- [ ] Existing skills directories (.agents/skills, skills/, .cursor/rules)
- [ ] README files for project/component descriptions
- [ ] Docker/deployment files for service boundaries
- [ ] Test configuration files for testing patterns
- [ ] CI/CD configuration for build/deploy patterns

#### Stack Detection

Read config files to identify:
- **Languages**: package.json (TS/JS), go.mod (Go), pyproject.toml (Python), Cargo.toml (Rust)
- **Frameworks**: next.config (Next.js), angular.json (Angular), nest-cli.json (NestJS), manage.py (Django)
- **State management**: Look for redux, zustand, signals, ngrx, pinia imports
- **Testing**: jest.config, vitest.config, playwright.config, pytest.ini, .mocharc
- **Styling**: tailwind.config, styled-components, CSS modules
- **Database**: prisma/, drizzle.config, typeorm, knex, sqlalchemy
- **Build tools**: turbo.json, nx.json, webpack.config, vite.config, esbuild

### Output: Repository Diagnostic

Present to user as structured summary:

```
## Repository Diagnostic

**Type**: monorepo | simple | multi-project
**Root**: /path/to/repo

### Structure
- apps/web (Next.js 15, React 19, Tailwind 4)
- apps/api (NestJS, Prisma, PostgreSQL)
- packages/ui (Shared components)
- packages/config (Shared configs)

### Detected Stack
| Layer | Technology | Version |
|-------|-----------|---------|
| Frontend | Next.js | 15.x |
| Backend | NestJS | 10.x |
| Database | PostgreSQL | via Prisma |
| Testing | Vitest + Playwright | - |

### Natural Boundaries
1. apps/web → frontend context
2. apps/api → backend context
3. packages/ui → design system context

### Existing AI Config
- AGENTS.md: none | root only | hierarchical
- Skills: [list found]
- Conventions: [list found]
```

---

## Phase 2: Adaptive Questions

### Philosophy

Ask the MINIMUM needed. If the codebase already reveals the answer, SKIP the question. Group by priority. STOP after asking and WAIT for the user to respond before continuing.

### Question Format Rules

1. **ALWAYS prefer multiple choice** — present concrete options the user can pick from
2. **ALWAYS include an "Other" option with free text** — so the user is never boxed in
3. **Allow multi-select** when the question accepts more than one answer (mark with `[multi-select]`)
4. **Use open-ended questions ONLY when** options cannot be reasonably pre-populated (e.g., "list your critical rules")
5. **Pre-select defaults** when the codebase analysis makes the likely answer obvious (mark with `← detected`)

### Question Protocol

Use the `question` tool if available. Otherwise present questions with lettered options. For each question, present it individually, wait for the response, then continue to the next.

### Question Bank

#### Priority 1 — Always Ask (unless obvious from code)

---

**Q1: What types of tasks do you primarily use AI for in this repo?** `[multi-select]`

| Option | Description |
|--------|-------------|
| a) Feature development | Writing new code and features |
| b) Bug fixing | Debugging and fixing issues |
| c) Refactoring | Improving existing code structure |
| d) Testing | Writing and improving tests |
| e) Code review | Reviewing PRs and code quality |
| f) Documentation | Writing docs and comments |
| g) All of the above | Full-spectrum usage |
| h) Other | _Write your answer_ |

> If code has test configs → pre-mark (d). If CI/CD → pre-mark (e). Default to (g) if unclear.

---

**Q2: What critical rules must the AI ALWAYS follow?** `[multi-select + free text]`

| Option | Example |
|--------|---------|
| a) Strict typing | Never use `any`, always explicit types |
| b) Tests required | Always write tests for new code |
| c) Specific architecture | Follow hexagonal/clean/screaming architecture |
| d) No direct DB access | Always go through repository/service layer |
| e) Specific linter rules | Never disable ESLint/Prettier rules |
| f) Conventional commits | Follow conventional commits format |
| g) None in particular | No special rules |
| h) Other | _Write your own rules_ |

> Pre-select based on detected config: tsconfig strict → (a), jest/vitest config → (b), eslint config → (e), commitlint → (f).

---

#### Priority 2 — Ask if Not Obvious from Code

---

**Q3: Which of these areas need their own specialized AI context?** `[multi-select]`

> This question is auto-populated from Phase 1 detected boundaries. Only ask if 2+ boundaries found.

| Option | Detected Area |
|--------|--------------|
| a) {area1} | {stack info} |
| b) {area2} | {stack info} |
| c) {area3} | {stack info} |
| d) All of the above | Each area gets its own AGENTS.md |
| e) None | Root AGENTS.md is enough |

> Default: if areas use different tech stacks → pre-select (d). If same stack → pre-select (e).

---

**Q4: Does this project follow specific patterns the AI should know?** `[multi-select + free text]`

| Option | Pattern |
|--------|---------|
| a) Container-presentational | Separation of smart/dumb components |
| b) Feature-based structure | Organized by feature, not by type |
| c) Barrel exports | index.ts re-exports in every module |
| d) Specific state management | Custom state patterns |
| e) Specific naming conventions | Prefixes, suffixes, casing rules |
| f) No special patterns | Follow standard conventions |
| g) Other | _Describe your patterns_ |

> Pre-select based on code: if detected feature folders → (b), if index.ts files prevalent → (c).

---

#### Priority 3 — Ask Only if Relevant

---

**Q5: There are existing AI config files. What should we do?** `[single-select]`

> Only ask if existing AGENTS.md, .cursor/rules, or copilot-instructions found.

| Option | Action |
|--------|--------|
| a) Keep and extend | Preserve existing rules, add new structure |
| b) Replace entirely | Start fresh with new hierarchical structure |
| c) Review together | Show me what exists so I can decide per section |

---

**Q6: What level of detail do you want in the generated AGENTS.md?** `[single-select]`

| Option | Level | Description |
|--------|-------|-------------|
| a) Minimal | Root only | One AGENTS.md, lean and focused |
| b) Standard | Root + local | Root + one AGENTS.md per distinct component |
| c) Detailed | Full system | Root + local + auto-invoke tables + QA checklists |

> Default: simple repo → (a), monorepo 2-3 components → (b), monorepo 4+ → (c).

---

### Adaptive Reduction Rules

| Condition | Action |
|-----------|--------|
| Simple repo, single stack | Skip Q3, default Q6 to (a) Minimal |
| Existing AGENTS.md found | Add Q5 to queue |
| Monorepo with clear boundaries | Pre-fill Q3 options with detected boundaries |
| Only 1-2 technologies detected | Skip Q4 options related to patterns not found in code |
| User picks "All of the above" on Q1 | Skip follow-up about task types |
| User says "just do it" / "dale" | Use smart defaults for all, show plan for approval only |

### Response Processing

After each answer:
1. Acknowledge the selection briefly
2. If answer reveals new context → adjust upcoming questions
3. If answer makes a future question redundant → skip it
4. Never ask more than 4 questions total in a simple repo
5. Never ask more than 6 questions total in a monorepo

---

## Phase 3: Skill Discovery

### Step 1: Inventory Existing Skills

Check all known skill locations:
1. Project-local: `.agents/skills/`, `skills/`
2. User-level: `~/.agents/skills/`, `~/.config/opencode/skills/`
3. Workspace: `.cursor/rules/`, `.github/copilot-instructions.md`

### Step 2: Find Relevant Skills

Use `find-skills` skill to search for skills matching the detected stack.

Map detected technologies to skill search queries:

| Detected Tech | Search Query |
|--------------|-------------|
| React/Next.js | "react", "nextjs", "frontend" |
| Angular | "angular", "frontend" |
| NestJS | "nestjs", "backend", "node" |
| Django | "django", "python", "backend" |
| Go | "go", "golang" |
| PostgreSQL | "postgresql", "database" |
| Prisma | "prisma", "orm", "database" |
| Playwright | "playwright", "e2e", "testing" |
| Jest/Vitest | "jest", "vitest", "testing" |
| Tailwind | "tailwind", "css", "styling" |
| Docker | "docker", "deployment" |
| TypeScript | "typescript" |

### Step 3: Classify Skills

Organize into three categories:

```
### Skill Map

#### Global Skills (apply everywhere)
| Skill | Source | Purpose |
|-------|--------|---------|
| typescript | user-level | Type patterns |
| git-master | user-level | Git operations |

#### Scoped Skills (apply to specific areas)
| Skill | Scope | Purpose |
|-------|-------|---------|
| nestjs-best-practices | apps/api | NestJS patterns |
| vercel-react-best-practices | apps/web | React patterns |

#### Missing Skills (recommended to create)
| Skill | Justification |
|-------|--------------|
| myapp-api | Project-specific API conventions |
```

### Reutilization Rule

ALWAYS prefer existing skills. Only recommend creating new skills when:
- No existing skill covers the pattern
- Project conventions differ significantly from generic best practices
- A decision tree specific to this project would save significant time

---

## Phase 4: Architecture Design

### Decision Tree: How Many AGENTS.md Files?

```
Is it a simple repo with one tech stack?
  YES → Root AGENTS.md only
  NO  →
    Does it have 2+ distinct technology contexts?
      YES → Root + one AGENTS.md per context
      NO  →
        Does it have 2+ independent deployable units?
          YES → Root + one AGENTS.md per unit
          NO  → Root AGENTS.md only
```

### Root AGENTS.md Structure

Every root AGENTS.md MUST have:

1. **How to Use This Guide** — explains hierarchy and override rules
2. **Project Overview** — what this repo does, high-level architecture
3. **Tech Stack** — technologies with versions (table format)
4. **Skills Reference** — global skills with relative paths
5. **Auto-invoke Table** — action → skill mappings
6. **Critical Rules** — NON-NEGOTIABLE rules (max 10)
7. **Commands** — common dev commands (setup, dev, test, lint, build)
8. **Component Index** — links to local AGENTS.md files (if any)

What it must NOT have:
- Framework-specific patterns (delegate to skills)
- Long code examples (delegate to skills)
- Component-specific rules (delegate to local AGENTS.md)
- Personality/tone instructions (those live in user-level config)
- SDD/orchestrator rules (those live in user-level config)

### Local AGENTS.md Structure

Each local AGENTS.md MUST have:

1. **Skills Reference** — skills specific to this component
2. **Auto-invoke Table** — component-specific action → skill mappings
3. **Critical Rules** — component-specific NON-NEGOTIABLE rules
4. **Tech Stack** — component-specific technologies
5. **Project Structure** — directory layout of this component
6. **Commands** — component-specific commands
7. **QA Checklist** — component-specific quality checks

Override rule: Local AGENTS.md overrides root when guidance conflicts.

### Sizing Guidelines

| Content | Max Size |
|---------|----------|
| Root AGENTS.md | ~4-8 KB |
| Local AGENTS.md | ~3-6 KB |
| Total across all AGENTS.md | ~20 KB max |

If content exceeds these limits, it belongs in a SKILL.md, not in AGENTS.md.

---

## Phase 5: Generation

### Generation Order

1. Root AGENTS.md first
2. Local AGENTS.md files (if any)
3. Present complete plan before writing ANY files

### Pre-write Confirmation

ALWAYS show the user:
1. File paths that will be created
2. Approximate size of each file
3. Skills that will be referenced
4. Ask for explicit confirmation before writing

### File Writing Rules

- Use relative paths for skill references: `skills/{name}/SKILL.md`
- Use relative paths for local AGENTS.md references: `apps/api/AGENTS.md`
- Never hardcode absolute paths
- Never include user-level config (personality, tone, SDD rules)
- Use tables for structured data (stacks, skills, auto-invoke)
- Use code blocks for directory structures and commands
- Mark critical rules with bold **NON-NEGOTIABLE** or **CRITICAL**

---

## Phase 6: Validation

After generating, verify:

- [ ] Root AGENTS.md exists and is under 8 KB
- [ ] Each local AGENTS.md is under 6 KB
- [ ] No duplication between root and local files
- [ ] All referenced skills actually exist
- [ ] All relative paths are correct
- [ ] Auto-invoke tables have no orphan skill references
- [ ] Critical rules are specific and actionable (not vague)
- [ ] Commands section has real, tested commands
- [ ] No user-level config leaked into project AGENTS.md

---

## Critical Patterns

### Context Efficiency

The ENTIRE point of this skill is to REDUCE context consumption. Every decision must be evaluated through this lens:

- Will this instruction be needed in >50% of sessions? → AGENTS.md
- Will this instruction be needed in <50% of sessions? → Skill
- Is this instruction generic to the technology? → Existing skill
- Is this instruction specific to this project? → Project skill or AGENTS.md

### Inheritance Model

```
User-level AGENTS.md (personality, global rules)
  └── Root AGENTS.md (project overview, global skills, cross-cutting rules)
       ├── Local AGENTS.md (component-specific context)
       │    └── Skills (detailed patterns, loaded on demand)
       └── Skills (detailed patterns, loaded on demand)
```

Each level adds specificity. No level repeats what a parent already provides.

### Anti-patterns to AVOID

| Anti-pattern | Why it's bad | What to do instead |
|-------------|-------------|-------------------|
| Everything in root AGENTS.md | Bloats every session | Split into local + skills |
| Duplicating skill content in AGENTS.md | Double maintenance, wasted context | Reference skill, don't copy |
| Personality/tone in project AGENTS.md | Not project-specific | Keep in user-level config |
| Vague rules ("write good code") | Not actionable | Specific: "Always use zod for validation" |
| AGENTS.md > 10KB | Too much context consumed | Split into local files or skills |
| Local AGENTS.md for simple repos | Unnecessary indirection | Root-only for simple repos |
| Framework tutorials in AGENTS.md | That's what skills are for | Reference the skill |

---

## Templates

See [assets/root-agents-template.md](assets/root-agents-template.md) for the root AGENTS.md template.
See [assets/local-agents-template.md](assets/local-agents-template.md) for the local AGENTS.md template.

---

## Commands

```bash
# Typical invocation
/agentmd

# Re-run analysis only (no generation)
/agentmd --analyze

# Regenerate from existing analysis
/agentmd --regenerate
```
