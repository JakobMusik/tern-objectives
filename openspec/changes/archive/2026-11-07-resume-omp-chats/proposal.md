# Proposal

## Why

The user mainly uses omp, and expected Resume to bring back omp chats from the start. Resume (0.9.0) brings back only Claude chats, with heavy limits: Tern's `agents.auto_acp` must be on, and the chat must be the only Claude chat in its folder. So the user's closed linked tabs, which hold omp chats, never show Resume. On 2026-11-07 the user asked to support omp only and to drop Claude support rather than keep a limited path.

Research on 2026-11-07 (design, source record) showed omp chats can be matched to their panes exactly, with no folder rule:
- Every omp process carries its pane's id in its environment as `TERN_PANE`. In the user's Tern, process 6843 has `TERN_PANE=100000000001`, the same id the store holds for that chat's pane.
- An omp chat that has had a message holds its chat file open (`~/.omp/agent/sessions/<folder>/<time>_<id>.jsonl`), and `lsof` shows it. A chat Tern restored and nobody has written to since names that file on its command line instead (`omp --restore <file>`).
- `omp --resume <file>` reopens a chat from its file (`omp --help`).
- A plugin can read all three by running `/bin/ps` and `lsof` with `tern.process.run`: a run from the harness took 134 ms.

## What Changes

1. **Saving omp chats:**
   - When an omp chat's turn starts or ends, when the plugin starts, and when the graph opens, the plugin finds each local omp chat's process and saves its chat file and folder under the chat's pane, in its own store.
   - It saves nothing for a chat that has no chat file yet, that is, one that has never had a message.
2. **Resume for omp:**
   - A closed tab with a row that has a saved omp chat, whose file still exists, shows "Resume" on its header.
   - Clicking it opens a new tab, in the current session and the chat's folder, and runs `omp --resume <file>` there, with a split to the right for each further chat. The new tab takes over the closed tab's links, as today.
   - A closed tab's row with a saved omp chat reads "omp" instead of "agent".
3. **BREAKING: Claude support goes:**
   - The plugin no longer saves Claude sessions. Closed tabs with Claude chats no longer show Resume, and their rows read "agent" again.
   - Saved Claude sessions already in the store are dropped.
   - A live Claude chat's row still reads "claude · <state>": that is only its name.
4. Release as 0.11.0, with the README's "Using the graph" and "Known limits" updated.

Out of scope:
- Claude, Codex and other agents. Claude needed `agents.auto_acp` and one chat per folder. Codex runs every session in one shared `codex app-server` process, so no process names a session.
- omp chats that have never had a message, or whose chat file was deleted or moved: there is nothing to resume.
- Chats on another machine: `ps` and `lsof` read this Mac only, and Resume refuses while the current session is on another machine, as today.
- Recreating shells, files or other panes, the tab's name, or its place in its old session.
- "Close linked tabs" for done objectives: a later change, which will reuse this capture before closing.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `agent-resume`: saved sessions are omp chat files matched by pane id, instead of Claude session ids matched by folder; Resume runs `omp --resume <file>`.
- `pane-details`: a closed tab's row with a saved omp chat reads "omp"; the closed-Claude case goes.

## Impact

- `lib/agents.luau`: capture rewritten: one `tern.process.run` of `/bin/sh` running `pgrep`, `ps` and `lsof`, parsed into pane → chat file. The Claude matching (`folder`, `session_of`, `pair`, the `cx.procs` sampling and the `turned` set) goes; `is_claude` and `base_name` stay for naming live rows.
- `lib/store.luau`: saved sessions hold omp chat files; entries that aren't omp chat files are dropped when the store is read.
- `lib/app.luau`: Resume types `omp --resume '<file>'`; a capture runs when the graph opens.
- `window.luau`: a capture at plugin start; the turn triggers stay.
- `lib/view.luau`: the Resume button needs the chat file to exist; its tooltip names omp.
- `lib/details.luau`: closed rows name their saved agent, now "omp".
- `README.md`, `plugin.toml` (0.11.0).
- No new permissions or dependencies: `/bin/sh`, `/usr/bin/pgrep`, `/bin/ps` and `/usr/sbin/lsof` ship with macOS.
