---
name: git-commit
description: Creates one commit from all current repository changes and pushes the current branch to origin. Use when the user asks to commit and push the working tree.
---

# Git Commit

Commit and push the current repository state. Invocation of this skill authorizes staging the
current changes, creating one commit, and pushing the current branch to `origin`.

## Workflow

Inspect the repository before acting:

- read the current branch, concise status, staged and unstaged diffs, untracked files, and recent
  commit subjects;
- understand the changes well enough to write an accurate commit message that matches the
  repository's existing style;
- stop and report briefly if there is nothing to commit or the directory is not a Git repository.

Stage all current changes with `git add -A`, then review the staged summary before committing.
Create a single commit with a concise subject and an explanatory body only when it adds useful
context. Do not modify working files, rewrite history, amend an existing commit, or create multiple
commits.

Push with `git push -u origin HEAD`. Never force-push. If committing or pushing fails, preserve the
resulting repository state and report the exact failure instead of applying unrelated fixes or
retrying destructively.

On success, report the commit hash and subject and confirm which branch was pushed.
