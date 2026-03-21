---
name: create-pr
description: >
  Open a pull request from the current branch to a target branch using the gh CLI. Use this skill
  whenever the user wants to open, create, or submit a PR or pull request — including phrases like
  "open a PR", "create a pull request", "submit this for review", "push a PR to develop", or
  "make a PR". Also trigger proactively when the user says they're done with a feature or fix and
  asks what to do next — they probably want a PR.
---

# Create Pull Request

Open a well-written pull request from the current branch using `gh pr create`. The goal is a PR description a reviewer can act on immediately — clear context, a scannable change list, and no filler.

---

## Arguments

- **target-branch** *(1st, optional)*: Base branch for the PR. Default: `develop`.
- **language** *(2nd, optional)*: Language for the PR title and body. Default: `English`.
- **ticket-url** *(3rd, optional)*: URL to a related ticket (Jira, Wrike, Linear, etc.). If provided, the skill will attempt to fetch and summarize the ticket for the **Context** section.

---

## Process

### 1. Validate the environment

```bash
# Check gh is available and authenticated
gh auth status

# Get current branch
git branch --show-current
```

If `gh` is not installed or not authenticated → stop and tell the user how to fix it (`gh auth login`).

If the current branch **is** the target branch, `main`, or `master` → stop and warn the user. A PR from `main` to `develop` is almost never intentional.

---

### 2. Gather context

Run these in order — each one adds a different layer of understanding:

```bash
# The full diff — this is the primary source of truth
git diff <target-branch>...HEAD

# File-level summary — good for the Changes Made section
git diff <target-branch>...HEAD --stat

# Commit messages — useful for intent, but treat as hints not facts
git log <target-branch>..HEAD --oneline
```

Read key changed files when the diff alone doesn't make the intent clear — e.g., when a file is renamed, a schema changes, or a new config is added.

**Source priority:** The code diff is ground truth. Commit messages are supplementary. If they conflict, trust the diff.

---

### 3. Fetch the ticket (if provided)

Attempt to access the ticket URL using any available tool (MCP server, web fetch, etc.).

- **If successful**: Extract the requirements, description, or acceptance criteria relevant to this PR. Summarize them in your own words for the Context section.
- **If inaccessible**: Use the raw URL as the context — don't skip the section.

---

### 4. Draft the title and body

**Title rules:**
- Under 70 characters
- Imperative mood: "Add user export endpoint" not "Added" or "Adding"
- Specific enough that a reviewer knows what changed without reading the body
- Written in the specified language

**Body format:**

```markdown
## Description
<2–4 sentences. What changed and why. Not a list — prose. Lead with the user-facing or system-level impact, then the approach taken. Skip anything obvious from the title.>

## Context
<Only include if a ticket-url was provided.>
<If ticket was accessible: a tight summary of the requirements or acceptance criteria this PR addresses.>
<If ticket was inaccessible: the raw URL.>

## Changes Made
<Bulleted list. Each bullet = one logical change. Name the file or component when it adds clarity.>
<Bad: "Updated user service" — Good: "Added `exportToCsv()` to `UserService` — streams rows to avoid memory issues on large datasets">
<Aim for 4–10 bullets. If you need more, consider whether this PR is too large.>
```

**What to avoid:**
- Vague descriptions ("various fixes", "refactoring", "updates")
- Restating the title verbatim in the description
- Listing every file changed — the diff does that; group by logical change instead
- Filler phrases ("In this PR, we...", "As per the ticket...")

---

### 5. Confirm with the user

Show the draft title and body and ask for approval before creating the PR. Don't proceed automatically.

---

### 6. Create the PR

Use a HEREDOC to preserve formatting and avoid quoting issues with special characters in the body:

```bash
gh pr create --base <target-branch> --title "<title>" --body "$(cat <<'PRBODY'
<body content here>
PRBODY
)"
```

**Common pitfall:** If the body contains backticks or `$` signs, the HEREDOC delimiter must be quoted (`'PRBODY'`) to prevent shell expansion. Always use the quoted form.

---

### 7. Output the result

Print the PR URL returned by `gh pr create`. Done.

---

## Constraints

- **Do not create or amend commits.** This skill only opens a PR for commits that already exist.
- **Do not push branches.** If the branch isn't pushed yet, tell the user to run `git push -u origin <branch>` first.
