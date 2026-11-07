# Design

## Context

See proposal.md, "Why".

- **Resume today (0.9.0, change `resume-closed-agents`):**
  - `lib/agents.luau` saves Claude sessions. At a turn's start or end (`window.luau` `agent_state` and `agent_finished` handlers), it lists `claude` processes with `cx.procs:list`, waits for a fresh sample, and pairs chats with processes by folder (`pair`). It saves only one-to-one pairs, and only for chats that have had a turn.
  - `State.agents` (`lib/store.luau:50`) maps a pane id to `{ agent, session, cwd, seen }`. `save_sessions` writes it and drops orphans; `adopt` moves a closed tab's links and sessions to the resumed tab; `prune` drops entries with their tabs.
  - `lib/view.luau:472` shows Resume on a closed tab when one of its agent rows has an entry. `lib/app.luau:503` (`resume`) types `claude --resume <id>` into a new tab and splits, then calls `adopt` and refreshes the new tab's snapshot from a 250 ms timer.
  - `lib/details.luau:108` names a closed agent row by its entry's `agent`.
- **What stays:** the Resume button's place and size, the new tab and splits, `adopt`, the 250 ms snapshot timer, orphan removal, and the snapshot refresh each capture does. Only how chats are found, what is stored and what is typed change.

### Source record

All on 2026-11-07, on the user's Mac (read-only `ps` and `lsof` of their own processes), or in the harness at `/tmp/tobj`.

| Claim | Evidence |
|---|---|
| Every omp process in the user's Tern carries its pane's id as `TERN_PANE` | `/bin/ps -wwE` of all 17 omp processes: each had a `TERN_PANE`, no two equal |
| That id is the plugin's pane id | omp process 6843 has `TERN_PANE=100000000001`; the live `kv.json` stores pane `100000000001`, kind "agent", for the linked tab "QA: Summarize the release checklist" |
| A harness shell (`tern serve`, no daemon) gets `TERN_WINDOW_PANE=<pane>` and no `TERN_PANE` | harness: `env` typed in pane 4 held `TERN_WINDOW_PANE=4`; the plugin listed pane 4 |
| An omp chat that has had a message holds its chat file open | `lsof -p`: 7 of 17 omp processes held one `~/.omp/agent/sessions/<folder>/<time>_<id>.jsonl` |
| A chat Tern restored, not written to since, holds no file but names it on its command line | the other 10 omp processes held no `.jsonl`: 9 ran `omp --restore <file>`, and 7457 (next row) ran plain `omp`; 6843, restored the same way and written to since, held its file |
| A chat that has never had a message has no file | process 7457 (plain `omp`, started 2026-11-03 10:18:27 UTC) held none, and `sessions/-demo/` has no file named for that time. A file is named after its process's start: 38515 started 08:35:41 UTC and holds `2026-11-06T08-35-41-832Z_….jsonl` |
| Subagents' files sit one level deeper, in the chat's own folder | `find ~/.omp/agent/sessions -mindepth 3 -name '*.jsonl'`: 773 files such as `<folder>/<chat>/DemoCheck.jsonl` |
| Every omp process's parent is a `zsh`, one per process | `ps -o ppid=` of the 17 processes: 17 different parents, all `/bin/zsh` |
| omp reopens a chat from its file | `omp --help`: `-r, --resume=<value>  Resume a session (by ID prefix, path, or picker if omitted)` |
| A plugin may run any program, with no declared permission | SDK book: "`tern.process.run` starts any program with any arguments"; "Tern does not declare, check or prompt for capabilities" |
| One `/bin/sh` running `pgrep`, `ps -wwE` and `lsof` returns the pids, panes and files | harness helper op `proc_run`: status 0 in 134 ms, 60 lines, matching the shell's own output |
| `tern.process.run` with a callback gives the window callback a fresh `cx` | `tern.d.luau:2129` |
| A shell-typed omp in the harness is an agent block, and D1's script pairs it with its pane and file | task 1.1: pane 16, `program` "omp"; pid 72648 with `TERN_WINDOW_PANE=16` held its `.jsonl` open; the script took 198 ms |
| `omp --resume '<file>'` typed at once into a new shell tab brings the chat back, and keeps writing to the same file | task 1.1: shot `s11_resumed` showed the earlier message; pid 73544 named the file on its command line, then held that same file after its next message |
| omp names the folder of a chat outside home with `--` around it | task 1.1: `sessions/--private-tmp-tobj-w-ompA--/` |
| omp creates a chat's file, and starts holding it, when the first reply ends, not when the message is sent | task 2.1: during the 46 s first turn of pane 140, `sessions/--private-tmp-tobj-w-ompC--/` stayed empty and its omp held no `.jsonl`; the file and its lock appeared as the turn ended. The capture at the turn's start saved nothing for it; the one at its end saved it about 1 s later (`seen` 1793992562, lock written at 1793992561) |

## Goals / Non-Goals

**Goals:**
- Never resume the wrong chat: a pane is paired only with the omp process whose environment names it.
- No polling. A capture costs one process run, at turns, at plugin start and when the graph opens.

**Non-Goals:**
- Keeping Claude Resume beside omp (proposal, item 3).
- Showing which chat a Resume will open; the row already reads "omp" with the pane's title.

## Decisions

### D1. Finding each omp chat's file
One `tern.process.run({ "/bin/sh", "-c", SCRIPT }, { timeout_ms = 5000 }, cb)`. The script prints tagged lines:
1. `pgrep -d, -f '(^|/)omp( |$)'` for the pids; with none, it exits.
2. `ps -ww -o pid=,args= -p <pids>`, prefixed `a `: each process's command line.
3. `ps -wwE -o pid=,command= -p <pids>`, reduced with `grep -oE` to the pid and `TERN_PANE=` or `TERN_WINDOW_PANE=` tokens, prefixed `e `.
4. `lsof -a -p <pids> -Fpn`, reduced to `p<pid>` lines and names ending in `.jsonl`.

