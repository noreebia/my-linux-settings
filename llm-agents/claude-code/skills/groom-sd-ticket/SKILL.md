---
name: groom-sd-ticket
description: >
  Grooms an ad-hoc Wrike SD:기술지원요청서 support task — pulls context from its source (parent task,
  related tasks, or a Slack thread), then sets an accurate title, the 고객사/제품/날짜 fields, an
  assignee, a resolution body, and a completion comment that centres the invoker's own contribution
  while still crediting the other actors.
argument-hint: "[--task=<url>] [--parent=<url>] [--context=<url>] [--no-comment]"
---

# Groom SD Ticket

The invoker handles software support requests and, after finishing a piece of work, retro-creates a
thin child task under the **SD:기술지원요청서** register so a manager has a clean, visible record of it.
These children start as near-empty stubs — title copied from the parent, no fields. This skill turns
one into a ticket that reads as if it were filed and worked organically.

**Resolve the invoker's identity once at the start** with `wrike_get_my_contact_id` (referred to below
as `<me>`). Don't hardcode an id — it's account-specific and would break this skill for anyone else or
after a token change. Their *role* is likewise not hardcoded: infer it from the source thread (see
step 2). `<me>` is what lets the skill centre the right person no matter who runs it.

The guiding constraint: **the work is real, only the ticket is late.** Groom truthfully. Don't invent
work, don't inflate the invoker's role, and don't mark an unfinished task as done. A manager skimming
these should come away with an accurate picture of who did what — not one where the invoker appears to
have done everything.

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

## 2. Map who did what — then centre the invoker

This is the part that's easy to get wrong and matters most. A support thread is a cast of people: the
requester relays the issue, different teams (back-end, front-end, a conversion/module team, an external
partner) handle their own layers, and the customer does the rollout. The ticket should foreground the
**invoker's** contribution — it's their record — while still attributing the rest accurately, so it
reads as a true account rather than the invoker claiming everyone's work.

Two things to infer from the source, not assume:

- **Which actor is the invoker.** Match `<me>` against the comment authors (`author.id` in
  `wrike_get_task_comments`, or the display name in Slack). Their own messages are the ground truth for
  what they personally did — the fix they describe, the version they say they shipped, the analysis
  they walked through.
- **What everyone else did.** The other participants' messages reveal their roles and contributions —
  a module-team member describing their binary fix, a front-end engineer mentioning a client build, a
  partner reporting the customer rollout.

Then write the credit so the division of labour is honest:

- Attribute to the invoker **only what their own messages show they did**, and describe the body from
  that vantage point (e.g. `[역할]` reflects their actual part — backend, analysis, packaging,
  advisory, whatever the thread shows).
