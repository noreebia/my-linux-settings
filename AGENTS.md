# Repository Guide

This is a personal Linux settings repository. It bootstraps and refreshes a working shell environment, tmux configuration, and LLM coding-agent configuration on Ubuntu/Debian-style systems.

## Mental Model

- The setup/update entrypoints live under `scripts/`. They copy checked-in config into `$HOME`, install small dependencies, or update agent config. Run individual scripts from the repository root.
- `configure.sh` runs the main setup scripts in order. It changes into the repository directory before running scripts.
- `llm-agents/AGENTS_GLOBAL.md` is not this repository's instruction file. It is the shared runtime instruction source copied into Claude, Codex, and Gemini config directories.
- Directory-local `AGENTS.md` files explain how to edit each subtree inside this repository.

## Layout

- `scripts/` holds the general package installer and setup scripts grouped under `zsh/`, `tmux/`, `llm-agents/`, and `mise/`.
- `zsh/` holds Oh My Zsh custom files copied into `~/.oh-my-zsh/`.
- `tmux/` holds `tmux.conf`, copied to `~/.tmux.conf`.
- `llm-agents/` holds shared agent instructions and per-agent configuration.
- `scripts/llm-agents/update_claude_code_settings.sh` deploys Claude Code settings, statuslines, and skills to `~/.claude/`.
- `scripts/llm-agents/update_codex_settings.sh` deploys Codex instructions, skills, and Codex TUI config to `~/.codex/`.
- `scripts/llm-agents/update_gemini_settings.sh` deploys shared instructions and skills to `~/.gemini/`.

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