Parsing, per pid:
- **omp only:** the command line's first word must have the base name `omp`, so a `vim /x/omp` can't count.
- **Pane:** `TERN_PANE`, else `TERN_WINDOW_PANE` (source record).
- **File:** the open `.jsonl` exactly two levels under a `sessions` folder, `…/sessions/<folder>/<name>.jsonl`, which leaves out subagents' files. If none is open: the value after `--restore` or `--resume`, as `=value` or the rest of the command line, when it has that shape and `tern.fs.exists` finds it. More than one candidate means unsure, and the pid is skipped.

Pairing: a pane is saved only if `cx.agents:list()` lists it, it is in a session on a local host (`local_panes`, kept from 0.9.0), and exactly one omp pid names it.

Alternatives:
- **`cx.procs:list`:** its answer can be minutes old (0.9.0 source record), has no environment, and has no open files.
- **Newest file in the chat's folder under `sessions/`:** wrong whenever two omp chats share a folder, which is common.
- **`~/.omp/run/session-owners/<id>.lock`:** these are empty flock files, held only by chats that have written; `lsof` already shows the chat file itself.

### D2. When captures run
- **Turns:** unchanged triggers: `agent_state` to "working", and `agent_finished` with "done" or "failed". A chat's first turn is saved by the capture at its end, since omp creates the file only then (source record). Later turns are saved at their start as well.
- **Plugin start:** the startup `tern.timer(0, …)` in `window.luau` also requests a capture. This saves chats that were running before this version was installed, and chats Tern restored after a restart.
- **Graph open:** `App.open` requests a capture. If it saves something new, the `Refresh` cycle redraws, and the closed tabs gain their buttons. It covers a restored chat no one has written to.
- **One at a time:** as now, a request 0.5 s ahead, and at most one under way. The `turned` set, the sample waits and the retries go: a chat with no message has no file to find (source record).
- **Writing:** as now: the capture refreshes linked tabs' snapshots, then `Store.save_sessions(found, live)`, which writes only when an entry differs.

### D3. What is stored
`AgentSession` keeps its shape: `{ agent = "omp", session = <absolute file path>, cwd = <the agent's cwd>, seen }`.
- **Valid entry:** `agent == "omp"`, and `session` an absolute path ending in `.jsonl`, two levels under a `sessions` folder, with no control characters. `Store.is_chat_file` checks this; it lives in the store because `normalize` needs it, and `agents.luau` already requires the store.
- **Migration:** `normalize` (`lib/store.luau:112`) keeps only valid entries. Claude sessions from 0.9.0 to 0.10.0 are therefore gone from every read, and from the file at the next write. `VERSION` stays 1.
- **Rollback:** an older plugin reads omp entries as sessions. Its Resume would toast "no saved Claude chat", since a path isn't a UUID (`is_session_id`), and it would type nothing.

### D4. Resume button and rows
- **Button:** a closed tab's agent row counts when its entry is valid and `tern.fs.exists(session)` holds. That is a stat per such row, per render, on the UI thread, a few rows at most. Tooltip: "Reopen this tab's omp chats in a new tab".
- **Rows:** `details.luau` names a closed agent row by its entry's `agent`, which is now always "omp". Without a valid entry it reads "agent", as before 0.9.0.
- **Live rows:** `is_claude` and `base_name` stay, so a live Claude chat still reads "claude · <state>".

### D5. Resume steps
As in 0.9.0 (`resume-closed-agents` D5, D6), with three changes:
- **Entries:** only valid entries whose file exists. If none: toast "That tab has no omp chat left to resume".
- **Typing:** `omp --resume '<file>'` and Return, with `'` written as `'\''`. Folder names may hold spaces (source record). D3 has already refused control characters.
- **Moved entries:** each new pane gets the same file: `omp --resume` keeps writing to it (task 1.1).

### D6. Release
0.11.0, a minor release. It changes Resume and removes Claude support, which is breaking for anyone who resumes Claude chats. The README says so.

## Risks / Trade-offs

- **`TERN_PANE` is not in `tern.d.luau` or the SDK book.** Tern sets it for its shells, and a later Tern could drop it. → Nothing is saved then, and nothing wrong is resumed. The harness name, `TERN_WINDOW_PANE`, is read as well.
- **omp's file handling may change** with an omp update, for example not holding the file open. → The command-line fallback covers restored chats. Otherwise nothing is saved, with no wrong resume.
- **A chat switched to a new chat (`/new`) with no message since** holds no file; its command line still names the old one. → Resume reopens the earlier chat, which still exists.
- **A tab closed during its chat's first reply** has nothing saved: omp hasn't created the file yet. → No Resume for that tab; the README names the limit.
- **Process cost:** about 134 ms of child processes per capture, off the UI thread except for the spawn. It runs at turns, which are seconds apart, at plugin start and at graph open.
- **`lsof` and `ps -E` see only the user's own processes.** omp runs as the user.
- **Remote sessions** are untested headless, as in 0.9.0. → Panes in sessions on remote hosts are skipped, and Resume refuses while the current session is remote.
- **Harness checks reach outside `/tmp`:**
  - they use the user's model account, one short message per check;
  - they write chat files under `~/.omp/agent/sessions/--private-tmp-tobj-*`, deleted after the checks;
  - the harness plugin also sees the user's live omp processes. Their panes, from `TERN_PANE`, aren't harness panes, so they are ignored.
