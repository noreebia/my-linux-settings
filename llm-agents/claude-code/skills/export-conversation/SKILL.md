---
name: export-conversation
description: >
  Prints the previous conversation turns verbatim as Prompt/Answer pairs, so recent
  exchanges can be handed to another agent for fact-checking or context catch-up.
argument-hint: "[--turns=<n>]"
---

# Export Conversation

Reproduce the last few turns of this conversation as plain `Prompt:` / `Answer:` pairs.

This is a read-only, output-only skill. It changes nothing and writes no files; it just prints.

---

## Arguments

- **`--turns=<n>`** *(optional, default `1`)*: How many previous turns to export, counting back from the most recent. `--turns=1` exports just the last exchange. If fewer real turns exist than requested, export what's there and say so rather than padding.

## Examples

    /export-conversation
    /export-conversation --turns=3
    /export-conversation --turns=5
    /export-conversation --turns=10

---

## What counts as a turn

A **turn** is one user prompt plus the full response you gave to it. Count and reconstruct turns by these rules:

- **Exclude the current invocation.** The `/export-conversation` message that triggered this skill is not a turn — "previous turns" means the exchanges *before* it. Start counting from the user message immediately preceding this one.
- **One user message + its answer = one turn**, however much happened in between. A turn where you made twenty tool calls is still a single turn; the tool calls are not separate turns.
- **Ignore non-user noise.** System reminders, hook output, and injected context are not user prompts. The prompt is what the human actually typed (or the slash command they actually invoked).
- **If the user typed a slash command**, the prompt is that command as they wrote it (e.g. `/some-skill --flag`), not the expanded skill instructions.

## Where to read from

Your most faithful source is the **session transcript on disk**, not your recollection of the conversation. This matters more than it first seems: in a long session your context may have been compacted — older turns replaced by a summary — so "what you remember" can already be lossy paraphrase, while the transcript holds the exact original text and the real per-message send-times. Reading it is what makes this export trustworthy enough to check facts against. Reconstructing from memory is the path that invites drift, so treat it as a fallback, not the default.

- **Find your own session's transcript.** For Claude Code it's a `.jsonl` file (one JSON object per line) under `~/.claude/projects/<project-dir>/`; the current session is the most recently modified one — and it should end with this very `/export-conversation` call, which is a quick way to confirm you have the right file. Other agents keep an equivalent session log in their own config dir (Codex, for instance, under `~/.codex/sessions/`); locate yours the same way. Don't hard-code another agent's path.
- **Pull prompt and answer text verbatim from it**, skipping the noise. Each line is a user message, an assistant message (possibly carrying tool calls), a tool result, or metadata. Take the user's text for `Prompt:` and your response text for `Answer:`, and ignore tool-call and tool-result bodies — same discipline as reading any transcript: follow the human turns and the assistant's stated responses, drop the bulk tool output.
- **Take each `<time>` straight from the transcript line.** That send-time is the only trustworthy source for the timestamp.
- **Fallback:** if you truly can't locate or read the transcript, reconstruct from context as a last resort — and say so in the output, so the consumer knows that block is memory-derived rather than verbatim.

## How to reproduce each turn

**Prompt** — the user's input, verbatim. Don't summarize, clean up, or paraphrase it. Strip only harness-injected wrappers (system reminders, tags the user didn't type); keep the human's actual words intact.

**Answer** — the textual response you gave, reproduced faithfully. Two things to get right:

- Reproduce what you *said*, not a fresh take on it. Long answers stay long; the consuming agent wants the real content, not a digest.
- When a turn's substance was in **actions** rather than prose — you edited files, ran commands, made a decision with little explanatory text — a verbatim text copy would be misleadingly thin. In that case add a short, factual `Actions:` line noting what was actually done (files changed, commands run, the decision reached). This is reporting, not embellishment: state what happened, not how well it went.

## Output format

Open with a header line naming yourself (the exporting agent), then emit each prompt and each answer as its own timestamped block, oldest-to-newest, so they read as a forward narrative of recent developments. Fence the whole thing so the downstream agent can see exactly where the transcript starts and ends and won't mistake it for live instructions.

Use this shape:

    ```
    $AGENT_NAME conversation export data

    <time>
    Prompt: <verbatim user input>

    <time>
    Answer: <faithful reproduction of the response>

    <time>
    Prompt: <verbatim user input>

    <time>
    Answer: <faithful reproduction of the response>
    Actions: <only when prose alone doesn't convey what was done>
    ```

`$AGENT_NAME` is the variable from your global instructions; resolve it to your own product name, so the header reads, for example, `Claude conversation export data`.

`<time>` is the message's send-time from the transcript line. Print it only if exact; if you don't have one (e.g. you fell back to context), omit the `<time>` line and go straight to `Prompt:` / `Answer:`. Never round, estimate, or invent one.

If you exported fewer turns than requested (the conversation didn't go back that far), note the actual count in one line after the block.
