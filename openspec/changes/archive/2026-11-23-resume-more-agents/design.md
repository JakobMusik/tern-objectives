# Design

## Context

See proposal.md, "Why".

- **Resume today (0.11.0 on, `resume-omp-chats`):**
  - `lib/agents.luau` runs one `/bin/sh` script (`pgrep`, `ps -wwE`, `lsof`) at turns, at plugin start, when the graph opens, and before the graph closes tabs (`save_now`).
  - It pairs each agent pane (`cx.agents:list`) in a local session with the one omp process whose `TERN_PANE` or `TERN_WINDOW_PANE` names it, and saves the `.jsonl` file that process holds open (or names on its command line).
  - `State.agents[pane] = { agent = "omp", session = <file>, cwd, seen }`; `normalize` keeps only valid omp entries (`valid_session`, `lib/store.luau:68`).
  - The Resume button needs an agent row with an existing file (`lib/view.luau:1025`). `resume` types `omp --resume '<file>'` (`lib/app.luau:824`).
- **Names and marks:** `agent_name` (`lib/details.luau:88`) names a chat by its command, or "claude" by its program, else "omp"; `attention` (line 124) marks omp chats only.
- **Tern:** 0.9.30. The API reference is regenerated with `tern plugin types` (`tern.d.luau`).

### Source record

All on 2026-11-22, in the harness (`tern serve` at `/tmp/tobj`, settings in `/tmp/tobj/config/settings.json`), with read-only `ps`, `lsof` and `sqlite3 -readonly` on the user's own processes and files.

| # | Claim | Evidence |
|---|---|---|
| S1 | Tern's settings: `agents.auto_acp` ("Whether typing an agent CLI opens it as an ACP chat in Tern … shells started while it is on wrap the CLIs; off, typing one runs it untouched") and `agents.keep_tui` ("Built-in agent ids that keep their own interface when typed") | doc comments in the Tern 0.9.30 binary (`strings`); Settings › Agents: "Open agent commands as ACP chats … `command claude` runs its own interface" |
| S2 | Tern's zsh defines `claude`, `codex` and `copilot` as `_ksi_acp <cli> "$@"`, which runs `"$TERN_ACP" acp "--typed=$cli" "$@"` when `TERN_ACP` is executable, else `command "$cli" "$@"` | the zsh integration text in the binary |
| S3 | `tern acp` reads `settings.json` from the config folder when it starts | `~/Library/Logs/Tern/tern-acp.log`: "settings loaded path=/tmp/tobj/config/settings.json" for each harness chat |
| S4 | A typed Claude ACP chat runs `tern acp --typed=claude` → node (claude-agent-acp 0.109.1) → `claude … --session-id=210e000f-…`. Every process carries `TERN_WINDOW_PANE` | `ps` of pane 4's processes |
| S5 | Claude keeps `~/.claude/sessions/<pid>.json` for each `claude` process: `sessionId`, `cwd` (`/private/tmp/tobj/w/acpA`), `kind` "interactive", `entrypoint` "sdk-ts" (ACP) or "cli" (own interface) | `64343.json`, `88563.json` |
| S6 | The transcript `~/.claude/projects/-private-tmp-tobj-w-acpA/<sessionId>.jsonl` appears with the first message, even when the reply is an account error | `ls` after one message; the folder name is the `cwd` with `/` turned into `-`; another user folder, `mine__SelectTTS`, became `mine--SelectTTS` |
| S7 | Claude in its own interface (`keep_tui` ["claude","codex"]) runs in a terminal pane (`kind` "terminal", `running` set) as one `claude` process with the pane in its environment. After `/clear`, its record's `sessionId` changed to a new id | panes listing; `88563.json` before and after `/clear` |
| S8 | Resuming Claude: `tern acp --resume claude:<id>` and `claude --resume <id>` (own interface) each showed the earlier message. With `keep_tui` [], a typed `claude --resume <id>` ran `tern acp --typed=claude --resume <id>`, an agent block | shots `acp_claude_resumed`, `nat_claude_resumed`; pane 20's processes |
| S9 | A typed Codex ACP chat runs `tern acp --typed=codex` → node (codex-acp 2.9.0) → `codex app-server`, whose arguments are exactly `app-server`. That server holds its one `~/.codex/sessions/2026/11/22/rollout-…-01a20390-….jsonl` open after one message | `ps`, `lsof` of pid 70351 |
| S10 | A typed `codex resume <id>` ran `tern acp --typed=codex resume <id>`, whose chat showed the earlier reply "ok". With `keep_tui` ["claude","codex"] the same line ran Codex's own interface with the earlier message; a thread made in Codex's own interface came back as an ACP chat with `keep_tui` [] | pane 10 (`last_message` "ok"); shot `x_acpB`; pane 22 |
| S11 | Codex's own interface holds no rollout file; the shared `codex app-server … --managed-daemon` (started outside Tern, `TERN_PANE=999999`) holds every thread. Nothing ties the window process to its thread: `state_5.sqlite` `threads` has no pid, and its `logs_2.sqlite` rows (`pid:94285:…`) carry no thread id | `lsof` of 94285; `sqlite3 -readonly` queries |
| S12 | The user's Antigravity agent runs `tern acp antigravity` → node `acp.mjs` → `agy acp`, which carries the pane and holds `brain/<id>` and `conversations/<id>.db` from the start. The user's live `agy acp` 43963, idle for 35 minutes, held only `brain/38930c88-…`; 48325, after `/new`, held two `brain` folders | `lsof` of harness pid 75984 and live pids 43963, 48325 |
| S13 | Antigravity resumed both ways: `tern acp --resume antigravity:<id>` gave an agent block with `last_message` "ok", and `agy --conversation <id>` ran its own interface with the earlier message | shots `acp_agy_resumed`, `x_acpC2` |
| S14 | Antigravity in its own interface (`agy`) holds `conversations/<id>.db` after the first message. After `/clear` it held two; after the next message, only the new one. `agy --conversation <id>` brought it back | `lsof` of 97836; shot `nat_agy_resumed` |
| S15 | Chats in their own interface give few events: typed Claude gives `command_started` (line "claude"), then only `title` changes ("✳ Claude Code", "Claude Code"); an Antigravity turn gave no event at all | the helper's event log |
| S16 | `cx.agents:list` lists an ACP chat with `command` null and `program` the first word typed: "codex", "claude", or "export" for a line starting with `export` | helper op `agents` |
| S17 | An ACP Codex chat reports `working` during a turn, then `idle` with the pane's `alert` true while unfocused; focusing the pane clears `alert` | helper ops `agents`, `panes`, pane 8 |
| S18 | `tern.fs.read(path, max_bytes)` requires a regular non-symlink file and refuses one over `max_bytes` | `tern.d.luau` 0.9.30, `fs.read` |
| S19 | Harness shells start with `HOME`, `ZDOTDIR` and `XDG_*` in a temporary folder. With `XDG_DATA_HOME` there, Claude's updater pointed `~/.local/bin/claude` into it; that link broke when the harness stopped, and was restored to `~/.local/share/claude/versions/2.1.330` | `env` in a harness shell; `readlink` at 22:33 |
| S20 | Every Claude message from the user's account returned "Your account can't receive replies from Claude right now" | each Claude spike |

