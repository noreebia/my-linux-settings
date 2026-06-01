#!/usr/bin/env python3
"""Wrike attachment helper — fills the gap the Wrike MCP leaves open.

Reuses the Wrike token already configured for the Wrike MCP server in
~/.claude.json (single source of truth — no second credential to manage).
Talks directly to the Wrike REST API for the binary-heavy attachment
operations that don't travel well over MCP's JSON-RPC transport.

Usage:
    wrike_attach.py list-task     <taskId>
    wrike_attach.py list-folder   <folderId>
    wrike_attach.py info          <attachmentId>
    wrike_attach.py download      <attachmentId> [outpath]
    wrike_attach.py download-all  <taskId> [dir]
    wrike_attach.py upload        <taskId> <filepath>

taskId/folderId may be the API string id (e.g. IEACA...) — resolve names to
ids with the MCP tools (wrike_search_tasks / wrike_search_folder_project)
before calling this script.
"""
import json
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

CONFIG_PATH = Path.home() / ".claude.json"
REGION_HOSTS = {"US": "www.wrike.com", "EU": "app-eu.wrike.com", "US2": "app-us2.wrike.com"}


def get_token_and_host():
    """Read the Wrike bearer token from the MCP server config.

    Returns (token, host). Host is derived from the JWT region claim so the
    script targets the correct data center automatically.
    """
    cfg = json.loads(CONFIG_PATH.read_text())
    server = cfg.get("mcpServers", {}).get("wrike")
    if not server:
        sys.exit("No 'wrike' MCP server found in ~/.claude.json — is the Wrike MCP installed?")
    auth = server.get("headers", {}).get("Authorization", "")
    token = auth.split(None, 1)[1] if auth.lower().startswith("bearer ") else auth
    if not token:
        sys.exit("No bearer token found in the wrike MCP config")

    # Decode the JWT payload (middle segment) to find the region claim. The
    # payload is base64url and not a secret; we only read it, never verify it.
    host = "www.wrike.com"  # US default if anything below fails
    try:
        import base64
        payload_b64 = token.split(".")[1]
        payload_b64 += "=" * (-len(payload_b64) % 4)  # restore base64 padding
        payload = json.loads(base64.urlsafe_b64decode(payload_b64))
        inner = json.loads(payload["d"]) if isinstance(payload.get("d"), str) else payload
        host = REGION_HOSTS.get(inner.get("r", "US"), "www.wrike.com")
    except Exception:
        pass  # fall back to US host
    return token, host


def api(method, path, host, token, data=None, headers=None, raw=False):
    url = f"https://{host}/api/v4{path}"
    hdrs = {"Authorization": f"Bearer {token}"}
    if headers:
        hdrs.update(headers)
    req = urllib.request.Request(url, data=data, method=method, headers=hdrs)
    body = urllib.request.urlopen(req).read()
    return body if raw else json.loads(body)


def get_meta(att_id, host, token):
    """Return the single-attachment metadata dict, or None if not found."""
    data = api("GET", f"/attachments/{att_id}", host, token).get("data", [])
    return data[0] if data else None


def unique_path(directory, name, used):
    """Pick a non-colliding path inside `directory` for `name`.

    Wrike lets two attachments share a filename, so bulk downloads must not
    overwrite each other. On a clash we insert ' (2)', ' (3)', … before the
    extension, and also track names claimed earlier in this same run.
    """
    stem, dot, ext = name.partition(".")
    candidate = name
    i = 2
    while candidate in used or (directory / candidate).exists():
        candidate = f"{stem} ({i}){dot}{ext}"
        i += 1
    used.add(candidate)
    return directory / candidate


def _save(att, host, token, out_path):
    blob = api("GET", f"/attachments/{att['id']}/download", host, token, raw=True)
    out_path.write_bytes(blob)
    return len(blob)


