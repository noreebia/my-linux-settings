---
name: augment-doc
description: >
  Assesses another agent's version of a document against the original, then selectively augments
  the original with genuinely superior ideas — or concludes that no changes are warranted.
argument-hint: "[--file-path=<path>] [--original-file-path=<path>]"
---

# Augment Doc

Assess another agent's take on the same topic as your document. Determine — honestly — whether any of their ideas, approaches, or coverage are genuinely better than yours. If so, fold those improvements into your original. If not, say so and move on.

The important thing: being asked to augment doesn't mean you must augment. The other agent may have taken a fundamentally different direction that doesn't apply, or your original may simply be stronger. The value of this skill is the honest assessment, not the act of changing things.

---

## Arguments

- **`--file-path=<path>`** *(optional)*: Path to the other agent's document — the source to assess. If a directory, read all files within it. When omitted, look for it in the conversation context (e.g., a prior `/adjust-take` output or pasted content).
- **`--original-file-path=<path>`** *(optional)*: Path to the original document to potentially augment. When omitted, the original should be identifiable from conversation context.

## Examples

Both documents on disk:

    /augment-doc --file-path=agents/codex/plans/auth-migration.md --original-file-path=agents/claude/plans/auth-migration.md

Source on disk, original from conversation context:

    /augment-doc --file-path=agents/gemini/system-analysis/api-layer.md

Everything in conversation context (after a prior /adjust-take in the same session):

    /augment-doc

---

## Process

### 1. Identify both documents

You need two things: the **original** (your document) and the **source** (the other agent's version).

- If `--file-path` was given, read the source document(s) at that path.
- If `--original-file-path` was given, read the original document at that path.
- If either is missing, look in the conversation context. In the typical workflow, both are already visible from prior steps. If you can't identify one or both, ask.

### 2. Assess the source against the original

Read both documents thoroughly, then go to the primary sources (codebase, configs, APIs, docs) to verify claims from both sides where it matters. Form your own judgment — don't assume the other agent's version is better just because it came later in the workflow.

For each meaningful difference between the two documents, arrive at a verdict: is the source's approach genuinely better, roughly equivalent, or worse than yours? "Different" is not the same as "better." A valid alternative direction isn't necessarily an improvement worth adopting — especially if it would compromise the coherence of your original.

It's entirely possible that nothing in the source warrants adoption. If your assessment concludes that the original is already the stronger document, say so clearly and explain why. That's a valid and valuable outcome.

### 3. Present the assessment

Present your assessment to the user — what you found worth adopting, what you'd leave as-is, and why. Be specific: name the sections, claims, or approaches from the source that are genuinely better and explain what makes them better.

If the assessment concludes that no changes are warranted, say so and stop. No need to produce anything further.

If the original is a file on disk (via `--original-file-path` or a known path from context), ask the user how to proceed:

- **Modify the original** — apply changes directly to the file
- **Output a new version** — produce an augmented copy, leaving the original untouched

If the original was inline (no file on disk), skip the ask and proceed directly.

### 4. Output or save

If proceeding, produce the augmented document. Adapt what you adopt to fit naturally — the result should read as a cohesive document, not a patchwork of two voices.

- **Modify original** (if user chose this): Edit the file at `--original-file-path` directly.
- **New version** (if user chose this): Write to `$AGENT_LOCAL_DIR/augmented/$CURRENT_TIME("YYYYMMDDHHMM")-<descriptive-slug>.md` with metadata header: `*Augmented: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Source: <path or description of source doc> | Original: <path or description of original doc>*`. Tell the user where it was saved.
- **Inline** (original was inline): Output directly in the conversation. Omit the metadata header.
