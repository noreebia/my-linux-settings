# zsh Guide

This directory contains shell customization copied into `~/.oh-my-zsh/` by `priority_01_install_zsh_2.sh`.

## Contents

- `.oh-my-zsh/custom/my_settings.zsh`: general aliases and helper functions.
- `.oh-my-zsh/custom/work_epapyrus.zsh`: work-specific helpers and aliases.
- `.oh-my-zsh/custom/wsl.zsh`: WSL-only helpers. The installer removes it from `~/.oh-my-zsh/custom/` on non-WSL systems.

## Editing Rules

- Write shell code for zsh, not Bash, unless the function deliberately shells out.
- Keep helpers idempotent and guarded. Avoid aliases or functions that delete files without an explicit path and safety check.
- If adding a dependency, update the relevant priority script so a fresh machine can use the helper.
- Be careful with `update_repo_files.sh`: it may copy live `~/.zshrc` into `zsh/.zshrc` if that file exists in future. Do not accidentally commit private shell config.