def list_attachments(scope, scope_id):
    token, host = get_token_and_host()
    items = api("GET", f"/{scope}/{scope_id}/attachments", host, token).get("data", [])
    if not items:
        print("(no attachments)")
        return
    for a in items:
        size = a.get("size", -1)
        kind = a.get("type", "?")
        size_str = f"{kind} (no local file)" if size < 0 else f"{size:,} B"
        print(f"{a['id']}  {a.get('name','?'):40}  {a.get('contentType','?'):25}  {size_str}")


def info(att_id):
    token, host = get_token_and_host()
    meta = get_meta(att_id, host, token)
    if not meta:
        sys.exit(f"No attachment found with id {att_id}")
    print(json.dumps(meta, indent=2))


def download(att_id, outpath=None):
    token, host = get_token_and_host()
    meta = get_meta(att_id, host, token)
    if not meta:
        sys.exit(f"No attachment found with id {att_id}")
    if meta.get("type") != "Wrike":
        sys.exit(f"'{meta.get('name', att_id)}' is an external {meta.get('type')} attachment — "
                 "Wrike doesn't host its bytes, so there's nothing to download. "
                 f"Its source URL is in `info {att_id}`.")
    name = meta.get("name", att_id)
    out = Path(outpath) if outpath else Path(name)
    if out.is_dir():
        out = out / name
    n = _save(meta, host, token, out)
    print(f"Downloaded {n:,} bytes -> {out}")


def download_all(task_id, dest_dir="."):
    token, host = get_token_and_host()
    items = api("GET", f"/tasks/{task_id}/attachments", host, token).get("data", [])
    wrike_items = [a for a in items if a.get("type") == "Wrike"]
    external = [a for a in items if a.get("type") != "Wrike"]
    if not items:
        print("(no attachments on this task)")
        return
    directory = Path(dest_dir)
    directory.mkdir(parents=True, exist_ok=True)
    used = set()
    total = 0
    for a in wrike_items:
        out = unique_path(directory, a.get("name", a["id"]), used)
        n = _save(a, host, token, out)
        total += n
        print(f"  {out.name}  ({n:,} B)")
    print(f"\nDownloaded {len(wrike_items)} file(s), {total:,} bytes total -> {directory}/")
    if external:
        names = ", ".join(a.get("name", a["id"]) for a in external)
        print(f"Skipped {len(external)} external attachment(s) (not Wrike-hosted): {names}")


def upload(task_id, filepath):
    token, host = get_token_and_host()
    p = Path(filepath)
    if not p.is_file():
        sys.exit(f"File not found: {filepath}")
    data = p.read_bytes()
    headers = {
        "X-File-Name": urllib.parse.quote(p.name),
        "Content-Type": "application/octet-stream",
    }
    res = api("POST", f"/tasks/{task_id}/attachments", host, token, data=data, headers=headers)
    a = res.get("data", [{}])[0]
    print(f"Uploaded {p.name} ({len(data):,} B) -> attachment {a.get('id','?')} on task {task_id}")


def main():
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        sys.exit(1)
    cmd, rest = args[0], args[1:]
    try:
        if cmd == "list-task":
            list_attachments("tasks", rest[0])
        elif cmd == "list-folder":
            list_attachments("folders", rest[0])
        elif cmd == "info":
            info(rest[0])
        elif cmd == "download":
            download(rest[0], rest[1] if len(rest) > 1 else None)
        elif cmd == "download-all":
            download_all(rest[0], rest[1] if len(rest) > 1 else ".")
        elif cmd == "upload":
            upload(rest[0], rest[1])
        else:
            sys.exit(f"Unknown command: {cmd}\n{__doc__}")
    except IndexError:
        sys.exit(f"Missing argument for '{cmd}'.\n{__doc__}")
    except urllib.error.HTTPError as e:
        sys.exit(f"Wrike API error {e.code}: {e.read().decode(errors='replace')[:500]}")
    except urllib.error.URLError as e:
        sys.exit(f"Network error reaching Wrike: {e.reason}")


if __name__ == "__main__":
    main()