## Goals / Non-Goals

**Goals:**
- Never resume the wrong chat: as for omp, a pane is saved only from a process whose environment names it, with exactly one chat session.
- Follow Tern's own settings for Claude and Codex at resume time, with no copy of them in the plugin.

**Non-Goals:**
- Reading Tern's settings, or choosing between Tern's chat and an agent's own interface, in the plugin.
- The "you:" line for other agents (`fix-spec-drift` D2 stays).

## Decisions

### D1. Agents, files and commands

| Agent | Chat process (environment names the pane) | Saved file (`session`) | Typed on Resume |
|---|---|---|---|
| omp | `omp` (unchanged) | the open `…/sessions/<folder>/<name>.jsonl` | `omp --resume '<file>'` |
| claude | `claude`, whose record (S5) has `kind` "interactive" | `<claude dir>/projects/<folder name>/<id>.jsonl`, where `<id>` is the record's `sessionId` | `claude --resume <id>` |
| codex | `codex` with arguments exactly `app-server` (S9) | the one open `…/sessions/YYYY/MM/DD/rollout-…-<id>.jsonl` | `codex resume <id>` |
| agy | `agy`, any arguments | the one open `…/conversations/<id>.db`; with none open, the one open `…/brain/<id>` folder's `<root>/conversations/<id>.db` | `agy --conversation <id>` |

`<id>` is always read back from the saved file's name and must be a UUID (8-4-4-4-12 hex), so nothing else reaches the shell. A file of an agent's shape is otherwise checked as omp's is: absolute, with no control characters (`resume-omp-chats` D3).

Alternatives:
- **`tern acp --resume <agent>:<id>`** (S8, S13): it always opens Tern's chat, so it ignores `keep_tui`, and the user asked for Tern's settings to decide.
- **Typing the agent's command** goes through Tern's shell (S2), which applies `auto_acp` and `keep_tui` as they are at that moment (S1, S3, S10). That's the user's rule, with nothing to copy.

### D2. Finding the chats

