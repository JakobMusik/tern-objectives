# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**. "Forced remote" means the fixtures copy with the local check in `lib/surface.luau` inverted, never the repo. "kv dump" reads `/tmp/tobj/config/plugin-data/objectives/kv.json`.

## 1. Graph in any session

- [ ] 1.1 `lib/surface.luau` handles both surfaces (design G1, G2, G5): the block in local sessions, a canvas glimpse elsewhere, replacing a graph on the wrong surface; `App.open` drops its local-only toast; the load timer stops closing canvases.

  Verify:
  - local: ⌃⌘O twice shows, then closes, the block (helper dump);
  - forced remote: ⌃⌘O twice shows a canvas owned by `objectives` with focus, then none;
  - a canvas left in a local session (forced remote, then the real check) is replaced by the block on the next fresh open.
- [ ] 1.2 `canvas_action` handler next to the link route (design G3).

  Verify, forced remote: a click on an objective's title gives it `ob-sel`; a "＋ Link" bar click and a tab menu row add links (kv dump); a pane-row click jumps and leaves no graph.
- [ ] 1.3 Style scope `:is(…)` for both surfaces (design G4).

  Verify: in forced-remote and local shots the graph looks the same; `edgecheck.py` passes on both; the canvas's hit areas measure as on the block.
- [ ] 1.4 README: sessions on other machines open the graph with nothing installed there; Esc there closes it only after a click on the title bar; the old local-only limit goes.

  Verify: the README holds both points and no "only in sessions on this machine".

## 2. Release and live check

- [ ] 2.1 Version `0.3.0`: an isolated install prints `installed objectives 0.3.0`; commit, push `main`, tag `v0.3.0`; `tern plugin install github.com/JakobMusik/tern-objectives --force` live.

  Verify: the tags API lists `v0.3.0`, and live `tern plugin list` shows `objectives 0.3.0` ready.
- [ ] 2.2 **(live)** In the user's "devbox" session: ⌃⌘O opens the graph, devbox's tabs are listed, a click links and a pane row jumps, and ⌃⌘O closes it.

  Verify with the user; record the findings here.

## Workflow follow-up

- Run the verify workflow, then archive the change into `openspec/specs/` and commit.
- Stop the harness services.
