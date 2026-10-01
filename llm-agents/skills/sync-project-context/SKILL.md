---
name: sync-project-context
description: >
  Reconstructs a project's recent trajectory and current direction from Git history, canonical
  documentation, current files, and conversation context. Use to catch up after work continued in
  another environment or session; not for code review or branch-only analysis.
argument-hint: "[--since=<revision>] [--commits=<count>]"
---

# Sync Project Context

Get aligned with a project whose work has continued elsewhere. Build enough historical and current
context to understand not only what changed, but the decisions, product or technical direction, and
active frontier those changes express. The next task should proceed from the same current reality
and broadly shared vision as the other environment.

This is a read-only context-reconstruction skill. Do not edit files, fetch or pull remote changes,
review implementation quality, or continue the work unless the user separately asks.

## Arguments

- **`--since=<revision>`** *(optional)*: Treat the named Git revision as the exclusive baseline and
  study `<revision>..HEAD` plus current uncommitted changes.
- **`--commits=<count>`** *(optional)*: Study the latest positive number of commits plus current
  uncommitted changes.

The arguments are mutually exclusive. When neither is supplied, inspect the recent log first and
choose the smallest coherent history window that explains the current work. State the window in the
briefing. If the directory is not a Git repository, explain the limitation and fall back to current
documentation, files, and any handoff context available in the conversation.

## Examples

```text
/sync-project-context
/sync-project-context --commits=8
/sync-project-context --since=origin/main
$sync-project-context --since=v0.4.0
```

## Context Boundaries

Use this skill for cross-environment or cross-session alignment around a project's recent evolution.
Use narrower tools when the user's request is narrower:

- use `refresh-context` for a known diff scope whose changes only need to replace stale working
  assumptions;
- use `analyze-branch` for a branch briefing relative to its detected parent;
- use `import-context` when a supplied handoff file, transcript, or directory is the primary source;
- use `understand-directory-context` for broad orientation in an unfamiliar directory without an
  emphasis on recent history.

## Reconstruct the Shared Context

### Establish present reality

Read the applicable repository instructions, current branch and upstream relationship, concise
working-tree status, and a dated recent commit log with subjects and bodies. Include uncommitted
changes in the model because the working tree is the immediate source of truth. Do not contact the
remote merely to refresh refs; report that remote-tracking information is only as current as the
local repository knows.

Validate explicit arguments before using them. For the default history window, look for a coherent
run of work rather than selecting an arbitrary fixed number of commits. Commit dates, related
subjects, merge boundaries, and shifts in subsystem or goal are useful signals. Expand the window
when an earlier commit establishes a decision that later commits refine; stop when older commits no
longer materially explain the current direction.

### Recover trajectory and intent

Use both history and current files:

- inspect commit subjects, bodies, and file-level statistics across the selected window to identify
  the sequence and themes;
- read the patches that establish or reverse meaningful behavior, architecture, product decisions,
  or operating conventions;
- read the current versions of the important affected files and their applicable instructions;
- consult canonical product, architecture, roadmap, or decision-history documents that explain why
  the changes exist;
- follow closely related callers, tests, configuration, and documentation far enough to understand
  the resulting system and its intended maintenance boundary.

Scale effort to the history. For a small window, reading every changed file may be practical. For a
large or rename-heavy window, prioritize decision-bearing changes and representative current files;
do not mechanically dump every file into context. Treat current files as truth about what exists now,
and history as evidence for how and why the project arrived there. If a commit message and the code
disagree, trust the code and note the mismatch only when it affects the shared understanding.

### Reconcile environments

Compare the reconstructed state with relevant claims, plans, and assumptions already present in the
conversation. Explicitly correct anything that is now stale. Track decisions that were reversed or
superseded so an older plan is not mistaken for current direction.

Build a working model of:

- the project's current purpose and guiding product or technical principles;
- the recent sequence of completed work and the intent connecting it;
- current architectural and workflow boundaries that future changes should preserve;
- what remains deliberately unfinished, deferred, or under reconsideration;
- material ambiguities, local-only work, divergence, or unverifiable remote state.

Do not turn this into a defect review. Mention a concern only when it changes the factual context or
creates an ambiguity that must be resolved before subsequent work.

## Brief the User

Report directly in the conversation, proportionate to the history. Lead by confirming that context is
synced, then cover:

- the repository state and history window used;
- the shared vision or direction now understood;
- the recent trajectory, grouped by meaningful work rather than file lists;
- the current frontier: remaining work, deliberate deferrals, and open questions;
- any prior statements that are no longer reliable.

Say plainly when no prior statement was contradicted. Distinguish repository facts from inferences,
and mention when upstream freshness was not verified. End ready to continue from the synchronized
context rather than proposing or starting additional work.
