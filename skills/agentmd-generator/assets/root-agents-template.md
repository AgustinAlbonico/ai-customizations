# {Project Name} — AI Agent Ruleset

> This repository uses hierarchical AGENTS.md files to provide AI agents with scoped context.
> Each component may have its own AGENTS.md with specific guidelines.
> **Component docs override this file when guidance conflicts.**

## Project Overview

{Brief description of what this project does — 2-3 sentences max}

## Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| {layer} | {tech} | {version} |

## Project Structure

```
{repo-name}/
├── {dir1}/          # {description}
├── {dir2}/          # {description}
└── {dir3}/          # {description}
```

## Skills Reference

> Load these skills on demand based on the task. Do NOT load all at once.

### Global Skills (apply across the entire project)

| Skill | Description |
|-------|-------------|
| [`{skill-name}`]({path}/SKILL.md) | {One-line description} |

### Auto-invoke Skills

| Action | Skill |
|--------|-------|
| {Specific action description} | `{skill-name}` |

## Critical Rules

> **NON-NEGOTIABLE** — These rules apply to ALL work in this repository.

1. {Rule 1 — specific and actionable}
2. {Rule 2 — specific and actionable}

## Commands

```bash
# Setup
{setup command}

# Development
{dev command}

# Testing
{test command}

# Linting
{lint command}
```

## Component Index

> Each component below has its own AGENTS.md with scoped context.

| Component | Path | Description |
|-----------|------|-------------|
| {name} | [{path}/AGENTS.md]({path}/AGENTS.md) | {description} |
