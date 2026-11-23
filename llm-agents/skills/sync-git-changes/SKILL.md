---
name: sync-git-changes
description: >
  Absorbs Git changes made in another environment or session and reconciles them with the current
  session's working understanding, with extra attention to overlapping work and stale assumptions.
---

# Sync Git Changes

Catch up on changes made elsewhere so the next task starts from the actual repository state.
Focus on concrete changes and their effects on the current session. Reconstruct broader project
direction only when it is necessary to understand those changes.

This skill takes no arguments. Stay read-only: do not fetch, pull, switch branches, edit files, or
continue implementation. This is context absorption, not a code review.

## Establish the Change Window

Inspect applicable repository instructions, the current branch, working-tree status, and recent
Git history. Include staged, unstaged, and relevant untracked files in the current-state picture.

When the conversation establishes a last-known commit, verify it and use it as the baseline.
Check its relationship to HEAD before choosing a comparison; a branch switch or rewritten history
may require a different comparison from a simple forward commit range. Do not infer a baseline
solely from timestamps or claim that Git identifies which environment produced a change.

If no reliable baseline is available, choose a small, coherent recent history window from the log
and expand it only as needed to understand the changes. State that scope without claiming it
captures every change since the previous session. If there are no changes in the established
scope, say so and stop. If Git history is unavailable, explain the limitation rather than inventing
a change history.

## Absorb and Reconcile

Scan the selected commits and file-level changes for breadth, then read the meaningful patches
and current affected files. Treat current files as the source of truth; commit messages provide
context, not proof of behavior. Follow related callers, tests, configuration, or documentation
when they clarify the resulting behavior.

Read more deeply where changes affect the session's active task, files already discussed, or
assumptions behind earlier advice. Keep unrelated changes in the working model without giving
them equal space in the response. Avoid an exhaustive file dump or a repository-wide orientation.

Reconcile the changes with the conversation:

- Update facts about behavior, interfaces, configuration, and workflows that changed.
- Correct earlier claims or plans that are now stale, including work already completed elsewhere.
- Identify overlap with unfinished session work so subsequent edits do not duplicate or undo it.
- Mention ambiguities only when they materially affect understanding or the next task.

Do not turn observations into defect findings, quality judgments, speculative intent, or a new
implementation plan. Distinguish observed facts from inferences when the difference matters.

## Completion

Briefly confirm that the changes have been absorbed and identify the comparison scope. Summarize
the concrete changes, emphasizing effects on the current session and any corrected assumptions.
If prior session understanding is unaffected, say so briefly. Mention unverified remote freshness
only when it limits the conclusion. Stop ready for the next instruction, without creating a report
file or starting additional work.
