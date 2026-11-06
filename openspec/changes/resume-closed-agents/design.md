# Design

## Context

See proposal.md, "Why".

- **Closed tabs today:**
  - A linked tab's snapshot (`TabSnap`, `lib/store.luau:27`) keeps its label, session, position, window key, and each pane's id, title and kind.
  - `refresh_snapshots` rewrites a snapshot whenever the graph sees the live tab, and compares snapshots field by field (`same`, line 195).
  - A closed tab is drawn from its snapshot by `ghost` (`lib/view.luau:224`). Clicking its header or rows only toasts "That tab is closed" (`jump_tab`, `lib/app.luau:434`).
- **Agents today:**
  - `lib/details.luau` reads `cx.agents:list()` once per render.
  - It names an agent by its command's base name, else "omp" (`agent_name`, line 91).
  - A closed agent row has no agent block, so it reads "agent".
- **Tern gives no session id:** neither `AgentBlock` (`tern.d.luau:770`) nor `PaneInfo` (523) carries an agent's session id.

### Source record

| Claim | Evidence |
|---|---|
| `tern acp` takes `--resume <session>`, `--fork <session>`, `--continue` and `--sessions` | Usage string in the Tern 0.9.12 binary: `usage: tern acp <agent> [--resume <session> \| --fork <session> \| --continue \| --sessions] [--model <model>] …` |
| A Tern shell's `claude` is a function running `$TERN_ACP acp --typed=claude "$@"`, or `claude` itself when `TERN_ACP` isn't executable | spike: `functions _ksi_acp` in a harness shell |
| `tern acp` wraps the chat only while the running Tern has `agents.auto_acp` on. A harness `tern serve` started without it wraps after `cx.settings:set("agents.auto_acp", true)` | spike: typed `claude` ran Claude's own UI as a terminal with only `settings.json` written after the serve started, and opened an ACP chat once `cx.settings:set` had run (task 1.1). `cx.settings` doc: "headless changes remain ephemeral" (`tern.d.luau:939`) |
| An ACP chat's process chain is `tern acp --typed=claude` → node adapter → `claude … --session-id=<uuid>` | spike `ps`, 2026-11-06: pids 25241 → 25726 → 25732, `--session-id=a1ac2ce7-…` |
| A resumed chat's process runs `claude --resume=<uuid>`, keeping the same id | spike `ps` after typing `claude --resume a1ac2ce7-…`; the adapter sets `sessionId = creationOpts.resume` (`claude-agent-acp` 0.99.1, `acp-agent.js:8831`, read before the harness upgraded it) |
| `cx.procs:list({ name = "claude" })` returns each process's pid, parent, `cwd`, `started` and full `command` argv. The name filter is a substring, so it also returns `Claude` and `Claude Helper` | spike helper op `procs`: process 27009, `cwd` `/private/tmp/tobj/w/agentspike`, argv `[…/claude, --resume=a1ac2ce7-…]`; `ProcessQuery` doc (`tern.d.luau:834`) |
| `cx.procs` reads only this machine | `tern.d.luau:853`: "Desktop window only: the local machine, even while viewing a remote host." |
| `cx.agents:list()` lists a shell-typed chat with `command` null, `program` "claude", and `cwd` `/tmp/…` (no `/private`). Its `model` is the chosen model: "Claude Code" before the first turn, "Opus 5.5" later | spike helper op `agents`, panes 12 and 8 |
| The 0.8.x graph names such a chat's row "omp · idle" | task 1.1: `ctl tree '.ob-r-8 .ob-rtype'` read `["omp · idle"]` |
| Sending a message fires one `agent_state` with `old` "idle" and `new` "working" | task 1.1: the helper's event log held `{pane 8, old idle, new working}` |
| Other `claude` processes on the Mac may pass `--resume <id>` as two arguments | task 1.1: a non-Tern `claude` process listed `--resume` as its own argument |
| A tab opened with `Launch.command = "claude"` runs Claude's own UI in an agent block, with `command` "claude" | spike: pane 4; its screen read "⏵⏵ auto mode on" |
| A chat's session file appears only when its first message is sent | spike: `~/.claude/projects/-private-tmp-tobj-w-agentspike/` didn't exist after the chat opened; `a1ac2ce7-….jsonl` did after the first message |
| Closing the tab, then typing `claude --resume <uuid>` in a new shell tab in the same folder, brings the chat back with its messages | spike shot `ag3`: the earlier "Reply with exactly: spike-ok" and "spike-ok" |
| `agent_state` gives `pane`, `old` and `new` state | `tern.d.luau:1337–1344` |
| `cx:run(pane, text)` types into a pane; `cx.layout:new_tab(launch, reveal)` and `split(target, dir, launch, reveal)` open panes | `tern.d.luau:1878`, `1749`, `1751` |
| `cx.layout:new_tab` returns the new pane's id, not the tab's. In the same call, `cx.session:layout`, `tabs` and `panes` don't list it yet, but `cx.session:tab_of(pane)` gives its tab | task 1.2: `new_tab` returned 18; `layout`, `tabs` and `panes` gave nothing, `tab_of(18)` gave 19, and so did timers at 0, 50 and 200 ms. Earlier: 5 for pane 5 in tab 6 |
| Typing `claude --resume <id>` into that pane straight away resumes the chat | task 1.2: the agent ran `claude --resume 82ec7f14-…`, and shot `r_resume_now` showed "Reply with exactly: ok" and "ok" |
| `cx.hosts:current()` has `kind` "local" or "remote"; `ManagedSession.host` names a session's host | `tern.d.luau:735–747`, `706` |
| A click on an inner node with its own action sends that action, not its parent's | pane rows: the jump button inside the row's `exp=` click jumps without folding (refine-graph-rows, design R7) |
| `tern acp` in the harness installed and ran the Claude adapter from the live `~/Library/Application Support/Tern/agents/claude`, not from `TERN_CONFIG_DIR` | spike: the live `installed.json` went from 0.99.1 to 0.101.0, and the node process ran from that folder |
| Codex keeps every session in one shared `codex app-server` process | `ps`; `codex-acp` 2.5.0 resumes per thread with `thread/resume` inside that server |

