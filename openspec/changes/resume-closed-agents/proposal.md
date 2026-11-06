# Proposal

## Why

The user asked to make closed tabs recoverable, where possible, with only their agent sessions needing to come back. Today a closed linked tab shows in the graph as a ghost from its snapshot: its rows read "agent", and clicking it only says the tab is closed. Tern itself can't reopen a closed tab. The only reopen in its palette is "Reopen closed note".

Research and a harness spike on 2026-11-06 (design, source record) showed it can be done for Claude:
- With Tern's `agents.auto_acp` on, which the user's settings have, typing `claude` in a Tern shell opens an ACP chat.
- Its `claude` process runs with `--session-id=<uuid>`, or `--resume=<uuid>` when resumed.
- A plugin can read those arguments, and the process's folder, with `cx.procs:list`.
- After the tab was closed, typing `claude --resume <uuid>` into a new shell tab in the same folder brought the chat back with its earlier messages.

## What Changes

1. **Saving Claude sessions:**
   - When a Claude chat's turn starts, the plugin looks up its process and saves the chat's session id and folder with the pane, in its own store.
   - It saves nothing when it can't tell which process belongs to which chat, for example when two Claude chats share a folder.
2. **Resume:**
   - A closed tab with at least one saved Claude session shows a "Resume" button on its header.
   - Clicking it closes the graph and opens a new tab in the current session, in the first chat's folder. It runs `claude --resume <id>` there, and in a split to the right for each further chat.
   - The objectives that linked the closed tab then link the new tab instead, so the ghost is replaced by the live tab.
   - The tab's other panes, such as shells, are not recreated.
3. **Rows name Claude:**
   - A closed tab's row with a saved Claude session reads "claude" instead of "agent".
   - A live Claude chat's row reads "claude · <state>". Today it most likely reads "omp · <state>": Tern lists a chat typed in a shell with no `command`, and the plugin names any such agent "omp" (`lib/details.luau:91`). This was found in research and not yet seen on screen; task 1.1 checks it.
4. Release as 0.9.0, with the README's "Using the graph" and "Known limits" updated.

Out of scope:
- Codex, omp, Copilot and other agents. Codex runs every session in one shared `codex app-server` process, so no process names a session.
- Claude's own terminal interface (`agents.auto_acp` off), whose process carries no session id until it is resumed.
- Tabs closed before 0.9.0, and chats that never started a turn: neither has a saved session.
- Chats on another machine. `cx.procs` reads this Mac only, and Resume refuses while the current session is on another machine.
- Recreating shells, files or other panes, the tab's name, or its place in its old session.
- Resuming from the right-click menu or the palette.
- Review mode and the done changes (change `review-done-objectives`), and the heading selection fix (change `unselectable-group-headers`).

## Capabilities

### New Capabilities

- `agent-resume`: saving Claude chat sessions per pane, and resuming a closed tab's chats into a new linked tab.

### Modified Capabilities

- `pane-details`: "Pane type" names Claude chats "claude", live and in closed tabs with a saved session.

## Impact

- `lib/store.luau`: a map of saved sessions by pane, dropped with the snapshots that no longer hold the pane, and a step that moves a closed tab's links to a new tab.
- New `lib/agents.luau`: capture, matching processes to chats, and the resume steps.
- `window.luau`: the `agent_state` handler also schedules a capture.
- `lib/view.luau`, `lib/app.luau`, `styles.css`: the Resume button and its action. It fits the tab header's existing height, so `lib/layout.luau` is unchanged.
- `lib/details.luau`: naming Claude chats.
- `README.md`, `plugin.toml` (0.9.0).
- No new permissions or dependencies.
