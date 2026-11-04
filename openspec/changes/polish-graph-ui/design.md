# Design

## Context

The 0.1.x graph is a window-authored canvas in a glimpse (archived change `2026-11-05-add-objectives-plugin`, D1 "Window half only", D2 "Canvas in a glimpse"). Canvases take no keys: SDK "Window API › `cx.canvas`" ("Input/editor nodes are rejected (canvases take no keys)"), and `CanvasSpec.view` forbids input, editor and image kinds (`tern.d.luau` L1443). A plugin can't bind Esc either: Tern leaves a plugin bind out when its default keymap already binds the key, as `editor.escape` does (SDK "Commands, Keys, and Overrides › Keymap layering"; harness log `plugin bind left out: the preset binds these keys keys="escape"`). Motivation is in proposal.md; requirements are in `specs/`.

### Spike record (headless Tern, 2026-11-05, throwaway plugin `tspike`)

| # | What ran | Result |
|---|---|---|
| S1 | `cx:new_block("tspike.panel", {}, "glimpse")`; a click inside it; Esc | It opened as a glimpse with Tern's header and footer, unfocused. After the click, focus was on the block. Esc reached its `key` handler (`"escape"`), and `cx:exit(0)` closed it. Focus went back to the pane below. |
| S2 | `new_block(…, {focus = true})`, then `cx.layout:focus(pane)` | `focus = true` left focus on the pane below. `cx.layout:focus` moved it to the block, and the first Esc closed it. |
| S3 | The window writes `{n, 30 KB}` to `tern.kv`; the host polls every 25 ms and acks through `cx:open` | Round trip 13.3, 25.9, 26.1, 36.6 and 38.1 ms. |
| S4 | The block returns a window-built `tern.ui.el` tree, read from kv, as `main` | Plugin CSS classes, a `data:image/svg+xml` background line and a `[data-surface='plugin.tspike.view']` rule all applied (shot `t5_view`). |
| S5 | Block click and right-click menu → `cx:open("tspike://act/…")` → window `tern.route.link` | `sel=o1` and the menu's `link=12` arrived with `link.pane` = the block. Focus stayed on the block, the rewritten view redrew it, and Esc still closed it afterwards. |
| S6 | `actions.menu` on a canvas node | An in-window menu with the plugin's rows plus Copy; the choice arrived as `canvas_action` `act = "link"`, `value = "7"`. |
| S7 | `cx.whiteboard:open{how = "glimpse"}`, two rects, an arrow drawn with the arrow tool | The arrow read back with `from_shape` and `to_shape` set. Esc cleared the selection, and a second Esc closed it. The whiteboard sends the plugin no events. |
| S0 | Earlier probe `objprobe` (2026-11-04): a block glimpse runs `cx:open("tern-objprobe://focus/12")` | The window's `route.link` handler focused pane 12. |

The test plugin, its kv and its shots are under `/tmp/tobj`; none of it enters the repository.

## Goals / Non-Goals

**Goals:**
- The window half keeps every decision: the view, clicks, the store, refresh and details. The host half only displays the view and passes input back.
- `kv.json` is still written only for real store changes.
- Rendering stays within the 50 ms window budget at about 30 objectives and 40 panes, with every row open.

**Non-Goals:**
- Logic in the host half; keys other than Esc; whiteboard surfaces.

## Decisions

### P1. The graph is a plugin block shown as a glimpse
**Choice:** `plugin.toml` gains `host = "host.luau"` and `[[blocks]] id = "graph"` with `palette = false`.
- **Opening:** `App.open` calls `cx:new_block("objectives.graph", {stem}, "glimpse")` (L1881–1883), then `cx.layout:focus(pane)` (S2).
- **Esc:** the block's `key` handler calls `cx:exit(0)` on `"escape"` and returns `false` for every other key (SDK "Blocks › Keys and paste").
- **⌃⌘O:** window key bindings take their keys before the block (same page), so ⌃⌘O keeps toggling.
- **Finding the graph:** the pane in `cx.session:panes()` with `kind == "plugin"` and `block == "objectives.graph"` (PaneInfo L555). This replaces the canvas lookup, and the rest of `Canvas.here`/`show`/`close` keeps its logic: reuse only an undocked glimpse in the current tab, close before jumping, close with `cx.layout:close`.

