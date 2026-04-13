---
name: review-doc
description: >
  Review an LLM-generated document — such as a system analysis, situation analysis, or implementation
  plan — and produce substantive feedback. Use this skill when the user wants a document critiqued,
  fact-checked, or stress-tested — triggered by phrases like "review this doc", "give me feedback on
  this plan", "check this analysis", "what's wrong with this", "poke holes in this", or any time a
  previously generated document needs a critical second pass. Also trigger when the user wants to
  validate whether a plan or analysis holds up before acting on it.
argument-hint: "[--file-path=<path>] [--file]"
---

# Review Document

Verify a document's claims against reality and produce honest, actionable feedback.

---

## Arguments

- **`--file-path=<path>`** *(required)*: Path to the document or directory to review. If a directory, read all files within it.
- **`--file`** *(optional flag)*: Write the review to a markdown file instead of outputting inline.

## Examples

    /review-doc --file-path=agents/claude/plans/auth-migration.md
    /review-doc --file-path=agents/claude/system-analysis/ --file
    /review-doc --file-path=docs/api-spec.md
    /review-doc --file-path=agents/claude/plans/auth-migration.md --file

---

## Process

### 1. Read and verify independently

Read the full document. Then verify its claims yourself — read the source files, configs, APIs, or whatever the document references. Don't evaluate based on plausibility alone; arrive at your own understanding so you can review with authority.

### 2. Evaluate and write the review

Be pragmatic, not perfectionist. Focus on things that would actually change a decision or cause a problem if left unaddressed. Acknowledge what the document gets right.

The review should include:

- A summary assessment — is this trustworthy and ready to act on?
- What works well (be genuine, not performative)
- Issues and concerns, ordered by severity — each with what the issue is, why it matters, and a concrete suggestion
- A closing verdict or recommendation

Adapt the structure and depth to the document. A short plan needs a different treatment than a 20-page system analysis.

### 3. Output or save

- **Inline** (default): Output directly in the conversation. Omit the metadata header (`*Reviewed: ... | Author: ...*`).
- **File** (if `--file` was given): Include the metadata header: `*Reviewed: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Target: <path to reviewed document>*`. Write to `$AGENT_LOCAL_DIR/reviews/<source-file-basename>-review.md`. Tell the user where it was saved.
