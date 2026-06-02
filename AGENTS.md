# Repository Guide

This is a personal Linux settings repository. It bootstraps and refreshes a working shell environment, tmux configuration, and LLM coding-agent configuration on Ubuntu/Debian-style systems.

## Mental Model

- The `priority_*.sh` files are setup/update entrypoints. They copy checked-in config into `$HOME`, install small dependencies, or update agent config.
- `configure.sh` runs the main priority scripts in order. It assumes it is executed from this repository and changes into the repo directory before running scripts.
- `update_repo_files.sh` is the reverse direction for selected files: it copies live user config from `$HOME` back into this repository.
- `llm-agents/AGENTS_GLOBAL.md` is not this repository's instruction file. It is the shared runtime instruction source copied into Claude, Codex, and Gemini config directories.
- Directory-local `AGENTS.md` files explain how to edit each subtree inside this repository.

## Layout

- `zsh/` holds Oh My Zsh custom files copied into `~/.oh-my-zsh/`.
- `tmux/` holds `tmux.conf`, copied to `~/.tmux.conf`.
- `llm-agents/` holds shared agent instructions and per-agent configuration.
- `priority_05_update_claude_code_settings.sh` deploys Claude Code settings, statuslines, and skills to `~/.claude/`.
- `priority_05_update_codex_settings.sh` deploys Codex instructions, skills, and Codex TUI config to `~/.codex/`.
- `priority_05_update_gemini_settings.sh` deploys shared instructions to `~/.gemini/`.

## Editing Rules

- Prefer preserving existing live user settings when update scripts touch `$HOME` config. Avoid replacing whole config files if the file may contain local trust records, auth settings, MCP credentials, or user-specific choices.
- Keep setup scripts idempotent where practical: rerunning them should not duplicate shell snippets, corrupt config, or fail just because a tool is already installed.
- Be careful with secrets. Do not copy tokens, credential files, or full live `~/.codex/config.toml` / `~/.claude/settings.json` content into the repo unless the user explicitly asks and the secret risk is addressed.
- Shell scripts are written for Bash and mostly Ubuntu/Debian. If adding dependencies, install them explicitly in the relevant script.
- Use ASCII for new repository files unless the existing file requires otherwise.

## Validation

Run the narrow checks that match the edit:

- Shell scripts: `bash -n <script>`
- Codex config: `python3 - <<'PY' ... tomllib.load(...) ... PY` or `codex --strict-config doctor --summary --ascii --no-color`
- Python helpers: `python3 -m py_compile <file>`
- General patch hygiene: `git diff --check`

