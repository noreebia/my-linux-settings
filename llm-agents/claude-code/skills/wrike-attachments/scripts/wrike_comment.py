#!/usr/bin/env python3
"""Post comments to Wrike tasks via the REST API.

Reuses the same auth pattern as wrike_attach.py: reads the bearer token from the
`wrike` MCP server config in ~/.claude.json and auto-detects the datacenter host.

Usage:
  wrike_comment.py whoami                      # read-only auth check
  wrike_comment.py get <taskId>                # list existing comments (id + text)
  wrike_comment.py add <taskId> <textfile>     # post a comment; body read from a file (HTML allowed)
"""
import sys
import os
import json
import base64
import urllib.request
import urllib.error
import urllib.parse

CLAUDE_CONFIG = os.path.expanduser("~/.claude.json")


REGION_HOSTS = {"US": "www.wrike.com", "EU": "app-eu.wrike.com", "US2": "app-us2.wrike.com"}


def _decode_region_host(token: str) -> str:
    # Mirror wrike_attach.py: region claim lives in the JWT payload's `d`/`r`.
    try:
        payload_b64 = token.split(".")[1]
        payload_b64 += "=" * (-len(payload_b64) % 4)
        payload = json.loads(base64.urlsafe_b64decode(payload_b64))
        inner = json.loads(payload["d"]) if isinstance(payload.get("d"), str) else payload
        return REGION_HOSTS.get(inner.get("r", "US"), "www.wrike.com")
    except Exception:
        return "www.wrike.com"


def _load_token() -> str:
    with open(CLAUDE_CONFIG) as f:
        cfg = json.load(f)

    def find_in(servers):
        if not isinstance(servers, dict):
            return None
        for name, spec in servers.items():
            if "wrike" in name.lower():
                env = (spec or {}).get("env", {}) or {}
                for k, v in env.items():
                    if "TOKEN" in k.upper() or "KEY" in k.upper():
                        return v
                hdrs = (spec or {}).get("headers", {}) or {}
                for k, v in hdrs.items():
                    if "auth" in k.lower():
                        return v.replace("Bearer ", "")
        return None

    tok = find_in(cfg.get("mcpServers", {}))
    if tok:
        return tok
    for proj in (cfg.get("projects", {}) or {}).values():
        tok = find_in((proj or {}).get("mcpServers", {}))
        if tok:
            return tok
    raise SystemExit("Could not find Wrike token in ~/.claude.json mcpServers config")


TOKEN = None
HOST = None


def _api(path: str, method: str = "GET", data=None):
    global TOKEN, HOST
    if TOKEN is None:
        TOKEN = _load_token()
        HOST = _decode_region_host(TOKEN)
    url = f"https://{HOST}/api/v4{path}"
    headers = {"Authorization": f"Bearer {TOKEN}"}
    body = None
    if data is not None:
        body = urllib.parse.urlencode(data).encode()
        headers["Content-Type"] = "application/x-www-form-urlencoded"
    req = urllib.request.Request(url, data=body, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        raise SystemExit(f"Wrike API error {e.code}: {e.read().decode(errors='replace')}")


def cmd_whoami():
    data = _api("/contacts?me=true")
    me = data.get("data", [{}])[0]
    print(f"OK host={HOST} me={me.get('firstName','')} {me.get('lastName','')} id={me.get('id','')}")


def cmd_get(task_id):
    data = _api(f"/tasks/{task_id}/comments")
    cs = data.get("data", [])
    if not cs:
        print("(no comments)")
        return
    for c in cs:
        print(f"{c.get('id')}  {c.get('createdDate')}  {c.get('text','')[:200]}")


def cmd_add(task_id, textfile):
    with open(textfile, encoding="utf-8") as f:
        text = f.read()
    data = _api(f"/tasks/{task_id}/comments", method="POST",
                data={"text": text, "plainText": "false"})
    c = data.get("data", [{}])[0]
    print(f"Posted comment {c.get('id')} to {task_id} ({c.get('createdDate')})")


def cmd_update(comment_id, textfile):
    with open(textfile, encoding="utf-8") as f:
        text = f.read()
    data = _api(f"/comments/{comment_id}", method="PUT",
                data={"text": text, "plainText": "false"})
    c = data.get("data", [{}])[0]
    print(f"Updated comment {c.get('id')} ({c.get('updatedDate')})")


def cmd_delete(comment_id):
    _api(f"/comments/{comment_id}", method="DELETE")
    print(f"Deleted comment {comment_id}")


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    cmd = sys.argv[1]
    if cmd == "whoami":
        cmd_whoami()
    elif cmd == "get":
        cmd_get(sys.argv[2])
    elif cmd == "add":
        cmd_add(sys.argv[2], sys.argv[3])
    elif cmd == "update":
        cmd_update(sys.argv[2], sys.argv[3])
    elif cmd == "delete":
        cmd_delete(sys.argv[2])
    else:
        raise SystemExit(f"Unknown command: {cmd}\n{__doc__}")


if __name__ == "__main__":
    main()
