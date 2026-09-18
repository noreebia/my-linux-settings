# Codex Assets Guide

This subtree is the source for Codex runtime config copied or merged into `~/.codex/` by `priority_05_update_codex_settings.sh`.

## Contents

- `config.toml`: reusable Codex configuration, including approval/sandbox defaults and the TUI statusline.
- `scripts/merge_codex_config.py`: merges reusable settings into a live `~/.codex/config.toml` without replacing project trust, auth, MCP, or other user-specific settings.
- `skills/`: Codex-only skills. These are deployed after the shared skill source and may intentionally override a shared skill with the same directory name.

## Editing Rules

- Do not check in a full live `~/.codex/config.toml`; it may contain trust records, MCP headers, and other private state.
- Keep `config.toml` focused on reusable settings that should be installed everywhere this repo is used.
- Put Codex-specific assets under a matching directory in this subtree, such as `skills/` or `plugins/`, when the shared Claude-compatible source cannot represent them cleanly. Update the Codex deployment script explicitly for each supported asset type.
- Keep shared behavior in `llm-agents/claude-code/skills/`; use `skills/` here only for Codex-only behavior or deliberate Codex variants.
- If Codex adds first-class script-backed statuslines later, update the merge helper and config deliberately; current Codex uses built-in `tui.status_line` item identifiers.
- Validate config changes with `codex --strict-config doctor --summary --ascii --no-color` when Codex is installed.
- Validate helper changes with `python3 -m py_compile llm-agents/codex/scripts/merge_codex_config.py`.
