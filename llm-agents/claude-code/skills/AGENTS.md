# Skills Guide

This directory contains reusable agent skills, mostly in `SKILL.md` files. The same skills are deployed to Claude Code and Codex, so write them to be useful across agents unless the skill explicitly depends on Claude-only behavior.

## Editing Rules

- Preserve the `SKILL.md` format. Keep descriptions concise and focused on what the skill does.
- Put long implementation logic in `scripts/` when a skill needs repeatable tooling. Prefer maintaining a script over embedding large command blocks in prose.
- Use relative paths inside a skill from that skill's own directory.
- Avoid adding runtime-only or generated files here. This subtree is copied into agent home directories.
- `CLAUDE.md` in this directory contains existing Claude-oriented skill-writing guidance. Keep this `AGENTS.md` aligned with it when updating conventions.

