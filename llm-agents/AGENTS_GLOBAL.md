# Language

- Keep in mind that the user's native language is English. When asked to write content (e.g., pull requests, letters, documentation, messages, translations) in a non-English language, write only that specific content in the requested language. All surrounding conversation — confirmations, follow-up questions, summaries — must remain in English.

# Variable Declarations

If any instructions reference the variables below, substitute them with their defined values.

- `$AGENT_NAME` = the agent's product/brand name (e.g., `Claude`, `Codex`, `Gemini`). Use this wherever an agent needs to identify itself — metadata headers, author fields, etc.
- `$AGENT_DIR` = the `agents/` directory, relative to the repository root. If no git repo can be detected, relative to the directory where the agent command was entered.
- `$AGENT_LOCAL_DIR` = `$AGENT_DIR/<lowercased $AGENT_NAME>` (e.g., `agents/claude`, `agents/codex`, `agents/gemini`).

# Function Declarations

If any instructions reference the functions below, resolve them by executing the described procedure and substitute the result.

- `$CURRENT_TIME("<format>")` = the current local time formatted per `<format>`. Must be resolved by executing a shell command (e.g., `date '+<format>'`) or equivalent tool each time it is called. Examples:
  - `$CURRENT_TIME("YYYYMMDDHHMM")` → `date '+%Y%m%d%H%M'` → `202604061430`
  - `$CURRENT_TIME("YYYY-MM-DD HH:MM")` → `date '+%Y-%m-%d %H:%M'` → `2026-04-06 14:30`

# Markdown File Generation

- When instructed to generate markdown files without a specific directory mentioned, write them under `$AGENT_LOCAL_DIR/`. Create directories as needed.
- Automatically organize files into a category subdirectory that fits the content. Choose a short, lowercase, kebab-case folder name. Examples:
  - `$AGENT_LOCAL_DIR/plans/`
  - `$AGENT_LOCAL_DIR/system-analysis/`
  - `$AGENT_LOCAL_DIR/guides/`
- These are merely examples. Choose the most fitting category for the content. If a category directory already exists, add to it rather than creating a near-duplicate.
- Name files descriptively with a `$CURRENT_TIME("YYYYMMDDHHMM")`-prefixed filename for chronological ordering (e.g., `202604021430-auth-refactor.md`, not `plan.md` or `auth-refactor.md`).

# Metadata Headers for Generated Files

When generating a file that includes a metadata header, place it as an italic line right after the document title:

```
*<Action>: YYYY-MM-DD HH:MM | Author: $AGENT_NAME | <context fields...>*
```

- **Action** — past-tense verb matching what the skill did (e.g., `Generated`, `Reviewed`, `Responded`, `Analyzed`)
- **Date/time** — `$CURRENT_TIME("YYYY-MM-DD HH:MM")`
- **Author** — always `$AGENT_NAME`
- **Context fields** — skill-specific key-value pairs (see each skill). Use ` | ` as separator. Only include fields that have a meaningful value — omit any that would be empty or redundant with the title.

