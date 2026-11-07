# Tasks

All checks run in the headless harness at `/tmp/tobj` (archived design D14) unless a task is marked **(live)**.
- "kv dump" means reading `/tmp/tobj/config/plugin-data/objectives/kv.json`.
- "view files" means `view-<stem>.json` and `.seq` in `/tmp/tobj/config/plugin-data/objectives/`.
- Any Esc test runs over a pane whose program is `cat -v`, never over an interactive shell.
- The throwaway plugin `tspike` stays in the fixtures folder only.

## 1. Risk checks before the rewrite

- [x] 1.1 Focus on open (design R2). In `tspike`, open a block glimpse and call `cx.layout:focus(pane)` in the same handler, with no wait, over a `cat -v` pane. Then press Esc once.

  Verify with `ctl state` and a shot: the block was focused, Esc closed it, and `cat -v` printed nothing. If the first Esc misses, focus from a 0 ms timer instead, and record the outcome in design.md R2.

  Result: the block (pane 12) had focus at once; the first Esc reached its key handler and closed it; focus returned to the `cat -v` pane, whose screen stayed empty.
- [x] 1.2 Right-click inside a child (design R4). In `tspike`, put `actions.menu` on a parent div only, and right-click a child div that has its own click action.

  Verify with a shot and `ctl pick` on `div.pop`: the parent's menu opens or it doesn't. If it doesn't, plan to give pane rows the tab menu too, and record the outcome in design.md R4.

  Result: the parent's menu opened over the child (shot `r4_menu`), and choosing its row sent `act = "plink"` from `main.parent`. Pane rows need no menu of their own.
- [x] 1.3 Plugin reload with a block shown (design R5). Run `ctl plugins fixtures` while the `tspike` block is shown.

  Verify with `ctl state` and a tspike kv dump: the block pane survives, and its `init` receives the saved state. Record the outcome in design.md R5, with the fallback if needed.

  Result: pane 13 survived with focus, and `init` ran again with `saved = {gen = 1}`. No fallback needed.

## 2. Block surface

- [x] 2.1 Add the host half: `plugin.toml` gains `host = "host.luau"` and `[[blocks]] id = "graph"` (`palette = false`). `host.luau` defines the thin `graph` block (design P1–P3):
  - it polls the `.seq` file every 25 ms and reads and decodes the tree when it changes;
  - it renders `{main = tree}`;
  - it forwards events as `objectives://act/<act>/<value>`;
  - `escape` calls `cx:exit(0)`;
  - `save` keeps the stem.

  Verify: `ctl plugins fixtures` loads `objectives` with no plugin errors in `/tmp/tobj/logs`, and the palette offers no "Objectives Graph" block.

  Result: loaded with no errors; `palette objectives` lists only the three commands (shot `p21_palette`). The block also sets `font = "sans"`, so the graph keeps the 0.1.2 face.
- [x] 2.2 Rework `lib/canvas.luau` into the block surface, renamed `lib/surface.luau` (design P1, P3):
  - find the graph pane by `block == "objectives.graph"`;
  - `show` opens with `cx:new_block(…, {stem}, "glimpse")`, then `cx.layout:focus`;
  - `update` writes the view files;
  - `close` closes the pane and removes the files;
  - `Model.read` skips the graph pane.

  Verify (objectives-graph "Opening the graph": Key toggles, Replacing a docked graph):
  - ⌃⌘O twice: `ctl state` shows the graph pane focused after the first press, and no graph pane after the second;
  - the view files exist only while the graph is shown;
  - after a session switch docks the graph, ⌃⌘O in that tab leaves exactly one graph pane.

  Result (helper dump): the first ⌃⌘O showed graph pane 48 with focus and wrote `view-window.json`/`.seq`; the second left no graph pane and no files. A switch to "alpha" and back docked pane 49 into tab 42's layout; ⌃⌘O then left exactly one graph, pane 51, focused and in no layout. The headless window key is `""`, so the stem falls back to `window`.
- [x] 2.3 Replace the `canvas_action` handler with the `tern.route.link` handler (design P4). It declines URLs that aren't `objectives://`, and swallows unacted any `objectives://` link that isn't an action or comes from a pane other than the graph's.

  Verify:
  - clicking an objective's title in a shot selects it;
  - a `tspike` block that runs `cx:open("objectives://act/new/")` opens no title field, and the kv dump is unchanged.

  Result: a click on the first title gave its node `ob-sel`, with focus kept on the graph. The `tspike` link from pane 52 was logged as ignored; no field opened (shot `g23_foreign`), and the kv dump was unchanged.
