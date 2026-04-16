# Skill Writing Guidelines

The following guidelines apply when creating or modifying SKILL.md files in this directory.

Claude is already smart. Skills should only contain context Claude doesn't already have — project-specific conventions, non-obvious operational details, and the *why* behind constraints. Everything else is wasted tokens competing with conversation history.

Default to high freedom: describe *what* the output should contain, not *how* to structure it. Most of our skills are open-field tasks (reviews, analysis, docs) where many approaches are valid — trust Claude to pick the right one for the context. Reserve rigid instructions for fragile operations where only one path is safe.

Use shared variables from `llm-agents/AGENTS_GLOBAL.md` rather than repeating definitions across skills.

## Description conventions

Keep the `description` field in frontmatter concise — 1–2 sentences in third person that say what the skill does. Do not include trigger phrases, example user prompts, or proactive-triggering language ("also trigger when..."). Skills are invoked manually, not auto-detected, so descriptions only need to be clear enough to distinguish skills from each other at a glance.

## Argument conventions

Skills that accept arguments should follow these conventions for reliable LLM parsing:

- **All args use `--flag` syntax** — booleans are bare flags (`--file`), key-value pairs use `=` (`--scope=commit`, `--lang=Korean`). This leverages CLI conventions deeply embedded in LLM training data and makes argument order irrelevant.
- **Absence = off / default** — don't force users to pass `no` or `false`. If a flag isn't present, use its default value.
- **Add `argument-hint` to frontmatter** — shown during autocomplete. Use `<required>` and `[optional]` brackets: `argument-hint: "[--scope=<scope>] [--file] [--plan=<hint>]"`.
- **Include an Examples section** — 3–5 invocation examples after the Arguments section. This is the single most effective way to ensure correct parsing.
- **Be consistent across skills** — shared concepts (e.g., `--scope`, `--file`) should use the same name and semantics everywhere.
