---
name: export-convo
description: >
  Prints the previous conversation turns verbatim as Prompt/Answer pairs, so recent
  exchanges can be handed to another agent for fact-checking or context catch-up.
argument-hint: "[--turns=<n>]"
---

# Export Conversation

Reproduce the last few turns of this conversation as plain `Prompt:` / `Answer:` pairs. The output is not for the user to read — it's a transcript meant to be **pasted into another agent**, which will use it either to check whether what was said is accurate, or to get up to speed on what just happened. That downstream purpose drives every decision here: the value is in faithfulness, not polish.

The catch is that you are reconstructing this from your own context window, which makes it tempting to *re-answer* instead of *report*. Resist that. You are a transcriptionist for this one task, not a participant. If the earlier answer was wrong, export the wrong answer — flagging it is the consuming agent's job, not yours. Silently "correcting" it defeats the entire point of a veracity check.

This is a read-only, output-only skill. It changes nothing and writes no files; it just prints.

---

## Arguments

- **`--turns=<n>`** *(optional, default `1`)*: How many previous turns to export, counting back from the most recent. `--turns=1` exports just the last exchange. If fewer real turns exist than requested, export what's there and say so rather than padding.

## Examples

    /export-convo
    /export-convo --turns=3
    /export-convo --turns=5
    /export-convo --turns=10

---

## What counts as a turn

A **turn** is one user prompt plus the full response you gave to it. Count and reconstruct turns by these rules:

- **Exclude the current invocation.** The `/export-convo` message that triggered this skill is not a turn — "previous turns" means the exchanges *before* it. Start counting from the user message immediately preceding this one.
- **One user message + its answer = one turn**, however much happened in between. A turn where you made twenty tool calls is still a single turn; the tool calls are not separate turns.
- **Ignore non-user noise.** System reminders, hook output, and injected context are not user prompts. The prompt is what the human actually typed (or the slash command they actually invoked).
- **If the user typed a slash command**, the prompt is that command as they wrote it (e.g. `/some-skill --flag`), not the expanded skill instructions.

## How to reproduce each turn

**Prompt** — the user's input, verbatim. Don't summarize, clean up, or paraphrase it. Strip only harness-injected wrappers (system reminders, tags the user didn't type); keep the human's actual words intact.

**Answer** — the textual response you gave, reproduced faithfully. Two things to get right:

- Reproduce what you *said*, not a fresh take on it. Long answers stay long; the consuming agent wants the real content, not a digest.
- When a turn's substance was in **actions** rather than prose — you edited files, ran commands, made a decision with little explanatory text — a verbatim text copy would be misleadingly thin. In that case add a short, factual `Actions:` line noting what was actually done (files changed, commands run, the decision reached). This is reporting, not embellishment: state what happened, not how well it went.

## Output format

Present turns oldest-to-newest, so they read as a forward narrative of recent developments. Fence the whole block so the downstream agent can see exactly where the transcript starts and ends and won't mistake it for live instructions.

Use this shape:

    ```
    Turn 1
    Prompt: <verbatim user input>
    Answer: <faithful reproduction of the response>

    Turn 2
    Prompt: <verbatim user input>
    Answer: <faithful reproduction of the response>
    Actions: <only when prose alone doesn't convey what was done>
    ```

If you exported fewer turns than requested (the conversation didn't go back that far), note the actual count in one line after the block.
