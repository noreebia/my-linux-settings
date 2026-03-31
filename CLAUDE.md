# Writing Skills (`llm-agents/claude-code/skills/`)

Claude is already smart. Skills should only contain context Claude doesn't already have — project-specific conventions, non-obvious operational details, and the *why* behind constraints. Everything else is wasted tokens competing with conversation history.

Default to high freedom: describe *what* the output should contain, not *how* to structure it. Most of our skills are open-field tasks (reviews, analysis, docs) where many approaches are valid — trust Claude to pick the right one for the context. Reserve rigid instructions for fragile operations where only one path is safe.

Reference `$AGENT_NAME`, `$AGENT_DIR`, `$AGENT_LOCAL_DIR` from `llm-agents/AGENTS_GLOBAL.md` instead of repeating definitions.