- [x] 2.4 Move the style scope to `[data-surface='plugin.objectives.graph']` in `styles.css` and `Layout.SCOPE` (design P9). Close canvases left by 0.1.x on load (design P10).

  Verify:
  - shots at 1400 and 460 px wide, light and dark, look like the 0.1.2 graph;
  - `edgecheck.py` puts the line ends within 2 px of node centres (objectives-graph "Link lines");
  - a canvas opened by a 0.1.2 fixture copy is gone after syncing this version and reloading (`ctl state`).

  Result: shots `e24_{1400,460}_{light,dark}` show the 0.1.2 look. `edgecheck.py` passed all four (7 objective ends and 5 tab ends, all within 0.3 px) once the viewport was tall enough to show the whole graph; at 900 px the lines leaving the visible area read as false ends. The 0.1.2 canvas (pane 53) was gone after the sync and reload (helper dump). The 0.1.x scope string is now `Layout.SCOPE`, shared by `edges.luau`.
- [x] 2.5 Esc and ⌃⌘O with focus inside the graph (objectives-graph "Closing with Esc", "Opening the graph": Toggle after clicking inside).

  Verify with `ctl key`, `ctl state` and shots over a fresh `cat -v` pane:
  - Esc right after ⌃⌘O closes the graph, and `cat -v` shows no `^[`;
  - after clicking an objective's title, one Esc closes it;
  - after the same click, ⌃⌘O closes it.

  Result over `cat -v` pane 55: each case closed the graph and returned focus to pane 55, whose screen stayed empty.
- [x] 2.6 Pickers, navigation and refresh on the new surface. Verify by re-running the scenarios with shots and `ctl state`:
  - objectives-graph "Graph returns after its pickers": Clicking into a field, Dismissing by clicking the graph;
  - tab-navigation "Jump to a tab" (cross-session) and "Jumped-to pane is uncovered";
  - objectives-graph "Live refresh": New tab appears.

  Result:
  - "＋ New objective", a click into the field (which closed the glimpse), "Write slides" + Enter: the graph came back with it selected.
  - Side note, a click into the field, a click where the graph was: the field closed, the note was unchanged, and the graph came back.
  - A click on "Components" from session beta showed session alpha with pane 18 focused, and a click on the right-hand row of "App build" focused pane 16, uncovered (shot `g26_pane`).
  - A tab opened programmatically appeared in the graph. It also docked the glimpse into its tab, as it does with 0.1.2's canvas (checked side by side; archived design R1).
- [x] 2.7 Sessions on other machines (design R3): "Open graph" shows an info toast and opens nothing when the current session's host isn't the local one.

  Verify:
  - the harness's `cx.hosts:current().kind` reads `"local"`, and the graph opens;
  - with the local-host check temporarily inverted, the command shows the toast, and `ctl state` holds no graph pane.

  Result: the harness reads `{id = 0, kind = "local"}`, and the graph opened. With the check inverted in the fixtures copy, ⌃⌘O showed the toast (shot `g27_toast`) and opened no graph. The check uses `ManagedHost.kind` rather than a host id of 0.
