---
name: review-implementation
description: >
  Review whether code changes correctly and completely implement a plan, spec, or design document.
  Use this skill when the user wants to verify that their implementation matches the original plan —
  triggered by phrases like "review my implementation", "did I implement this correctly",
  "check this against the plan", "does this match the spec", "review implementation of",
  "compare my changes to the plan", or any time the user has both code changes and a plan document
  and wants to know if they align. Also trigger when the user finishes implementing a plan and wants
  a quality check before committing or opening a PR.
---

# Review Implementation

Compare code changes against a plan or specification and produce a clear assessment: what was implemented correctly, what's missing, what deviates from the plan, and whether the implementation quality holds up.

This skill serves two purposes — **completeness** (did you build everything the plan asked for?) and **quality** (did you build it well?). Both matter. A complete but poorly implemented plan is still a problem, and a beautifully written partial implementation is still incomplete.

---

## Arguments

- **generate-file** *(1st, optional)*: Any truthy value (`true`, `yes`, `file`) writes the review to a markdown file instead of outputting inline. The file is saved alongside the plan document with a `-impl-review` suffix (e.g., `auth-plan.md` → `auth-plan-impl-review.md`).
- **scope** *(2nd, required)*: Which code changes to review. Accepts:
  - `unstaged` — unstaged changes in the working tree
  - `commit` — the last commit
  - `commit-N` — the last N commits (e.g., `commit-3` for the last 3 commits)
  - `branch` — all commits on the current branch since it diverged from the base branch
- **plan** *(3rd, required)*: Where to find the plan. Accepts three forms:
  - A **file path** — read that specific file as the plan
  - A **directory path** — read all documents in that directory to build context
  - A **directory path + keyword** (space-separated) — search the directory for files whose filename contains the keyword, and read those

---

## Process

### 1. Resolve the plan

Determine which form the `plan` argument takes and load the plan context accordingly.

**Single file** (the argument is a path to a file that exists):
Read the file. This is the plan.

**Directory** (the argument is a path to a directory):
List all files in the directory and read them all. Together they form the plan context. If the directory has many files, prioritize markdown and text files. Briefly note which files were loaded so the user knows what you're working from.

**Directory + keyword** (the argument contains both a path and a keyword, space-separated — e.g., `agents/plans auth` or `docs/ migration`):
Split the argument into the directory portion and the keyword. Search the directory for files whose filename contains the keyword (case-insensitive). Read all matching files. If nothing matches, tell the user and stop — don't guess.

After loading, summarize the plan's key objectives and deliverables in a few sentences so the user can confirm you've understood it correctly.

---

### 2. Gather the code changes

Use the `scope` argument to collect the relevant diff.

| Scope | Command |
|-------|---------|
| `unstaged` | `git diff` (working tree changes only) |
| `commit` | `git log -1 -p` (patch of the last commit) |
| `commit-N` | `git log -N -p` (patches of the last N commits) |
| `branch` | Determine the base branch, then `git diff <base>...HEAD` |

For the `branch` scope, determine the base branch by checking the most likely upstream (`main`, `master`, or `develop`). If ambiguous, ask the user.

Also run `git diff --stat` (with the same scope) to get a file-level summary of what changed — this helps map changes to plan items later.

If the diff is large, read the key changed files in full to understand context that the diff alone doesn't show.

---

### 3. Understand both sides

Before writing the review, make sure you genuinely understand:

- **The plan's intent**: What problem is being solved? What are the requirements, constraints, and design decisions? What are the acceptance criteria, if any?
- **The implementation's approach**: What did the developer actually build? What patterns and libraries did they use? Where did they deviate from the plan and was that intentional or accidental?

If the plan references parts of the codebase you haven't seen, read them. Don't evaluate an implementation against a plan if you don't understand the existing code it's building on.

---

### 4. Evaluate

Assess the implementation across two dimensions:

#### Completeness

Walk through each item, requirement, or deliverable in the plan and determine whether it's been addressed in the code changes.

- **Implemented** — The code fully addresses this plan item.
- **Partially implemented** — Some aspects are present but the item isn't fully addressed. Be specific about what's missing.
- **Not implemented** — No evidence of this plan item in the changes.
- **Deviates** — The code does something different from what the plan specified. Note whether the deviation seems intentional (a reasonable alternative approach) or accidental (likely an oversight).

#### Quality

For the code that was implemented, evaluate:

- **Correctness** — Does the code actually work as intended? Are there logic errors, off-by-one mistakes, race conditions, or unhandled edge cases?
- **Design** — Does the implementation follow the architectural approach the plan laid out? If it deviates, is the deviation an improvement or a regression?
- **Error handling** — Are failure modes addressed appropriately? Does the code handle the unhappy paths the plan identified (if any)?
- **Consistency** — Does the new code follow the conventions and patterns of the existing codebase?
- **Risks** — Are there security concerns, performance issues, or maintainability problems introduced by this implementation?

Be pragmatic. Focus on things that would actually cause problems. Don't nitpick style or naming unless it creates confusion.

---

### 5. Write the review

```markdown
# Implementation Review: <Plan Title or Description>

*Reviewed: <datetime> | Scope: <scope used> | Author: <agent-name>*

## Plan Summary
<Brief recap of what the plan called for — 3-5 sentences. This anchors the reader so they don't need to re-read the plan.>

## Completeness

### Implemented
<Bulleted list of plan items that are fully addressed. For each, a one-line note on how it was implemented.>

### Partially Implemented
<Bulleted list of plan items that are incomplete. For each: what's done, what's missing, and how significant the gap is.>

### Not Implemented
<Bulleted list of plan items with no corresponding changes. Note whether each item might be intentionally deferred or accidentally missed.>

### Deviations
<Bulleted list of places where the implementation diverges from the plan. For each: what the plan said, what was built instead, and whether the deviation seems reasonable.>

## Quality Assessment

### What's Done Well
<Specific things the implementation gets right — good patterns, solid error handling, clean design choices. Be genuine.>

### Issues
<Numbered list, ordered by severity. Each item: the issue, why it matters, where it is (file and area), and a suggested fix or direction.>

## Verdict
<3-5 sentences. Overall: is this implementation ready, does it need minor fixes, or does it need significant rework? What should the developer focus on next?>
```

Omit any section that has no items (e.g., if there are no deviations, skip that section entirely).

---

### 6. Output or save

- **Inline** (default): Output the review directly in the conversation. Omit the header line (`*Reviewed: ... | Author: ...*`) — it adds noise in a terminal and the user already knows who wrote it.
- **File** (if `generate-file` was set): Include the header line. Write to `<plan-file-basename>-impl-review.md` in the same directory as the plan. If the plan was a directory, save the review inside that directory. Tell the user where it was saved.

**Author name**: The `<agent-name>` in the header identifies which agent produced the review (e.g., `Claude`, `Codex`, `Gemini`).
