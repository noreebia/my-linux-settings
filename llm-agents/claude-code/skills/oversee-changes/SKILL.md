---
name: oversee-changes
description: >
  Reviews recent code changes against four criteria — works as intended, no glaring flaws, no
  bugs, elegant — and modifies the code directly to fix what's wrong.
argument-hint: "[--scope=<scope>]"
---

# Oversee Changes

Review code changes against four criteria and **fix what you find**. The deliverable is improved code in the working tree, not a written review.

The four criteria:

1. **Works as intended** — the code does what the surrounding context (commit message, plan, callers, tests, types, naming) implies it should do.
2. **No glaring flaws** — no obvious design mistakes, missed cases, dead branches, or contradictions with conventions clearly established elsewhere in the same codebase.
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

Run `git diff --stat` for a file-level summary too. If the diff is empty, tell the user and stop.

Read each changed file in full — the diff alone isn't enough context to judge intent or fix correctly.

### 2. Evaluate against the four criteria

Look at the changes as a whole and identify issues by category:

- **Works as intended** — cross-check against commit messages, function names, types, comments, tests, and how the new code is called. Look for mismatches between what the code *says* it does and what it *actually* does.
- **Glaring flaws** — missed edge cases, contradictory logic, code that's reachable but does the wrong thing, violations of conventions clearly established elsewhere.
- **Bugs and problems** — incorrect operators, wrong variable used, null/undefined hazards, mutation of shared state, off-by-one, silent failures, leaked resources, race conditions, security issues, broken error paths.
- **Elegance** — unnecessary complexity, dead code, duplicated logic, awkward abstractions, missing abstractions where the same pattern repeats, names that obscure meaning, comments that explain *what* instead of *why*.

If the changes are clean across all four, that's a valid outcome — proceed to step 4 and report it honestly.

### 3. Apply fixes

Modify the code directly. Default behavior by criterion:

- **Correctness, flaws, bugs (criteria 1–3)** — fix unconditionally. These are objective problems.
- **Elegance (criterion 4)** — fix only when the improvement is *unambiguous* (e.g., dead code, obvious duplication, a clearly better idiom). If the change is a judgment call where reasonable engineers would disagree, do **not** modify; surface it as a suggestion in the final summary instead.

**Adjacent files (outside the diff) — when allowed:** If a change in the diff causes a problem in a file outside the diff (e.g., a renamed/changed function whose caller is now broken, or a removed export still imported elsewhere), fix the adjacent file too. This keeps the codebase coherent.

This is the only reason to edit outside the diff. Do **not** use it as a license to refactor untouched code, improve naming in unrelated files, or apply elegance fixes to things the diff didn't touch. The test is: *would this adjacent file have been fine if the in-scope change hadn't happened?* If yes, the adjacent fix is in bounds. If no, leave it alone.

**Don't update tests.** If a fix changes behavior in a way that would benefit from a new test, surface that as a suggestion in the summary instead. Updating already-broken tests so they pass against the corrected behavior is fine; adding new tests is out of scope.

**Don't expand the diff with new abstractions.** The goal is the author's work, intact and improved — not a different implementation.

If a fix would be large enough to substantially alter the author's approach, stop and propose it instead of applying it. The bar: would the original author recognize this as "the same change, fixed up" rather than "a different change"?

After each fix, re-read the surrounding code briefly to confirm the fix is consistent and didn't introduce a new problem.

### 4. Report

After all fixes are done, produce a single summary in the conversation. Keep it proportional to the work — a small clean diff with one fix needs two sentences, not a structured report.

When there is something to report, group by category:

- **Bugs / flaws / correctness fixed** — each with file:line and a one-line reason. Call out adjacent-file edits explicitly so the user sees the diff grew beyond the original scope.
- **Elegance applied** — same format. Only the unambiguous cases.
- **Suggestions not applied** — judgment-call elegance fixes, places where adding a test seems warranted, or fixes that would substantially alter the author's approach. Each with file:line and why you held back.
- **Clean areas** — briefly note what looked good, so the author knows what to keep doing.

If nothing was worth fixing, say so honestly: a few bullets on what you looked at and why it held up. Don't pad — "the change is small, internally consistent, and the obvious edge cases are covered" is more useful than a synthetic positive review.
