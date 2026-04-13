---
name: peer-review
description: >
  Review LLM-generated content for factual accuracy, logical soundness, and completeness. The content
  can be inlined (pasted from another AI session) or a document on disk. Use this skill when the user
  pastes content from another LLM (ChatGPT, Gemini, Copilot, another Claude session, etc.) and wants
  it fact-checked, verified, or critiqued, OR when the user wants a document reviewed — triggered by
  phrases like "review this", "check this answer", "is this accurate", "verify this", "peer review",
  "fact-check this", "second opinion on this", "review this doc", "give me feedback on this plan",
  "check this analysis", "what's wrong with this", "poke holes in this", or any time the user pastes
  a Q&A exchange, references a document, or wants an independent assessment. Also trigger when the
  user says things like "I asked GPT this and got this answer", "another LLM told me X", "can you
  verify what Gemini said", "does this answer look right to you", or wants to validate whether a
  plan or analysis holds up before acting on it.
argument-hint: "[--file-path=<path>] [--file]"
---

# Peer Review

Independently verify LLM-generated content — inlined or on disk — and produce an honest accuracy assessment.

Treat each factual claim as unverified and check it yourself. LLMs hallucinate confidently, so plausibility alone is not evidence.

---

## Arguments

- **`--file-path=<path>`** *(optional)*: Path to the document or directory to review. If a directory, read all files within it. When omitted, review content inlined in the conversation.
- **`--file`** *(optional flag)*: Write the review to a markdown file instead of outputting inline.

## Examples

    /peer-review
    /peer-review --file
    /peer-review --file-path=agents/claude/plans/auth-migration.md
    /peer-review --file-path=agents/claude/system-analysis/ --file
    /peer-review --file-path=docs/api-spec.md --file

---

## Process

### 1. Identify the content to review

- If `--file-path` was given, read the document(s) at that path.
- Otherwise, look in the conversation for pasted content. If the user hasn't pasted it yet, ask them to. If the boundary between "original question" and "LLM answer" is ambiguous, make your best inference.

When reviewing a document on disk, also read the source files, configs, APIs, or whatever the document references — don't evaluate based on plausibility alone; arrive at your own understanding so you can review with authority.

### 2. Extract and verify claims

Read through the content and identify every substantive factual claim — things that are either true or false, not opinions or style choices. Then verify each one independently using whatever means are most appropriate — use your judgment, but be thorough. Flag your confidence level honestly when you can't fully verify something.

Focus your effort on claims that matter — the ones the user would act on or that could cause harm if wrong. Don't spend time verifying trivially true filler.

### 3. Write the review

For each substantive claim, classify it:

- **Accurate** — verified against a reliable source
- **Inaccurate** — contradicted by evidence (explain what's actually true)
- **Misleading** — technically true but missing critical context that changes the practical meaning
- **Unverifiable** — can't confirm or deny with available sources (say so honestly)

Then provide:

- An overall assessment — can the user trust this content?
- What the content gets right (acknowledge good parts genuinely)
- Errors and concerns, ordered by severity — each with what's wrong, why it matters, and what's actually true
- Missing information — important things the content should have mentioned but didn't
- A closing verdict with a recommendation on how to proceed

Adapt depth to the content. A short factual question deserves a focused check; a long technical document warrants thorough verification.

### 4. Output or save

- **Inline** (default): Output directly in the conversation. Omit the metadata header.
- **File** (if `--file` was given): Include the metadata header: `*Reviewed: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Source: <path if from file, otherwise "inlined LLM content">*`. Write to `$AGENT_LOCAL_DIR/reviews/$CURRENT_TIME("YYYYMMDDHHMM")-peer-review.md`. Tell the user where it was saved.