- Name the other actors and their contributions explicitly — a `[비고]` line, or inline ("…module-side
  fix by the 스마트오피스팀"). The test: a reader should be able to tell the invoker's work from the
  collaborators' at a glance.
- If the invoker's part was analysis or advisory only, say exactly that. An honest "1차 분석" or
  "사양 검토" reads better to a manager than a vague implication of a completed fix.

## 3. Set the fields and body (Wrike MCP)

Use `wrike_update_task`. The custom-field IDs and their value encodings are not guessable — get them
right:

| Field | id | type | how to pass it |
|---|---|---|---|
| 고객사 | `IEAAOKQMJUAMOM6X` | Text | plain string — `"삼성증권"` |
| 제품 | `IEAAOKQMJUAHWAAT` | **Multiple** | a JSON-array **string** — `"[\"StreamDocs\",\"StreamDocs Vu!\"]"` |
| 작업 완료일 | `IEAAOKQMJUAMOH6K` | Date | `"2026-04-13"` |

Beyond these, make sure the stub has the basics a real ticket carries — don't leave a groomed task
looking half-filled:

- **assignee** — if unset, assign the invoker with `addResponsibles: ["<me>"]` (the id resolved up
  front). It's their work and their record, so they should own it.
- **the standard request fields** — these stubs descend from a 기술지원요청서 template that also has
  요청부서(팀) (`IEAAOKQMJUAHWAQY`, DropDown) and sometimes 납품 버전(SD) (`IEAAOKQMJUAA2SMX`). If the
  parent populated them and the child is blank, copy them across. Run `wrike_get_custom_fields` to
  confirm an id or its allowed options before setting a field you're unsure of — don't guess an
  encoding. Skip fields that genuinely don't apply rather than inventing values.

- **제품** — copy the source task's exact value. Product names must match the field's options verbatim,
  including the `!` in `StreamDocs Vu!`. If a parent is mis-tagged (one KC parent carried `LiJaMong`
  when the work was clearly StreamDocs Vu!), use what the work actually was, not the bad tag — and flag
  it. `wrike_get_custom_fields --title 제품` lists the valid options.
- **고객사** — often only stated in the Slack thread or a comment, not a field. Pull it from there.
- **dates** — set Planned with `start` = when work began and `due` = the completion date. For start,
  prefer a concrete signal: the request 접수 date, the first 회의, or — when those are murky — the
  invoker's *own* first comment in the thread (filter to author `<me>`). Use a Milestone only if no
  start is recoverable.
- **status** — `Completed` for finished work; leave `Active` or `Cancelled` if that's the truth.
- **SD: Kanban board (the task's "location")** — the team tracks work by month, so each task should sit
  in the monthly board that matches *when the work happened*. Pick the month from 작업 완료일 for finished
  work (fall back to the due/completion month); for in-progress work use the Planned `start` month, else
  the created month. File it with `addParents: ["<board id>"]` — additive, so it won't disturb the SS
  register parent or the subtask link. Find the id with
  `wrike_search_folder_project(title="Kanban", project=true)` and take the `SD: Kanban-{Month}` entry —
  ignore the `CS:` / `SO:` / `kanban-HK-*` / `kanban-VI-*` boards (other teams and partners). Boards are
  per-month and new ones appear each month, so look the id up rather than hardcoding. If the task already
  sits in a *different* month's board with nothing supporting that month, move it (`removeParents` the
  wrong one); flag genuine multi-month spans for the user instead of force-moving.
- **title** — rewrite to say what was done, with the shipped version, e.g.
  `SDVu so4sdv 비정상 종료코드 예외 세분화 (5.15.6.13)`. **Don't prefix the 고객사 name** — the manager
  reads the customer from the 고객사 field, so repeating it in the title is just clutter. (A system name
  like `홈택스` that *is* the work context is fine; the customer org name — `삼성증권`, `국세청` — is not.)
  Caution: a literal `+` in a title gets form-decoded by the API into a stray double-space — write `및`
  or `and` instead.
- **description** — a Korean HTML write-up (`<b>`, `<br/>`, `<ul><li>`) with sections roughly:
  `[고객사]`, `[제품]`, `[역할]` (the invoker's actual part from step 2), `[요청]`, `[처리 내용]`,
  `[반영 버전]`, `[완료일]`, and `[비고]` for collaborators. If the task already holds real content
  (e.g. an API spec the invoker wrote), **prepend** a summary block and keep the original below a
  divider — don't clobber it.

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
fields. Matching `<me>` against the parent's comment authors shows the invoker is the back-end engineer
on the thread: their messages describe adding error code `BSD110010` for abnormal so4sdv exit codes,
shipped in StreamDocs 5.15.6.13 on 2026-03-25. A separate author from the 스마트오피스팀 describes the
module-side fix to so4sdv itself.

**Output:**
- title → `SDVu SmartOffice(so4sdv) 비정상 종료코드 예외 세분화 (BSD110010, 5.15.6.13)` (no 고객사 prefix — it lives in the 고객사 field)
- 고객사 → `강원특별자치도교육청` · 제품 → `["StreamDocs","StreamDocs Vu!"]` · 작업 완료일 → `2026-03-25`
- assignee → the invoker (`<me>`) · dates → Planned, start `2026-01-26` (request 접수) → due `2026-03-25` · status → Completed
- location → filed into the `SD: Kanban-March` board (work completed 2026-03-25) via `addParents`
- body → `[역할] 백엔드`, `[처리 내용]` describing the new exit-code handling, with a `[비고]` crediting
  the 스마트오피스팀's module-side fix to them — not folded into the invoker's work.
- comment → `[처리 결과]` + bullets on cause, the BSD110010 addition, and the shipped version.

---

## Reference

- Folders: **SD:기술지원요청서** = `MQAAAAEEuLo3` (where these children live); the original
  **SS:기술지원요청서** register = `IEAAOKQMI5PTT7DR`. `addParents` files a task into a folder, which
  also lifts it off the account root.
- Linking a child *as a subtask* of a parent isn't exposed by `wrike_update_task` (no `superTaskIds`
  param). But `wrike_create_task` **does** accept `parentTasks` — so when you create a fresh stub you can
  link it as a subtask of the source request at creation time (and `folderId` files it into the SD
  register in the same call). The limitation only bites when grooming a *pre-existing* stub that already
  lacks the relationship: there, note it for the user to set in the web UI.
- For file attachments (download/upload), which the MCP also can't do, see the `wrike-attachments`
  skill in the same scripts directory.
