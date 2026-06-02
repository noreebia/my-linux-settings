# Claude Code Assets Guide

This subtree is the source for Claude Code runtime assets copied into `~/.claude/` by `priority_05_update_claude_code_settings.sh`.

## Contents

- `settings.json`: merged into `~/.claude/settings.json`; source keys overwrite existing keys, while existing-only keys are preserved.
- `statuslines/`: shell statusline implementations. `settings.json` currently points at `~/.claude/statuslines/default-v3.sh`.
- `skills/`: reusable skill definitions. These are also synced into Codex by the Codex updater, excluding `CLAUDE.md`.
- `commands/`: Claude Code command snippets.

## Editing Rules

- Keep `settings.json` free of user-specific secrets. It should contain reusable defaults, permissions, and runtime paths only.
- Statusline scripts should tolerate missing tools or missing JSON fields and exit cleanly; they run frequently inside the TUI.
- If a Claude asset is also consumed by Codex, keep the content agent-neutral or add Codex-specific handling in the Codex updater.
- After changing `settings.json`, validate with `jq . llm-agents/claude-code/settings.json` when `jq` is available.
- After changing a statusline script, run `bash -n <script>` at minimum.

