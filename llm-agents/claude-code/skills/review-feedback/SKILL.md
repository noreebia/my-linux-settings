---
name: review-feedback
description: >
  Read feedback on a document you produced and determine how to respond — what to accept, what to
  push back on, and what to do next. Use this skill when an agent or reviewer has critiqued a
  document and the user wants to process that feedback — triggered by phrases like "review this
  feedback", "what do you think of this review", "respond to the feedback", "which of these points
  are valid", "do you agree with this critique", or any time feedback on a prior output needs to be
  evaluated and acted on.
---

# Review Feedback

Evaluate feedback on a document and produce a considered response — what's valid, what isn't, and what to do next.

---

## Arguments

- **file-path** *(required)*: Path to the feedback document.
- **generate-file** *(optional)*: Any truthy value (`true`, `yes`, `file`) writes the response to a markdown file instead of outputting inline. The file is named with a `-response` suffix (e.g., `plan-review.md` → `plan-review-response.md`), saved in the same directory.
- **context** *(optional)*: Additional context — the original document, constraints, priorities, or background the reviewer may not have had.

---

## Process

### 1. Gather context

Read the feedback document. Also read the original document being reviewed if available — you need both sides to evaluate fairly.

Before forming opinions, verify the feedback's factual claims yourself. Don't assume the reviewer was right just because they were thorough — check the code, the docs, the constraints. If you have context the reviewer didn't, factor that in.

### 2. Evaluate and respond

For each point, arrive at a position: **accept**, **accept with modification**, **reject**, or **defer**. Back each position with evidence, not just opinion. Rejections especially need clear reasoning.

Structure the response however best fits the feedback — a 3-point review needs a different treatment than a 15-point one. The response should include:

- An overall take on the feedback's quality and accuracy
- A point-by-point response with your verdict and reasoning for each
- Concrete next steps for the original document

### 3. Output or save

- **Inline** (default): Output directly in the conversation. Omit the metadata header (`*Responded: ... | Author: ...*`).
- **File** (if `generate-file` was set): Include the metadata header. Write to `<feedback-file-basename>-response.md`. Tell the user where it was saved.

**Author name**: The `<agent-name>` in the metadata header identifies which agent produced the response (e.g., `Claude`, `Codex`, `Gemini`).
