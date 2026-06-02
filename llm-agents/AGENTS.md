# llm-agents Guide

This directory contains shared and per-agent configuration for LLM coding agents.

## Runtime Deployment

- `AGENTS_GLOBAL.md` is the shared instruction source. Update scripts copy it under each agent's expected runtime filename:
  - Claude Code: `~/.claude/CLAUDE.md`
  - Codex: `~/.codex/AGENTS.md`
  - Gemini: `~/.gemini/GEMINI.md`
- `CLAUDE.md` is repo documentation for Claude-facing work in this folder. Keep `AGENTS.md` as the cross-agent local guide.
- `claude-code/skills/` is currently the shared skill source. Codex receives these skills through `priority_05_update_codex_settings.sh`.

## Editing Rules

- Keep runtime instructions portable across agents. Avoid wording that assumes only Claude unless editing `claude-code/` specifically.
- Do not reference `AGENTS_GLOBAL.md` by filename inside deployed instructions or skills unless the file is actually present at runtime. Its destination name changes per agent.
- When adding a new agent, add a dedicated subdirectory and update the relevant `priority_05_update_*` script instead of mixing agent-specific config into another agent's folder.
- Preserve user-specific runtime state when deploy scripts merge settings into `$HOME`.

## Important Files

- `AGENTS_GLOBAL.md`: shared runtime behavior and generated-file conventions.
- `claude-code/settings.json`: Claude Code permissions and statusline command config.
- `codex/config.toml`: Codex TUI statusline config.

