---
name: second-take
description: >
  Evaluates another agent's output against independent research and responds in proportion —
  endorsement, targeted improvements, or a full standalone alternative. Works with content
  inlined in the conversation or read from disk.
argument-hint: "[--file-path=<path>] [--file]"
---

# Second-Take

Form your own view of another agent's output and respond in proportion to what you find. The output is always grounded in your own independent research of the problem — but whether that yields an endorsement, a set of targeted improvements, or a full alternative depends on what the research actually shows.

---

## Arguments

- **`--file-path=<path>`** *(optional)*: Path to the document or directory to produce a second take on. If a directory, read all files within it. When omitted, work from content inlined in the conversation.
- **`--file`** *(optional flag)*: Write the output to a markdown file instead of outputting inline.

## Examples

Inline (the content pasted as the argument):

    /second-take ## Migration Plan\n### Phase 1: Add new auth tables\n...

From file:

    /second-take --file-path=agents/codex/plans/auth-migration.md
    /second-take --file-path=agents/codex/system-analysis/ --file
    /second-take --file-path=agents/gemini/plans/api-redesign.md --file

---

## Process

### 1. Identify the original work

- If `--file-path` was given, read the document(s) at that path.
- Otherwise, look in the conversation for inlined content. If nothing is identifiable, ask the user.

Read the original thoroughly. If feedback or critique on the original is also available (in conversation or alongside the file), absorb it as useful signal about where the original may be weak — but treat it as someone else's assessment, not yours.

### 2. Build your own understanding

This is what separates a second take from a revised draft. Go to the primary sources yourself:

- Read the codebase, configs, APIs, docs, or whatever the original document was about
- Form your own mental model of the problem space
- Identify things the original got right, got wrong, and missed entirely

You're not editing the original. You're writing your own version informed by having seen theirs.

### 3. Produce your take

Lead with a short assessment — your verdict on the original, grounded in the research you just did: what it got right, what's weak or missing, and where you'd diverge and why. This up-front framing lets the reader see your reasoning before the output that follows.

Then shape the rest of the output to match what the assessment implies. Three modes:

- **Endorse** — if the original holds up under your independent research, say so and explain why. Note minor caveats if any, but don't manufacture alternatives to appear substantive.
- **Improve** — if the original is largely sound but has specific gaps, weaknesses, or errors, comment on those targeted improvements. Keep what works; sketch the deltas rather than rewriting the whole thing.
- **Replace** — if your research points to a substantially different approach, write a complete, standalone alternative. Match the general category of the original (plan → plan, analysis → analysis, guide → guide) so someone reading only your document gets a complete picture.

Don't default to Replace. A second take exists to add signal, not volume — if the original is good, saying so plainly is more useful than producing a parallel document for its own sake. Pick the mode your research actually justifies, and be willing to land on Endorse when that's the honest answer.

### 4. Output or save

- **Inline** (default): Output directly in the conversation. Omit the metadata header.
- **File** (if `--file` was given): Include the metadata header: `*Generated: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Source: <path if from file, otherwise "inlined content">*`. Write to `$AGENT_LOCAL_DIR/second-takes/$CURRENT_TIME("YYYYMMDDHHMM")-<descriptive-slug>.md`. Tell the user where it was saved.
