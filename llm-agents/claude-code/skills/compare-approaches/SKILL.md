---
name: compare-approaches
description: >
  Compares two approaches to the same problem — typically two documents from different agents or
  drafts — and produces an honest, evidence-based assessment of where each is stronger, where
  they diverge, and which (if either) should be preferred. Works with content inlined in the
  conversation or read from disk.
argument-hint: "[--file-path=<path>] [--original-file-path=<path>] [--file]"
---

# Compare Approaches

Compare two approaches to the same problem and report on what's stronger about each, where they meaningfully diverge, and which is preferable overall. The deliverable is the comparison itself — the user decides what to do with it.

Being asked to compare doesn't mean one must win. Two approaches can be roughly equivalent, complementary, or rooted in different premises that make a direct ranking meaningless. Say so when that's the case.

---

## Arguments

- **`--file-path=<path>`** *(optional)*: Path to the alternate approach (e.g., another agent's version). If a directory, read all files within it. When omitted, look for inlined content in the conversation.
- **`--original-file-path=<path>`** *(optional)*: Path to the original or baseline approach to compare against. When omitted, look for inlined content in the conversation.
- **`--file`** *(optional flag)*: Write the comparison to a markdown file instead of outputting inline.

## Examples

Both documents on disk:

    /compare-approaches --file-path=agents/codex/plans/auth-migration.md --original-file-path=agents/claude/plans/auth-migration.md

Alternate on disk, baseline from conversation:

    /compare-approaches --file-path=agents/gemini/system-analysis/api-layer.md

Both inline (paste both into the conversation, then invoke):

    /compare-approaches

Save the comparison to a file:

    /compare-approaches --file-path=agents/codex/plans/auth-migration.md --original-file-path=agents/claude/plans/auth-migration.md --file

---

## Process

### 1. Identify both approaches

You need both: the **alternate** (e.g., the new or other agent's version) and the **original** (the baseline being compared against).

- If a `--file-path` was given, read the document(s) at that path.
- If a `--original-file-path` was given, read the document at that path.
- For anything not provided as a path, look in the conversation for inlined content. If you can't tell which inlined block is which, ask.

### 2. Assess

Read both thoroughly, then go to the primary sources (codebase, configs, APIs, docs, etc.) to verify substantive claims from both sides where it matters. Don't assume one version is better just because it's newer or came from a particular source.

For each meaningful difference, form a verdict: is the alternate genuinely better, roughly equivalent, or worse? "Different" is not the same as "better." A valid alternative direction isn't necessarily an improvement — especially if it would compromise the coherence of the original or rests on premises the original deliberately rejected.

### 3. Write the comparison

Structure the comparison around what the user actually needs to decide. A useful comparison covers:

- A short verdict up front — overall, is one approach preferable, are they equivalent, or is it situational?
- The meaningful differences, each with: what differs, which side handles it better and why, and whether it's worth acting on
- Strengths of each approach that the other lacks
- Areas where both fall short or miss something important
- A recommendation on how to proceed (adopt one, selectively combine, keep as-is, etc.)

Adapt depth to the size and nature of the differences. Two near-identical drafts need a focused comparison; two genuinely different approaches warrant a thorough one.

### 4. Output or save

- **Inline** (default): Output directly in the conversation. Omit the metadata header.
- **File** (if `--file` was given): Include the metadata header: `*Compared: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Alternate: <path or "inlined"> | Original: <path or "inlined">*`. Write to `$AGENT_LOCAL_DIR/comparisons/$CURRENT_TIME("YYYYMMDDHHMM")-<descriptive-slug>.md`. Tell the user where it was saved.
