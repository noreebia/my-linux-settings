---
name: refresh-context
description: >
  Reads recent code changes and surrounding files into the agent's working context to catch up
  after another agent or session has modified the code.
argument-hint: "[--scope=<scope>]"
---

# Refresh Context

Catch up after another agent (or another session) has modified the code. The point is **not** to review, fix, or critique the changes — it's to replace stale assumptions in the agent's working memory with what's actually in the files now, so the next prompt operates on real current state.

This matters because LLM agents don't naturally re-read files between turns. They answer from whatever context they already have. If that context predates someone else's edits, the next response can be confidently wrong — referencing a function signature that no longer exists, repeating an "I'll add X" plan that was already done, or building on an approach that was rejected and replaced.

This is a **read-only** skill. It does not modify code.

---

## Arguments

- **`--scope=<scope>`** *(optional, default: `unstaged`)*: Which range of changes to absorb. Accepts:
  - `unstaged` — working tree changes
  - `commit` — the last commit
  - `commit-N` — the last N commits (e.g., `commit-3`)
  - `branch` — all changes since diverging from the parent branch. **Do NOT assume the parent branch is `main` or `master`** — you MUST detect it using the procedure in the Process section below before running any diff.
  - *`<branch-name>`* — any other value is treated as a target branch to diff against (e.g., `develop`, `staging`).

## Examples

    /refresh-context
    /refresh-context --scope=unstaged
    /refresh-context --scope=commit
    /refresh-context --scope=commit-3
    /refresh-context --scope=branch
    /refresh-context --scope=develop

---

## Process

### 1. Gather the changes

| Scope | Command |
|-------|---------|
| `unstaged` | `git diff` |
| `commit` | `git log -1 -p` |
| `commit-N` | `git log -N -p` |
| `branch` | Detect the parent branch — never assume or default to any branch. List every candidate that exists locally (`develop`, `main`, `master`, plus any like `staging`, `release`), run `git rev-list --count <candidate>..HEAD` for each, and pick the lowest. If candidates tie, ask the user — do not fall back to a guess. Then `git diff <parent>...HEAD`. |
| `<branch-name>` | Verify branch exists (`git rev-parse --verify`), then `git diff <branch-name>...HEAD` |

Run `git diff --stat` as well for a file-level summary. If the diff is empty, tell the user and stop — there's nothing to absorb.

### 2. Absorb the changes

Read each changed file **in full**. Don't rely on the diff alone. Both views matter:

- The **diff** highlights what's different from your prior mental model — i.e., where your assumptions might now be wrong.
- The **full file** anchors your understanding to the actual current state, including the unchanged regions that interact with the edits.

For non-trivial changes, also pull in closely-related files the diff implies are affected — direct callers of a changed function, tests for modified logic, sibling modules in the same feature area. You're rebuilding a coherent picture, not skimming isolated files.

**Opportunistically check for agent reports.** This repo's convention (see `llm-agents/CLAUDE.md`) is that agents write reports under `$AGENT_LOCAL_DIR/<category>/` (e.g., `agents/claude/code-reviews/`, `agents/claude/system-analysis/`). If recent files there appear to relate to the same change, read them too — they often explain the *why* behind edits the diff alone can't convey.

### 3. Reconcile and report

This is the part that makes the skill worth running. Produce a brief reconciliation, focused on changes to *your own* understanding — not a recap of the diff:

- **Stale prior statements** *(highest priority)*: If anything you previously asserted, planned, or recommended in this conversation is now contradicted by the changes, call it out explicitly with a one-line correction. The user needs to know which of your earlier outputs are no longer trustworthy.
- **Updated facts**: A handful of bullets capturing what you now know differently — signature changes, replaced approaches, removed/added behaviors, resolved TODOs. Frame in terms of *what changed in your model*, not what's in the diff.
- **Open questions**: Anything the diff makes ambiguous that the user may want to clarify before the next prompt — e.g., a partial refactor, a TODO left behind, a behavior change with no apparent test.

If nothing in the changes contradicts your prior context (e.g., you had no relevant prior context, or the changes are purely additive in untouched areas), say so plainly. A short, honest "absorbed; no prior statements affected" is more useful than padding.

Keep the report tight. Its job is to confirm absorption and surface what now needs to be unlearned — not to summarize the work that was done.
