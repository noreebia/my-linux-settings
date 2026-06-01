---
name: wrike-attachments
description: Download, upload, and list file attachments on Wrike tasks and folders. Use when the user wants to retrieve, save, fetch, add, or list attachments/files on a Wrike task or folder — capabilities the Wrike MCP server does not provide.
---

# Wrike Attachments

The Wrike MCP server handles tasks, comments, projects, custom fields, and approvals, but **cannot retrieve or upload file attachments** (its transport isn't suited to binary content). This skill fills that gap by calling the Wrike REST API directly.

## Authentication

No setup needed. The helper script reads the Wrike bearer token straight from the `wrike` MCP server config in `~/.claude.json` (single source of truth — if the token rotates, both stay in sync) and auto-detects the correct data-center host from the token's region claim.

## How to use

Attachments are addressed by task/folder/attachment **string IDs** (e.g. `IEACA...`), not names. If the user refers to a task by name, first resolve it to an ID with the MCP tools (`wrike_search_tasks`, `wrike_get_tasks`, `wrike_search_folder_project`), then pass that ID here.

Run the script with Bash:

```bash
python3 ~/.claude/skills/wrike-attachments/scripts/wrike_attach.py <command> <args>
```

| Command | Purpose |
|---|---|
| `list-task <taskId>` | List attachments on a task (id, name, type, size) |
| `list-folder <folderId>` | List attachments on a folder/project |
| `info <attachmentId>` | Full metadata for one attachment (JSON) |
| `download <attachmentId> [outpath]` | Download one attachment; defaults to its original filename in the cwd |
| `download-all <taskId> [dir]` | Download every Wrike-hosted attachment on a task into `dir` (default cwd) |
| `upload <taskId> <filepath>` | Upload a local file as a new attachment on a task |

For "save all the files/photos off this task", prefer `download-all` over many `download` calls. It de-duplicates clashing filenames (Wrike allows two attachments to share a name) so nothing is silently overwritten.

## Typical flow

1. User: "Get the attachments on the 'Q3 Budget' task."
2. Use `wrike_search_tasks` (MCP) to find the task and its ID.
3. `wrike_attach.py list-task <id>` to list them, showing names/types to the user.
4. `wrike_attach.py download <attachmentId>` for any the user wants saved locally.

## Notes

- `size` of `-1` means an external attachment (Google Drive, Box, etc.) — there's no Wrike-hosted blob to download. `download` refuses these with a clear message (their source URL is in `info`); `download-all` skips them and reports which were skipped.
- Errors surface as `Wrike API error <code>: <body>`; a 404 usually means a stale/incorrect ID, a 403 means the token lacks access to that item.
- Does **not** conflict with the Wrike MCP — they operate independently. Prefer MCP tools for everything except attachment binary I/O.
