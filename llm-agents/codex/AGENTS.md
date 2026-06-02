# Codex Assets Guide

This subtree is the source for Codex runtime config copied or merged into `~/.codex/` by `priority_05_update_codex_settings.sh`.

## Contents

- `config.toml`: reusable Codex configuration. Currently it defines the TUI statusline only.
- `scripts/merge_tui_config.py`: merges the statusline settings into a live `~/.codex/config.toml` without replacing project trust, auth, MCP, or other user-specific settings.

## Editing Rules

- Do not check in a full live `~/.codex/config.toml`; it may contain trust records, MCP headers, and other private state.
- Keep `config.toml` focused on reusable settings that should be installed everywhere this repo is used.
- If Codex adds first-class script-backed statuslines later, update the merge helper and config deliberately; current Codex uses built-in `tui.status_line` item identifiers.
- Validate config changes with `codex --strict-config doctor --summary --ascii --no-color` when Codex is installed.
- Validate helper changes with `python3 -m py_compile llm-agents/codex/scripts/merge_tui_config.py`.