**Alternatives:**
- Keep the canvas: Esc stays unfixable (Context).
- Whiteboard (S7): plain boxes, no clicks reach the plugin, a drawing toolbar, and the arrow tool must be picked first.
- A `settings.json` Esc bind: plugin commands' `available` only filters palette rows (SDK `tern.command`), so Esc would be taken in every pane.

### P2. A thin block: the window half renders, the block shows
`BlockCx` has no `session`, `layout`, `pick` or `prompt` (L1417–1437), so the graph's logic can't move to the host half. The block holds only the latest tree and returns `{ main = tree }`. `View.build`, `App.action`, `Store`, `Refresh` and `Details` stay in the window half unchanged in role.

### P3. View hand-off through two files in the data folder
**Files:** both halves share the plugin's data folder, `tern.plugin.data` (SDK "Architecture › Two halves"). Each render of the window half writes:
1. `view-<stem>.json`: `{"n": n, "tree": …}`, through `tern.fs.write` (L2116);
2. then `view-<stem>.seq`: just `n`.

`<stem>` is the window key from `cx:window_key()` (archived D8), with every character outside `[A-Za-z0-9_-]` replaced by `_`. It is passed as the block's launch argument and kept by its `save`.

**Reading:** the block re-arms a 25 ms `tern.timer` (one-shot, L2080–2081). It reads the `.seq` file with `max_bytes = 32` (L2114). Only when `n` changes does it read and `tern.json.decode` the tree, then call `cx:render()`. A decode failure, such as a half-written file, keeps the old tree and the old `n`, so the next poll tries again.

**Clean-up:** the window half removes both files when it sees the graph gone.

**Why not `tern.kv`:**
- `kv.json` is rewritten whole on every `set` (SDK "Files, Processes, and Storage").
- Writing the tree there would rewrite the store several times a second while the graph is shown. That widens the window in which two windows' simultaneous writes race, and the last rename wins.
- `tern.fs` has no stat (L2108–2125), hence the small `.seq` file.

### P4. Clicks travel as links, accepted only from the graph's own pane
**Block side:** the block's `event` turns `{act, value}` into `cx:open("objectives://act/<act>/<value>")`, both parts percent-encoded (L1411).

**Window side:** `window.luau` replaces `tern.on("canvas_action")` with `tern.route.link` (L2268–2274). The handler:
- declines (returns nil) every URL that doesn't start with `objectives://`, so other links keep their built-in handling;
- swallows, with `{handled = true}` and no action, any `objectives://` link that isn't `objectives://act/…` or whose `link.pane` isn't the graph's current pane (LinkRequest L1219–1235; S5 showed `pane` is the block). So an `objectives://` hyperlink printed by a program can't drive the plugin. Declining it would hand the URL to the built-in handling, which would try to open it;
- otherwise decodes the two parts, calls `App.action({act, value}, cx)` and returns `{handled = true}`.

The verbs of archived D5 are kept, plus `lnk=<objective>:<tab>` from the tab menu (P6).

### P5. Origin
`App.open` reads `cx.session:focused()` before opening and keeps it as `origin`, unless that pane is the graph itself. `finish` (the reopen after a picker) passes `keep_origin`, so the origin survives the field flow. Closing the graph clears it: the toggle, a jump, or Esc seen as the graph pane disappearing.

`View.build` receives `origin`:
- the tab node whose live rows include it gets `ob-origin`, an accent ring;
- the row itself gets `ob-row-origin`, a 3 px accent bar at its left edge.

The pane-to-tab mapping is read live on every render, so the mark follows a moved pane and vanishes with a closed one.

### P6. Linking UI
**Link bar:**
- While an objective is selected, each tab node ends in a bar 26 px tall: "＋ Link" (accent outline) or "× Unlink" (muted), `actions = {click = "link=<tab>"}`, with a tooltip naming the objective.
- The bar sits outside the header, whose click jumps, so a near miss no longer jumps.
- `Layout.px.link_h = 26` is added to a tab's height only while a selection exists. Edge ends stay at header centres (archived D3), so lines don't move.

