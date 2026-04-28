---
name: oversee-changes
description: >
  Reviews code changes for correctness, flaws, bugs, and elegance, then applies fixes directly to
  the working tree when improvements can be made.
argument-hint: "[--scope=<scope>]"
---

# Oversee Changes

Review code changes against four criteria and **fix what you find** — don't just report. The output of this skill is improved code in the working tree, not a written review.

The four criteria:

1. **Works as intended** — the code does what the surrounding context (commit message, plan, callers, tests, types) implies it should do.
2. **No glaring flaws** — no obvious design mistakes, missed cases, dead branches, or contradictions with the rest of the codebase.
3. **No bugs or problems** — no incorrect logic, off-by-ones, race conditions, resource leaks, security issues, or runtime errors waiting to happen.
4. **Elegant solution** — clear, idiomatic, appropriately abstracted; not over- or under-engineered for the task.

---

## Arguments

- **`--scope=<scope>`** *(optional, default: `unstaged`)*: Which code changes to oversee. Accepts:
  - `unstaged` — working tree changes
  - `commit` — the last commit
  - `commit-N` — the last N commits (e.g., `commit-3`)
  - `branch` — all changes since diverging from the parent branch. **Do NOT assume the parent branch is `main` or `master`** — you MUST detect it using the procedure in the Process section below before running any diff.
  - *`<branch-name>`* — any other value is treated as a target branch to diff against (e.g., `develop`, `staging`).

## Examples

    /oversee-changes
    /oversee-changes --scope=unstaged
    /oversee-changes --scope=commit
    /oversee-changes --scope=commit-3
    /oversee-changes --scope=branch
    /oversee-changes --scope=develop

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

Also run `git diff --stat` for a file-level summary. If the diff is empty, tell the user and stop.

Read each changed file in full — you need the surrounding code to judge intent and fix correctly. For large changes, also read closely-related files (callers, tests, sibling modules) when needed.

### 2. Evaluate against the four criteria

Go through the changes and identify issues in each category:

- **Works as intended** — cross-check against commit messages, function names, types, comments, tests, and how the new code is called. Look for mismatches between what the code *says* it does and what it *actually* does.
- **Glaring flaws** — missed edge cases, contradictory logic, code that's reachable but does the wrong thing, violations of conventions clearly established elsewhere in the same codebase.
- **Bugs and problems** — incorrect operators, wrong variable used, null/undefined hazards, mutation of shared state, off-by-one, silent failures, leaked resources, race conditions, security issues, broken error paths.
- **Elegance** — unnecessary complexity, dead code, duplicated logic, awkward abstractions, missing abstractions where the same pattern repeats, poor naming that obscures meaning, comments that explain *what* instead of *why*.

Be honest. If the changes are already good across all four criteria, that is a valid outcome — proceed to step 4 and report it.

### 3. Apply fixes

Modify the code directly. Default behavior by criterion:

- **Correctness, flaws, bugs (criteria 1–3)** — fix unconditionally. These are objective problems.
- **Elegance (criterion 4)** — fix only when the improvement is *unambiguous* (e.g., dead code, obvious duplication, a clearly better idiom). If the change is a judgment call where reasonable engineers would disagree, do **not** modify; surface it as a suggestion in the final summary instead.

Stay inside the scope of the changes being overseen. Do not refactor untouched code, do not expand the diff to unrelated files, and do not introduce new abstractions that weren't already implied by the changes. The goal is to leave the author's work intact and improved, not to rewrite it.

If a fix would be large or significantly alter the author's approach, stop and propose it instead of applying it. The bar is: would the original author recognize this as "the same change, fixed up" rather than "a different change"?

After each fix, re-read the surrounding code briefly to confirm the fix is consistent and didn't introduce a new problem.

### 4. Report

Output a concise summary in the conversation covering:

- **What was overseen** — the scope and the rough size of the diff.
- **Fixes applied** — bulleted list, each with file:line and a one-line reason. Group by criterion.
- **Suggestions not applied** — anything from criterion 4 (or larger criterion 1–3 fixes) that you chose to surface instead of modifying. Include file:line and why you held back.
- **Clean areas** — briefly note what looked good, so the author knows what to keep doing.

Keep the report proportional to the work. A small clean diff with one fix needs two sentences, not a structured report.
