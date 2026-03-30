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

Read a document — typically produced by another agent or a prior conversation — verify its claims against reality, and produce honest, actionable feedback.

The goal is not to be harsh or to find fault for its own sake. The goal is to make sure the document is actually correct and useful before someone acts on it.

---

## Arguments

- **file-path** *(required)*: Path to the document or directory to review. If a directory, read all files within it.
- **generate-file** *(optional)*: Any truthy value (`true`, `yes`, `file`) writes the review to a markdown file instead of outputting inline. The file will be saved alongside the source document with a `-review` suffix (e.g., `plan.md` → `plan-review.md`).
- **context** *(optional)*: Additional context to guide the review — specific concerns, constraints, background knowledge, or areas to focus on.

---

## Process

### 1. Read the document

Read the full document (or all files if a directory). Note the document's apparent purpose, audience, and key claims before moving on.

---

### 2. Build independent context

Don't take the document's descriptions at face value. Before evaluating its claims, verify them yourself:

- **Codebase or technical analysis**: Read the actual source files, configs, and artifacts referenced. If the document says "the auth service uses JWT" — check that it does.
- **Implementation plan**: Read the parts of the codebase the plan would modify. Understand what's already there before judging whether the proposed changes make sense.
- **External references** (URLs, tickets, APIs): Attempt to fetch and read them for additional context.
- **Situation analysis**: Look for evidence that either supports or contradicts the document's framing of the problem.

The goal is to arrive at your own understanding so you can evaluate the document's claims with authority, not just plausibility.

---

### 3. Evaluate

Assess the document across these dimensions:

**Accuracy** — Are the factual claims correct? Does the document describe the system, situation, or problem as it actually is?

**Completeness** — What's missing? Are there important aspects, edge cases, stakeholders, or risks that aren't addressed?

**Soundness of reasoning** — Do the conclusions follow from the evidence? Are there logical gaps, unsupported assumptions, or leaps of faith?

**Actionability** — If this is a plan or proposal: is it specific enough to execute? Are the steps clear? Are dependencies and risks called out?

**Blind spots** — What might the original author have missed because of their vantage point, assumptions, or available information?

**Alternatives** — Are there meaningfully different approaches that weren't considered and are worth raising?

Be pragmatic, not perfectionist. Not every difference of opinion is worth raising — focus on things that would actually change a decision or cause a problem if left unaddressed. Acknowledge what the document gets right.

---

### 4. Write the review

Structure your feedback clearly:

```markdown
# Review: <Document Title>

*Reviewed: <datetime — e.g., 2024-01-15 14:30> | Author: <agent-name>*

## Summary
<2–3 sentences: overall assessment. Is this document trustworthy and ready to act on, or does it need significant revision?>

## What Works
<Specific things the document gets right, handles well, or that you agree with. Be genuine — don't manufacture praise, but don't skip this section either.>

## Issues & Concerns
<Numbered list. Each item: what the issue is, why it matters, and a concrete suggestion for how to address it.>
<Order by severity — lead with the most important.>

## Minor Notes
<Small things that are worth mentioning but wouldn't change the document's validity — wording, missing details, style.>
<Skip this section entirely if there's nothing minor worth saying.>

## [Closing section — pick the label that fits the document]
- **"Recommendation"** for plans and proposals
- **"Verdict"** for analyses and evaluations
- **"Bottom Line"** for situation assessments and general docs

<1–3 sentences synthesizing the key takeaway. It's fine if this echoes the Summary — the reader has now worked through all the detail, so the same message lands differently as a closer. Be direct and concrete.>
```

---

### 5. Output or save

- **Inline** (default): Output the review directly in the conversation.
- **File** (if `generate-file` was set): Write the review to `<source-file-basename>-review.md`. Tell the user where it was saved.

**Author name**: The `<agent-name>` in the header identifies which agent produced the review (e.g., `claude`, `codex`, `gemini`).
