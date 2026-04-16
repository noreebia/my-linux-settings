---
name: augment-doc
description: >
  Assesses another agent's version of a document against the original, then selectively augments
  the original with genuinely superior ideas — or concludes that no changes are warranted.
argument-hint: "[--file-path=<path>] [--target-file-path=<path>] [--file]"
---

# Augment Doc

Assess another agent's take on the same topic as your document. Determine — honestly — whether any of their ideas, approaches, or coverage are genuinely better than yours. If so, fold those improvements into your original. If not, say so and move on.

The important thing: being asked to augment doesn't mean you must augment. The other agent may have taken a fundamentally different direction that doesn't apply, or your original may simply be stronger. The value of this skill is the honest assessment, not the act of changing things.

---

## Arguments

- **`--file-path=<path>`** *(optional)*: Path to the other agent's document — the source to assess. If a directory, read all files within it. When omitted, look for it in the conversation context (e.g., a prior `/adjust-take` output or pasted content).
- **`--target-file-path=<path>`** *(optional)*: Path to the original document — the augmentation target. When omitted, the original should be identifiable from conversation context.
- **`--file`** *(optional flag)*: Write the output to a markdown file instead of outputting inline.

## Examples

Both documents on disk:

    /augment-doc --file-path=agents/codex/plans/auth-migration.md --target-file-path=agents/claude/plans/auth-migration.md
    /augment-doc --file-path=agents/codex/plans/auth-migration.md --target-file-path=agents/claude/plans/auth-migration.md --file

Source on disk, target from conversation context:

    /augment-doc --file-path=agents/gemini/system-analysis/api-layer.md
    /augment-doc --file-path=agents/codex/plans/auth-migration.md --file

Everything in conversation context (after a prior /adjust-take in the same session):

    /augment-doc
    /augment-doc --file

---

## Process

### 1. Identify both documents

You need two things: the **original** (your document) and the **source** (the other agent's version).

- If `--file-path` was given, read the source document(s) at that path.
- If `--target-file-path` was given, read the original document at that path.
- If either is missing, look in the conversation context. In the typical workflow, both are already visible from prior steps. If you can't identify one or both, ask.

### 2. Assess the source against the original

Read both documents thoroughly, then go to the primary sources (codebase, configs, APIs, docs) to verify claims from both sides where it matters. Form your own judgment — don't assume the other agent's version is better just because it came later in the workflow.

For each meaningful difference between the two documents, arrive at a verdict: is the source's approach genuinely better, roughly equivalent, or worse than yours? "Different" is not the same as "better." A valid alternative direction isn't necessarily an improvement worth adopting — especially if it would compromise the coherence of your original.

It's entirely possible that nothing in the source warrants adoption. If your assessment concludes that the original is already the stronger document, say so clearly and explain why. That's a valid and valuable outcome.

### 3. Augment (if warranted)

If your assessment identified genuine improvements worth adopting, produce an updated version of your original that incorporates them. Adapt what you adopt to fit naturally — the result should read as a cohesive document, not a patchwork of two voices.

Close with a brief **Assessment and changes** section: what you assessed, what you adopted and why, and what you chose not to adopt and why. This gives the user visibility into your reasoning, whether the outcome was heavy augmentation or no changes at all.

### 4. Output or save

- **Inline** (default): Output directly in the conversation. Omit the metadata header.
- **File** (if `--file` was given): Include the metadata header: `*Augmented: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Source: <path or description of source doc> | Target: <path or description of original doc>*`. Write to `$AGENT_LOCAL_DIR/augmented/$CURRENT_TIME("YYYYMMDDHHMM")-<descriptive-slug>.md`. Tell the user where it was saved.
