# tmux Guide

This directory contains tmux configuration copied to `~/.tmux.conf` by `priority_02_setup_tmux.sh`.

## Editing Rules

- Keep the file compatible with the tmux version commonly available on Ubuntu/Debian.
- The config assumes `xclip` for clipboard copy/paste behavior. If changing clipboard integration, update the setup script if a new dependency is required.
- Preserve the current ergonomic intent: prefix `Ctrl-s`, mouse support, Vim-style pane navigation, large scrollback, visible status, and system-clipboard paste.
- Validate with `tmux source-file tmux/tmux.conf` in a tmux session when practical.

