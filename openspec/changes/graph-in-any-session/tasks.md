# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**. "Forced remote" (groups 1–2 only) means the fixtures copy with the local check in `lib/surface.luau` inverted, never the repo. "kv dump" reads `/tmp/tobj/config/plugin-data/objectives/kv.json`.

Groups 1–2 shipped 0.3.0 with two surfaces (design "History"); groups 3–4 move every session to the canvas.

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

  Smoke test (agent, live window, 0.3.0): `tern ctl session switch devbox` then ⌃⌘O focused a new pane labelled "Objectives".
  - Its element tree held one `.ob-root` on the `plugin.tern.canvas` surface and none on the block.
  - The tab column listed all six sessions with "devbox ● current", and devbox's tab "demo" carried the origin ring.
  - A second ⌃⌘O closed it and returned focus to "demo"; the window then went back to "plugins".

  The user's check moved to 4.2 when every session moved to the canvas.

## 3. Canvas in every session

- [x] 3.1 `lib/surface.luau` handles only the canvas and closes a 0.3.0 block on its first lookup (design G1, G2, G5); `canvas_action` is the only click path, and the link route, `App.link`, `host.luau` and the manifest's host entry and block go (G3).

  Verify:
  - ⌃⌘O twice: a canvas owned by `objectives` with focus and only `kv.json` in the data folder, then none (helper dump);
  - a click on an objective's title gives it `ob-sel`; a "＋ Link" bar click and a tab menu row add links (kv dump); a pane-row click jumps and leaves no graph;
  - a 0.3.0 block open while the fixtures reload as the new code is gone after the next ⌃⌘O, which shows the canvas, and its view files are removed.

  Result:
  - leftover block: 0.3.0 opened block pane 31 with its view files. After the reload as the new code, both survived until ⌃⌘O, which closed the block, removed the files and opened canvas 32 with focus. The second ⌃⌘O closed it, and focus went back to pane 13. With the sweep disabled in the fixtures copy, pane 31 and the files outlived the reload, so the sweep is what removes them;
  - the data folder held only `kv.json` while canvases 32 and 33 were shown;
  - clicks on canvas 33: o3 got `ob-sel`; its bar on tab 14 gave `[12, 14]` with o3 still selected; the "Components" menu's "Review pull requests" row gave o5 `[17, 14, 9]`; a click on pane row 8 showed session web with pane 8 focused and no canvas left.
- [x] 3.2 Style scope `[data-surface='plugin.tern.canvas'] .ob-root` (design G4).

  Verify: the shot matches `s13_canvas`; `edgecheck.py` passes; hit areas measure 22 px as before.

  Result: shot `s32_canvas` matches `s13_canvas` (UI face, ring inset on "Components", the "ui" row bar); `edgecheck.py` passes with 7 objective ends and 5 tab ends; hit areas are unchanged (done box and ⋯ 22 × 18, ▸/▾ 22 × 22, nodes 48, rows 22). All 64 selectors use the canvas scope.
- [x] 3.3 README: one surface, nothing installed on other machines, the ways to close the graph; no host half, view files or "Esc closes it too".

  Verify: `grep` finds no "host half", "view-" or "Esc closes it too" in the README.

  Result: no matches. Install describes one window script drawing in Tern's canvas popup, with nothing needed on other machines; the commands table and Known limits give the ways to close the graph.

## 4. Release and live check

- [x] 4.1 Version `0.4.0`: an isolated install prints `installed objectives 0.4.0` and lists 0 blocks; commit, push `main`, tag `v0.4.0`; `tern plugin install github.com/JakobMusik/tern-objectives --force` live.

  Verify: the tags API lists `v0.4.0`, and live `tern plugin list` shows `objectives 0.4.0` ready.

  Result: an isolated install printed `installed objectives 0.4.0` and listed `0 blocks, 0 lenses, window ready`; release commit `cb975b7`; the tags API lists `v0.4.0` first; live `tern plugin list` shows `objectives 0.4.0 … 0 blocks, 0 lenses, window ready`, with `tabnav 0.1.0` untouched. The installed folder has no `host.luau`, and the live data folder holds only `kv.json`.
- [x] 4.2 **(live)** With the user: ⌃⌘O opens the graph as a canvas in a session on this Mac and in "devbox"; devbox's tabs are listed; a click links and a pane row jumps; ⌃⌘O closes it.

  Result (user, 0.4.0): "it works", and the lines stay after a plugin reload (design R5).

  Smoke test (agent, live window, 0.4.0, devbox): ⌃⌘O focused a new pane labelled "Objectives", one `.ob-root` on the canvas surface. The tab column listed all six sessions with "devbox ● current", and devbox's tab "demo" carried the origin ring. A second ⌃⌘O closed it and returned focus to "demo"; the window then went back to "plugins".

## Workflow follow-up

- Run the verify workflow, then archive the change into `openspec/specs/` and commit.
- Stop the harness services.
