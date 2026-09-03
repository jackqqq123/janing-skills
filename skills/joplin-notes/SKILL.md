---
name: joplin-notes
description: Add, search, and manage notes in Joplin via its local REST API (Web Clipper / ClipperServer, default http://127.0.0.1:41184). Use when the user wants the agent to create a note, fetch notebook folders, list notes, or search Joplin content. Requires a valid Joplin API token (Web Clipper token) and the Joplin Clipper server running.
user-invocable: true
---

# Joplin Notes

Add, read, search, and organize notes in the user's Joplin instance through the
local JSON REST API served by the Web Clipper / ClipperServer.

## Prerequisites

1. **Joplin app running** with the **Web Clipper** service enabled.
2. A valid **API token** (Web Clipper token). Get it from Joplin:
   **Settings → Web Clipper → Authorization token**, or ask the Joplin CLI
   (`joplin config webclipper.token` if the CLI is available).

The default endpoint is `http://127.0.0.1:41184`. If the port differs,
read it from `JOPLIN_API_BASE_URL` or the user's configuration.

This skill reads the token from the **environment**, never from this file.

## Configuration

Two environment variables supply the connection. They are read at call time;
you do **not** paste a token into this file.

- `JOPLIN_API_BASE_URL` = `http://127.0.0.1:41184` (default already set below)
- `JOPLIN_TOKEN` = the Web Clipper API token

`JOPLIN_TOKEN` is a user-level environment variable on this machine (set via
`setx JOPLIN_TOKEN <token>` so every new shell/agent process inherits it). The
export inside a running bash session is the per-session equivalent.
Do **not** write the token into this file or into any repository file.

All curl calls below use `$JOPLIN_TOKEN`; they inherit the value from the
environment. If it is missing, the API returns 401/403 — remind the user to set
the variable instead of hard-coding a token.

## Core helpers

### 1. Verify connectivity

```bash
curl -s -m 5 "$JOPLIN_API_BASE_URL/ping"
# Expect: JoplinClipperServer
```

### 2. List notebooks (folders)

```bash
curl -s -m 5 "$JOPLIN_API_BASE_URL/folders?token=$JOPLIN_TOKEN&limit=100"
```

Each item has `id`, `title`, and `parent_id`. Use this to resolve a
destination folder before creating a note.

### 3. Find a notebook by title

```bash
curl -s -m 5 "$JOPLIN_API_BASE_URL/folders?token=$JOPLIN_TOKEN&limit=100" \
  | python -c "import sys,json;d=json.load(sys.stdin);print([x['id'] for x in d['items'] if x['title']=='<TITLE>'][0])"
```

### 4. Create a note

**Important — Chinese / non-ASCII titles & body:** on Windows the shell and
`curl` pass non-ASCII text through the local code page (often GBK), which
Joplin reads as UTF-8 and corrupts. **Always create notes via Python with an
explicit UTF-8 JSON body.** This is the reliable path:

Set `NOTE_TITLE`, `NOTE_BODY`, and optionally `NOTE_PARENT_ID` (folder id) as
environment variables, then run the helper — the values go in as env vars, so
quotes/backticks/newlines in the note content can **not** break out of the shell:

```bash
NOTE_TITLE="$NOTE_TITLE" NOTE_BODY="$NOTE_BODY" NOTE_PARENT_ID="$NOTE_PARENT_ID" \
JOPLIN_TOKEN="$JOPLIN_TOKEN" python -c '
import os, urllib.request, urllib.parse, json
tok   = os.environ["JOPLIN_TOKEN"]
base  = os.environ.get("JOPLIN_API_BASE_URL", "http://127.0.0.1:41184")
url   = base + "/notes?" + urllib.parse.urlencode({"token": tok})
data  = {"title": os.environ["NOTE_TITLE"], "body": os.environ["NOTE_BODY"]}
if os.environ.get("NOTE_PARENT_ID"):
    data["parent_id"] = os.environ["NOTE_PARENT_ID"]
req   = urllib.request.Request(url, data=json.dumps(data).encode("utf-8"), method="POST")
req.add_header("Content-Type", "application/json")
with urllib.request.urlopen(req, timeout=8) as r:
    print(r.read().decode("utf-8"))
'
```

- `body` supports **Markdown**.
- Omit `parent_id` (or set `null`) to place the note in the default notebook.
- If a folder id is unknown, first resolve it via the folder list helper.

### 5. Search / list notes

```bash
curl -s -m 5 "$JOPLIN_API_BASE_URL/search?token=$JOPLIN_TOKEN&query=<QUERY>&limit=50"
```

### Reading a note back

`GET /notes/<id>` returns metadata but usually **not** `body` by default
(`body` is `null`). To read the full body, request the field explicitly:

```bash
python -c '...' # add &fields=body,title,parent_id to the GET
```

If `body` is still `null`, the note was created via a client that did not
store a body, or the field needs `fields=body`.

## Standard add-note workflow

When the user says "add a note about X" (top-level or part of a task):

1. **Ping** the server to confirm it is reachable. If it fails, tell the user
   to start Joplin / enable Web Clipper and do **not** guess.
2. If the user named a target notebook, **resolve its folder id** with the
   folder-list helper. If no notebook is named, keep `parent_id` unset.
3. **Create the note** with `POST /notes` (title + Markdown body).
4. **Confirm** the created note: print the returned `id`, `title`, and the
   folder it landed in so the user can verify.

## Error handling

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `ping` returns error / connection refused | Joplin not running, or Web Clipper off | Start Joplin, enable Web Clipper |
| HTTP 401 / 403 on authed calls | Wrong or missing token | Re-check token in Settings → Web Clipper |
| 404 Not Found on `/api/*` | Old Clipper route; use `/folders` and `/notes` (no `/api` prefix) | Use the paths in this skill |
| `parent_id` folder not found | Folder id stale or wrong | Re-resolve via folder list |

## Notes

- The Joplin MCP server is **not** a separate npm package; if the user's Joplin
  build exposes `joplin mcp`, prefer that over the raw REST calls above. This
  skill uses the portable REST API so it works with the running ClipperServer.
- Never store the real token in a shared repo; keep it in a local env var or
  the user's user-level config.
