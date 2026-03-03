---
name: open-pr
description: Open a pull request from the current branch to a target branch using the gh CLI.
user-invocable: true
arguments:
  - name: target-branch
    description: The branch to open the PR against. Defaults to 'develop'.
    default: develop
  - name: language
    description: The language to write the PR title and description in. Defaults to 'English'.
    default: English
---

# Open Pull Request

Open a pull request from the current branch to a target branch using `gh pr create`.

## Arguments

- **target-branch** (1st argument): The base branch for the PR. Default: `develop`.
- **language** (2nd argument): The language for the PR title and body. Default: `English`.

## Process

1. Run `git branch --show-current` to get the current branch name. If on the target branch or on `main`/`master`, stop and warn the user.
2. Run `git log <target-branch>..HEAD --oneline` and `git diff <target-branch>...HEAD --stat` to understand what changes will be included in the PR.
3. Read the changed files to understand the full context of the changes.
4. Draft a PR title and body **written entirely in the specified language**:
   - Title: concise summary, under 70 characters.
   - Body: use this format:
     ```
     ## Summary
     <1-3 bullet points describing the changes>

     ## Changes
     <bulleted list of notable changes per file or area>
     ```
5. Push the current branch to the remote if it hasn't been pushed yet (`git push -u origin HEAD`).
6. Create the PR using `gh pr create --base <target-branch> --title "<title>" --body "<body>"`.
   Use a HEREDOC for the body to preserve formatting.
7. Output the PR URL to the user.

## Important

- Always confirm with the user before pushing or creating the PR.
- If `gh` is not installed or not authenticated, stop and tell the user.
- Do not amend or create any commits — this skill only opens a PR for existing commits.
