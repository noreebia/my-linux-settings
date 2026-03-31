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

Review code changes — whether unstaged work, recent commits, or an entire feature branch — and produce clear, actionable feedback. The review covers correctness, design, security, performance, and consistency with codebase conventions.

The goal is to catch real problems and surface meaningful improvements, not to nitpick style. Treat this like a review from a thoughtful senior colleague: honest, constructive, and focused on what matters.

---

## Arguments

- **generate-file** *(1st, optional)*: Any truthy value (`true`, `yes`, `file`) writes the review to a markdown file instead of outputting inline. The file is saved in the `$AGENT_DIR/code-reviews/` directory with a descriptive name based on the scope and current date (e.g., `feature-auth-2025-01-15.md`). Tell the user where the file was saved.
- **scope** *(2nd, optional)*: Which code changes to review. Defaults to `unstaged` if omitted. Accepts:
  - `unstaged` — unstaged changes in the working tree (`git diff`)
  - `commit` — the last commit (`git log -1 -p`)
  - `commit-N` — the last N commits (e.g., `commit-3` for the last 3 commits; `git log -N -p`)
  - `branch` — all changes on the current branch since it diverged from the base branch. Determines the base by checking for `main`, `master`, or `develop` (in that order). If ambiguous, ask the user.
  - *`<branch-name>`* — any other value is treated as a target branch name (e.g., `develop`, `staging`, `release/v2`). Diffs the current working tree against that branch (`git diff <branch-name>...HEAD`), showing what would change if you merged into it. This is the "review before merging" mode.

---

## Process

### 1. Gather the changes

Use the `scope` argument to collect the relevant diff.

| Scope | Command | What it shows |
|-------|---------|---------------|
| `unstaged` | `git diff` | Working tree changes not yet staged |
| `commit` | `git log -1 -p` | Patch of the last commit |
| `commit-N` | `git log -N -p` | Patches of the last N commits |
| `branch` | `git diff <base>...HEAD` | All changes since branching from base |
| `<branch-name>` | `git diff <branch-name>...HEAD` | All changes relative to the named branch |

For `branch` scope, determine the base branch by checking which of `main`, `master`, or `develop` exists as a remote-tracking branch (in that order). If multiple exist, prefer the one the current branch was most likely forked from. If truly ambiguous, ask the user.

For `<branch-name>` scope, first verify the branch exists (`git rev-parse --verify <branch-name>`). If it doesn't, tell the user and stop.

Also run `git diff --stat` (with the same scope) to get a file-level summary of what changed — this grounds the review and helps identify the most impactful files.

If the diff is empty, tell the user there are no changes to review and stop.

---

### 2. Understand the context

Before writing the review, build enough context to review intelligently:

- **Read key changed files in full** — the diff alone often lacks the surrounding context needed to judge whether a change is correct. For the most heavily modified files, read them completely.
- **Understand the codebase conventions** — look at neighboring files, imports, and patterns to understand what "consistent" means for this project.
- **Check for related changes** — if multiple files were modified, understand how they relate. A change to a function signature should be reflected in all its callers.

Don't review blindly from a diff. Understand what the code is doing and why before judging it.

---

### 3. Evaluate

Assess the changes across these dimensions:

**Correctness** — Does the code actually work? Look for logic errors, off-by-one mistakes, null/undefined access, unhandled edge cases, race conditions, or incorrect assumptions about data shapes or API contracts.

**Design** — Is the approach sound? Are abstractions appropriate (not too many, not too few)? Is the code organized in a way that makes sense? Are there simpler ways to achieve the same result?

**Security** — Are there vulnerabilities? Check for injection risks (SQL, XSS, command), improper authentication or authorization, exposed secrets, insecure defaults, or unsafe data handling. Pay special attention to code that handles user input, authentication, or sensitive data.

**Performance** — Are there obvious performance issues? Unnecessary database queries in loops, unbounded memory growth, missing indexes on queried fields, O(n^2) operations on potentially large datasets. Don't micro-optimize — focus on algorithmic and architectural concerns.

**Error handling** — Are failure modes addressed? Does the code handle network failures, invalid input, and unexpected state gracefully? Are errors logged or surfaced appropriately, not silently swallowed?

**Consistency** — Does the new code follow the conventions and patterns of the existing codebase? Naming, file structure, import patterns, error handling style.

**Testing** — If the changes include tests: are they meaningful? Do they test behavior, not implementation? If the changes don't include tests: should they? Flag untested logic that's complex or critical.

Prioritize findings by severity. Lead with things that would cause bugs, security issues, or data loss. Don't waste the reader's time with style preferences or trivial suggestions.

---

### 4. Write the review

```markdown
# Code Review

*Reviewed: <datetime> | Scope: <scope used> | Branch: <current branch> | Author: <agent-name>*

## Overview
<2-4 sentences. What do these changes do? What's the overall quality assessment? Is this ready to merge, or does it need work?>

## Changes Summary
<Brief file-by-file or area-by-area summary of what was changed and why, based on the diff stat and your reading of the code.>

## Issues

### Critical
<Problems that must be fixed — bugs, security vulnerabilities, data loss risks, broken functionality.>
<Each item: what the issue is, where it is (file:line or area), why it matters, and a suggested fix.>

### Important
<Problems that should be fixed — design concerns, missing error handling, performance issues, incomplete implementations.>

### Minor
<Things worth considering — style inconsistencies, small improvements, optional refactors.>

## What's Done Well
<Specific things the code gets right. Good patterns, clean logic, thoughtful handling of edge cases. Be genuine — this helps the author know what to keep doing.>

## Verdict
<2-4 sentences. Clear recommendation: approve, request changes, or needs discussion. What should the author focus on first?>
```

Omit any severity section (Critical/Important/Minor) that has no items. If there are no issues at all, replace the Issues section with a brief note that the code looks clean.

---

### 5. Output or save

- **Inline** (default): Output the review directly in the conversation. Omit the header line (`*Reviewed: ... | Author: ...*`) — it adds noise in a terminal and the user already knows who wrote it.
- **File** (if `generate-file` was set): Include the header line. Write to `$AGENT_DIR/code-reviews/<descriptive-name>.md`. Derive the name from the branch name or a short description of the changes, plus the date (e.g., `feature-auth-2025-01-15.md`, `fix-login-bug-2025-01-15.md`). Tell the user where it was saved.

**Author name**: The `<agent-name>` in the header identifies which agent produced the review (e.g., `Claude`, `Codex`, `Gemini`).
