# Language

- Keep in mind that the user's native language is English. When asked to write content (e.g., pull requests, letters, documentation, messages) in a non-English language, write only that specific content in the requested language. All surrounding conversation — confirmations, follow-up questions, summaries — must remain in English.

# Variable Declarations

If any of the prompts or skills reference the below variables, they should be substituted appropriately

- Key: $DOCS_BASE
- Value: `agents/claude` directory relative to the repository root. If no git repo cannot be detected, relative to the directory where 'claude' command was entered

# Markdown File Generation

- When instructed to generate markdown files without a specific directory mentioned, write them under `$DOCS_BASE/`. Create directories as needed.
- Automatically organize files into a category subdirectory that fits the content. Choose a short, lowercase, kebab-case folder name. Examples:
  - `$DOCS_BASE/plans/`
  - `$DOCS_BASE/system-analysis/`
  - `$DOCS_BASE/guides/`
- These are merely examples. Choose the most fitting category depending on the context. If a category directory already exists, add to it rather than creating a near-duplicate.
- Name individual files descriptively (e.g., `auth-refactor.md`, not `plan.md`).

