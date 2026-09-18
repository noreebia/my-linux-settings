# llm-agents Guide

This directory contains shared configuration and per-agent settings for LLM coding agents such as Claude Code, Codex, and Gemini.

## Runtime Deployment

- `AGENTS_GLOBAL.md` is the shared instruction source. Update scripts copy it under each agent's expected runtime filename:
  - Claude Code: `~/.claude/CLAUDE.md`
  - Codex: `~/.codex/AGENTS.md`
  - Gemini: `~/.gemini/GEMINI.md`
- `CLAUDE.md` files in this repo should be thin Claude Code shims that import the matching `AGENTS.md` with `@AGENTS.md`.
- `skills/` is the shared skill source for all supported agents. Agent update scripts adapt or filter shared files as needed before deployment.
- `codex/skills/` contains Codex-only skills and deliberate Codex variants. The Codex updater overlays them after preparing the shared skills.

## Structure

```text
llm-agents/
|-- AGENTS_GLOBAL.md      # Shared instructions injected into every agent
|-- skills/               # Shared, agent-neutral skill source
|-- claude-code/          # Claude-specific runtime assets
`-- codex/                # Codex-specific runtime config, helpers, and skill overlays
```

## Editing Rules

- Keep runtime instructions portable across agents. Avoid wording that assumes only Claude unless editing `claude-code/` specifically.
- Do not reference `AGENTS_GLOBAL.md` by filename inside deployed instructions or skills unless the file is actually present at runtime. Its destination name changes per agent.
- When adding a new agent, add a dedicated subdirectory and update the relevant `priority_05_update_*` script instead of mixing agent-specific config into another agent's folder.
- Preserve user-specific runtime state when deploy scripts merge settings into `$HOME`.
- Agents should write generated markdown files inside their own `$AGENT_LOCAL_DIR` when those global instructions apply, for example `agents/claude/` or `agents/codex/`. Do not write into `$AGENT_DIR` directly or into another agent's subdirectory unless explicitly instructed.
- A Claude review of a Codex-generated document still belongs under Claude's local output directory, such as `agents/claude/reviews/`, not beside the Codex file.

## Important Files

- `AGENTS_GLOBAL.md`: shared runtime behavior and generated-file conventions.
- `claude-code/settings.json`: Claude Code permissions and statusline command config.
- `codex/config.toml`: Codex TUI statusline config.
