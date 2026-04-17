---
name: second-take
description: >
  Produces an independent, complete document on the same topic as another agent's output —
  a full second version (plan, analysis, or guide), not feedback. Works with content inlined in
  the conversation or read from disk.
argument-hint: "[--file-path=<path>] [--file]"
---

# Second-Take

Produce your own complete take on the same topic as another agent's output. This isn't feedback on their work — it's your own work on the same problem, informed by having seen theirs.

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

Write a complete, standalone document on the same topic. Match the general category of the original (plan produces a plan, analysis produces an analysis, guide produces a guide) but don't feel bound to the same structure or scope.

Your output should:

- Stand on its own — someone reading only your document should get a complete picture
- Reflect your independent analysis, not a point-by-point response to the original
- Incorporate what the original got right (no need to be contrarian for its own sake)
- Diverge where your own research leads you to a different conclusion

At the end, include a short **Divergence notes** section that highlights where and why your take differs from the original. Keep it factual — this helps the user compare the two takes and make a decision.

### 4. Output or save

- **Inline** (default): Output directly in the conversation. Omit the metadata header.
- **File** (if `--file` was given): Include the metadata header: `*Generated: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Source: <path if from file, otherwise "inlined content">*`. Write to `$AGENT_LOCAL_DIR/second-takes/$CURRENT_TIME("YYYYMMDDHHMM")-<descriptive-slug>.md`. Tell the user where it was saved.
