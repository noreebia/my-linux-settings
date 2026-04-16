---
name: adjust-take
description: >
  Produces an independent, complete document on a topic after reviewing another agent's output —
  a full adjusted version (plan, analysis, or guide), not just feedback. Designed to follow
  /peer-review in a multi-agent workflow, but works standalone when pointed at any agent-generated
  content. Use whenever the user wants an adjusted take, a "second opinion as a deliverable",
  an alternative version, or asks you to produce your own version of another agent's work. Also
  use when the user says things like "now write your own", "what would you do differently",
  "give me your take on this", "adjust this", or "build on this".
argument-hint: "[--file-path=<path>] [--file]"
---

# Adjust-Take

Produce your own complete take on the same topic as another agent's output. This isn't feedback on their work — it's your own work on the same problem, informed by having seen theirs.

The typical workflow: another agent produces a document, someone runs `/peer-review` on it, then you run `/adjust-take` to deliver your own version — absorbing what worked, correcting what didn't, and reshaping the whole thing through your own lens. The skill also works when you're simply pointed at another agent's output without a prior review.

---

## Arguments

- **`--file-path=<path>`** *(optional)*: Path to the document or directory to produce an adjusted take on. If a directory, read all files within it. When omitted, work from the conversation context — the original document and any peer-review output should already be visible from a prior step.
- **`--file`** *(optional flag)*: Write the output to a markdown file instead of outputting inline.

## Examples

After a peer review in the same conversation (no --file-path needed):

    /adjust-take
    /adjust-take --file

Cold start — pointed directly at another agent's output:

    /adjust-take --file-path=agents/codex/plans/auth-migration.md
    /adjust-take --file-path=agents/codex/system-analysis/ --file
    /adjust-take --file-path=agents/gemini/plans/api-redesign.md --file

---

## Process

### 1. Understand the original work

- If `--file-path` was given, read the document(s) at that path. This is a cold start — there's no prior peer-review in context, so you'll be reading, assessing, and producing your take from scratch.
- If no `--file-path`, the original document should already be in the conversation — typically from a prior `/peer-review` that read and quoted it, or pasted inline by the user. If you can't identify what to produce an adjusted take on, ask.

Read the original thoroughly. If a peer-review exists in the conversation, absorb its findings — they're useful signal about where the original may be weak. But they're someone else's assessment, not yours. Don't just fix what the reviewer flagged and call it done.

### 2. Build your own understanding

This is what separates an adjusted take from a revised draft. Go to the primary sources yourself:

- Read the codebase, configs, APIs, docs, or whatever the original document was about
- Form your own mental model of the problem space
- Identify things the original got right, got wrong, and missed entirely — including things the peer review may have also missed

You're not editing the original. You're writing your own version informed by having seen theirs.

### 3. Produce your take

Write a complete, standalone document on the same topic. Match the general category of the original (plan produces a plan, analysis produces an analysis, guide produces a guide) but don't feel bound to the same structure or scope. If the original was a migration plan with 5 phases and you think 3 is better, write 3.

Your output should:

- Stand on its own — someone reading only your document should get a complete picture
- Reflect your independent analysis, not a point-by-point response to the original
- Incorporate what the original got right (no need to be contrarian for its own sake)
- Diverge where your own research leads you to a different conclusion
- Note the most significant differences from the original and briefly explain why you went a different direction

At the end, include a short **Divergence notes** section that highlights where and why your take differs from the original. Keep it factual — this helps the user (or a third agent) compare the two takes and make a decision.

### 4. Output or save

- **Inline** (default): Output directly in the conversation. Omit the metadata header.
- **File** (if `--file` was given): Include the metadata header: `*Generated: $CURRENT_TIME("YYYY-MM-DD HH:MM") | Author: $AGENT_NAME | Adjusted take on: <title or path of original document>*`. Write to `$AGENT_LOCAL_DIR/adjust-takes/$CURRENT_TIME("YYYYMMDDHHMM")-<descriptive-slug>.md`. Tell the user where it was saved.
