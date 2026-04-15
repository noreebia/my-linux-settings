---
name: prune-zshrc
description: >
  Removes redundant aliases, functions, and shell options from ~/.zshrc that are
  already defined in zsh/.oh-my-zsh/custom/my_settings.zsh. Use this skill whenever
  the user mentions "prune zshrc", "clean up zshrc", "remove duplicate aliases",
  "zshrc has duplicates", "deduplicate zshrc", "zshrc cleanup", or asks to remove
  things from .zshrc that are already in my_settings.zsh or the oh-my-zsh custom
  directory. Also use when the user says their .zshrc is bloated, has old aliases,
  or needs trimming.
---

# Prune ~/.zshrc

Remove lines from `~/.zshrc` that are already covered by `zsh/.oh-my-zsh/custom/my_settings.zsh`. Since Oh My Zsh auto-sources all `*.zsh` files in its custom directory, anything defined in `my_settings.zsh` does not need to also live in `~/.zshrc`.

---

## Why this matters

The install script deploys `my_settings.zsh` to `~/.oh-my-zsh/custom/` via `cp -r`. Oh My Zsh sources it automatically. Over time, the same aliases and functions accumulate in `~/.zshrc` from old install script runs or manual additions. These duplicates are harmless but confusing — the later definition silently wins, which can mask stale values.

---

## Step 1 — Parse my_settings.zsh

Read `zsh/.oh-my-zsh/custom/my_settings.zsh` (relative to the repo root) and extract:

- **Aliases**: every `alias <name>=` line. The key is the alias name (everything before `=`).
- **Functions**: every function definition (`<name>() {`). The key is the function name.
- **Companion aliases**: an alias whose value is a function name from the same file (e.g., `alias git-sync-all='git_sync_all'`). These are still aliases — just note they belong with their function.
- **Shell options**: `setopt` / `unsetopt` lines.

Build a checklist of these items — you'll match against them in the next step.

---

## Step 2 — Scan ~/.zshrc for redundant items

Read `~/.zshrc` and identify every line or block that matches an item from Step 1:

### Matching rules

| Item type | Match by | What to remove |
|---|---|---|
| Alias | Alias **name** (e.g., `alias upd=` matches `alias upd=` regardless of value) | The single line |
| Function | Function **name** (e.g., `cdc()` matches `cdc()`) | The entire block from the line containing `name()` through the matching closing `}` at the same indentation level |
| Shell option | Exact option name (e.g., `setopt NULL_GLOB`) | The single line |

Matching is by **name**, not value. If `~/.zshrc` has `alias upd="apt update"` and `my_settings.zsh` has `alias upd="sudo apt update && sudo apt upgrade -y"`, the one in `~/.zshrc` is still redundant — `my_settings.zsh` is the source of truth and its version will win at runtime anyway.

### Items to keep

Everything in `~/.zshrc` that does **not** have a matching name in `my_settings.zsh` must be kept. This includes machine-specific config, PATH exports, eval statements, plugin config, theme settings, and any aliases/functions/options unique to this machine.

---

## Step 3 — Present the plan

Before making any changes, show the user two lists:

**Will remove** — each redundant item with its line number(s) and type:
```
- Line 133: alias upd="..." (alias)
- Line 148-150: cdc() { ... } (function)
- Line 174: alias git-sync-all="..." (companion alias)
```

**Will keep** (unique to ~/.zshrc) — just the names and types, so the user can verify nothing important is being dropped:
```
- alias git="hub"
- alias cdcl="cd ~/code_linux"
- open() function
- export PATH="$HOME/.local/bin:$PATH"
```

Wait for the user to confirm before proceeding. If they flag something that should be kept, exclude it.

---

## Step 4 — Remove redundant items

Work through the removals. A few things to watch for:

- **Function blocks**: remove from the line containing `funcname()` (or `funcname ()`) through the closing `}` that ends the function. Be careful with nested braces — track brace depth.
- **Companion aliases**: if a function like `git_sync_all()` is removed, also remove its companion alias (e.g., `alias git-sync-all='git_sync_all'`) if it appears nearby.
- **Blank line cleanup**: after removing a block, if it leaves consecutive blank lines, collapse them down to at most one blank line. Don't leave gaps.
- **Comment lines**: if a comment line immediately precedes a removed item and clearly belongs to it (e.g., `# Usage: gh-publish [public|private]` right before `gh-publish()`), remove the comment too. Don't remove comments that are generic section headers or unrelated.

---

## Step 5 — Summarize

After making changes, report:

- **Removed**: list of item names and types that were removed
- **Kept**: list of unique items that remain in `~/.zshrc`
- **Action needed**: remind the user to run `source ~/.zshrc` to reload
