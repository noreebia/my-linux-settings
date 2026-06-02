# Skills Guide

This directory contains reusable agent skills, mostly in `SKILL.md` files. The same skills are deployed to Claude Code and Codex, so write them to be useful across agents unless the skill explicitly depends on Claude-only behavior.

Skills should only contain context the base agent is unlikely to know: project-specific conventions, non-obvious operational details, and the reason behind constraints. Avoid spending skill tokens on generic coding advice that competes with conversation history.

Default to high freedom: describe what the output should contain, not how to structure it. Most skills here are open-field tasks such as reviews, analysis, or docs where many approaches are valid. Reserve rigid workflows for fragile operations where only one path is safe.

## Editing Rules

- Preserve the `SKILL.md` format. Keep descriptions concise and focused on what the skill does.
- Put long implementation logic in `scripts/` when a skill needs repeatable tooling. Prefer maintaining a script over embedding large command blocks in prose.
- Use relative paths inside a skill from that skill's own directory.
- Avoid adding runtime-only or generated files here. This subtree is copied into agent home directories.
- When using shared variables from `AGENTS_GLOBAL.md`, remember that the file is deployed under different names per agent. If a skill needs a convention at runtime, inline enough context for it to stand alone.

## Description Conventions

- Keep the `description` field in frontmatter concise: one or two sentences in third person that say what the skill does.
- Do not include trigger phrases, example user prompts, or proactive-triggering language such as "also trigger when".
- Descriptions only need to distinguish skills from each other at a glance.

## Argument Conventions

- Use `--flag` syntax for all arguments. Booleans are bare flags, and key-value pairs use `=`, such as `--scope=commit`.
- Absence means off or default. Do not force users to pass `no` or `false`.
- Add `argument-hint` to frontmatter for skills that accept arguments. It is shown during autocomplete. Use `<required>` and `[optional]` brackets, such as `argument-hint: "[--scope=<scope>] [--file] [--plan=<hint>]"`.
- Include three to five invocation examples after the Arguments section.
- Be consistent across skills. Shared concepts such as `--scope` or `--file` should use the same name and semantics everywhere.
