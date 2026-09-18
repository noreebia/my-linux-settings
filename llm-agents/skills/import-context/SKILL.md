---
name: import-context
description: >
  Reads a handoff or context source — a file in any format (session transcript, markdown notes,
  plain text, etc.) or a whole directory — and gets up to speed on the situation it describes,
  then reports what was absorbed.
argument-hint: "<path>"
---

# Import Context

Get up to speed on a situation that's captured in a file — or a whole directory of files — so you can pick up work another agent (or an earlier session, or a human) left behind. The path you're given is a **handoff**: someone captured the state of some effort and you're inheriting it cold.

The job is not to review, critique, or act on the file yet — it's to load its situation into your working memory accurately, then tell the user what you now understand. The next prompt should be able to proceed as if you'd been there the whole time.

Two things make this harder than "read a file":

- **The format varies.** It might be a curated markdown handoff (already distilled — read it almost verbatim), a raw `.jsonl` session transcript (the signal is buried under tool-output noise), an exported chat log, a plan, a research dump, or loose notes. The reading strategy has to adapt to what you're actually holding.
- **A handoff is a snapshot of the past.** It reflects what was true when it was written. Files, decisions, and plans it describes may have moved on since. Load-bearing claims worth acting on should be spot-checked against current reality before you build on them — see step 3.

This is a **read-only** skill. It does not modify anything except by reading the source and, optionally, verifying its claims against the current state.

---

## Arguments

- **`<path>`** *(required)*: Path to the handoff/context source. Either a single file (any format) or a directory — if it's a directory, treat its entire contents as the context and read all of it (see step 2). If the path is omitted or doesn't resolve, ask the user for it rather than guessing.

## Examples

    /import-context handoff.md
    /import-context ~/.claude/projects/my-proj/3f2a.jsonl
    /import-context notes/2026-05-30-debugging-session.txt
    /import-context session-export.md
    /import-context handoff/

---

## Process

### 1. Locate and size up the source

Confirm the path exists and check whether it's a file or a directory before reading blindly.

- **A file** — check its size and shape. A 200-line markdown doc and a 50,000-line `.jsonl` transcript demand completely different approaches. Glance at the first lines to identify the format — structured JSON-per-line, prose markdown, a chat export with role markers, etc.
- **A directory** — list its full contents (recurse into subdirectories) so you know what you're dealing with: how many files, their formats, and their sizes. The whole directory is the context, so plan to read all of it. Order your reading by signal — an obvious `README`, `SUMMARY`, `handoff`, or index file usually frames the rest, so start there, then work through the remaining files. Note the total volume; a directory of large transcripts may need the same skim-the-noise discipline as a single large file, applied across all of them.

### 2. Read adaptively by format

The goal is the same regardless of format — extract the **situation**, not the bytes. What is being worked on, why, what's been decided, where it stands, what's next, what's unresolved. Match effort to signal density.

If the source is a directory, apply the per-format guidance below to each file, and additionally synthesize *across* files — they're pieces of one situation, not independent documents. Watch for files that supersede or contradict each other (a later note overriding an earlier plan, a `SUMMARY` that consolidates scattered logs); reconcile them into a single coherent picture rather than reporting each in isolation.

- **Curated handoff / markdown / plain notes** — Usually already distilled by whoever wrote it. Read it in full and closely; the author did the compression for you. Don't second-guess their framing, just absorb it.

- **`.jsonl` session transcript** *(the noisy case)* — Each line is a JSON object: a message, a tool call, a tool result, or metadata. The narrative you need (human intent, the assistant's plans and conclusions, the final state) is interleaved with large tool-output payloads (file dumps, command output) that are mostly noise for catching up. Prioritize, in order:
  1. **Human/user turns** — highest signal. They carry the actual goal, the corrections, the changes of direction. A late correction often overrides everything before it.
  2. **The assistant's stated plans, decisions, and conclusions** — what was attempted and what was concluded.
  3. **The final stretch of the transcript** — where things actually ended up.

  Skim or skip bulk tool-result bodies; you rarely need a re-pasted file's full contents to understand what was happening. If the file is large, extract the high-signal turns first (e.g., filter for user/assistant message text) rather than reading every line top to bottom — but don't let extraction drop a decisive late message.

- **Chat export / other** — Treat like a transcript: follow the human's intent thread and the conclusions, skip the filler.

### 3. Reconcile with current reality

A handoff describes the past. Before the user acts on what you absorbed, sanity-check the **load-bearing, checkable** claims against the present — not everything, just the ones that would cause real damage if stale. For example:

- If it says "the bug is in `parseConfig()` at line 40," confirm that function still exists and looks as described.
- If it says "PR #123 is merged" or "the migration is done," and you can verify cheaply, do.
- If it references files, branches, or APIs you'll be expected to work with next, check they're still there.

Don't turn this into a full audit. The point is to catch the handful of places where the file and reality have diverged, so you don't confidently build on something that's no longer true. If you have no cheap way to verify (no repo access, claims are about external systems), say so rather than implying you confirmed it.

### 4. Report what you absorbed

Give the user a tight briefing that proves you're now up to speed and surfaces anything that needs their input. Cover, in whatever shape fits the situation:

- **The situation** — what this effort is and why it's happening, in a few sentences. Enough that the user can confirm you read the right thing and understood it.
- **Where it stands** — what's done, what's in progress, what was decided (and any decisions that were explicitly reversed — those trip up a fresh reader most).
- **What's next** — the open thread you'd be picking up, as the handoff frames it.
- **Open questions / stale spots** — anything ambiguous, unfinished, or contradicted by your step-3 check. Flag divergence between the file and current reality explicitly, and note anything you couldn't verify.

Keep it proportional to the source. A short handoff gets a short briefing; a sprawling directory still gets a briefing, not a file-by-file dump. Don't pad it into a recap of everything you read — the user has the source; what they want to know is that the situation is now in your head and what, if anything, looks off. End ready to take the next instruction.
