# Proposal

## Why

In 0.2.x, "Objectives: Open graph" refuses to open in a session that runs on another machine, such as the user's "devbox" session over SSH. The tracking itself isn't the problem: the window half sees every session the window shows, remote ones included. The graph's popup is a plugin block, though, and Tern opens a block on the machine that owns the session. That machine has no `objectives` plugin, and couldn't read the view the window writes on this Mac anyway.

A probe in the user's live window settled the alternative. devbox (Tern 0.9.5) offers the native canvas block, the canvas opened over a devbox tab, and `objectives.graph` was unavailable there. A canvas is filled from window Lua, so it needs nothing on the remote machine.

0.3.0 shipped two surfaces: the block in sessions on this machine, a canvas elsewhere. After seeing that, the user chose one surface, the canvas, in every session, so that each change to the graph is built and checked once.

## What Changes

- In every session, ⌃⌘O shows the graph as a **canvas** glimpse over the current tab, the 0.1.x surface. Content, lines, link bars, menus and clicks are unchanged, and nothing is installed on other machines.
- The plugin block `objectives.graph`, its host half (`host.luau`) and the view files it read go. A block left open by 0.3.0 is closed and replaced by the canvas.
- Esc no longer closes the graph from inside it, since a canvas takes no keys. Tern's popup closes on Esc while its title bar has focus; ⌃⌘O, a click outside and × always close it.
- If a session's machine can't show a canvas, an error toast says so. The 0.2.x "opens only in sessions on this machine" note goes.
- A canvas left by 0.1.x is redrawn as the graph instead of closed on load.
- Release 0.4.0 (0.3.0 was the two-surface step). The README describes the one surface and how to close it.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`: adds "Graph in any session"; removes "Closing with Esc".
- `plugin-package`: "Manifest" drops the host entry and the block; "README" drops the host half and the local-sessions limit and says how to close the graph.

## Impact

- **Code:**
  - `lib/surface.luau` finds, opens, updates and closes the canvas, and closes a 0.3.0 block;
  - `lib/app.luau` drops the local-only refusal and the link handler;
  - `window.luau` handles `canvas_action` and no longer routes `objectives://` links;
  - `host.luau` is deleted, and `plugin.toml` loses its host entry and block and moves to version 0.4.0;
  - `styles.css` and `Layout.SCOPE` are scoped to the canvas;
  - `README.md`.
- **Tern APIs:** `cx.canvas` (open, set, get, list) and `canvas_action` replace `cx:new_block`, `tern.block.define` and `tern.route.link`.
- **Not affected:** the store, links, pane details and navigation.

## Out of scope

- Esc pressed inside the graph. A canvas takes no keys, and a plugin can't bind Esc while the preset binds it.
- Installing anything on remote machines.
- Machines whose Tern can't show a canvas, beyond the toast.
