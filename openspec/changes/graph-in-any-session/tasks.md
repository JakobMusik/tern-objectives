# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**. "Forced remote" means the fixtures copy with the local check in `lib/surface.luau` inverted, never the repo. "kv dump" reads `/tmp/tobj/config/plugin-data/objectives/kv.json`.

## 1. Graph in any session

- [x] 1.1 `lib/surface.luau` handles both surfaces (design G1, G2, G5): the block in local sessions, a canvas glimpse elsewhere, replacing a graph on the wrong surface; `App.open` drops its local-only toast; the load timer stops closing canvases.

  Verify:
  - local: ⌃⌘O twice shows, then closes, the block (helper dump);
  - forced remote: ⌃⌘O twice shows a canvas owned by `objectives` with focus, then none;
  - a canvas left in a local session (forced remote, then the real check) is replaced by the block on the next fresh open.

  Result (helper dump):
  - local: block pane 18 with focus and view files, then none;
  - forced remote: canvas pane 19 owned by `objectives`, focused, with no view files written (shot `r11_canvas`), then none;
  - leftover canvas: pane 22 survived the switch to the real check and was adopted; the first ⌃⌘O closed it, and the second opened block pane 23.

  The canvas first drew in the terminal face, so `.ob-root` now sets `var(--sans)` (design G6).
- [x] 1.2 `canvas_action` handler next to the link route (design G3).

  Verify, forced remote: a click on an objective's title gives it `ob-sel`; a "＋ Link" bar click and a tab menu row add links (kv dump); a pane-row click jumps and leaves no graph.

  Result: o2 got `ob-sel`; its bar on tab 12 gave `[9, 12]` with o2 still selected; the "Benchmarks" menu's "Review pull requests" row gave o5 `[17, 14]`; a click on pane row 13 showed session api with pane 13 focused and no canvas left.
- [x] 1.3 Style scope `:is(…)` for both surfaces (design G4).

  Verify: in forced-remote and local shots the graph looks the same; `edgecheck.py` passes on both; the canvas's hit areas measure as on the block.

  Result:
  - shots `s13_canvas` and `s13_block` match;
  - hit areas are identical: done box and ⋯ 22 × 18, ▸/▾ 22 × 22, nodes 48, rows 22;
  - edgecheck first failed on both, with the origin ring's outer shadow read as a line end in the gap. With the ring inset (design G6), both pass, with 7 objective ends and 5 tab ends.
- [x] 1.4 README: sessions on other machines open the graph with nothing installed there; Esc there closes it only after a click on the title bar; the old local-only limit goes.

  Verify: the README holds both points and no "only in sessions on this machine".

  Result: Install says nothing is needed on the machines sessions run on, and that a session on another machine gets Tern's canvas panel; Known limits gives the Esc behaviour there. The local-only line is gone.

## 2. Release and live check

- [x] 2.1 Version `0.3.0`: an isolated install prints `installed objectives 0.3.0`; commit, push `main`, tag `v0.3.0`; `tern plugin install github.com/JakobMusik/tern-objectives --force` live.

  Verify: the tags API lists `v0.3.0`, and live `tern plugin list` shows `objectives 0.3.0` ready.

  Result: an isolated install printed `installed objectives 0.3.0`; release commit `d7053fc`; the tags API lists `v0.3.0` first; live `tern plugin list` shows `objectives 0.3.0 … 1 blocks, 0 lenses, window ready`, with `tabnav 0.1.0` untouched.
- [ ] 2.2 **(live)** In the user's "devbox" session: ⌃⌘O opens the graph, devbox's tabs are listed, a click links and a pane row jumps, and ⌃⌘O closes it.


  Smoke test (agent, live window, 0.3.0): `tern ctl session switch devbox` then ⌃⌘O focused a new pane labelled "Objectives".
  - Its element tree held one `.ob-root` on the `plugin.tern.canvas` surface and none on the block.
  - The tab column listed all six sessions with "devbox ● current", and devbox's tab "demo" carried the origin ring.
  - A second ⌃⌘O closed it and returned focus to "demo"; the window then went back to "plugins".

  Clicks, jumps and the redraw after a reload (design R5) are left for the user.
  Verify with the user; record the findings here.

## Workflow follow-up

- Run the verify workflow, then archive the change into `openspec/specs/` and commit.
- Stop the harness services.
