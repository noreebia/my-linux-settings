# Language

- Keep in mind that the user's native language is English. When asked to write content (e.g., pull requests, letters, documentation, messages) in a non-English language, write only that specific content in the requested language. All surrounding conversation — confirmations, follow-up questions, summaries — must remain in English.

# File Output

- `$DOCS_BASE` = `agents/claude` (relative to the repository root).
- When instructed to generate markdown files, write them under `$DOCS_BASE/` unless instructed otherwise. Create directories as needed.
- Automatically organize files into a category subdirectory that fits the content. Choose a short, lowercase, kebab-case folder name. Examples:
  - Refactor or implementation plans → `$DOCS_BASE/plans/`
  - Codebase or system analysis → `$DOCS_BASE/system-analysis/`
  - Architecture or design decisions → `$DOCS_BASE/architecture/`
  - Research, spikes, or investigations → `$DOCS_BASE/research/`
  - Guides, how-tos, or runbooks → `$DOCS_BASE/guides/`
  - Meeting notes or summaries → `$DOCS_BASE/notes/`
- These are examples, not an exhaustive list. Pick the most fitting category, or create a new one if none of the above apply. If a category directory already exists, add to it rather than creating a near-duplicate.
- Name individual files descriptively (e.g., `auth-refactor.md`, not `plan.md`).

