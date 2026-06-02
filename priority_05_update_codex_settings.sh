#!/bin/bash
set -euo pipefail

SOURCE_DIR="./llm-agents/codex"
TARGET_DIR="$HOME/.codex"
CONFIG_SOURCE="$SOURCE_DIR/config.toml"
CONFIG_TARGET="$TARGET_DIR/config.toml"

command -v python3 >/dev/null 2>&1 || sudo apt install python3 -y

merge_codex_config() {
  local source="$1"
  local target="$2"

  if [ ! -f "$target" ]; then
    cp "$source" "$target"
    return
  fi

  local tmp
  tmp="$(mktemp)"

  python3 - "$source" "$target" > "$tmp" <<'PY'
from pathlib import Path
import re
import sys

source_path = Path(sys.argv[1])
target_path = Path(sys.argv[2])
source_lines = source_path.read_text().splitlines()
target_lines = target_path.read_text().splitlines()

keys = ("status_line_use_colors", "status_line")
source_values = {}
i = 0
while i < len(source_lines):
    line = source_lines[i]
    stripped = line.strip()
    for key in keys:
        if re.match(rf"^{re.escape(key)}\s*=", stripped):
            block = [line]
            if "[" in line and "]" not in line:
                i += 1
                while i < len(source_lines):
                    block.append(source_lines[i])
                    if source_lines[i].strip().startswith("]"):
                        break
                    i += 1
            source_values[key] = block
            break
    i += 1

if not source_values:
    sys.exit("No Codex TUI settings found in source config")

out = []
in_tui = False
seen_tui = False
written = set()
i = 0

def emit_missing():
    for key in keys:
        if key in source_values and key not in written:
            out.extend(source_values[key])
            written.add(key)

while i < len(target_lines):
    line = target_lines[i]
    stripped = line.strip()

    if re.match(r"^\[[^\]]+\]\s*$", stripped):
        if in_tui:
            emit_missing()
        in_tui = stripped == "[tui]"
        seen_tui = seen_tui or in_tui
        out.append(line)
        i += 1
        continue

    replaced = False
    if in_tui:
        for key in keys:
            if key in source_values and re.match(rf"^{re.escape(key)}\s*=", stripped):
                out.extend(source_values[key])
                written.add(key)
                if "[" in line and "]" not in line:
                    i += 1
                    while i < len(target_lines) and not target_lines[i].strip().startswith("]"):
                        i += 1
                replaced = True
                break
    if not replaced:
        out.append(line)
    i += 1

if in_tui:
    emit_missing()

if not seen_tui:
    if out and out[-1] != "":
        out.append("")
    out.append("[tui]")
    emit_missing()

print("\n".join(out) + "\n", end="")
PY

  mv "$tmp" "$target"
}

mkdir -p "$TARGET_DIR"

# Copy AGENTS_GLOBAL.md as AGENTS.md to ~/.codex
cp ./llm-agents/AGENTS_GLOBAL.md "$TARGET_DIR/AGENTS.md"

# Reuse Claude skills for Codex.
rsync -a --exclude='CLAUDE.md' ./llm-agents/claude-code/skills/ "$TARGET_DIR/skills/"

merge_codex_config "$CONFIG_SOURCE" "$CONFIG_TARGET"

echo "Codex settings updated successfully."
