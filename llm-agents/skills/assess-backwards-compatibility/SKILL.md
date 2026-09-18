---
name: assess-backwards-compatibility
description: >
  Assesses whether code changes or a proposed plan maintain backwards compatibility with existing
  functionality.
argument-hint: "[--scope=<scope>] [--plan=<path>]"
---

# Assess Backwards Compatibility

Analyze code changes or a proposed plan and assess whether they preserve existing behavior. The goal is not to block incompatibilities but to surface them clearly — what changes, what doesn't, and what you as the engineer need to be aware of before merging or implementing.

---

## Arguments

- **`--scope=<scope>`** *(optional, required if `--plan` is not given)*: Which code changes to assess. Accepts:
  - `unstaged` — unstaged changes in the working tree
  - `commit` — the last commit
  - `commit-N` — the last N commits (e.g., `commit-3`)
  - `branch` — all commits on the current branch since it diverged from the parent branch. **Do NOT assume the parent branch is `main` or `master`** — you MUST detect it using the procedure in the Process section below before running any diff.
  - *`<branch-name>`* — any other value is treated as a target branch to diff against
- **`--plan=<path>`** *(optional)*: Path to a plan, spec, or design document (or a directory containing multiple plan documents) to assess instead of (or in addition to) a code diff. When used without `--scope`, the assessment is based on the plan's proposed changes against the current codebase.

## Examples

    /assess-backwards-compatibility --scope=commit
    /assess-backwards-compatibility --scope=branch
    /assess-backwards-compatibility --scope=commit-3
    /assess-backwards-compatibility --scope=develop
    /assess-backwards-compatibility --plan=agents/claude/plans/auth-migration.md
    /assess-backwards-compatibility --scope=branch --plan=agents/claude/plans/auth-migration.md

---

## Process

### 1. Gather the changes and surrounding context

**If `--scope` was given** — collect the diff:

| Scope | Command |
|-------|---------|
| `unstaged` | `git diff` |
| `commit` | `git log -1 -p` |
| `commit-N` | `git log -N -p` |
| `branch` | Detect the parent branch — never assume or default to any branch. List every candidate that exists locally (`develop`, `main`, `master`, plus any like `staging`, `release`), run `git rev-list --count <candidate>..HEAD` for each, and pick the lowest. If candidates tie, ask the user — do not fall back to a guess. Then `git diff <parent>...HEAD`. |
| `<branch-name>` | Verify branch exists (`git rev-parse --verify`), then `git diff <branch-name>...HEAD` |

Run `git diff --stat` for a file-level summary. Read key changed files in full — you need the before-and-after context, not just the diff lines, to assess behavioral impact.

**If `--plan` was given** — read the plan document. If the path is a directory, read all documents within it and treat them as a single combined plan. Identify every proposed change: new files, modified files, changed interfaces, altered behavior, removed functionality. Then explore the current codebase to understand what exists today in those areas — read the files the plan intends to modify, trace their callers and dependents, check how they're imported and used. You need the current state to predict what the proposed changes would break.

**If both `--scope` and `--plan` were given** — gather both. Use the plan for intent and the diff for what was actually implemented. Assess compatibility based on the concrete diff, but flag any plan items not yet implemented that would also affect compatibility.

### 2. Assess backwards compatibility

For each changed area, trace what depends on it and determine what would break. Prioritize by real risk — behavioral changes and altered contracts matter most. For opt-in changes (feature flags, new parameters), verify the system behaves identically when not opted in. Adapt depth to the scope of the changes.

### 3. Produce the assessment

Output directly in the conversation. Structure the assessment as:

**Summary** — one-paragraph verdict: is this change backwards compatible, partially compatible, or breaking? Set expectations upfront.

**Compatibility Breakdown** — walk through each finding. Group by category (additive, behavioral, contractual, structural). For each:
- What changed and where
- Classification and reasoning
- Whether it's opt-in and what happens when not opted in
- Impact on existing code paths and dependents

**Risk Assessment** — highlight the changes most likely to cause real problems. Distinguish between theoretical risks and likely ones based on how the code is actually used.

**Recommendations** — concrete suggestions for preserving compatibility where it's at risk. These are advisory, not prescriptive — the user decides what to act on.

Adapt depth to the size and nature of the changes. A small additive feature needs a lighter touch than a refactor that touches shared interfaces.
