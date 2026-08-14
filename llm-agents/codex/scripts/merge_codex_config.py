#!/usr/bin/env python3
"""Merge reusable Codex settings without replacing user-specific config."""

from pathlib import Path
import re
import shutil
import sys
import tempfile


MERGED_ROOT_KEYS = ("approval_policy", "sandbox_mode")
MERGED_TUI_KEYS = ("status_line_use_colors", "status_line")


def read_tui_setting_blocks(path: Path) -> dict[str, list[str]]:
    lines = path.read_text().splitlines()
    blocks: dict[str, list[str]] = {}
    index = 0

    while index < len(lines):
        line = lines[index]
        stripped = line.strip()

        for key in MERGED_TUI_KEYS:
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


def read_root_settings(path: Path) -> dict[str, str]:
    settings: dict[str, str] = {}

    for line in path.read_text().splitlines():
        stripped = line.strip()
        if re.match(r"^\[.*\]\s*$", stripped):
            break

        for key in MERGED_ROOT_KEYS:
            if re.match(rf"^{re.escape(key)}\s*=", stripped):
                settings[key] = line
                break

    missing = set(MERGED_ROOT_KEYS) - settings.keys()
    if missing:
        raise RuntimeError(
            f"Missing reusable Codex settings in {path}: {', '.join(sorted(missing))}"
        )

    return settings


def merge_root_settings(source: Path, target_lines: list[str]) -> list[str]:
    source_settings = read_root_settings(source)
    output: list[str] = []
    written: set[str] = set()
    in_root = True

    def emit_missing() -> None:
        for key in MERGED_ROOT_KEYS:
            if key not in written:
                output.append(source_settings[key])
                written.add(key)

    for line in target_lines:
        stripped = line.strip()

        if in_root and re.match(r"^\[.*\]\s*$", stripped):
            emit_missing()
            if output and output[-1] != "":
                output.append("")
            in_root = False

        replaced = False
        if in_root:
            for key in MERGED_ROOT_KEYS:
                if re.match(rf"^{re.escape(key)}\s*=", stripped):
                    output.append(source_settings[key])
                    written.add(key)
                    replaced = True
                    break

        if not replaced:
            output.append(line)

    if in_root:
        emit_missing()

    return output


def merge_tui_settings(source: Path, target_lines: list[str]) -> str:
    source_blocks = read_tui_setting_blocks(source)

    output: list[str] = []
    in_tui = False
    seen_tui = False
    written: set[str] = set()
    index = 0

    def emit_missing() -> None:
        for key in MERGED_TUI_KEYS:
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
            for key in MERGED_TUI_KEYS:
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
        print("Usage: merge_codex_config.py <source-config.toml> <target-config.toml>", file=sys.stderr)
        return 2

    source = Path(sys.argv[1])
    target = Path(sys.argv[2])

    if not target.exists():
        shutil.copyfile(source, target)
        return 0

    target_lines = target.read_text().splitlines()
    merged_lines = merge_root_settings(source, target_lines)
    merged = merge_tui_settings(source, merged_lines)
    with tempfile.NamedTemporaryFile("w", delete=False, dir=str(target.parent)) as tmp:
        tmp.write(merged)
        tmp_path = Path(tmp.name)

    tmp_path.replace(target)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
