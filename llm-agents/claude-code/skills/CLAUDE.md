# Skill Writing Guidelines

The following guidelines apply when creating or modifying SKILL.md files in this directory.

Claude is already smart. Skills should only contain context Claude doesn't already have — project-specific conventions, non-obvious operational details, and the *why* behind constraints. Everything else is wasted tokens competing with conversation history.

Default to high freedom: describe *what* the output should contain, not *how* to structure it. Most of our skills are open-field tasks (reviews, analysis, docs) where many approaches are valid — trust Claude to pick the right one for the context. Reserve rigid instructions for fragile operations where only one path is safe.

Use shared variables from `llm-agents/AGENTS_GLOBAL.md` rather than repeating definitions across skills.

## Argument conventions

Skills that accept arguments should follow these conventions for reliable LLM parsing:

- **Required args are positional** — the first bare word(s) after the skill name. One positional arg per skill is ideal; two is the max.
- **Optional args use `--flag` syntax** — booleans are bare flags (`--file`), key-value pairs use `=` (`--plan=<hint>`, `--lang=Korean`). This leverages CLI conventions deeply embedded in LLM training data.
- **Never use positional placeholders for optional args** — don't force users to pass `no` or `false` to "skip" an optional arg. Absence = off.
- **Add `argument-hint` to frontmatter** — shown during autocomplete. Use `<required>` and `[optional]` brackets: `argument-hint: "<scope> [--file] [--plan=<hint>]"`.
- **Include an Examples section** — 3–5 invocation examples after the Arguments section. This is the single most effective way to ensure correct parsing.
- **Be consistent across skills** — shared concepts (e.g., `scope`, `--file`) should use the same name and semantics everywhere.
