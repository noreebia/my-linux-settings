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
argument-hint: "<scope> [--file] [--plan=<hint>]"
---

# Review Implementation

Compare code changes against a plan and assess both **completeness** (did you build everything?) and **quality** (did you build it well?).

---

## Arguments

- **scope** *(positional, required)*: Which code changes to review. Accepts:
  - `unstaged` — unstaged changes in the working tree
  - `commit` — the last commit
  - `commit-N` — the last N commits (e.g., `commit-3` for the last 3 commits)
  - `branch` — all commits on the current branch since it diverged from the base branch
- **`--file`** *(optional flag)*: Write the review to a markdown file instead of outputting inline.
- **`--plan=<hint>`** *(optional)*: A hint for locating the plan. This can be anything — a file path, a directory, a keyword to search for, a description of what to look for, or omitted entirely if the plan is already in the conversation context. Use your best judgment to find or identify the plan from whatever the user provides.

## Examples

    $review-implementation commit
    $review-implementation branch --file
    $review-implementation commit-3 --plan=auth-migration
    $review-implementation unstaged --file --plan=agents/claude/plans/my-plan.md

---

## Process

### 1. Load the plan and gather the diff

Find the plan. If `--plan` was given, use its value as a hint — it might be a file path, directory, search keyword, or description. If not given, check the conversation context — the plan may have been discussed or generated earlier in this session. If you still can't identify the plan, ask the user. Once loaded, summarize the plan's key objectives so the user can confirm you've understood it.

Collect the diff using the `scope` argument:

| Scope | Command |
|-------|---------|
| `unstaged` | `git diff` |
| `commit` | `git log -1 -p` |
| `commit-N` | `git log -N -p` |
| `branch` | `git diff <base>...HEAD` (check `main`, `master`, `develop` for base; ask if ambiguous) |

Also run `git diff --stat` to get a file-level summary. For large diffs, read key changed files in full for context. If the plan references codebase areas not in the diff, read those too — you need the full picture.

### 2. Evaluate and write the review

**Completeness**: Walk through each plan item and classify it:
- **Implemented** — fully addressed
- **Partially implemented** — present but incomplete (be specific about what's missing)
- **Not implemented** — no corresponding changes (note if likely deferred vs overlooked)
- **Deviates** — different from what the plan specified (note if the deviation seems intentional or accidental)

**Quality**: For the code that was implemented, review it as you would any code — correctness, design, risks. Be pragmatic. Focus on things that would actually cause problems, not style nitpicks.

Structure the review to cover: a plan summary, the completeness breakdown, quality issues (ordered by severity), what's done well, and a verdict on readiness. Adapt depth to the size of the changes.

### 3. Output or save

- **Inline** (default): Output directly in the conversation. Omit the metadata header (`*Reviewed: ... | Author: ...*`).
- **File** (if `--file` was given): Include the metadata header: `*Reviewed: YYYY-MM-DD HH:MM | Author: $AGENT_NAME | Plan: <path to plan or "conversation context"> | Scope: <git scope used>*`. Write to `$AGENT_LOCAL_DIR/code-reviews/<descriptive-name>.md`. Tell the user where it was saved.
