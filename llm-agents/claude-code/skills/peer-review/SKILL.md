---
name: peer-review
description: >
  Review inlined LLM-generated content — typically a question and answer copied from another AI
  session — for factual accuracy, logical soundness, and completeness. Use this skill when the user
  pastes content from another LLM (ChatGPT, Gemini, Copilot, another Claude session, etc.) and
  wants it fact-checked, verified, or critiqued. Triggered by phrases like "review this", "check
  this answer", "is this accurate", "verify this", "peer review", "fact-check this", "second
  opinion on this", or any time the user pastes a Q&A exchange and wants an independent assessment.
  Also trigger when the user says things like "I asked GPT this and got this answer", "another LLM
  told me X", "can you verify what Gemini said", or "does this answer look right to you".
argument-hint: "[--file]"
---

# Peer Review

Independently verify inlined LLM-generated content and produce an honest accuracy assessment.

The user will paste content from another LLM session directly into the conversation. Your job is to treat each factual claim as unverified and check it yourself — LLMs hallucinate confidently, so plausibility alone is not evidence.

---

## Arguments

- **`--file`** *(optional flag)*: Write the review to a markdown file instead of outputting inline.

## Examples

    /peer-review
    /peer-review --file

---

## Process

### 1. Identify the content to review

Look in the conversation for the pasted Q&A content. If the user hasn't pasted it yet, ask them to. If the boundary between "original question" and "LLM answer" is ambiguous, make your best inference — the user rarely formats it neatly.

### 2. Extract and verify claims

Read through the answer and identify every substantive factual claim — things that are either true or false, not opinions or style choices. Then verify each one independently:

- **Search the web** for authoritative sources (official docs, specs, RFCs, reputable references)
- **Check the codebase** if the claims relate to the current project
- **Reason through** logical and technical claims using your own knowledge, but flag your confidence level when you can't find an external source

Focus your effort on claims that matter — the ones the user would act on or that could cause harm if wrong. Don't spend time verifying trivially true filler.

### 3. Write the review

For each substantive claim, classify it:

- **Accurate** — verified against a reliable source
- **Inaccurate** — contradicted by evidence (explain what's actually true)
- **Misleading** — technically true but missing critical context that changes the practical meaning
- **Unverifiable** — can't confirm or deny with available sources (say so honestly)

Then provide:

- An overall assessment — can the user trust this answer?
- What the original answer gets right (acknowledge good parts genuinely)
- Errors and concerns, ordered by severity — each with what's wrong, why it matters, and what's actually true
- Missing information — important things the original answer should have mentioned but didn't
- A closing verdict with a recommendation on how to proceed

Adapt depth to the content. A short factual question deserves a focused check; a long technical explanation warrants thorough verification.

### 4. Output or save

- **Inline** (default): Output directly in the conversation. Omit the metadata header.
- **File** (if `--file` was given): Include the metadata header: `*Reviewed: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Source: inlined LLM content*`. Write to `$AGENT_LOCAL_DIR/reviews/$CURRENT_TIME("YYYYMMDDHHMM")-peer-review.md`. Tell the user where it was saved.