## Goals / Non-Goals

**Goals:**
- Never resume the wrong conversation. When the match is unsure, save nothing.
- Cost nothing while no Claude turn starts: no polling.

**Non-Goals:**
- A session picker. Tern's own `/sessions`, inside an agent chat, lists a folder's sessions; it was not tried here.

## Decisions

### D1. Which agents are Claude chats
An agent is a Claude chat when the base name of its `command` is `claude`, or, with no `command`, when its pane's `program` (`cx.session:pane`, `PaneInfo.program`) is `claude`. `agent_name` uses the same test, so a shell-typed chat reads "claude" instead of falling through to "omp".

Alternative: `model == "Claude Code"`. That field reads as a display name, and its value isn't documented.

### D2. Capture on a turn's start
- **Trigger:** the `agent_state` handler in `window.luau` already requests a render. It also calls `Agents.request(cx)` when `ev.new == "working"`.
- **Timing:** one capture runs 1 s later, and at most one is pending.
- **Reading:** a capture reads `cx.agents:list()`, then awaits `cx.procs:list({ name = "claude", limit = 100 })`. It keeps processes whose name is exactly `claude` and whose argv holds `--session-id` or `--resume`, in either the `=value` or the separate-argument form, with a UUID value.
- **Folders:** both sides are normalised: a leading `/private` before `/tmp/`, `/var/` or `/etc/` is dropped.
- **Matching:** for each Claude chat in a session on a local host, it collects the chats and the processes in its folder. Only a one-to-one pair saves an id.
- **Writing:** `Store.mutate` runs only when an entry differs. Each window's VM may capture the same chat and write the same value; read-before-write keeps that harmless.

Why a turn's start: before the first message, no conversation file exists to resume (source record). And a chat moved to a new session is caught at that session's first turn.

Alternatives:
- **Polling every few seconds:** costs a process sample even when nothing changes.
- **Capturing at `tab_closed`:** the processes are already gone by then.
- **Reading `~/.claude/projects/<folder>/`:** `tern.fs.list` gives names without times, so telling which file is the chat's means reading every file.

