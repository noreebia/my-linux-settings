---
name: create-pr
description: Open a pull request from the current branch to a target branch using the gh CLI.
user-invocable: true
disable-model-invocation: true
argument-hint: "[target-branch] [language]"
---

# Open Pull Request

Open a pull request from the current branch to a target branch using `gh pr create`.

## Arguments

- **target-branch** (1st argument): The base branch for the PR. Default: `develop`.
- **language** (2nd argument): The language for the PR title and body. Default: `English`.

## Process

1. Run `git branch --show-current` to get the current branch name. If on the target branch or on `main`/`master`, stop and warn the user.
2. Run `git diff <target-branch>...HEAD` to get the full code diff. This is the **primary source** for writing the PR description.
3. Run `git diff <target-branch>...HEAD --stat` for a file-level overview of what changed.
4. Read key changed files if needed for additional context.
5. Run `git log <target-branch>..HEAD --oneline` to see commit messages. Use these as a **supplementary source** — they may provide useful intent or context but should not be trusted over what the actual code diff shows, as commit messages might not be accurate.
6. Draft a PR title and body **written entirely in the specified language**:
   - Title: concise summary, under 70 characters.
   - Body: use this format:
     ```
     ## Summary
     <1-3 bullet points describing the changes>

     ## Changes
     <bulleted list of notable changes per file or area>
     ```
7. Create the PR using `gh pr create --base <target-branch> --title "<title>" --body "<body>"`.
   Use a HEREDOC for the body to preserve formatting.
8. Output the PR URL to the user.

## Important

- Always confirm with the user before pushing or creating the PR.
- If `gh` is not installed or not authenticated, stop and tell the user.
- Do not amend or create any commits — this skill only opens a PR for existing commits.