# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:**
  - Start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then run `ctl plugins fixtures`.
  - After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells).
  - Never source `/tmp/tobj/bin/env.sh` in a persistent shell.
- **Layout and store:** tabs "Server" (two panes, so moving one leaves the tab open), "Benchmarks" and "Guides". The store holds open "Fix login bug" → Server and Benchmarks, "Speed up search" → Server, and "Write slides" → Guides. It also holds done "Set up CI" → Server, and a tab no objective links. The store goes in through `/tmp/tobj/config/plugin-data/objectives/kv.json` (key `"state"`), then the graph is closed and opened again.
- **Reading:**
  - `ctl tree '.ob-obj'` for node classes (`ob-sel`, `ob-lit`, `ob-acts-on`);
  - `ctl tree '.ob-e'` for the line layers (`ob-e-dim` on the faded one);
  - `ctl shot NAME` for a PNG and layout JSON;
  - the helper's `focus` and `move_to_tab` ops to set the origin and move it.
- **After the checks:** stop the harness service.

## 1. Selection on a fresh open

- [ ] 1.1 `M.open` clears `selected` on a fresh open (design D1), with the comment above `selected` saying so. The README's "Click an objective to select it" paragraph says each open starts with nothing selected.

  Verify with `ctl key`, `ctl click` and `ctl tree`, opening from the tab no objective links:
  - objectives-graph "Selection on a fresh open": "Closed and opened again" (no `ob-sel`, no `.ob-acts`, the ⌥⇧R toast), "Kept after a picker" (the Note field with a click into it), "Review mode kept" and "New objective by key";
  - "Origin highlight" "Kept after a picker" still holds;
  - the README paragraph, read back.

## 2. The origin tab's links

- [ ] 2.1 The focus tab, strong lines and tinted nodes (design D2–D4):
  - the origin lookup moved up, the focus tab and `ob-lit` in `lib/view.luau`;
  - `strong` in `lib/edges.luau`;
  - `.ob-obj.ob-lit` before the attention rules in `styles.css`.

  The README paragraph says that with nothing selected, the lines of the tab the graph was opened from stand out and the objectives they lead to are tinted.

  Verify with `ctl tree`, `move_to_tab` and shots:
  - objectives-graph "Origin tab's links":
    - "Opened from a linked tab": `ob-lit` on exactly the two nodes, `ob-e-dim` on the 1.5 px layer, and in the shot a thick line drawn over a faded one where they cross;
    - "Selecting takes over", "Clearing brings it back", "Origin tab unlinked", "Origin pane moves", "Done objectives" and "Review mode";
    - "Highlighted and marked", with the omp chat in "Server" asked a yes/no question through the helper's `ask` op;
    - "Node size unchanged", from the shot's layout data;
  - "Selection" "Select and clear", opened from the unlinked tab;
  - "Link lines" "Done objective selected" and "Done objective not selected" unchanged;
  - "Light and dark themes": shots under `ctl appearance light` and `ctl appearance dark` of a tinted node beside a selected one (select it, clear, then compare) and beside a plain card: the tint reads as different from the selection ring and from a plain card in both;
  - render times in `/tmp/tobj/logs/tern-serve.log`, with no objectives warnings or errors;
  - the README paragraph, read back.

## 3. The README screenshot

- [ ] 3.1 Take `docs/graph.png` again (design D5), as 0.17.0 took it:
  - the demo layout and `/tmp/tobj/kv.readme-0170.json`, its dates moved so the chips read as in the current image;
  - the same window size and crop;
  - opened from "Guides", with nothing selected and the Done group open.

  Update its alt text to name the tinted "Read about rate limiting" and its thick line to Guides. Show the draft to the user before committing it.

  Verify:
  - plugin-package "Screenshots match this version": open nodes show grips, and no node shows ⋯;
  - "Graph screenshot first": the README's first image is still `docs/graph.png`;
  - every line end sits within 2 px of its node and tab-header centres, checked as custom-order-and-direct-controls task 3.1 did: shot pixels at the gap column's edges against the layout rects (`edgecheck.py` is gone);
  - the user approved the draft.

## 4. Release 0.22.0

- [ ] 4.1 Version `0.22.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.22.0`. Tick this box, then commit, push `main` and tag `v0.22.0` (annotated, message "objectives 0.22.0").
- [ ] 4.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.22.0 … ready`, with the other plugins untouched.
- [ ] 4.3 **(live)** With the user:
  - opening the graph from a tab that open objectives link draws that tab's lines thick, fades the others, and tints those objectives;
  - selecting an objective replaces that, and clicking empty space brings it back;
  - an objective selected when the graph closed is no longer selected when it opens again, while review mode, if it was on, still is.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive highlight-origin-tab-links --yes`), run `openspec validate --specs --strict`, commit and push.