### D3. Where saved sessions live
`State.agents: { [string]: { agent: string, session: string, cwd: string, seen: number } }`, keyed by pane id.
- **Why a separate map:** inside `TabSnap.panes`, every `refresh_snapshots` would have to carry it over, and `same` would compare it.
- **Stored version:** `normalize` fills `agents = {}`, and `VERSION` stays 1. An older plugin keeps the map, because `mutate` writes back the whole state it read.
- **Removal:**
  - `drop_orphans` (called on delete and unlink) and `prune` also drop entries whose pane is in no snapshot and not live;
  - a capture drops such entries too.

### D4. The Resume button
- **Placement:** a `span` in the header's first line (`.ob-th1`), right of the label, with `click = "resume=<tab>"`.
- **Clicks:** the inner node's action wins over the header's `tab=` (source record), so the rest of the header still toasts.
- **Size:** 28 × 22 px, like the jump button, with `user-select: none`. It fits the 38 px header, so `lib/layout.luau` doesn't change.
- **When it shows:** `View.build` gets `state.agents`. A ghost with status "closed" shows the button when one of its rows' panes has an entry.

### D5. Resume steps
1. Check the host: if `cx.hosts:current().kind ~= "local"`, toast "Resume works in a session on this Mac" and stop.
2. Re-read the state. Take the closed tab's rows that have entries, in row order. If the tab is live again or none are left, toast and stop.
3. `Surface.close(cx)`, then `pane = cx.layout:new_tab({ cwd = first.cwd })`. It reveals by default, and returns the new shell pane's id. The tab is `cx.session:tab_of(pane)` (source record).
4. Type `claude --resume <id>` and Return with `cx:run(pane, …)`, straight away. Each further entry gets `cx.layout:split(previous, "right", { cwd }, { focus = false })`, then the same typing.
5. Call `Store.adopt(closed_tab, new_tab, moved)` (D6), where `moved` maps each resumed entry to its new pane.

Notes:
- **Ids:** an id is typed only if it matches the UUID pattern, so nothing else reaches the shell.
- **Why typing:** it goes through the shell's `claude` function, which opens the ACP chat. A `Launch.command` runs Claude's own UI instead (source record).
- **Timing:** typing at once works (task 1.2), so there is no wait.

### D6. The new tab takes the closed tab's links
`Store.adopt(old, new, moved)`:
- in every objective, replaces `old` with `new` at the same place, without duplicating `new`;
- removes `old`'s snapshot and its saved sessions;
- saves each resumed chat's session under its new pane, so the new tab can be resumed again before its next turn.

The new tab's snapshot is written by `refresh_snapshots` once the window lists the tab. Tern lists it only after the call that opened it (source record). So the resume step also starts a 250 ms `tern.timer` that reads the window and refreshes the snapshots, whether or not the graph is shown.

Alternative: copying the links and keeping the ghost. The objective would then show the same work twice until a prune.

### D7. Release
0.9.0, a minor release: it adds behaviour.

## Risks / Trade-offs

- **Two Claude chats in one folder get no saved session** (D2). That's common in one repository. → README known limit. Pairing chats with processes by start time was rejected: [INFERENCE] a chat's process can start again under the same pane, for example when the adapter reopens a session, and that would swap the pairs.
- **A chat moved to a new session keeps its old id until its next turn.** → Resuming then reopens the previous conversation, which still exists.
- **Typing before the shell is ready** is untested (D5). → Spike task 1.2.
- **The cost of `cx.procs:list`** is unmeasured. [INFERENCE] It samples off the UI thread, since it returns an awaitable. → It runs at most once per turn start. Task 2.2 logs its time.
- **Process `cwd` may be nil** when the OS can't read it (`tern.d.luau:857`). → No match, nothing saved.
- **Remote sessions** are untested headless: the harness has no second host. → D5 checks the current host, and D2 skips chats in sessions on remote hosts. The README names the limit.
- **Claude's own UI with `agents.auto_acp` off** can resume with the same typed command. [INFERENCE] Untested: its process carries no id until it is resumed, so such chats are rarely saved at all.
- **Harness checks touch things outside `/tmp`:**
  - The live adapter folder, `~/Library/Application Support/Tern/agents/claude` (source record). The adapter is already at the current version, so the checks should install nothing.
  - The user's Claude account: one short message per check.
  - `~/.claude/projects/-private-tmp-tobj-*`: these session files are deleted after the checks.