- [x] 2.8 README for the new surface (plugin-package "README"):
  - the plugin has a window half and a host half that only shows the graph;
  - Esc closes the graph; the old Esc limit goes;
  - the graph opens only in sessions on the local machine.

  Verify: the README holds those three points and no longer says "window-half only".

  Result: Install describes both halves; the Open graph row says Esc closes it; Known limits lists the local-sessions limit, with the Esc limit and the footer note gone (the footer's hint is now true); Data names the transient view files. No "window-half only" or "canvas" is left.

## 3. Pane rows open by default

- [x] 3.1 Store `view.collapsed` instead of `view.expanded`, with `normalize` dropping `expanded` (design P7).

  Verify by kv dump (objective-store "Remembered view settings": Rows opened under 0.1.x, Settings survive reload):
  - plant a 0.1.x `view.expanded`, open the graph: every live row is open (shot);
  - fold one row: the dump holds `collapsed` with that pane and no `expanded`;
  - after a plugin reload, the row is still folded and the others open.

  Result: with `expanded = {"14": true}` planted, every live row opened (shot `g31_open`). A ▾ on row 14 left `view = {collapsed = {"14": true}, done_open = false, scope = "all"}`, with no `expanded`. After `ctl plugins fixtures`, the handed-over view showed row 14 as ▸ and all 15 other rows as ▾. `edgecheck` passed with every row open (shot `g31_tall`).
- [x] 3.2 Rows open unless folded; ▾ folds and ▸ opens (pane-details "Expandable pane rows").

  Verify with shots and `ctl state`:
  - a two-pane tab never folded shows both detail areas;
  - ▾ then ▸ removes and restores them;
  - focus stays on the graph pane.

  Result: "App build" showed both panes' details. Pane 16's detail lines went 1 → 0 → 1 across ▾ and ▸, and focus stayed on the graph pane after each click. The README's pane-row paragraph now says details show by default.
- [x] 3.3 Render cost with every row open (design R1): 30 objectives, 40 panes, all rows open.

  Verify: the debug log's `render` lines, extended to include encoding and the two file writes, stay at or under 20 ms. If they don't, apply the fallback in R1 and record it.

  Result: the first build ran 11–25 ms. Profiling showed `tern.ui.el` converting every nested subtree again, so `View.build` now builds plain `{k, p, c}` wire nodes, and renders run 5.0–9.1 ms (build 3.2–6.5, hand-over 1.7–2.6). Lines still meet node centres at full height (shot `g33_tall`). R1's fallback wasn't needed.

## 4. Origin highlight

- [x] 4.1 Keep the origin pane in `App` and pass it to `View.build`: `ob-origin` ring on its tab node, `ob-row-origin` bar on its row (design P5).

  Verify by shots (objectives-graph "Origin highlight"):
  - Opened from a split pane: focus the right-hand pane of "App build", then ⌃⌘O; only that node and row are marked;
  - Origin pane moves: tobjh `move_to_tab` while the graph is shown; the marks follow;
  - Kept after a picker: the "＋ New objective" field flow with a click into the field; the same marks after the reopen;
  - New origin on a fresh open: close, focus a pane in "Components", reopen; only the new marks.

  Result (view-file classes and shots `g41_*`):
  - from pane 16, the right-hand pane of "App build", only `ob-t-15 ob-origin` and `ob-r-16 ob-row-origin` were marked;
  - moving pane 16 between tabs 19 and 15 moved both marks within 1 s;
  - after the field flow, which left pane 18 focused, the reopened graph still marked pane 16;
  - a fresh open from pane 18 marked only "Components" and its `ui` row (`g41_fresh`).

  Ring and bar are box-shadows, so no geometry moved.

  Seen on the way: a plugin reload forgets the origin, like the selection (design P5). Once, the heartbeat stopped silently after a long idle gap in the harness. It didn't recur in three traced runs, and the refresh code is unchanged from 0.1.2.

## 5. Linking and hit areas

- [x] 5.1 Link bar at the foot of each tab node while an objective is selected; drop the corner ＋/×; add `Layout.px.link_h` (design P6).

  Verify:
  - tab-links "Linking from the graph": Add then remove a link, by kv dump after each `ctl click` on the bar, with the graph shown and the objective still selected;
  - objectives-graph "Selection": Select and clear, and "New objective button": Create and select, by shots;
  - `edgecheck.py` keeps line ends within 2 px with the bars shown.

  Result:
  - with o2 selected, 24 bars read "＋ Link" and one "× Unlink" (shot `g51_selected`);
  - clicks on tab 15's bar gave o2 `[19, 15]`, then `[19]`, with the graph shown and o2 selected after both;
  - an empty-space click left no bar and no selection;
  - a new "Link bar demo" was selected, with 25 "＋ Link" bars.

  The first edgecheck at full height failed by 2.3 px on the deepest tab end. Each long curve met the node edge at a slant, so `edgecheck` read a sloped line one column in. Every line now ends in 4 px level stubs (design P11), and edgecheck passes at 1400 and 460 px, light and dark, with at most 0.5 px.
- [x] 5.2 Right-click menu on tab nodes, plus pane rows if 1.2 required it (design P6).

  Verify (tab-links "Link menu on tab nodes"):
  - Link without selecting and Unlink from the menu, by `ctl click … right`, a click on the row and a kv dump;
  - No objectives yet: a shot shows the single disabled row, and the kv dump is unchanged.

  Result:
  - with no selection, the menu on "Benchmarks" listed "Link to" and every open objective in graph order, with "Speed up search" checked (shot `g52_menu`); choosing "Review pull requests" gave o5 `[27, 24]`, and a line joined the nodes (`g52_linked`);
  - the menu opened from pane row 23 showed "Review pull requests" checked, and choosing it gave `[27]`;
  - with every objective done (planted, then restored), the menu held "No objectives yet" and Tern's Copy, and choosing the disabled row left the kv dump unchanged.

  The spec now says "the menu's only row of its own", because Tern adds Copy to every menu.
- [x] 5.3 Hit areas of 22 px for the done box, ⋯ and ▸/▾ (design P8).

  Verify (objectives-graph "Larger hit areas"): the shot layout JSON gives each of them a width of at least 22 px and the height of its line, objective nodes 48 px tall and rows 22 px tall. `ctl click` 9 px right of a done box's visible centre still marks the objective done.

  Result (shot `g53_hit`): 31 done boxes and 31 ⋯ at 22 × 18; 40 ▸/▾ at 22 × 22; objective nodes 48 tall, lines 18, rows 22. A click 9 px right of o1's box centre hit `.ob-check` and marked it done; it was then reopened.
- [x] 5.4 README: describe linking with the bar and the tab menu.

  Verify: the README's linking steps work as written when followed in the harness.

  Result: "Using the graph" now describes the "＋ Link" / "× Unlink" bar, the "Link to" menu on a tab's header or rows, and the origin outline (group 4's doc line). The steps are the ones exercised in 5.1 and 5.2.

