# Design

## Context

Motivation is in proposal.md. The 0.2.x graph is the plugin block `objectives.graph` (archived change `2026-11-05-polish-graph-ui`, P1–P3). The window half writes the view into the plugin's data folder, and the block reads it there.

- `cx:new_block` opens "on the window's current host" (`tern.d.luau` L1881–1883), so in a remote session the block would need the plugin on that machine and would read that machine's data folder.
- A canvas is "the native block kind `tern.canvas`: persistent, replicated content supplied from window Lua, without a host entry"; "a host without canvas support returns `nil, err`" (SDK "Window API › `cx.canvas`").
- Canvases take no keys (same page), which is why 0.2 moved off them.

### Probe record (user's live window, 2026-11-05, throwaway plugin `objremoteprobe`, linked and then unlinked)

From the local session, the probe switched to "devbox" and back.

| Read | Result |
|---|---|
| `cx.hosts:current()` | `{name = "devbox", kind = "remote", state = "connected"}` (Tern 0.9.5 there) |
| `cx.session:block_types()` | `["tern.canvas"]`: canvas support, no `objectives` blocks |
| `cx.canvas:open{how = "glimpse"}` | opened a pane in devbox's tab 4500000000000001; `cx.canvas:get` read it back |
| `cx:new_block("objectives.graph", …, "glimpse")` | `nil` |

Luau prints and parses such ids exactly. In the harness, `tostring`, concatenation, `%d` and `tern.json.encode` of 4500000000000001 all gave `4500000000000001`.

## Goals / Non-Goals

**Goals:** one graph in any session; the same view tree, clicks and styles on both surfaces; no change for sessions on this machine.

**Non-Goals:** Esc in remote sessions; anything installed or written on remote machines.

## Decisions

### G1. The surface follows the session's machine
`Surface.show` asks `cx.hosts:current().kind` (ManagedHost L735–736):
- `"local"` opens the block, as in 0.2;
- anything else opens `cx.canvas:open{title = "Objectives", view, about, how = "glimpse"}` and focuses it.

A graph shown on the wrong surface for the current session (a canvas in a local session, a block in a remote one) is closed and replaced. A failed canvas open returns `nil, err`, and `App.open` shows the error toast it already has.

**Alternatives:**
- Install the plugin on remote machines: the view files would still be on this Mac, and Tern has no window → block channel across machines.
- Canvas everywhere: loses Esc in local sessions.

### G2. One surface module for both kinds
`lib/surface.luau` remembers which kind it found:
- **find:** the block, a pane with `block == "objectives.graph"`; or a canvas owned by `objectives` in `cx.canvas:list()`.
- **update:** the view files (block) or `cx.canvas:set(pane, {view = view})` (canvas).
- **close:** `cx.layout:close` for both, plus the view files for the block.
- **here** and the docked check are unchanged.
- The canvas gets the tree itself, since a canvas draws its view root, while the block's host half wraps it in a column (archived P2).

### G3. Clicks from both surfaces
`window.luau` registers `tern.on("canvas_action")` again, next to `tern.route.link`:
- events not owned by `objectives` are ignored;
- the rest go to the same `App.action({act, value}, cx)` and are consumed.

`App.link` stays for the block.

### G4. One style scope for both surfaces
`Layout.SCOPE` and every rule in `styles.css` use `:is([data-surface='plugin.objectives.graph'], [data-surface='plugin.tern.canvas']) .ob-root`. `:is()` takes complex selectors and has the specificity of its strongest argument, here one attribute (SDK "Supported CSS › Pseudo-classes"), so rule precedence is unchanged.

### G5. Leftover canvases are adopted
Archived P10 closed every `objectives` canvas on load. Canvases are now a valid surface, so the load-time timer only redraws. `Surface.find` adopts a 0.1.x canvas like any other, and ⌃⌘O in a local session replaces it with the block (G1).

### G6. Same face and ring on both surfaces
- **Face.** A canvas draws in the terminal face, and only a block can ask for `font = "sans"`. `.ob-root` sets `font-family: var(--sans)`, Tern's UI stack (SDK "Theme tokens": `--sans`), so both surfaces read alike (task 1.1).
- **Ring.** The origin ring is an inset box-shadow. As an outer shadow it reached 1.5 px into the gap column, where the edge check read it as a line end (task 1.3).

## Risks / Trade-offs

- **R1. Esc in remote sessions.** Tern's glimpse closes on Esc only while its title bar has focus, as in 0.1.x. → ⌃⌘O, a click outside and × close it; the README says so.
- **R2. No remote machine in the harness.** → The canvas path is exercised with the local check inverted in the fixtures copy (as in archived task 2.7). The live check on devbox confirms it.
- **R3. Remote tabs in the graph.** The window half lists the window's sessions with `cx.session:*`; whether devbox's tabs appear and jump correctly is only visible live. → Live check.
- **R4. Docking.** A canvas glimpse docks on programmatic focus changes exactly as the block does, and the same "close before jumping" rule applies (archived design D2).
- **R5. Redraw after a plugin reload.** The load-time timer redraws a shown graph and its line sheet, as in 0.1.x. In the headless harness, plugin timers set at load fire only when the plugin next runs a hook, so a redraw after reload with a canvas shown couldn't be observed there; a click redraws it. → Seen live after the 0.3.0 install. A speculative retry was tried and dropped.

## Migration Plan

Release 0.3.0: tag `v0.3.0`, then `tern plugin install … --force` live. The stored data is unchanged. Rollback is a reinstall of `v0.2.1`.
