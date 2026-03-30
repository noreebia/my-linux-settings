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

Read feedback on a document you (or another agent) produced and produce a clear-headed response: what's valid, what isn't, and what should happen next.

The goal is not to defensively reject criticism or to reflexively accept all of it. The goal is to think carefully about each point and arrive at a considered, honest position.

---

## Arguments

- **file-path** *(required)*: Path to the feedback document to evaluate.
- **generate-file** *(optional)*: Any truthy value (`true`, `yes`, `file`) writes the response to a markdown file instead of outputting inline. The file will be named with a `-response` suffix (e.g., `plan-review.md` → `plan-review-response.md`), saved in the same directory.
- **context** *(optional)*: Additional context to inform the evaluation — e.g., the original document that was reviewed, constraints on what can change, priorities to weigh, or background the reviewer may not have had.

---

## Process

### 1. Read the feedback

Read the full feedback document. If the original document being reviewed is available (from context or the filesystem), read that too — you need to understand what the feedback is responding to.

---

### 2. Build independent context

Before forming opinions on the feedback, verify its claims yourself:

- If the feedback makes factual claims about a codebase or system — check them. Don't assume the reviewer was right just because they were thorough.
- If the feedback references external constraints, requirements, or prior decisions — try to verify those.
- If context was provided that the reviewer may not have had access to — factor that in when assessing whether their concerns still apply.

---

### 3. Evaluate each point

For each piece of feedback, decide:

**Accept** — The point is valid and the original document should be updated to address it. Be willing to accept feedback that's uncomfortable if it's correct.

**Accept with modification** — The concern is legitimate but the suggested fix isn't quite right. You agree with the problem, not the solution.

**Reject** — The point is based on a misunderstanding, incorrect information, a matter of preference without material impact, or a constraint the reviewer wasn't aware of. Have a clear reason, not just a feeling.

**Defer** — The point may be valid but is out of scope for now. Note it as a future consideration rather than dismissing it.

Use the provided context to inform these judgments. If you have information the reviewer didn't, that can change whether their concern holds.

---

### 4. Write the response

```markdown
# Feedback Response: <Document Title>

*Responded: <datetime — e.g., 2024-01-15 14:30> | Author: <agent-name>*

## Overall Take
<2–3 sentences: your honest reaction to the feedback as a whole. Was it well-targeted? Did it surface real issues? Were there significant misunderstandings?>

## Point-by-Point Response

### [Accepted] <Brief restatement of the feedback point>
<Why you agree. What change should be made to the original document.>

### [Accepted with modification] <Brief restatement>
<What's valid about the concern. What you'd actually do differently from what was suggested.>

### [Rejected] <Brief restatement>
<Why you disagree. Be specific — cite evidence, context, or reasoning. Don't just say "this is a matter of perspective.">

### [Deferred] <Brief restatement>
<Why this is out of scope now. Where it should be tracked for later.>

## Recommended Next Steps
<What should happen to the original document based on this response? E.g., "Update sections 2 and 4 to address the accepted points, leave the rest unchanged." Be concrete.>
```

Omit any category heading (Accepted, Rejected, etc.) if there are no points in that category.

---

### 5. Output or save

- **Inline** (default): Output the response directly in the conversation.
- **File** (if `generate-file` was set): Write to `<feedback-file-basename>-response.md`. Tell the user where it was saved.

**Author name**: The `<agent-name>` in the header identifies which agent produced the response (e.g., `Claude`, `Codex`, `Gemini`).