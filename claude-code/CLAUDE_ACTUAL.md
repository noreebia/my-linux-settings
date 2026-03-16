# Language

- Keep in mind that the user's native language is English. When asked to write content (e.g., pull requests, letters, documentation, messages, translations) in a non-English language, write only that specific content in the requested language. All surrounding conversation — confirmations, follow-up questions, summaries — must remain in English.

# Variable Declarations

If any instructions reference the variables below, substitute them with their defined values.

- `$AGENT_DIR` = the `agents/claude` directory, relative to the repository root. If no git repo can be detected, relative to the directory where the `claude` command was entered.

# Markdown File Generation

- When instructed to generate markdown files without a specific directory mentioned, write them under `$AGENT_DIR/`. Create directories as needed.
- Automatically organize files into a category subdirectory that fits the content. Choose a short, lowercase, kebab-case folder name. Examples:
  - `$AGENT_DIR/plans/`
  - `$AGENT_DIR/system-analysis/`
  - `$AGENT_DIR/guides/`
- These are merely examples. Choose the most fitting category for the content. If a category directory already exists, add to it rather than creating a near-duplicate.
- Name individual files descriptively (e.g., `auth-refactor.md`, not `plan.md`).

