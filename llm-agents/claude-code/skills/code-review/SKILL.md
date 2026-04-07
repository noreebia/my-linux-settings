---
name: code-review
description: >
  Review code changes and produce actionable feedback on correctness, design, security, and
  maintainability. Use this skill whenever the user wants a code review — triggered by phrases
  like "review my code", "code review", "review these changes", "check my code before merging",
  "review what I've done", "look over my changes", "review this diff", "review before I push",
  or any time the user wants feedback on code changes before committing, pushing, or opening a PR.
  Also trigger proactively when the user finishes a block of work and says things like
  "I think this is ready" or "take a look at this".
argument-hint: "[scope] [--file]"
---

# Code Review

Review code changes and produce honest, actionable feedback. Focus on real problems — not style nitpicks.

---

## Arguments

- **scope** *(positional, optional, default: `unstaged`)*: Which code changes to review. Accepts:
  - `unstaged` — working tree changes
  - `commit` — the last commit
  - `commit-N` — the last N commits (e.g., `commit-3`)
  - `branch` — all changes since diverging from the base branch
  - *`<branch-name>`* — any other value is treated as a target branch to diff against (e.g., `develop`, `staging`). This is the "review before merging" mode.
- **`--file`** *(optional flag)*: Write the review to a markdown file.

## Examples

    $code-review
    $code-review commit
    $code-review branch --file
    $code-review commit-3
    $code-review develop --file

---

## Process

### 1. Gather the changes

| Scope | Command |
|-------|---------|
| `unstaged` | `git diff` |
| `commit` | `git log -1 -p` |
| `commit-N` | `git log -N -p` |
| `branch` | Auto-detect the parent branch (check upstream tracking branch, then fall back to finding the nearest common ancestor among remote branches), then `git diff <parent>...HEAD`. Ask the user if detection is ambiguous. |
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