## 6. Release and live check

- [x] 6.1 Set the version to `0.2.0` and refresh `docs/graph.png` from the harness, with rows open, an origin mark and a selection showing link bars.

  Verify:
  - plugin-package "Manifest": Local install check; an install of the repo folder against an isolated config prints `installed objectives 0.2.0`, and `tern plugin list` shows it ready;
  - plugin-package "README": README contents.

  Result:
  - the harness was reset to the demo layout (web: "App build", "Components"; api: "Server", "Benchmarks"; docs: "Guides") with the eight demo objectives; the load-test data is kept in `/tmp/tobj/kv.load-backup.json`;
  - `docs/graph.png` (1600 × 1452) was opened from the right-hand pane of "App build", with "Write release notes" selected;
  - an isolated `tern plugin install .` printed `installed objectives 0.2.0`, and `tern plugin list` showed `objectives 0.2.0 … 1 blocks, 0 lenses, window ready`;
  - the README holds the install command, ⌃⌘O, "Esc closes it too", the local-sessions limit, `plugin-data/objectives/`, the screenshot and the host half.
- [x] 6.2 Commit, push `main` and tag `v0.2.0`.

  Verify: `gh api repos/JakobMusik/tern-objectives/tags` lists `v0.2.0`.

  Result: release commit `bea2669`; the tags API lists `v0.2.0`, `v0.1.2`, `v0.1.1` and `v0.1.0`.
- [x] 6.3 **(live)** Run `tern plugin install github.com/JakobMusik/tern-objectives --force` in the user's live Tern.

  Verify: `tern plugin list` shows `objectives 0.2.0` ready.

  Result: `installed objectives 0.2.0`; `tern plugin list` shows `objectives 0.2.0 … 1 blocks, 0 lenses, window ready`, with the user's `tabnav 0.1.0` untouched.
- [x] 6.4 **(live)** The user checks in their window:
  - ⌃⌘O, then Esc after clicking inside;
  - rows open by default;
  - the origin marks;
  - linking by the bar and by the tab menu.

  Verify with the user; record the findings here.

  Result (user, 0.2.0): Esc works and the origin highlight works. One issue: the "＋ Link" / "× Unlink" text could be selected, so a press that drifted only selected and copied the text instead of clicking the bar. Fixed in 6.5.
- [x] 6.5 Make the link bar's text unselectable (`user-select: none`, Supported CSS), so a drifting press still counts as a click (tab-links "Linking from the graph": Press that drifts across the bar).

  Verify: in the harness, `ctl down`/`move`/`up` 40 px along a "＋ Link" bar, before and after the change; check the shot for a text highlight and the kv dump for the link.

  Result: before, the drag highlighted "+ Li" and linked nothing (shot `g65_drag_before`). After, the same drag selected nothing and linked o2 to tab 22 (`g65_drag_after`), and the same drag on "× Unlink" removed it again.
- [x] 6.6 Release `0.2.1`: set the version, commit, push `main`, tag `v0.2.1`, and run `tern plugin install github.com/JakobMusik/tern-objectives --force` in the user's live Tern.

  Verify: `gh api repos/JakobMusik/tern-objectives/tags` lists `v0.2.1`, and the live `tern plugin list` shows `objectives 0.2.1` ready.

  Result: release commit `66b1aa4`; the tags API lists `v0.2.1` first; an isolated install printed `installed objectives 0.2.1`; live `tern plugin list` shows `objectives 0.2.1 … 1 blocks, 0 lenses, window ready`, with `tabnav 0.1.0` untouched.

## Workflow follow-up

- Run the verify workflow against the specs before archiving.
- Archive the change so its deltas merge into `openspec/specs/`, then commit the archive.
- Stop the harness services.