**Tab menu:**
- The tab node root carries `actions.menu` (SDK "Building Views › Actions and events"; S5, S6): a `{header = "Link to"}` row, then one check row per open objective in graph order, `{id = "lnk=<objective>:<tab>", label = title, checked = linked}`.
- With none, a single row `{id = "none", label = "No objectives yet", disabled = "Create one with ＋ New objective"}`.
- Choosing a row toggles that link. The selection is untouched.

### P7. Rows open by default
`view.collapsed`, a map of pane id to `true`, replaces `view.expanded`. A live row is open unless it is collapsed, and `exp=<pane>` flips it. `Store.normalize` copies only the known view fields, so a 0.1.x `expanded` map is dropped at the next view write. `Layout.add_tab` already counts detail lines, so taller tabs need no layout change.

### P8. Hit areas without moving geometry
The clickable spans of the done box, ⋯ and ▸/▾ become 22 px wide and as tall as their line (18 px in objective nodes, 22 px in rows). The visible mark stays its current size, drawn centred with `::before` (SDK "Supported CSS", pseudo-elements). `Layout.px` is unchanged except for `link_h`.

### P9. Style scope
`styles.css` and `Layout.SCOPE` move from `[data-surface='plugin.tern.canvas']` to `[data-surface='plugin.objectives.graph']` (S4 showed the block's surface carries `plugin.<id>.<block>`).

### P10. Canvases left by 0.1.x
Canvases survive a plugin reload (SDK "Window API › `cx.canvas`": "reloading a plugin does not reset its canvases"). After updating, the load-time timer closes any canvas owned by `objectives` (`cx.canvas:list()`), so an old glimpse doesn't linger.

## Risks / Trade-offs

- **R1. Render plus hand-off cost with every row open.** → Checked in task 3.3 at 30 objectives, 40 panes, 45 links and every row open:
  - with `tern.ui.el`, renders took 11–25 ms. `View.build` alone took about 10 ms, half of it after the columns were built, because every container's `tern.ui.el` converts its whole subtree again; 500 flat calls cost only about 2 ms;
  - with plain `{k, p, c}` wire tables (`Node`, L134–135), which the block receives as decoded JSON anyway, renders took 5.0–9.1 ms (build 3.2–6.5, hand-over 1.7–2.6, a 64 KB view file);
  - lines still met node centres (edgecheck at full height). No fallback needed.
- **R2. Focus on open.** S2 needed `cx.layout:focus` after `new_block`. → Checked in task 1.1: `cx.layout:focus(pane)` in the same handler as `new_block`, with no wait, focused the block at once. The first Esc closed it, and the `cat -v` pane below printed nothing. No timer needed.
- **R3. Sessions on other machines.** `cx:new_block` opens on the window's current host (L1881), where the plugin may be missing and whose data folder differs. A real remote host is untested; the harness has none. → When `cx.hosts:current().kind` (ManagedHost L735–736) isn't `"local"`, "Open graph" shows an info toast and opens nothing; the README states the limit. In task 2.7 the harness read `kind = "local"`, and with the check inverted the toast showed and no graph opened.
- **R4. Right-click inside a child node.** → Checked in task 1.2: a right-click on a child that has only a click action opens the parent's `actions.menu`, and the choice arrives with the parent's id. The menu sits on the tab node root, and pane rows carry none.
- **R5. Plugin reload with the graph shown.** → Checked in task 1.3: the block pane survives `ctl plugins fixtures` and keeps focus. `init` runs again with the state its `save` returned, so the block keeps its stem and goes on polling. No reopen fallback needed.
- **R6. Esc while a menu or Tern popover is open** closes that first (Tern's own layer rule), so a second Esc closes the graph. Accepted.

## Migration Plan

1. Release 0.2.0: push `main`, tag `v0.2.0`, then `tern plugin install github.com/JakobMusik/tern-objectives --force` in the live Tern. The user does the live check.
2. Stored objectives, links and snapshots are unchanged. `view.expanded` disappears at the next view write.
3. Rollback: reinstall from tag `v0.1.2`. 0.1.2 ignores `view.collapsed`, starts with every row folded, and leaves the data-folder view files unread.

## Open Questions

None. R3's local-host id is checked against the harness listing during the task that adds the toast.
