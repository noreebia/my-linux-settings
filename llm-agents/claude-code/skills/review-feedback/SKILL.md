---
name: review-feedback
description: >
  Read feedback on a document you produced and determine how to respond — what to accept, what to
  push back on, and what to do next. Use this skill when an agent or reviewer has critiqued a
  document and the user wants to process that feedback — triggered by phrases like "review this
  feedback", "what do you think of this review", "respond to the feedback", "which of these points
  are valid", "do you agree with this critique", or any time feedback on a prior output needs to be
  evaluated and acted on. The feedback can be a file on disk OR pasted inline in the conversation —
  the user doesn't need to provide a file path if the feedback is already in the conversation context.
argument-hint: "[--file-path=<path>] [--file]"
---

# Review Feedback

Evaluate feedback on a document and produce a considered response — what's valid, what isn't, and what to do next.

---

## Arguments

- **`--file-path=<path>`** *(optional)*: Path to the feedback document. When omitted, use the feedback from the conversation context — the user may have pasted it inline or it may be from a previous `/review-doc` in the same session.
- **`--file`** *(optional flag)*: Write the response to a markdown file instead of outputting inline. The file is named with a `-response` suffix (e.g., `plan-review.md` → `plan-review-response.md`), saved in the same directory.

## Examples

Inline paste (most common — paste the feedback as the argument):

    /review-feedback The plan looks solid overall but there are gaps in the error handling
    strategy. Specifically: 1) The retry logic doesn't account for...

    /review-feedback ## Issues\n- Auth flow assumes single-tenant but we're multi-tenant\n- Missing rate limiting on the upload endpoint...

From a file:

    /review-feedback --file-path=agents/claude/reviews/auth-plan-review.md
    /review-feedback --file-path=agents/claude/reviews/auth-plan-review.md --file

---

## Process

### 1. Gather context

If `--file-path` was given, read the feedback document. Otherwise, use the feedback already present in the conversation context — the user may have pasted it inline. Also read the original document being reviewed if available — you need both sides to evaluate fairly.

Before forming opinions, verify the feedback's factual claims yourself. Don't assume the reviewer was right just because they were thorough — check the code, the docs, the constraints.

### 2. Evaluate and respond

For each point, arrive at a position: **accept**, **accept with modification**, **reject**, or **defer**. Back each position with evidence, not just opinion. Rejections especially need clear reasoning.

Structure the response however best fits the feedback — a 3-point review needs a different treatment than a 15-point one. The response should include:

- An overall take on the feedback's quality and accuracy
- A point-by-point response with your verdict and reasoning for each
- Assessment of the situation - potential next steps for the original document, or the situation more broadly, in light of the feedback

### 3. Output or save

- **Inline** (default): Output directly in the conversation. Omit the metadata header (`*Responded: ... | Author: ...*`).
- **File** (if `--file` was given): Include the metadata header: `*Responded: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Feedback: <path to feedback doc> | Original: <path to original doc if known>*`. Write to `$AGENT_LOCAL_DIR/reviews/<feedback-file-basename>-response.md`. Tell the user where it was saved.