The script's `pgrep` pattern becomes `(^|/)(omp|claude|codex|agy)( |$)`. Its `ps -wwE` step also keeps `HOME=` and `CLAUDE_CONFIG_DIR=` tokens. Its `lsof` step also keeps names ending in `/conversations/<uuid>.db` or `/brain/<uuid>`. `parse` records each process's agent (its first word's base name, which leaves out the node bridges and `tern acp`), its arguments, pane, home, Claude folder and open files.

**Candidate panes:** this window's panes in sessions on local hosts (`local_panes`, as now):
- agent blocks, whose folder is the block's `cwd`;
- terminal panes with a command running (`PaneInfo.running`), whose folder is the pane's `cwd`.

Agent blocks are omp's and every ACP chat; running terminals are where an agent's own interface runs (S7, S14).

**Pairing:** per candidate pane, the chat processes naming it are:
- omp processes, on agent blocks only (as now);
- `claude` processes;
- Codex servers (D1), on agent blocks only. That leaves out Codex's own interface and the shared server (S11);
- `agy` processes.

Exactly one chat process gives the pane its file by D1; none, or more than one, gives nothing new. So a pane where omp runs `claude` as a tool is skipped until that tool ends.

**Claude's record:** for the one `claude` process of a pane, the callback reads `<dir>/sessions/<pid>.json` with `tern.fs.read(path, 65536)` (S18) and decodes it with `tern.json`. `<dir>` is `CLAUDE_CONFIG_DIR`, else `HOME/.claude`, both from that process's own environment, since harness shells run with another home (S19). A record that is unreadable, not `kind` "interactive", or without a UUID `sessionId` gives nothing. The transcript's folder name is the record's `cwd` with every character other than `A-Z`, `a-z` and `0-9` turned into `-` (S6); the transcript must exist (`tern.fs.exists`). The saved folder is the record's `cwd`, where Claude files its sessions.

Alternatives:
- **Claude's `--session-id` argument:** only ACP chats carry it, and it misses `/clear` (S7).
- **Newest file in a folder:** wrong when two chats share a folder (`resume-omp-chats` D1).
- **`cx.procs:list`:** its answer can be minutes old (`resume-closed-agents` source record).

### D3. What is stored

`AgentSession` keeps its shape. `agent` is "omp", "claude", "codex" or "agy", and `session` is that agent's file (D1). `Store.is_chat_file` becomes `Store.chat_file_ok(agent, file)`, with one pattern per agent:
- omp: `/sessions/<folder>/<name>.jsonl`, as now;
- claude: `/projects/<folder>/<uuid>.jsonl`;
- codex: `/sessions/<yyyy>/<mm>/<dd>/rollout-…-<uuid>.jsonl`;
- agy: `/conversations/<uuid>.db`.

`Store.chat_id(entry)` returns the UUID that Resume types. `normalize` keeps only entries that pass, so 0.9.0–0.10.0's Claude ids (no path) are still dropped. `VERSION` stays 1.

Rollback: 0.32.0's `valid_session` drops every non-omp entry at its next write.

### D4. When captures run

- **As now:** at a turn's start or end, at plugin start, when the graph opens, and before the graph closes tabs.
- **A command that starts an agent:** `window.luau` adds a `command_started` handler. If any word of `ev.line` has the base name `claude` or `agy`, it calls `Agents.request()`. Words are split at whitespace and `;`, `&`, `|`, `(` and `)`. That capture finds no transcript yet (S6), but it starts the next point.
- **Every 30 s while a chat runs in its own interface:** after a capture that paired a `claude` or `agy` process with a terminal pane, `agents.luau` arms one `tern.timer(30000, …)` that calls `Agents.request()`. It isn't armed again while one is waiting, and it stops after a capture that finds no such chat.
- **No request is lost:** a request that comes while a capture waits or runs used to be dropped. Now it queues one more capture after that one, and still at most one runs at a time. The new triggers (a command starting, the 30-second timer) overlap more often with a turn's start or end, and a dropped turn-end request would wait for the next trigger.
- **First omp turn:** the turn-end scan may beat the first open file by about two seconds (task 1.1). Give that finished pane one later sample inside the existing three-second window, only if the first scan identified the same running omp and still has no file. This uses no directory or time-based guess for the session id.

Why: Claude's own interface only changes its title, and Antigravity's sends nothing (S15). Without this, a tab closed with ⌘W would keep no chat unless the graph had opened since the first message.

Alternatives:
- **`title` events:** none come from Antigravity, and shells change titles at every command.
- **A poll that is always on:** it would cost a process run even with no such chat.

### D5. Snapshot rows of chats in their own interface

The process scan associates a confirmed agent and file with the **current command**, not just its pane number. A new command, a finished command or a closed pane invalidates that association. A scan returning after the command ended must not reattach its result to the next command.

`Model.read` passes this window-local observation with the live row. A running terminal becomes an agent in a snapshot only if its observed file matches its saved entry. Thus `sleep` after a Claude chat cannot inherit that chat. Live Claude and agy terminals can show their name without claiming Tern reports an agent state. With no match they remain shells. Nothing is added to the stored format.

### D6. Resume

`resume` (`lib/app.luau:773`) takes each agent row's entry that passes D3 and whose file exists. It types:
- `omp --resume '<file>'`, quoted as now;
- `claude --resume <id>`, `codex resume <id>` or `agy --conversation <id>`, where `<id>` is `Store.chat_id`, a bare UUID.

Each new tab or split opens in the entry's folder, as now. For Claude that is the record's `cwd`, since Claude looks for the session in that folder's project.

`agy` with arguments runs Antigravity's own interface even with the user's `agy` shortcut (S13; the shortcut's README: only a bare `agy` is redirected).

Moved entries keep their file. Claude's `--resume`, Codex's `resume` and `agy --conversation` keep the same id (`resume-closed-agents` source record; S9, S14).

The toast for a tab with nothing to resume reads "That tab has no chat left to resume".

### D7. Names and marks

For a live block, use its explicit agent command or known program when available. A launch through `tern acp`, a shell function or a wrapper may not give the program's name; the agent process observed for the current command then names the row, even before a transcript is available. A saved agent name is a fallback. An explicit unrelated block command keeps its name, and the established fallback for an unlabelled omp block remains "omp".

`Details.attention` uses Tern's state and unseen-reply `alert` for every live agent block (S17), independent of its display name. A native terminal, a snapshot or a missing agent block never contributes a mark.

### D8. Wording

- `lib/view.luau`:
  - the Resume tooltip: "Reopen this tab's chats in a new tab";
  - the close tooltips: "…; saved chats come back with Resume.";
  - the `.ob-tclose` question's tooltip.
- README:
  - "See what needs you": agent chats;
  - "Jump anywhere": the last reply for a chat block; the last user message as well for omp;
  - "Finish cleanly": Resume brings back omp, Claude Code, Codex and Antigravity chats. Claude and Codex come back as Tern's chat or in their own interface, as Tern's settings say; Antigravity in its own interface;
  - a limits note: native Codex is not captured, the file must exist, and several candidate sessions never replace a confirmed entry.

### D9. Release

0.33.0, a minor release: it adds behaviour.

## Risks / Trade-offs

- **Claude's records and folder names are not documented** (S5, S6). If Claude changes them, no transcript is found and nothing is saved; nothing wrong is resumed. A very long folder may get a different name from Claude [INFERENCE]; then nothing is saved either.
- **`ps -E` splits values at spaces.** A `HOME` or `CLAUDE_CONFIG_DIR` with spaces gives a wrong folder, so nothing is saved.
- **A Codex chat that never had a message** may have a rollout file already [untested]. Resuming it would open an empty chat, or Codex reports that the thread had no messages (codex-acp's own error text).
- **An idle Antigravity chat after `/new` or `/clear`,** in either mode, holds two `brain` folders and no conversation file (S12; task 1.1, pane 162). Nothing new is saved until it writes again, so Resume brings back the conversation saved before. The one saved at its next message is the new one (task 1.1).
- **omp's first transcript may not yet be open when the first scan runs** (task 1.1). D4 checks again once for that finished command. If the file still cannot be identified, leave it unsaved rather than matching by folder.
- **A command that runs `claude` or `agy` through an alias or script** isn't seen by D4's word check. It is saved at the next turn of another chat, plugin start or graph open; a tab closed before any of these keeps nothing.
- **The 30-second save** costs one process run, about 150–200 ms off the UI thread (`resume-omp-chats` source record), every 30 s while a chat runs in its own interface.
- **The live check of Claude** may meet the account error (S20). The transcript is still written (S6), so Resume shows the earlier message.
- **Harness checks reach outside `/tmp`:**
  - the integration checks use the user's model accounts for short turns;
  - only identified test transcripts created by the checks are removed from the Claude and omp test projects;
  - Codex's and Antigravity's test chats stay in their own history, since deleting their files would leave their indexes pointing at missing files;
  - every agent check starts its shell with `HOME=/Users/macintosh` and `XDG_*` unset (S19). After the checks, `readlink ~/.local/bin/claude` must still point into `~/.local/share/claude/versions/`.
- **Remote sessions** stay untested, as for omp: panes in sessions on other hosts are skipped.

## Migration Plan

None beyond D3: entries that 0.32.0 saved stay valid. A rollback to 0.32.0 drops the new agents' entries at its next write and keeps omp's.
