# {Component Name} — AI Agent Ruleset

> **Scoped context** for `{component-path}/`.
> These rules override the [root AGENTS.md](../../AGENTS.md) when guidance conflicts.

## Skills Reference

> Skills specific to this component. Load on demand, not all at once.

| Skill | Description |
|-------|-------------|
| [`{skill-name}`]({path}/SKILL.md) | {One-line description} |

### Auto-invoke Skills

| Action | Skill |
|--------|-------|
| {Specific action for this component} | `{skill-name}` |

## Critical Rules

> **NON-NEGOTIABLE** — Specific to this component.

1. {Rule 1 — specific and actionable}
2. {Rule 2 — specific and actionable}

## Tech Stack

| Technology | Version | Purpose |
|-----------|---------|---------|
| {tech} | {version} | {purpose} |

## Project Structure

```
{component-name}/
├── {dir1}/          # {description}
├── {dir2}/          # {description}
└── {dir3}/          # {description}
```

## Decision Trees

### {Decision Name}

```
{Question}?
  YES → {Action A}
  NO  → {Action B}
```

## Commands

```bash
# Development
{dev command}

# Testing
{test command}
```

## QA Checklist

- [ ] {Check 1 — specific to this component}
- [ ] {Check 2 — specific to this component}
- [ ] {Check 3 — specific to this component}
