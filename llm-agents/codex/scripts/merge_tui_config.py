#!/usr/bin/env python3
"""Merge Codex TUI statusline settings without replacing user config."""

from pathlib import Path
import re
import shutil
import sys
import tempfile


MERGED_KEYS = ("status_line_use_colors", "status_line")


def read_setting_blocks(path: Path) -> dict[str, list[str]]:
    lines = path.read_text().splitlines()
    blocks: dict[str, list[str]] = {}
    index = 0

    while index < len(lines):
        line = lines[index]
        stripped = line.strip()

        for key in MERGED_KEYS:
            if re.match(rf"^{re.escape(key)}\s*=", stripped):
                block = [line]
                if "[" in line and "]" not in line:
                    index += 1
                    while index < len(lines):
                        block.append(lines[index])
                        if lines[index].strip().startswith("]"):
                            break
                        index += 1
                blocks[key] = block
                break

        index += 1

    if not blocks:
        raise RuntimeError(f"No Codex TUI settings found in {path}")

    return blocks


def merge_tui_settings(source: Path, target: Path) -> str:
    source_blocks = read_setting_blocks(source)
    target_lines = target.read_text().splitlines()

    output: list[str] = []
    in_tui = False
    seen_tui = False
    written: set[str] = set()
    index = 0

    def emit_missing() -> None:
        for key in MERGED_KEYS:
            if key in source_blocks and key not in written:
                output.extend(source_blocks[key])
                written.add(key)

    while index < len(target_lines):
        line = target_lines[index]
        stripped = line.strip()

        if re.match(r"^\[[^\]]+\]\s*$", stripped):
            if in_tui:
                emit_missing()
            in_tui = stripped == "[tui]"
            seen_tui = seen_tui or in_tui
            output.append(line)
            index += 1
            continue

        replaced = False
        if in_tui:
            for key in MERGED_KEYS:
                if key in source_blocks and re.match(rf"^{re.escape(key)}\s*=", stripped):
                    output.extend(source_blocks[key])
                    written.add(key)
                    if "[" in line and "]" not in line:
                        index += 1
                        while index < len(target_lines) and not target_lines[index].strip().startswith("]"):
                            index += 1
                    replaced = True
                    break

        if not replaced:
            output.append(line)
        index += 1

    if in_tui:
        emit_missing()

    if not seen_tui:
        if output and output[-1] != "":
            output.append("")
        output.append("[tui]")
        emit_missing()

    return "\n".join(output) + "\n"


def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: merge_tui_config.py <source-config.toml> <target-config.toml>", file=sys.stderr)
        return 2

    source = Path(sys.argv[1])
    target = Path(sys.argv[2])

    if not target.exists():
        shutil.copyfile(source, target)
        return 0

    merged = merge_tui_settings(source, target)
    with tempfile.NamedTemporaryFile("w", delete=False, dir=str(target.parent)) as tmp:
        tmp.write(merged)
        tmp_path = Path(tmp.name)

    tmp_path.replace(target)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
