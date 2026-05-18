---
name: allow-tool-prompt
description: >
  Parses a Claude Code tool-permission prompt and adds the broadest possible auto-approval rule
  to the managed settings.json so that tool (and every sibling tool from the same source) stops
  asking on future invocations.
---

# Allow Tool Prompt

When Claude Code wants to invoke a tool that isn't on the allow-list, it prints a permission prompt and waits. The user is tired of approving these one at a time. This skill takes a pasted prompt and adds the **widest** matching rule to `permissions.allow` in the managed settings file — the goal is to stop being asked again, not to minimize blast radius. Pick the broadest rule that plausibly covers the source of the prompt.

The target file is `llm-agents/claude-code/settings.json` in this repo. `priority_05_update_claude_code_settings.sh` deep-merges it into `~/.claude/settings.json` on the next install run. Editing `~/.claude/settings.json` directly would be lost on the next merge, so don't do that.

---

## Process

### 1. Identify the tool from the prompt

The input is the permission-prompt block the user pasted (or referenced from earlier in the conversation). Two shapes show up:

**MCP tool** — `(MCP)` suffix and a `<server> - <tool_name>(args)` line:

```
   excalidraw - import_scene(filePath: "...", mode: "replace") (MCP)
```

Extract `<server>` (e.g. `excalidraw`).

**Native tool** — no `(MCP)` suffix; the line names a built-in tool:

```
   Bash(npm install --save-dev jest)
   Edit(/home/sooyoung/code_linux/foo/src/app.tsx)
   WebFetch(https://example.com/docs)
```

Extract just the tool name (`Bash`, `Edit`, `WebFetch`, etc.).

If the prompt is too garbled to identify the tool confidently, ask the user once for clarification rather than guessing. Otherwise, proceed.

### 2. Translate to the widest matching rule

| Source | Rule |
|---|---|
| Any MCP tool (e.g. `excalidraw - import_scene (MCP)`) | `mcp__<server>` (e.g. `mcp__excalidraw`) |
| `Bash(<anything>)` | `Bash(*)` |
| `Edit(<anything>)` | `Edit` |
| `Write(<anything>)` | `Write` |
| `Read(<anything>)` | `Read` |
| `WebFetch(<anything>)` | `WebFetch` |
| `WebSearch(<anything>)` | `WebSearch` |
| Any other named tool | the bare tool name |

The principle: drop every qualifier (path, command, URL, args). The bare tool name (or `mcp__<server>` for MCPs) is the widest form Claude Code accepts and matches every future invocation of that tool from that source.

### 3. Edit the managed settings file

Target: `llm-agents/claude-code/settings.json` at the repo root. Locate it with `git rev-parse --show-toplevel` if the cwd isn't already inside the repo.

The install script merges this file into `~/.claude/settings.json` with `jq -s '.[0] * .[1]'`, which **replaces arrays whole** rather than unioning them. Every existing entry in `permissions.allow` has to survive this edit untouched — dropping even one silently re-enables permission prompts elsewhere.

Do the edit by parsing, mutating, and re-serializing — not by string-level patching. Use `jq`:

```bash
SETTINGS="$(git rev-parse --show-toplevel)/llm-agents/claude-code/settings.json"
jq --arg rule "$RULE" '
  if (.permissions.allow | index($rule)) then .
  else .permissions.allow += [$rule]
  end
' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
```

`jq` defaults to 2-space indentation, which matches the file's existing style.

### 4. Check for redundancy before writing

If the rule is already in `permissions.allow`, report "already allowed" and skip the write. No need to scan for narrower-rules-now-redundant — leaving them is harmless clutter and removing them isn't worth the risk of touching unrelated entries.

### 5. Report and remind

After writing, tell the user three things, briefly:

1. The exact rule that was added (or that nothing changed, because it was already present).
2. To run `./priority_05_update_claude_code_settings.sh` from the repo root to merge the change into `~/.claude/settings.json`.
3. That the current Claude Code session won't pick it up until restart — the next session will be prompt-free for this source.

Keep this to a few lines. The user pasted a prompt to make it go away; that's the whole story.
