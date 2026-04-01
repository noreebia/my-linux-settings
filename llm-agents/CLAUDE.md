# llm-agents

This directory contains shared configuration and per-agent settings for LLM coding agents (Claude Code, Codex, Gemini, etc.).

## Structure

```
llm-agents/
├── AGENTS_GLOBAL.md      # Shared instructions injected into every agent
└── claude-code/           # Shared agent config (skills, settings, statuslines) — named after Claude Code but deployed to all agents
```

## How AGENTS_GLOBAL.md is deployed

`AGENTS_GLOBAL.md` is the single source of truth for cross-agent instructions (variables, file generation rules, metadata headers). The `priority_05_*` install scripts copy it into each agent's config directory under that agent's expected filename:

| Agent       | Script                                    | Destination                  |
|-------------|-------------------------------------------|------------------------------|
| Claude Code | `priority_05_update_claude_code_settings.sh` | `~/.claude/CLAUDE.md`     |
| Codex       | `priority_05_update_codex_settings.sh`       | `~/.codex/AGENTS.md`      |
| Gemini      | `priority_05_update_gemini_settings.sh`      | `~/.gemini/GEMINI.md`     |

Because the filename changes per agent, **avoid referencing `AGENTS_GLOBAL.md` by name** in skills or agent-facing instructions — it won't exist under that name at runtime. Skills should inline any format or convention they need rather than cross-referencing this file.

## File generation boundaries

Agents should write generated files inside their own `$AGENT_LOCAL_DIR` (e.g., `agents/claude/`, `agents/codex/`). Do not write into `$AGENT_DIR` directly or into another agent's subdirectory unless explicitly instructed — a Claude review of a Codex-generated document still goes under `agents/claude/reviews/`, not alongside the Codex file.
