---
name: groom-sd-ticket
description: >
  Grooms an ad-hoc Wrike SD:기술지원요청서 support task — pulls context from its source (parent task,
  related tasks, or a Slack thread), then sets an accurate title, the 고객사/제품/날짜 fields, a
  resolution body, and a completion comment crediting only the user's backend work.
argument-hint: "[--task=<url>] [--parent=<url>] [--context=<url>] [--no-comment]"
---

# Groom SD Ticket

The user (김수영B 책임, contact `KUAW2WF6`) is a **backend engineer** on the 솔루션개발 team. After
finishing a piece of support work, they retro-create a thin child task under the **SD:기술지원요청서**
register so a manager has a clean, visible record of it. These children start as near-empty stubs —
title copied from the parent, no fields. This skill turns one into a ticket that reads as if it were
filed and worked organically.

The guiding constraint: **the work is real, only the ticket is late.** Groom truthfully. Don't invent
work, don't inflate the user's role, and don't mark an unfinished task as done. A manager skimming
these should come away with an accurate picture, not a flattering one.

---

## Arguments

- **`--task=<url>[,<url>…]`** *(optional)*: One or more child tasks to groom (Wrike permalink or
  numeric id, comma-separated for a batch). Each is groomed independently against its own source.
- **`--parent=<url>[,<url>…]`** *(optional)*: One or more source/parent tasks. Used as the explicit
  context source, and — if no `--task` is given — to locate the child(ren) created under each.
- **`--context=<url>`** *(optional)*: Force a specific source — a Slack permalink or another Wrike task
  — when the stub doesn't make the source obvious. Applies to a single `--task`; for a batch where each
  task needs a different source, run them separately or let the skill infer each source from its stub.
- **`--no-comment`** *(optional)*: Update fields/body only; skip the completion comment. Applies to the
  whole batch.
- At least one of `--task` or `--parent` is required.

## Examples

    /groom-sd-ticket --task=https://www.wrike.com/open.htm?id=4467337026
    /groom-sd-ticket --task=https://www.wrike.com/open.htm?id=4467337026,https://www.wrike.com/open.htm?id=4467337225,4467337349
    /groom-sd-ticket --parent=https://www.wrike.com/open.htm?id=4344579136
    /groom-sd-ticket --task=https://www.wrike.com/open.htm?id=4467440625 --context=https://epapyrus.slack.com/archives/C06UYKENQ5D/p1775037066332159
    /groom-sd-ticket --task=https://www.wrike.com/open.htm?id=4467337349 --no-comment

---

## Batches

When `--task`/`--parent` carries several comma-separated links, groom each one independently — they
rarely share a customer, product, or version. It's efficient to fetch all the stubs (and their parents)
up front in one or two `wrike_get_tasks` calls to map the work, then go through them one at a time
applying steps 1–4. A parent's full comment thread can be large, so reading parents one at a time (or
via a subagent that returns just the distilled facts) keeps context manageable. End with a single
combined report (step 5) covering every task and its judgment calls.

## 1. Find the real context

The child is a stub; the story lives in its source. Where to look, in rough order of likelihood:

- **Parent task** — the child is usually a subtask (`superTaskIds`). Read the parent's description **and
  its entire comment thread** (`wrike_get_task_comments`). The comments — not the description — are
  where the actual fix, the shipped version, and the real dates live.
- **Related Wrike tasks** — the stub's body links other tasks (`open.htm?id=…`). Read them.
- **Slack thread** — the body links a Slack permalink (channel `C06UYKENQ5D` = 솔루션개발). Convert the
  permalink's `pXXXXXXXXXXXXXXXX` into a `ts` of `XXXXXXXXXX.XXXXXX` (split after the 10th digit) and
  read it with `slack_read_thread`. The customer and version are typically stated in the opening
  message.

Read until you can answer four things: what was requested, **what was actually done**, which version it
shipped in, and when work started and finished.

## 2. Attribute honestly — backend only

This is the part that's easy to get wrong and matters most to the user. Support threads involve many
people: PS부 relays the request, FE/pdfio/스마트오피스 teams handle their layers, the customer does the
rollout. Read the thread and separate the user's contribution from everyone else's.

Credit `KUAW2WF6` with **only their backend work** — analysis, DB/DDL, server-side API and logic
changes, packaging. Do not phrase an FE patch, a pdfio interface, another team's diagnosis, or the
customer's production rollout as theirs. Name collaborators explicitly in a `[비고]` line so the
division of labour is visible. If the user's role was advisory or analysis only, say exactly that —
an honest "1차 분석" reads better to a manager than a vague claim of completion.

## 3. Set the fields and body (Wrike MCP)

Use `wrike_update_task`. The custom-field IDs and their value encodings are not guessable — get them
right:

