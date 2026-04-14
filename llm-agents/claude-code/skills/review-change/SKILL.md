---
name: review-change
description: >
  Reviews code changes for correctness, design, security, and maintainability. Works with unstaged
  changes, commits, or branch diffs.
argument-hint: "[--scope=<scope>] [--file]"
---

# Code Review

Review code changes and produce honest, actionable feedback. Focus on real problems — not style nitpicks.

---

## Arguments

- **`--scope=<scope>`** *(optional, default: `unstaged`)*: Which code changes to review. Accepts:
  - `unstaged` — working tree changes
  - `commit` — the last commit
  - `commit-N` — the last N commits (e.g., `commit-3`)
  - `branch` — all changes since diverging from the parent branch. **Do NOT assume the parent branch is `main` or `master`** — you MUST detect it using the procedure in the Process section below before running any diff.
  - *`<branch-name>`* — any other value is treated as a target branch to diff against (e.g., `develop`, `staging`). This is the "review before merging" mode.
- **`--file`** *(optional flag)*: Write the review to a markdown file.

## Examples

    /review-change --scope=unstaged
    /review-change --scope=commit
    /review-change --scope=branch --file
    /review-change --scope=commit-3
    /review-change --scope=develop --file

---

## Process

### 1. Gather the changes

| Scope | Command |
|-------|---------|
| `unstaged` | `git diff` |
| `commit` | `git log -1 -p` |
| `commit-N` | `git log -N -p` |
| `branch` | Detect the parent branch — do NOT assume `master` or `main`. Check which of `develop`, `main`, `master` exists and pick the one with the fewest commits from HEAD (smallest `git rev-list --count <branch>..HEAD`). Ask the user if ambiguous. Then `git diff <parent>...HEAD`. |
| `<branch-name>` | Verify branch exists (`git rev-parse --verify`), then `git diff <branch-name>...HEAD` |

Also run `git diff --stat` for a file-level summary. If the diff is empty, tell the user and stop.

Read key changed files in full for context — don't review blindly from a diff.

### 2. Review and write up

Prioritize by severity. Lead with bugs, security issues, and data loss risks. Don't waste the reader's time with trivial suggestions.

The review should include:

- An overview of what the changes do and overall quality assessment
- Issues grouped by severity (critical / important / minor) — each with location, why it matters, and a suggested fix
- What's done well (genuinely — helps the author know what to keep doing)
- A verdict: approve, request changes, or needs discussion

Adapt depth to the size of the changes. A 10-line fix doesn't need the same treatment as a 500-line feature.

### 3. Output or save

- **Inline** (default): Output directly in the conversation. Omit the metadata header (`*Reviewed: ... | Author: ...*`).
- **File** (if `--file` was given): Include the metadata header: `*Reviewed: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Scope: <git scope used> | Branch: <current branch>*`. Write to `$AGENT_LOCAL_DIR/code-reviews/<descriptive-name>.md`. Tell the user where it was saved.
