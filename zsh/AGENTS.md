# zsh Guide

This directory contains shell customization copied into `~/.oh-my-zsh/` by `scripts/zsh/2_configure_essential_plugins.sh`.

`scripts/zsh/1_initialize_sh.sh` installs Zsh and Oh My Zsh. `scripts/zsh/3_configure_zioxide.sh` installs zoxide and fzf when missing and adds zoxide initialization to the user's `.zshrc`.

## Contents

- `.oh-my-zsh/custom/main.zsh`: general aliases and helper functions.
- `.oh-my-zsh/custom/work_epapyrus.zsh`: work-specific helpers and aliases.
- `.oh-my-zsh/custom/wsl.zsh`: WSL-only helpers. The installer removes it from `~/.oh-my-zsh/custom/` on non-WSL systems.

## Editing Rules

- Write shell code for zsh, not Bash, unless the function deliberately shells out.
- Keep helpers idempotent and guarded. Avoid aliases or functions that delete files without an explicit path and safety check.
- If adding a dependency, update the relevant setup script under `scripts/zsh/` so a fresh machine can use the helper.
- Keep machine-specific settings and secrets from live `~/.zshrc` out of the repository.

