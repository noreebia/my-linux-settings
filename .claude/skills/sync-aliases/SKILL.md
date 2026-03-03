---
name: sync-aliases
description: Sync aliases from zsh/aliases.sh into priority_01_install_zsh_2.sh so they get registered in .zshrc during setup.
disable-model-invocation: true
---

# Sync Aliases

Ensure every alias and function defined in `zsh/aliases.sh` is registered in `priority_01_install_zsh_2.sh`.

## Source of truth

`zsh/aliases.sh` is the canonical list of aliases and shell functions.

## Process

1. Read `zsh/aliases.sh` and extract every `alias name=...` line and every shell function (e.g. `cdc() { ... }`).
2. Read `priority_01_install_zsh_2.sh` and determine which of those aliases/functions are already being registered.
3. For each alias or function in `zsh/aliases.sh` that is **not** already handled in `priority_01_install_zsh_2.sh`, add a registration block using the existing patterns in the file:
   - For simple aliases: `grep -q 'alias name=' ~/.zshrc || echo 'alias name="value"' >> ~/.zshrc`
   - For multi-line alias groups that logically belong together: use `grep -q ... || cat >> ~/.zshrc << 'TAG' ... TAG` heredoc blocks, matching how the file already groups related aliases.
   - For shell functions: use `grep -q 'funcname()' ~/.zshrc || cat >> ~/.zshrc << 'EOF' ... EOF` blocks.
4. Also check the reverse: if `priority_01_install_zsh_2.sh` registers an alias or function that no longer exists in `zsh/aliases.sh`, remove that registration block from the script and tell the user what was removed.
5. If an alias exists in both files but with a **different value**, update the registration in `priority_01_install_zsh_2.sh` to match `zsh/aliases.sh`.
6. Present a summary of changes made (added, updated, removed).

## Important

- Preserve the overall structure and style of `priority_01_install_zsh_2.sh` (the plugin-installation section at the top must remain untouched).
- Keep alias values exactly as they appear in `zsh/aliases.sh` — pay attention to escaping (e.g. `\$1` in awk patterns needs to become `\\$1` inside the install script's heredocs/echo statements where the shell would otherwise expand it).
- Place new registrations in the alias/function section of the script (after the existing alias lines, before the final `echo` line).
