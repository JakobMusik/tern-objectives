# Proposal

## Why

In 0.2.x, "Objectives: Open graph" refuses to open in a session that runs on another machine, such as the user's "devbox" session over SSH. The tracking itself isn't the problem: the window half sees every session the window shows, remote ones included. The graph's popup is a plugin block, though, and Tern opens a block on the machine that owns the session. That machine has no `objectives` plugin, and couldn't read the view the window writes on this Mac anyway.

A probe in the user's live window settled the alternative. devbox (Tern 0.9.5) offers the native canvas block, the canvas opened over a devbox tab, and `objectives.graph` was unavailable there. A canvas is filled from window Lua, so it needs nothing on the remote machine.

## What Changes

- In a session on another machine, ⌃⌘O shows the graph as a **canvas** glimpse over the current tab, the 0.1.x surface. It has the same content, lines, link bars, menus and clicks, and nothing is installed on that machine. Sessions on this machine keep the block.
- The graph's Esc stays a property of the block. In a canvas, Tern's popup closes on Esc only while its title bar has focus; ⌃⌘O, a click outside and × always close it.
- If the other machine can't show a canvas either, an error toast says so. The 0.2.x "opens only in sessions on this machine" note goes.
- A canvas left by 0.1.x is now redrawn as the graph instead of closed on load.
- Release 0.3.0. The README describes both surfaces and the Esc difference.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`: "Opening the graph" covers sessions on other machines; "Closing with Esc" applies to sessions on this machine.
- `plugin-package`: "README" replaces the local-sessions limit with the remote-session behaviour.

## Impact

- **Code:**
  - `lib/surface.luau` finds, opens, updates and closes either surface;
  - `lib/app.luau` drops the local-only refusal;
  - `window.luau` handles `canvas_action` again, next to the link route;
  - `styles.css` and `Layout.SCOPE` cover both surfaces;
  - `plugin.toml` moves to version 0.3.0;
  - `README.md`.
- **Tern APIs:** `cx.canvas` (open, set, get, list) comes back alongside `cx:new_block`.
- **Not affected:** the store, links, pane details, navigation and the block's behaviour in sessions on this machine.

## Out of scope

- Esc in sessions on other machines. A canvas takes no keys, and a block there would need the plugin installed on that machine plus a channel for the view, which Tern doesn't offer across machines.
- Installing anything on remote machines.
- Machines whose Tern can't show a canvas, beyond the toast.
