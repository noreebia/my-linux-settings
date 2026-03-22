---
name: sync-aliases
description: >
  Sync aliases from zsh/aliases.sh into priority_01_install_zsh_2.sh so they get registered in
  .zshrc during setup. Use this skill whenever the user adds, removes, or changes an alias in
  aliases.sh and wants the install script updated to match — triggered by phrases like "sync my
  aliases", "update the install script", "I added a new alias", "aliases are out of sync", or any
  time aliases.sh and priority_01_install_zsh_2.sh may have drifted apart.
---

# Sync Aliases

Keep `zsh/aliases.sh` and `priority_01_install_zsh_2.sh` in sync. `aliases.sh` is the single source of truth — the install script must register exactly what's in it, nothing more, nothing less.

---

## Files

| File | Role |
|---|---|
| `zsh/aliases.sh` | **Source of truth.** The canonical list of aliases and functions. |
| `priority_01_install_zsh_2.sh` | **Target.** Registers everything from `aliases.sh` into `~/.zshrc` at setup time. |

---

## Step 1 — Parse both files

**From `aliases.sh`, extract:**
- Every `alias name=value` line
- Every shell function definition (`name() { ... }`)
- Any alias that references a function defined in the same file (e.g. `alias git-sync-all='git_sync_all'` — note it's a companion to the `git_sync_all()` function and must stay grouped with it)

**From `priority_01_install_zsh_2.sh`, extract all existing registrations** in the alias section (everything between the `# register aliases` comment and the `cp -r` line near the end).

---

## Step 2 — Diff and decide

Compare the two lists and categorize every item:

| Category | Action |
|---|---|
| In `aliases.sh`, **not** in install script | **Add** a registration block |
| In install script, **not** in `aliases.sh` | **Remove** the registration block |
| In both, but value differs | **Update** the registration to match `aliases.sh` |
| In both, value matches | No change needed |

---

## Step 3 — Escaping (read this carefully before writing any line)

This is the hardest part. The install script writes shell code as strings — so characters that are special to the shell must be escaped an extra level.

### Three registration patterns

**Pattern A — Simple alias** (no single-quotes or `$` in the value):
```bash
grep -q 'alias name=' ~/.zshrc || echo 'alias name="value"' >> ~/.zshrc
```
Use single-quotes around the entire `echo` argument. Safe for values that only contain double-quotes internally.

---

**Pattern B — Alias whose value contains single-quotes** (e.g. the `awk` aliases):

In `aliases.sh`:
```bash
alias git-prune-local="git fetch -p && git branch -vv | awk '/: gone] / {print \$1}' | xargs -r git branch -D"
```

The value contains `'...'` (single-quoted awk pattern) and `\$1`. In the install script this must become:
```bash
grep -q 'alias git-prune-local=' ~/.zshrc || echo 'alias git-prune-local="git fetch -p && git branch -vv | awk '"'"'/: gone] / {print \$1}'"'"' | xargs -r git branch -D"' >> ~/.zshrc
```

The `'"'"'` sequence is how you embed a literal single-quote inside a single-quoted string:
- `'` — close the current single-quote
- `"'"` — a double-quoted literal single-quote
- `'` — reopen the single-quote

The `\$1` in `aliases.sh` stays as `\$1` in the install script — single-quoted strings don't expand `$`, so no additional escaping is needed.

**Rule of thumb:** Every `'` inside the alias value needs to become `'"'"'` in the install script's `echo` line.

---

**Pattern C — Shell function** (single or multi-line body):

```bash
grep -q 'funcname()' ~/.zshrc || cat >> ~/.zshrc << 'EOF'
funcname() {
  # body copied verbatim from aliases.sh
}
EOF
```

Use a quoted heredoc (`<< 'EOF'`) so the shell does **not** expand `$`, backticks, or anything else inside. Copy the function body **exactly** from `aliases.sh` — indentation, comments, and all.

If a function has a companion alias (like `git_sync_all` and `alias git-sync-all='git_sync_all'`), register the companion alias **immediately after** the function's `EOF` block — keep them grouped.

---

## Step 4 — Make the changes

### Insertion point

New registrations go **after the last existing alias/function block**, and **before** this line near the end of the file:
```bash
cp -r ./zsh/.oh-my-zsh/* ~/.oh-my-zsh/
```

The plugin-installation section at the top of the file (the `git clone` and `for plugin in` blocks) must not be touched.

### Removing a stale registration

For a **simple alias** line — delete the single `grep -q ... || echo ...` line.

For a **function block** — delete from the `grep -q 'funcname()'` line through its closing `EOF` line, inclusive. If there's a companion alias line immediately after (e.g. `grep -q 'alias git-sync-all=' ...`), delete that too.

### Updating a changed value

Replace the old registration line/block with a new one using the correct pattern for the alias type. Don't try to do an in-place sed substitution on complex lines — replace the whole registration block.

---

## Step 5 — Summarise

After making all changes, tell the user:

- **Added:** list of alias/function names added to the install script
- **Removed:** list of names removed
- **Updated:** list of names whose values were changed
- **Unchanged:** count of items that were already in sync

If everything was already in sync, say so clearly and make no changes.