| Field | id | type | how to pass it |
|---|---|---|---|
| 고객사 | `IEAAOKQMJUAMOM6X` | Text | plain string — `"삼성증권"` |
| 제품 | `IEAAOKQMJUAHWAAT` | **Multiple** | a JSON-array **string** — `"[\"StreamDocs\",\"StreamDocs Vu!\"]"` |
| 작업 완료일 | `IEAAOKQMJUAMOH6K` | Date | `"2026-04-13"` |

- **제품** — copy the source task's exact value. Product names must match the field's options verbatim,
  including the `!` in `StreamDocs Vu!`. If a parent is mis-tagged (one KC parent carried `LiJaMong`
  when the work was clearly StreamDocs Vu!), use what the work actually was, not the bad tag — and flag
  it. `wrike_get_custom_fields --title 제품` lists the valid options.
- **고객사** — often only stated in the Slack thread or a comment, not a field. Pull it from there.
- **dates** — set Planned with `start` = when work began and `due` = the completion date. For start,
  prefer a concrete signal: the request 접수 date, the first 회의, or — when those are murky — the
  user's *own* first comment in the thread (filter to author `KUAW2WF6`). Use a Milestone only if no
  start is recoverable.
- **status** — `Completed` for finished work; leave `Active` or `Cancelled` if that's the truth.
- **title** — rewrite to say what was done, with the shipped version, e.g.
  `강원특별자치도교육청 - SDVu so4sdv 비정상 종료코드 예외 세분화 (5.15.6.13)`. Caution: a literal `+`
  in a title gets form-decoded by the API into a stray double-space — write `및` or `and` instead.
- **description** — a Korean HTML write-up (`<b>`, `<br/>`, `<ul><li>`) with sections roughly:
  `[고객사]`, `[제품]`, `[역할] 백엔드`, `[요청]`, `[처리 내용 — 백엔드]`, `[반영 버전]`, `[완료일]`,
  and `[비고]` for collaborators. If the task already holds real content (e.g. an API spec the user
  wrote), **prepend** a summary block and keep the original below a divider — don't clobber it.

## 4. Post a completion comment (unless `--no-comment`)

The Wrike MCP **cannot post comments** — that capability isn't exposed. Use the REST helper, which
reads its token from `~/.claude.json` (no setup):

    python3 ~/.claude/skills/wrike-attachments/scripts/wrike_comment.py add <taskId> <htmlfile>
    python3 ~/.claude/skills/wrike-attachments/scripts/wrike_comment.py get <taskId>   # verify
    python3 ~/.claude/skills/wrike-attachments/scripts/wrike_comment.py whoami         # auth check

Write a short, scannable Korean note: a `[처리 결과]` (or `[분석 결과]` / `[진행 상황]` to match the
real status) lead line, then `•`-bulleted 원인/조치/반영 버전. Two confirmed quirks on this account:

- Comments are **stamped with the current time and can't be backdated.** That's acceptable here — the
  manager understands these are for visibility, and the body/dates carry the real timeline.
- The API **can't edit** a comment (PUT → 403) but **can delete** (`delete <commentId>`). To fix one:
  delete and re-`add`. So get the wording right the first time.

## 5. Verify and surface judgment calls

Re-read the task (or `wrike_comment.py get`) to confirm the fields came back populated, and hand the
user the permalink(s). Then flag anything you inferred or decided, so they can correct it: a customer
name guessed from Slack, a product you overrode off a bad parent tag, a status you left non-Completed,
or a start date based on your best guess.

---

## Worked example

A representative run — stub in, groomed ticket out.

**Input** — child stub `4467311854`, title `"SDVu SmartOffice converter 예외 처리되지 않는 현상"`, no
fields. Its parent's comment thread shows: customer 강원특별자치도교육청; the user added error code
`BSD110010` for abnormal so4sdv exit codes; shipped in StreamDocs 5.15.6.13 on 2026-03-25.

**Output:**
- title → `강원특별자치도교육청 - SDVu SmartOffice(so4sdv) 비정상 종료코드 예외 세분화 (BSD110010, 5.15.6.13)`
- 고객사 → `강원특별자치도교육청` · 제품 → `["StreamDocs","StreamDocs Vu!"]` · 작업 완료일 → `2026-03-25`
- dates → Planned, start `2026-01-26` (request 접수) → due `2026-03-25` · status → Completed
- body → `[처리 내용 — 백엔드]` describing the new exit-code handling, with a `[비고]` noting the
  스마트오피스팀's module-side fix as theirs.
- comment → `[처리 결과]` + bullets on cause, the BSD110010 addition, and the shipped version.

---

## Reference

- Folders: **SD:기술지원요청서** = `MQAAAAEEuLo3` (where these children live); the original
  **SS:기술지원요청서** register = `IEAAOKQMI5PTT7DR`. `addParents` files a task into a folder, which
  also lifts it off the account root.
- Linking a child *as a subtask* of a parent (`superTaskIds`) isn't exposed by the MCP `update_task` —
  if a stub needs that relationship and doesn't have it, note it for the user to set in the web UI.
- For file attachments (download/upload), which the MCP also can't do, see the `wrike-attachments`
  skill in the same scripts directory.
