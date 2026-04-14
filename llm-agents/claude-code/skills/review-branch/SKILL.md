---
name: review-branch
description: >
  Perform a final merge-readiness review of the current branch — evaluating implementation quality,
  regression risks, backwards compatibility, and test coverage to determine if there are any blockers.
  Use this skill whenever the user wants a pre-merge assessment — triggered by phrases like
  "review this branch", "is this branch ready to merge", "final review before merging",
  "any blockers on this branch", "can I merge this", "pre-merge review", "review before PR",
  "is this ready to ship", "merge check", "branch review", or any time the user is about to merge
  or open a PR and wants a holistic quality check. Also trigger when the user says things like
  "I think this branch is done" or "ready to merge this into develop" — they're looking for
  a final sanity check, not just a code review.
argument-hint: "[--file]"
---

# Review Branch

Final merge-readiness review. Assess the entire branch as a coherent unit of work — not just whether the code is correct, but whether this branch is ready to land in the target branch without causing problems.

This is the last gate before merging. The output is a clear verdict: merge, merge with caveats, or block — with specific reasons.

---

## Arguments

- **`--file`** *(optional flag)*: Write the review to a markdown file instead of outputting inline.

## Examples

    /review-branch
    /review-branch --file

---

## Process

### 1. Detect the parent branch

Git doesn't record which branch a branch was created from, so you have to infer it by finding the nearest common ancestor. Do NOT assume the parent is `main` or `master`. Use this procedure:

1. List candidate base branches — at minimum check `develop`, `main`, `master`, but also include any other long-lived branches that exist locally (e.g., `staging`, `release`).
2. For each candidate, count how many commits on HEAD are not on that branch: `git rev-list --count <candidate>..HEAD`. The candidate with the **fewest** commits ahead is the most likely parent — it's the branch HEAD diverged from most recently.
3. If two candidates tie or the result is ambiguous, ask the user.

### 2. Gather the full picture

Run these in parallel where possible:

- `git diff --stat <parent>...HEAD` — file-level change summary
- `git diff <parent>...HEAD` — the full diff (ground truth)
- `git log --oneline <parent>..HEAD` — commit history on this branch
- `git status` — any uncommitted work still in flight

Read the most important changed files in full. The diff tells you *what* changed; reading the files tells you *whether it was done well*. Prioritize files that contain core logic, public interfaces, and tests over config and boilerplate.

### 3. Understand intent

Before evaluating quality, understand what this branch is trying to accomplish. Infer intent from:
- The branch name
- Commit messages (treat as hints, not truth — the diff takes precedence if they conflict)
- The nature and shape of the changes themselves

This matters because a good review evaluates whether the branch achieves its goal, not just whether the code compiles. A feature branch that's well-written but only half-implements the feature isn't ready to merge.

### 4. Evaluate merge readiness

Assess across these dimensions, adapting depth to the size and nature of the branch:

**Implementation quality** — Is the intended change implemented well? Look for correctness, edge cases, error handling, and design coherence. This isn't a line-by-line code review (that's what `review-change` is for) — it's a higher-level assessment of whether the implementation is solid and complete.

**Regression risk** — Could these changes break existing functionality? Trace outward from the changed code: what calls it, what depends on it, what assumptions does surrounding code make? Pay special attention to changes in shared modules, interfaces, config, and anything that other parts of the system rely on. Check for removed or renamed exports, changed function signatures, altered default values, and modified behavior in existing code paths.

**Backwards compatibility** — If this branch modifies public APIs, data schemas, config formats, or any interface consumed by external code or users, assess whether existing consumers would break. Additive changes are usually safe; modifications and removals need scrutiny.

**Test coverage** — Are the changes adequately tested? Check whether:
- New functionality has corresponding tests
- Changed behavior has updated tests (stale tests that still pass but no longer test the right thing are worse than no tests — they create false confidence)
- Edge cases and error paths are covered
- Tests are meaningful, not just present for coverage numbers

Don't require tests for trivial changes (config tweaks, typo fixes, documentation). Focus on whether the tests that *should* exist actually do.

**Loose ends** — Check for things that would be embarrassing to merge:
- TODOs or FIXMEs that should have been resolved on this branch
- Commented-out code that should be removed or restored
- Debug logging or temporary workarounds left behind
- Uncommitted changes that were probably meant to be included
- Merge conflicts or unresolved markers

### 5. Produce the verdict

Structure the review as:

**Verdict** — Lead with the bottom line. One of:
- **Ready to merge** — no blockers, ship it
- **Merge with caveats** — no hard blockers, but there are things to be aware of (list them)
- **Blocked** — specific issues that should be resolved before merging (list them)

**Branch summary** — 2–3 sentences on what this branch does, so the review is self-contained and readable even without prior context.

**Findings** — Walk through anything noteworthy across the evaluation dimensions above. Group by severity, not by dimension — a critical regression risk matters more than a minor test gap. For each finding:
- What the issue is and where it lives
- Why it matters (real impact, not theoretical purity)
- Suggested resolution if applicable

**What's done well** — Genuinely acknowledge good work. This isn't filler — it helps the author understand what to keep doing.

Adapt depth to the branch. A 3-commit bug fix gets a focused review. A 30-commit feature branch gets a thorough one. Don't pad a small review to look comprehensive, and don't rush through a large one.

### 6. Output or save

- **Inline** (default): Output directly in the conversation. Omit the metadata header.
- **File** (if `--file` was given): Include the metadata header: `*Reviewed: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Branch: <current branch> → <parent branch> | Commits: <count>*`. Write to `$AGENT_LOCAL_DIR/code-reviews/$CURRENT_TIME("YYYYMMDDHHMM")-<branch-name>-review.md`. Tell the user where it was saved.

---

## Constraints

- **Read-only**: Do not modify source files, fix issues, or make commits. This skill only evaluates and reports. If something needs fixing, the author decides how.
- **Diff is ground truth**: If commit messages describe something that doesn't match the diff, trust the diff. Code doesn't lie; commit messages are written by humans in a hurry.
- **Don't duplicate other skills**: This is a merge-readiness assessment, not a line-by-line code review (`review-change`), a plan compliance check (`review-implementation`), or a backwards compatibility deep-dive (`assess-backwards-compatibility`). If an issue warrants deeper analysis in one of those dimensions, note it in the findings and suggest running the appropriate skill — don't try to replicate their full process here.
