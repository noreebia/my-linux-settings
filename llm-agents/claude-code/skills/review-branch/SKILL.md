---
name: review-branch
description: >
  Final merge-readiness review of the current branch. Evaluates implementation quality, regression
  risks, backwards compatibility, test coverage, and loose ends to produce a go/no-go verdict.
argument-hint: "[--file]"
---

# Review Branch

Assess the entire branch as a coherent unit of work and determine if it's ready to merge. The output is a verdict — merge, merge with caveats, or block — with specific reasons.

---

## Arguments

- **`--file`** *(optional flag)*: Write the review to a markdown file instead of outputting inline.

## Examples

    /review-branch
    /review-branch --file

---

## Process

### 1. Detect the parent branch

Do NOT assume the parent is `main` or `master`. Check which of `develop`, `main`, `master` (and any other long-lived branches) exists locally and pick the one with the fewest commits from HEAD (`git rev-list --count <candidate>..HEAD`). Ask the user if ambiguous.

### 2. Gather context and understand intent

Diff against the parent branch (stat + full diff), read the commit log, check `git status` for uncommitted work. Read key changed files in full — the diff shows *what* changed, the files show *whether it was done well*.

Before evaluating, understand what this branch is trying to accomplish. A branch that's well-written but only half-implements the feature isn't ready to merge.

### 3. Evaluate merge readiness

Assess these dimensions, adapting depth to the branch's size:

- **Implementation quality** — Is the intended change complete and well-implemented? This is a higher-level assessment than a line-by-line code review.
- **Regression risk** — Could these changes break existing functionality? Trace outward: what calls it, what depends on it, what assumptions does surrounding code make?
- **Backwards compatibility** — If public APIs, data schemas, or shared interfaces changed, assess impact on existing consumers.
- **Test coverage** — Do tests exist where they should? Are existing tests updated for changed behavior? Stale tests that pass but no longer test the right thing are worse than missing tests.
- **Loose ends** — Unresolved TODOs/FIXMEs, commented-out code, debug logging, uncommitted changes, merge conflict markers.

### 4. Produce the verdict

Lead with the bottom line: **ready to merge**, **merge with caveats**, or **blocked**. Follow with a branch summary, findings grouped by severity, and what's done well.

If an issue warrants deeper analysis, suggest the appropriate skill (`review-change`, `assess-backwards-compatibility`, etc.) rather than replicating their full process.

### 5. Output or save

- **Inline** (default): Output directly in the conversation. Omit the metadata header.
- **File** (if `--file`): Include header: `*Reviewed: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Branch: <current branch> → <parent branch> | Commits: <count>*`. Write to `$AGENT_LOCAL_DIR/code-reviews/$CURRENT_TIME("YYYYMMDDHHMM")-<branch-name>-review.md`.

---

## Constraints

- **Read-only** — do not modify files, fix issues, or make commits.
- **Diff is ground truth** — if commit messages conflict with the diff, trust the diff.
