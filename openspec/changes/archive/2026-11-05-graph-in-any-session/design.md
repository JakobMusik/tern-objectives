# Design

## Context

Motivation is in proposal.md. The 0.2.x graph is the plugin block `objectives.graph` (archived change `2026-11-05-polish-graph-ui`, P1–P3). The window half writes the view into the plugin's data folder, and the block reads it there.

- `cx:new_block` opens "on the window's current host" (`tern.d.luau` L1881–1883), so in a remote session the block would need the plugin on that machine and would read that machine's data folder.
- A canvas is "the native block kind `tern.canvas`: persistent, replicated content supplied from window Lua, without a host entry"; "a host without canvas support returns `nil, err`" (SDK "Window API › `cx.canvas`").
- Canvases take no keys (same page), which is why 0.2 moved off them. A plugin can't bind Esc either: the harness logs `plugin bind left out: the preset binds these keys keys="escape"` for a fixture that tries.

### Probe record (user's live window, 2026-11-05, throwaway plugin `objremoteprobe`, linked and then unlinked)

From the local session, the probe switched to "devbox" and back.

| Read | Result |
|---|---|
| `cx.hosts:current()` | `{name = "devbox", kind = "remote", state = "connected"}` (Tern 0.9.5 there) |
| `cx.session:block_types()` | `["tern.canvas"]`: canvas support, no `objectives` blocks |
| `cx.canvas:open{how = "glimpse"}` | opened a pane in devbox's tab 4500000000000001; `cx.canvas:get` read it back |
| `cx:new_block("objectives.graph", …, "glimpse")` | `nil` |

Luau prints and parses such ids exactly. In the harness, `tostring`, concatenation, `%d` and `tern.json.encode` of 4500000000000001 all gave `4500000000000001`.

### History

0.3.0 (tasks 1.1–2.1) chose the surface by the session's machine: the block in sessions on this machine, so Esc kept working there, and a canvas elsewhere. Both surfaces shared the view, clicks and styles, but every UI change still had to be checked twice, and the two differed in face and ring until fixed (G6). The user then chose the canvas everywhere (group 3).

## Goals / Non-Goals

**Goals:** one graph surface in every session; the same view tree, clicks and styles as 0.3.0; nothing installed on other machines.

**Non-Goals:** Esc pressed inside the graph; anything installed or written on remote machines.

## Decisions

### G1. A canvas in every session
`Surface.show` opens `cx.canvas:open{title = "Objectives", view, about, how = "glimpse"}` and focuses it, whatever machine the session runs on. A failed open returns `nil, err`, and `App.open` shows the error toast it already has.

**Alternatives:**
- The block in local sessions and a canvas elsewhere (0.3.0): keeps Esc locally, at the cost of two surfaces to build and check. The user chose one surface.
- Install the plugin on remote machines: the view files would still be on this Mac, and Tern has no window → block channel across machines.

### G2. One surface module
`lib/surface.luau` handles only the canvas:
- **find:** the canvas owned by `objectives` in `cx.canvas:list()`;
- **update:** `cx.canvas:set(pane, {view = view})`;
- **close:** `cx.layout:close`;
- **here** and the docked check are unchanged.

The canvas gets the tree itself, since a canvas draws its view root (the block's host half wrapped it in a column).

### G3. Clicks through `canvas_action`
`window.luau` handles `tern.on("canvas_action")`:
- events not owned by `objectives` are ignored;
- the rest go to `App.action({act, value}, cx)` and are consumed.

The `objectives://` link route, `App.link` and `host.luau` go, along with the host entry and block in `plugin.toml`.

### G4. One style scope
`Layout.SCOPE` and every rule in `styles.css` use `[data-surface='plugin.tern.canvas'] .ob-root`. 0.3.0's `:is(…)` over both surfaces had the same specificity, so rule precedence is unchanged.

### G5. Leftovers from earlier versions
- **0.1.x canvas:** archived P10 closed every `objectives` canvas on load. Canvases are the surface again, so `Surface.find` adopts one, and the load-time timer only redraws.
- **0.3.0 block:** a graph block open while 0.4.0 installs survives the reload with its block gone. The first lookup in a VM closes any pane whose block is `objectives.graph` and removes this window's `view-<window>.json` and `.seq`, so ⌃⌘O then opens the canvas.

### G6. Canvas face and ring
- **Face.** A canvas draws in the terminal face, and only a block can ask for `font = "sans"`. `.ob-root` sets `font-family: var(--sans)`, Tern's UI stack (SDK "Theme tokens": `--sans`), so the graph keeps the block's look (task 1.1).
- **Ring.** The origin ring is an inset box-shadow. As an outer shadow it reached 1.5 px into the gap column, where the edge check read it as a line end (task 1.3).

## Risks / Trade-offs

- **R1. Esc.** Tern's glimpse closes on Esc only while its title bar has focus, as in 0.1.x. → ⌃⌘O, a click outside and × close it; the README says so.
- **R2. No remote machine in the harness.** With no branch on the session's machine, the harness's local sessions run the same code as remote ones. → The smoke test and the user's check in devbox confirmed it (task 4.2).
- **R3. Remote tabs in the graph.** The window half lists the window's sessions with `cx.session:*`; whether devbox's tabs appear and jump correctly is only visible live. → Confirmed live: devbox's tabs are listed and jumps work (task 4.2).
- **R4. Docking.** A canvas glimpse docks on programmatic focus changes exactly as the block did, and the same "close before jumping" rule applies (archived design D2).
- **R5. Redraw after a plugin reload.** The load-time timer redraws a shown graph and its line sheet, as in 0.1.x. In the headless harness, plugin timers set at load fire only when the plugin next runs a hook, so a redraw after reload with a canvas shown couldn't be observed there; a click redraws it. A speculative retry was tried and dropped. → Live, on 0.4.0, the user saw the lines stay after a plugin reload (task 4.2).

## Migration Plan

Release 0.4.0: tag `v0.4.0`, then `tern plugin install … --force` live. The stored data is unchanged; a 0.3.0 block left open is closed (G5). Rollback is a reinstall of `v0.3.0`.
