# Claude Code Assets Guide

This subtree is the source for Claude Code runtime assets copied into `~/.claude/` by `priority_05_update_claude_code_settings.sh`.

## Contents

- `settings.json`: merged into `~/.claude/settings.json`; source keys overwrite existing keys, while existing-only keys are preserved.
- `statuslines/`: shell statusline implementations. `settings.json` currently points at `~/.claude/statuslines/default-v3.sh`.
- `commands/`: Claude Code command snippets.

Shared skills live in `../skills/` and are deployed separately to `~/.claude/skills/` by the Claude updater.

## Editing Rules

- Keep `settings.json` free of user-specific secrets. It should contain reusable defaults, permissions, and runtime paths only.
- Statusline scripts should tolerate missing tools or missing JSON fields and exit cleanly; they run frequently inside the TUI.
- Put cross-agent skills in `../skills/`. Keep this subtree for Claude-specific settings, commands, and presentation assets.
- After changing `settings.json`, validate with `jq . llm-agents/claude-code/settings.json` when `jq` is available.
- After changing a statusline script, run `bash -n <script>` at minimum.
