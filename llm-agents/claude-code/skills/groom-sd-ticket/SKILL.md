---
name: groom-sd-ticket
description: >
  Grooms a Wrike SD:기술지원요청서 support task — pulls context from its source (parent task,
  related tasks, or a Slack thread), then fills in an accurate title, customer/product/date fields,
  a resolution body, and a completion comment crediting only the user's backend work.
argument-hint: "[--task=<url>] [--parent=<url>] [--context=<url>] [--no-comment]"
---

# Groom SD Ticket

The user (김수영B 책임, contact id `KUAW2WF6`) is a **backend engineer** on the 솔루션개발 team. They
retro-create ad-hoc child tasks under the **SD:기술지원요청서** register (mirroring the original
**SS:기술지원요청서** request tickets) so a manager has visibility into work that's already done. These
child tasks start nearly empty — same title as the parent, no fields. This skill fleshes one out so it
reads as a real, organically-handled ticket.

The work is real; only the ticket is late. Groom honestly — never invent work, never mark an
in-progress or cancelled task as completed.

---

## Arguments

- **`--task=<url>`** *(optional)*: The child task to groom (Wrike permalink or numeric id). The skill
  reads its current state and finds its own context source.
- **`--parent=<url>`** *(optional)*: A parent/source task. The skill grooms the child task(s) created
  under it. If both `--task` and `--parent` are given, `--parent` is treated as the explicit context source.
- **`--context=<url>`** *(optional)*: Force a specific context source — a Slack permalink, another Wrike
  task, or a parent task — when the child's body doesn't make it obvious.
- **`--no-comment`** *(optional)*: Update fields/body only; don't post a completion comment.
- At least one of `--task` or `--parent` is required.

## Examples

    /groom-sd-ticket --task=https://www.wrike.com/open.htm?id=4467337026
    /groom-sd-ticket --parent=https://www.wrike.com/open.htm?id=4344579136
    /groom-sd-ticket --task=https://www.wrike.com/open.htm?id=4467440625 --context=https://epapyrus.slack.com/archives/C06UYKENQ5D/p1775037066332159
    /groom-sd-ticket --task=https://www.wrike.com/open.htm?id=4467337349 --no-comment

---

## Process

### 1. Find the context

The child task is a stub. The real story lives elsewhere — figure out where from the child's
`description`/`superTaskIds` and the args:

- **Parent task** (most common): the child is a subtask. Read the parent's description **and its full
  comment thread** (`wrike_get_task_comments`). The comments are where the actual fix, version, and
  dates live.
- **Related tasks**: the body links other Wrike tasks (`open.htm?id=...`). Read those.
- **Slack thread**: the body links a Slack permalink (channel `C06UYKENQ5D` = 솔루션개발). Convert the
  `pXXXXXXXXXXXXXXXX` timestamp to `XXXXXXXXXX.XXXXXX` and read it with the Slack MCP
  (`slack_read_thread`). The customer name and version are usually stated in the first message.

Read enough to know: what was requested, **what was actually done**, which version it shipped in, and
when work started/finished.

### 2. Attribute correctly — backend only

Identify the actors in the comments/thread. Credit the user (`KUAW2WF6`) with **only their backend
work** — analysis, DB/DDL, API changes, server-side fixes, packaging. Do **not** phrase FE patches,
pdfio/module work, customer-side rollout, or another team's diagnosis as theirs. Name collaborators
explicitly (e.g. "pdfio 인터페이스 추가는 김보근 선임") so the division of labor is honest. If the
user's role was advisory/analysis only, say so.

### 3. Update the task (Wrike MCP)

Set via `wrike_update_task`:

- **Title** — rewrite to describe what was actually done, including the shipped version
  (e.g. `... (5.15.6.13)`). Drop the copied-from-parent title.
- **고객사** (customer), field id `IEAAOKQMJUAMOM6X`, type Text → plain string, e.g. `"삼성증권"`.
- **제품** (product), field id `IEAAOKQMJUAHWAAT`, type **Multiple** → a JSON-array **string**, e.g.
  `"[\"StreamDocs\",\"StreamDocs Vu!\"]"`. Copy the parent/source task's exact value. Product names must
  match the field's options verbatim, incl. the `!` in `StreamDocs Vu!`. (Run `wrike_get_custom_fields
  --title 제품` if you need the option list.)
- **작업 완료일** (completion date), field id `IEAAOKQMJUAMOH6K`, type Date → `yyyy-MM-dd`.
- **dates** — make it Planned with `start` = when work began (request 접수 / first 회의 / your first
  comment for ambiguous cases) and `due` = completion date. Use a Milestone only if start is unknown.
- **status** — `Completed` for finished work; leave `Active`/`Cancelled` honest if that's the true state.
- **description** — a structured resolution write-up in Korean HTML (`<b>`, `<br/>`, `<ul><li>`):
  `[고객사]`, `[제품]`, `[역할] 백엔드`, `[요청]`, `[처리 내용 — 백엔드]`, `[반영 버전]`, `[완료일]`.
  Keep it to what the user did; note collaborators in a `[비고]`. For the rare task that already holds
  real content (e.g. an API spec), **prepend** a summary block and keep the original below a divider —
  don't overwrite.

### 4. Post a completion comment (unless `--no-comment`)

The Wrike MCP **cannot post comments** — use the REST helper:

    python3 ~/.claude/skills/wrike-attachments/scripts/wrike_comment.py add <taskId> <htmlfile>

(also `get <taskId>` to verify, `whoami` to auth-check; auth is read from `~/.claude.json`, no setup).
Write a concise, readable Korean note — lead with a `[처리 결과]` line, then bulleted
원인/조치/반영버전. Use `<b>` and `•` for scannability.

Caveats, all confirmed on this account:

- Comments are **stamped with the current time and cannot be backdated**. That's fine — the manager
  knows these are for visibility; the body/dates carry the real timeline.
- The API **cannot edit** a comment (PUT → 403) but **can delete** (`delete <commentId>`). To fix a
  posted comment: delete it and `add` a corrected one. So get the text right the first time.

### 5. Verify and report

Confirm the field values came back populated, and give the user the permalink(s). Flag any judgment
calls — a customer name inferred from Slack, a parent tagged with a placeholder product (e.g. the KC
tasks whose parent was mis-tagged `LiJaMong`), or a status you deliberately left non-Completed.

---

## Reference — account facts

| Custom field | id | type | value format |
|---|---|---|---|
| 고객사 | `IEAAOKQMJUAMOM6X` | Text | `"한양대학교"` |
| 제품 | `IEAAOKQMJUAHWAAT` | Multiple | `"[\"StreamDocs Vu!\"]"` |
| 작업 완료일 | `IEAAOKQMJUAMOH6K` | Date | `"2026-04-13"` |

- **SD:기술지원요청서** folder = `MQAAAAEEuLo3` (where these children live). The **SS:기술지원요청서**
  register = `IEAAOKQMI5PTT7DR`. Filing a task into a real folder lifts it off the account root
  (`addParents`).
- Slack 솔루션개발 channel = `C06UYKENQ5D`.
- See also the `wrike-attachments` skill for file attachments (download/upload), which the MCP also
  can't do.
