---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git push:*), Bash(git branch:*)
description: Create a git commit and push to remote
argument-hint: "[--skip-lookup]"
---

## Context

- Invocation arguments: $ARGUMENTS
- Current git status: !`if [ "$ARGUMENTS[0]" = "--skip-lookup" ]; then printf 'Skipped by --skip-lookup'; else git status; fi`
- Current git diff (staged and unstaged changes): !`if [ "$ARGUMENTS[0]" = "--skip-lookup" ]; then printf 'Skipped by --skip-lookup'; else git diff HEAD; fi`
- Current branch: !`if [ "$ARGUMENTS[0]" = "--skip-lookup" ]; then printf 'Skipped by --skip-lookup'; else git branch --show-current; fi`
- Recent commits: !`if [ "$ARGUMENTS[0]" = "--skip-lookup" ]; then printf 'Skipped by --skip-lookup'; else git log --oneline -10; fi`

## Your task

When `--skip-lookup` is supplied, use the changes already established in the current conversation
as the source of truth for the commit scope and message. Do not run further status, diff, log, branch,
untracked-file, or changed-file lookups, and do not review the staged summary. If the conversation
does not contain enough context for an accurate commit message, stop and ask the user to invoke this
command again without the flag.

Otherwise, use the repository context above. Create a single commit and push it to the remote using
`git push -u origin HEAD`.

Except for the insufficient-context case above, use a single message to stage, commit, and push.
Do not use any other tools or do anything else, and do not send text besides these tool calls.
