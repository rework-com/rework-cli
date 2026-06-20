---
name: rework-cowork
description: |
  Drive Rework Cowork (v3 project management) from the terminal with the `rework` CLI —
  workspaces, projects, boards, tasks, flow pipelines, planning (milestones/WBS/roadmap/backlog),
  resources/cost, issues, check-ins, docs & files, search, and dashboard. Plus `rework feedback`
  to report bugs/requests. Use for any "rework"/"cowork" project-management request from a terminal,
  script, or CI — deterministic, no LLM tokens needed to call it.
triggers:
  - rework
  - rework cowork
  - /rework
  # resource-oriented
  - rework project
  - rework board
  - rework task
  - cowork project / board / task / milestone / issue
  # actions
  - create a task in rework / cowork
  - set up a rework project
  - move a card / advance a flow item in rework
  - log a risk / post a check-in in cowork
  # discovery
  - find / list / search rework projects, boards, tasks
  # personal
  - my rework tasks
  # urls
  - cowork.rework.com/...
invocable: true
argument-hint: "cowork <group> <action> [args] [--data '<json>']"
---

# rework — CLI for Rework Cowork (v3 project management)

`rework <command> [args] [flags]`. Covers the full Cowork surface (workspaces → projects → boards →
tasks, plus planning, resources, governance, knowledge) over the same service the Rework MCP uses.
This page tells an agent how to use it CORRECTLY — the silent-failure rules below are load-bearing.

## Agent invariants (read first)

