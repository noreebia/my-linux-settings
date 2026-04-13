---
name: re-review
description: >
  Re-review a document after it has been revised in response to a previous review. This is NOT
  an open-ended critique — it's a targeted verification of whether the issues from the previous
  review were addressed. Use this skill after the peer-review → assess-feedback → revision cycle,
  when the user wants to check if the updated document resolves the earlier feedback. Triggered by
  phrases like "re-review this", "check if they addressed the feedback", "review this again",
  "did they fix the issues", "second pass on this doc", "follow-up review", or any time a document
  was previously reviewed and has since been updated. Also trigger when the user says things like
  "I updated the plan, take another look" or "Codex reviewed this before, check again".
argument-hint: "[--original-file-path=<path>] [--review-file-path=<path>] [--file]"
---

# Re-review

Verify whether a revised document addresses the issues raised in a previous review. Focus on accountability — did each issue get resolved? — not on discovering new problems from scratch.

---

## Arguments

- **`--original-file-path=<path>`** *(optional)*: Path to the previous review. When omitted, infer from conversation context or search `$AGENT_LOCAL_DIR/reviews/` for a matching review file.
- **`--review-file-path=<path>`** *(optional)*: Path to the revised document (or directory) to re-review. When omitted, infer from the conversation context — the previous `/peer-review` invocation identifies which document was reviewed.
- **`--file`** *(optional flag)*: Write the re-review to a markdown file instead of outputting inline.

## Examples

    /re-review
    /re-review --file
    /re-review --original-file-path=agents/claude/plans/auth-migration.md
    /re-review --original-file-path=agents/claude/plans/auth-migration.md --file
    /re-review --original-file-path=agents/claude/plans/auth-migration.md --review-file-path=agents/codex/reviews/auth-migration-review.md
    /re-review --review-file-path=agents/codex/reviews/auth-migration-review.md --file

---

## Process

### 1. Find the document and previous review

**Document**: If `--review-file-path` was given, use it. Otherwise, infer from the conversation context — the previous `/peer-review` invocation identifies which document was reviewed. If still unclear, ask the user.

**Previous review**: If `--original-file-path` was given, use it. Otherwise:

1. Check the conversation context — this skill is almost always invoked in the same session as the original `/peer-review`, so the review content or path is likely already available
2. Search `$AGENT_LOCAL_DIR/reviews/` for a file matching `<basename>-review.md`
3. If none found, ask the user

Read both the revised document and the previous review.

### 2. Assess each previous issue

Walk through every issue and concern from the previous review and classify it:

- **Addressed** — fully resolved
- **Partially addressed** — attempted but incomplete (specify what's still missing)
- **Not addressed** — no corresponding changes
- **Regressed** — the revision made this worse or introduced a new problem in this area

Verify claims against the codebase where applicable — don't just compare text, check whether what the document says is actually true.

### 3. Flag new issues

The revision may have introduced new problems. Note any significant ones, but keep the focus on the previous review's findings — this is a follow-up, not a fresh review.

### 4. Output or save

- **Inline** (default): Output directly in the conversation. Omit the metadata header.
- **File** (if `--file` was given): Include the metadata header: `*Re-reviewed: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Target: <path to revised document> | Previous review: <path to previous review>*`. Write to `$AGENT_LOCAL_DIR/reviews/<basename>-re-review.md`. Tell the user where it was saved.
