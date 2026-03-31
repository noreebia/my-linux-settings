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
---

# Code Review

Review code changes and produce honest, actionable feedback. Focus on real problems — not style nitpicks.

---

## Arguments

- **generate-file** *(1st, optional)*: Any truthy value (`true`, `yes`, `file`) writes the review to `$AGENT_DIR/code-reviews/` with a descriptive name based on the branch/scope and date. Tell the user where it was saved.
- **scope** *(2nd, optional)*: Which code changes to review. Defaults to `unstaged` if omitted. Accepts:
  - `unstaged` — working tree changes
  - `commit` — the last commit
  - `commit-N` — the last N commits (e.g., `commit-3`)
  - `branch` — all changes since diverging from the base branch
  - *`<branch-name>`* — any other value is treated as a target branch to diff against (e.g., `develop`, `staging`). This is the "review before merging" mode.

---

## Process

### 1. Gather the changes

| Scope | Command |
|-------|---------|
| `unstaged` | `git diff` |
| `commit` | `git log -1 -p` |
| `commit-N` | `git log -N -p` |
| `branch` | `git diff <base>...HEAD` (check `main`, `master`, `develop` for base; ask if ambiguous) |
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
- **File** (if `generate-file` was set): Include the metadata header. Write to `$AGENT_DIR/code-reviews/<descriptive-name>.md`. Tell the user where it was saved.

Use `$AGENT_NAME` for the author field in metadata headers.
