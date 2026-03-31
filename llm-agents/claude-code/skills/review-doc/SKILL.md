---
name: review-doc
description: >
  Review an LLM-generated document — such as a system analysis, situation analysis, or implementation
  plan — and produce substantive feedback. Use this skill when the user wants a document critiqued,
  fact-checked, or stress-tested — triggered by phrases like "review this doc", "give me feedback on
  this plan", "check this analysis", "what's wrong with this", "poke holes in this", or any time a
  previously generated document needs a critical second pass. Also trigger when the user wants to
  validate whether a plan or analysis holds up before acting on it.
---

# Review Document

Verify a document's claims against reality and produce honest, actionable feedback.

---

## Arguments

- **file-path** *(required)*: Path to the document or directory to review. If a directory, read all files within it.
- **generate-file** *(optional)*: Any truthy value (`true`, `yes`, `file`) writes the review to a markdown file instead of outputting inline. Saved alongside the source with a `-review` suffix (e.g., `plan.md` → `plan-review.md`).
- **context** *(optional)*: Additional context — specific concerns, constraints, or areas to focus on.

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
- **File** (if `generate-file` was set): Include the metadata header. Write to `<source-file-basename>-review.md`. Tell the user where it was saved.

**Author name**: The `<agent-name>` in the metadata header identifies which agent produced the review (e.g., `Claude`, `Codex`, `Gemini`).
