---
name: create-pr
description: >
  Opens a pull request from the current branch to a target branch using the gh CLI.
argument-hint: "[--target-branch=<branch>] [--language=<language>] [--context=<url>]"
---

# Create Pull Request

Open a well-written pull request from the current branch using `gh pr create`. The goal is a PR description a reviewer can act on immediately — clear context, a scannable change list, and no filler.

---

## Arguments

- **`--target-branch=<branch>`** *(optional, default: `develop`)*: Base branch for the PR.
- **`--language=<language>`** *(optional, default: `English`)*: Language for the PR title and body.
- **`--context=<url>`** *(optional)*: URL to a related ticket or context source (Jira, Wrike, Linear, etc.). If provided, the skill will attempt to fetch and summarize it for the **Context** section.

## Examples

    /create-pr
    /create-pr --target-branch=main
    /create-pr --target-branch=develop --language=Korean
    /create-pr --target-branch=main --context=https://linear.app/team/issue/PROJ-123
    /create-pr --target-branch=develop --language=Korean --context=https://jira.example.com/browse/PROJ-456

---

## Process

### 1. Validate and gather context

Check that `gh` is authenticated and the current branch isn't the target branch (or `main`/`master` — a PR from those is almost never intentional).

Gather the diff, diff stat, and commit log against the target branch. The code diff is ground truth — commit messages are supplementary. If they conflict, trust the diff. Read key changed files when the diff alone doesn't make intent clear.

If `--context` was provided, fetch it and extract relevant requirements for the Context section. Attempt to access the URL using any available tool (MCP server, web fetch, etc.). If inaccessible, use the raw URL.

### 2. Draft the title and body

**Title:** Under 70 characters, imperative mood ("Add user export endpoint" not "Added"), specific enough to stand alone. Written in the specified language.

**Body format:**

```markdown
## Description
<2–4 sentences of prose. Lead with the user-facing or system-level impact, then the approach. Skip anything obvious from the title.>

## Context
<Only if --context was provided. Tight summary of the requirements, or the raw URL if inaccessible.>

## Changes Made
<Bulleted list, 4–10 items. Each bullet = one logical change. Name the file or component when it adds clarity.>
<Bad: "Updated user service" — Good: "Added `exportToCsv()` to `UserService` — streams rows to avoid memory issues on large datasets">
```

### 3. Confirm and create

Show the draft to the user and wait for approval. Then create the PR using a HEREDOC to preserve formatting:

```bash
gh pr create --base <target-branch> --title "<title>" --body "$(cat <<'PRBODY'
<body content here>
PRBODY
)"
```

Print the PR URL. Done.

---

## Constraints

- **Do not create or amend commits.** This skill only opens a PR for existing commits.
- **Do not push branches.** If the branch isn't pushed yet, tell the user to run `git push -u origin <branch>` first.