1. **Parse with `--json`, present like a colleague.** Add `--json` to any command to get raw JSON for
   reasoning. When you report back to a human, talk in plain language ("I added the task to the Design
   board") — never echo raw ids, JSON, flags, or the word "CLI"/"API".
2. **Every id is a SUID string** (e.g. `aEyJk3Xl-…`), not a number. Capture ids from list/overview
   output and pass them straight through. (Exception: `resource` items use INTEGER user ids — see Resources.)
3. **Dates are unix SECONDS.** Compute relative dates ("next month") from today's date in your context,
   then convert to seconds. A 13-digit millisecond value errors upstream. Never hard-code a guessed epoch.
4. **Reading is via composites, not get-by-id.** A whole project = `project overview <id>`; a whole board
   (+ its columns + items) = `board page <id>`; a task's subtasks = `task list --parent <id>`. There is no
   "get one row" command — use these.
5. **Writes return the created/updated object including its new id.** Capture it (`--json`) and chain the
   next call; you don't need a read-back to discover the id.
6. **No name→user lookup.** Assignees/owners need a SUID. Get it from `project overview <id>` (owners/
   followers) or from existing rows; assign to yourself via `rework me`. If you can't get the id, say so —
   never invent one.
7. **Nothing is deleted.** Cowork deletes are intentionally unavailable. Retire a task with `task status
   <id> -10` (closed); retire a project with `project update <id> --data '{"status":-2}'` (archived).
8. **A 403 means the signed-in user lacks rights** on that project/board (owner/manager/assignee gated) —
   say so plainly; don't retry.

## Setup / auth

```bash
rework auth login                 # prompts; or --email E --password P [--tfa T]; or env REWORK_EMAIL/PASSWORD
rework auth status                # who's signed in
rework auth logout
rework me                         # your user (id, name, email) — also the cheapest connection check
```
Authentication is OAuth 2.0 against your Rework account. After login, every command is authenticated.

## Output modes

| Goal | How |
|---|---|
| Human-readable list/summary | default (no flag) |
| Raw JSON to parse/reason over | append `--json` |
| Point at a non-default server | `--server <url>` (advanced; default = the hosted connector) |

Lists print `<id>  <name>  (status N)`; writes print `v <action> (id …)`. Reads of composites
(`overview`, `page`, `dashboard`, `search`) print JSON.

## Object model (the hierarchy)

```
WORKSPACE (stage-pipelines projects)
   └── PROJECT (the root scope)
         ├── BOARD  (model = task | flow | cost | ridac | doc | file)
         │     └── TASK (+ subtasks)
         └── project-scoped: MILESTONE · WBS · OUTCOME · ROADMAP · BACKLOG  (rework cowork plan)
                             ISSUE · CHECK-IN (rework cowork issue/checkin)
                             PLAN-LINE + RESOURCE (rework cowork resource)
                             DOC · FILE (rework cowork doc/file)
```

## Quick reference

| Task | Command |
|---|---|
| List projects | `rework cowork project list` |
| Whole project (boards, stages, stats) | `rework cowork project overview <projectId>` |
| Whole board (columns + items) | `rework cowork board page <boardId>` |
| Tasks on a board | `rework cowork task list <boardId>` |
| My open tasks | `rework cowork task mine` |
| New project | `rework cowork project create "Name" [--workspace <wsId> --stage <stageId>]` |
| New board | `rework cowork board create <projectId> <model> "Name"` |
| New task | `rework cowork task create <boardId> "Title" [--assignee <suid>]` |
| Subtask | `rework cowork task subtask <parentTaskId> "Title"` |
| Mark done | `rework cowork task status <taskId> 1` |
| Mark in-review | `rework cowork task update <taskId> --data '{"status":0,"review":1}'` |
| Move task to a column | `rework cowork task move <taskId> --stage <stageId>` |
| Add milestone | `rework cowork plan create milestone <projectId> "M1" --data '{"target_date":1790000000}'` |
| Log a risk/issue | `rework cowork issue create <projectId> "Risk" --data '{"severity":2,"description":"<p>…</p>"}'` |
| Weekly check-in | `rework cowork checkin create <projectId> --data '{"label":"at_risk","progress":60,"content":"<p>…</p>"}'` |
| Search | `rework cowork search "query" [--type projects\|boards\|tasks\|documents\|milestones]` |
| Report a bug/idea to Rework | `rework feedback "…" [--severity bug\|feature_request\|confusion\|info]` |

## Writing fields — the `--data` escape hatch

Common fields are named flags; the long tail goes in `--data '<json>'` (a plain JSON object, merged on
top — **raw JSON, no base64, no field_<id> keying**). Arrays REPLACE the stored value (re-send the full
set to append).

```bash
rework cowork task create <boardId> "Ship v2" \
  --assignee aEyU… \
  --data '{"deadline":1790000000,"tags":["release"],"owners":["aEyU…"],"checklists":[{"text":"smoke test"}]}'
```
Field catalog by entity: **task** content, deadline, start_date, tags[], owners[], followers[],
linked_ids[] (milestone/WBS suids), checklists[], form[] (custom-field values), review · **project**
content, privacy, status, tags[], owners[], followers[], color, icon, started_at, ended_at, outcomes[] ·
**issue** description, severity(0-3), status(0 open..10 resolved), assignee_id, due_date · **checkin**
label(on_track|at_risk|off_track), progress(0-100), content · **milestone/plan** target_date, deliverables[],
status · **resource** name, quantity, unit, amount, currency, status, category_id.

## Boards — the TYPE × MODEL matrix (the key skill: don't default to one Tasks board)

A project holds MANY boards; the `model` (set at create) decides its shape and the commands that drive it.
Most real projects want **3–4 boards**, not one. Create with `board create <projectId> <model> "Name"`.

| Model | Board does | Items driven by |
|---|---|---|
| `task` | execution kanban (tasklist + stage axes) | `rework cowork task *` |
| `flow` | gated delivery pipeline (ordered steps) | `rework cowork flow *` |
| `cost` | planned budget & actual costs | `rework cowork resource *` |
| `ridac` | governance (Risks, Issues, Decisions, Actions, Changes) | `rework cowork task *` on the ridac board |
| `doc` | Notion-like rich pages (specs, runbooks) | `rework cowork doc *` |
| `file` | file/asset registry | `rework cowork file *` |

Composition patterns (pick what fits): **Construction** cost + task + ridac + doc + file · **Software**
task + flow + ridac + doc · **Marketing** task + cost + file · **Services** flow + cost + ridac.

## Tasks — status, review, and the two axes

- `status` int: `0` active, `1` done (auto-stamps completion), `-1` failed, `-10` closed.
  `rework cowork task status <id> <int>` is the setter.
- **"In review" is NOT a status** — it's `status 0 + review:1`: `task update <id> --data '{"status":0,"review":1}'`.
- A task sits on a **STAGE** (the kanban COLUMN axis) AND a **TASKLIST** (the list/row axis). Move with
  `task move <id> --stage <stageId>` (and/or `--tasklist <id>`). A new `task` board auto-provisions a
  default tasklist+stage, so a task created with just board+name lands placed.
- A SUBTASK inherits the parent's board — `task subtask <parentId> "Title"`.

## Flow boards

Steps are the gates; items flow through them. **A new flow board starts with ZERO steps** — the steps you
create are the only ones. Step config nests under `config`.

```bash
rework cowork flow step-add <boardId> "Code review" --data '{"config":{"kind":"active","assignment":"keep"}}'
rework cowork flow item-add <boardId> "Release 2.1"          # seeds on the FIRST step
rework cowork flow next <itemId> --note "approved"           # advance; also: back/move/fail/reassign/star
```
`kind`: `active` = normal gate, `done` = items here count complete, `failed` = treated as failed. Lifecycle
notes (`--note`) are plain text.

## Common workflows

```bash
# Set up a project for a software team (3 boards + a milestone + an assigned task)
P=$(rework cowork project create "Mobile App" --json | ... )            # capture project id
rework cowork board create $P task "Sprint"
rework cowork board create $P flow "Release pipeline"
rework cowork board create $P ridac "Risks & decisions"
rework cowork plan create milestone $P "Beta" --data '{"target_date":1793000000}'
# find a teammate's suid, then assign:
rework cowork project overview $P --json    # read owners/followers for the suid
rework cowork task create <sprintBoardId> "Design login" --assignee <suid>

# Move a task across the board, then close it
rework cowork task move <taskId> --stage <inReviewStageId>
rework cowork task status <taskId> 1
```

## Resource reference (commands per group)

```
workspace   list | get <id> | create "Name" | update <id> | stage-add <wsId> "Stage" | stage-update <id>
project     list [wsId] | overview <id> | create "Name" [--workspace W --stage S] | update <id> [--workspace W --stage S] | pin <id> [--off]
board       list <projectId> | page <id> | activity <id> | create <projectId> <model> "Name" | update <id> | pin <id> [--off]
              tasklist-add <boardId> "Col" | tasklist-update <id> | tasklist-reorder <id...>
              stage-add <boardId> "Col" | stage-update <id> | stage-reorder <id...>
task        list <boardId> [--project P --parent T --assignee U --status N] | mine [open|done|overdue]
              create <boardId> "Title" [--assignee U] | subtask <parentId> "Title" | update <id>
              status <id> <int> | move <id> [--tasklist T --stage S --order N]
flow        items <boardId> [--step S --status N] | step-add/-update/-reorder | item-add/-update
              next | back | move | fail | reassign | star  <itemId>  [--step --user --note --reason --off]
plan        list <scope> <projectId> | create <scope> <projectId> "Name" | update <scope> <id>
              wbs-linked <projectId> | outcome-reorder <projectId> <id...>
              backlog-move <id> [--before/--after] | backlog-stage <id> <status> | backlog-promote <id> <boardId>
              (scope = milestone | wbs | outcome | roadmap | backlog)
resource    planlines <projectId> [--metatype material|workload] | planline-add <projectId> "Name" | planline-update <id>
              items <boardId> | by-task <taskId> | item-add "Name" --data '{"board_id":…}' | item-update <id>
issue       list <projectId> | create <projectId> "Title" | update <id>
checkin     list <projectId> | create <projectId> | update <id>
doc         list [boardId] [--mine] | create <boardId> "Title" --data '{"content":"<p>…</p>"}' | update <id>
file        list [boardId] | create <boardId> "Name" --data '{"url":"…"}' | update <id>
search      <query> [--type … --per N]   ·   dashboard
item-type   list <metatype> [--all --page N] | create <metatype> "Name" | update <id> | bulk <id...> [--color --icon]
```

## Content formatting (silent-failure trap)

- **PROJECT content is PLAIN TEXT** — pass plain text, no HTML (the About panel shows tags literally).
- **TASK / DOC / CHECK-IN / ISSUE bodies are rich HTML** — use `<p>`, `<b>`, etc.

## Feedback, version, updates

```bash
rework feedback "Need a board-archive command" --severity feature_request
rework -v            # installed version
rework update        # check whether a newer version is available, prints the install one-liner
```

## Errors

- `not signed in / 401` → `rework auth login`.
- `403` → your account lacks the right on that project/board (ACL) — don't retry; tell the user.
- `--data must be valid JSON` → pass a JSON object, e.g. `--data '{"deadline":1790000000}'`.
- A write that "succeeds" but the value didn't take → check the field name (use `--data` keys above) and
  that dates are unix seconds, project content is plain text, and arrays were sent in full.

## Learn more

- Repo + binaries: https://github.com/rework-com/rework-cli
- Same surface for AI agents: the Rework Cowork MCP (`/v3/cowork/mcp`).
