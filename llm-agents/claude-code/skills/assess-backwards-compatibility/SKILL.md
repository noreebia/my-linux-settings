---
name: assess-backwards-compatibility
description: >
  Assess whether code changes maintain backwards compatibility with existing functionality.
  Use this skill whenever the user wants to understand the compatibility impact of changes —
  triggered by phrases like "is this backwards compatible", "will this break anything",
  "check backwards compatibility", "assess compatibility", "does this affect existing behavior",
  "is this safe to ship", "will this affect existing code", or any time the user wants to
  understand whether changes preserve existing behavior. Also trigger when the user finishes
  a feature and wants to verify it won't break existing code paths or dependent modules.
---

# Assess Backwards Compatibility

Analyze code changes and assess whether they preserve existing behavior. The goal is not to block incompatibilities but to surface them clearly — what changes, what doesn't, and what you as the engineer need to be aware of before merging.

---

## Arguments

- **scope** *(required)*: Which code changes to assess. Accepts:
  - `unstaged` — unstaged changes in the working tree
  - `commit` — the last commit
  - `commit-N` — the last N commits (e.g., `commit-3`)
  - `branch` — all commits on the current branch since it diverged from the base branch
  - *`<branch-name>`* — any other value is treated as a target branch to diff against

---

## Process

### 1. Gather the changes and surrounding context

Collect the diff using the `scope` argument:

| Scope | Command |
|-------|---------|
| `unstaged` | `git diff` |
| `commit` | `git log -1 -p` |
| `commit-N` | `git log -N -p` |
| `branch` | `git diff <base>...HEAD` (check `main`, `master`, `develop` for base; ask if ambiguous) |
| `<branch-name>` | Verify branch exists (`git rev-parse --verify`), then `git diff <branch-name>...HEAD` |

Run `git diff --stat` for a file-level summary. Read key changed files in full — you need the before-and-after context, not just the diff lines, to assess behavioral impact.

### 2. Assess backwards compatibility

Evaluate every change from the perspective of the existing codebase: would anything that previously worked stop working or behave differently? Think in terms of callers, imports, dependent modules, tests, configurations, and integrations.

For each changed area, classify the change into one of these categories:

- **Additive** — new functionality that doesn't touch existing behavior (new endpoints, new optional fields, new modules). Existing code paths are unaffected.
- **Behavioral** — existing functionality now behaves differently under the same inputs or conditions (changed defaults, altered return values, modified side effects, different error handling). This is the highest-risk category.
- **Contractual** — changes to interfaces, signatures, types, schemas, or protocols that other code depends on (renamed fields, removed parameters, changed types, altered API contracts).
- **Structural** — internal reorganization that *should* be invisible externally but may leak (moved files, renamed internals that are imported elsewhere, changed module boundaries).

For each finding, determine:

1. **What changed** — the specific modification
2. **What depends on it** — which callers, modules, tests, or integrations rely on the previous behavior
3. **Is it opt-in?** — does the change only activate when explicitly enabled (feature flag, new parameter, configuration)? If opt-in, confirm that the system behaves identically when not opted in.
4. **Impact if not addressed** — what breaks or degrades in the existing codebase

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
