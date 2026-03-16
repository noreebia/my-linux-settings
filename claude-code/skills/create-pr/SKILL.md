---
name: create-pr
description: Open a pull request from the current branch to a target branch using the gh CLI.
user-invocable: true
disable-model-invocation: true
argument-hint: "[target-branch] [language] [ticket-url]"
---

# Open Pull Request

Open a pull request from the current branch to a target branch using `gh pr create`.

## Arguments

- **target-branch** (1st argument): The base branch for the PR. Default: `develop`.
- **language** (2nd argument): The language for the PR title and body. Default: `English`.
- **ticket-url** (3rd argument, optional): A URL to a ticket (Wrike, Jira, etc.) related to this PR. If provided, the agent will attempt to access and analyze the ticket content to generate a **Context** section in the PR body. If the agent cannot access the ticket (no MCP server, authentication issues, etc.), it will include the URL itself as the context in a best-effort manner.

## Process

1. Run `git branch --show-current` to get the current branch name. If on the target branch or on `main`/`master`, stop and warn the user.
2. Run `git diff <target-branch>...HEAD` to get the full code diff. This is the **primary source** for writing the PR description.
3. Run `git diff <target-branch>...HEAD --stat` for a file-level overview of what changed.
4. Read key changed files if needed for additional context.
5. Run `git log <target-branch>..HEAD --oneline` to see commit messages. Use these as a **supplementary source** — they may provide useful intent or context but should not be trusted over what the actual code diff shows, as commit messages might not be accurate.
6. If a **ticket-url** was provided, attempt to access and read the ticket content using any available tool (MCP server, web fetch, etc.). If successful, extract the relevant context (requirements, description) to use in the **Context** section. If the ticket cannot be accessed, use the URL itself as the context content.
7. Draft a PR title and body **written entirely in the specified language**:
   - Title: concise summary, under 70 characters.
   - Body: use this format:
     ```
     ## Description
     <A concise overview of the changes introduced.>

     ## Context
     <only include this section if a ticket-url was provided>
     <if the ticket was accessible: a summary of the ticket's context, requirements, or acceptance criteria relevant to this PR>
     <if the ticket was not accessible: just the ticket URL>

     ## Changes Made
     <bulleted list of notable changes, referencing files or features as needed>
     ```
8. Create the PR using `gh pr create --base <target-branch> --title "<title>" --body "<body>"`.
   Use a HEREDOC for the body to preserve formatting.
9. Output the PR URL to the user.

## Important

- Always confirm with the user before pushing or creating the PR.
- If `gh` is not installed or not authenticated, stop and tell the user.
- Do not amend or create any commits — this skill only opens a PR for existing commits.