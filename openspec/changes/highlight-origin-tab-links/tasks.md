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

- [x] 1.1 `M.open` clears `selected` on a fresh open (design D1), with the comment above `selected` saying so. The README's "Click an objective to select it" paragraph says each open starts with nothing selected.

  Verify with `ctl key`, `ctl click` and `ctl tree`, opening from the tab no objective links:
  - objectives-graph "Selection on a fresh open": "Closed and opened again" (no `ob-sel`, no `.ob-acts`, the ⌥⇧R toast), "Kept after a picker" (the Note field with a click into it), "Review mode kept" and "New objective by key";
  - "Origin highlight" "Kept after a picker" still holds;
  - the README paragraph, read back.

  Result (harness, today 2026-11-09). One session, tabs 3 "Scratch" (pane 2, linked to nothing, focused), 5 "Server" (panes 4 and 10), 7 "Benchmarks" (pane 6) and 9 "Guides" (pane 8). The store held:
  - open o1 "Fix login bug" → Server and Benchmarks, o2 "Speed up search" → Server, o3 "Write slides" → Guides;
  - done o4 "Set up CI" → Server (review in 11d), o5 "Profile slow queries" → Benchmarks and o6 "Restyle the docs site", both due.

  The graph was opened from Scratch each time.
  - **Closed and opened again:** o1 selected had `ob-sel ob-acts-on` and one `.ob-acts`. After ⌃⌘O twice, no node had `ob-sel`, no `.ob-acts` showed, and ⌥⇧R gave the info toast "Select an objective in the graph to rename it" with no field.
  - **Kept after a picker:** with o1 selected, Note opened the field. A click into it closed the glimpse. "check the logs" and Enter showed the graph again with o1 `ob-sel ob-acts-on` and its bar, and the kv dump held the note.
  - **Review mode kept:** "Review (2)" listed o5 and o6. With o5 selected, ⌃⌘O twice showed both still listed, neither selected, and "Review (2)" still `ob-on`.
  - **New objective by key:** with o1 selected, ⌃⌘O closed the graph and focus went back to pane 2. ⌥N opened the graph with the title field. "Write slides" and Enter selected the new o7, and o1 was not selected.
  - **Origin highlight "Kept after a picker":** "＋ New objective", a click into the field, "Plan the demo" and Enter showed the graph again with Scratch's node `ob-origin` and pane 2's row `ob-row-origin`, the same as before. After the Note field too.
  - **README:** the paragraph now ends "Each time you open the graph, nothing is selected."
  - **Log:** 13 renders, the longest 5.3 ms, and no objectives warnings or errors.

## 2. The origin tab's links

- [x] 2.1 The focus tab, strong lines and tinted nodes (design D2–D4):
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

  Result (harness, today 2026-11-09). Layout and store as in 1.1, saved in `/tmp/tobj/kv.hl.json`. "Server" holds pane 4 and, for the marked check, pane 10.
  - **Opened from a linked tab:** opened from pane 4 in Server:
    - o1 and o2 had `ob-lit`, and o3–o6 didn't;
    - the layers were `ob-e-all ob-e-dim`, then `ob-e-sel`;
    - no node had `ob-sel`, no `.ob-acts` and no `.ob-linkbar` showed;
    - shot `hl_open`: the tinted o1 and o2 have thick red and blue lines to Server, and the lines o1 → Benchmarks and o3 → Guides are faded. Zoomed in, the thick blue o2 → Server line runs over the faded pink o1 → Benchmarks line where they cross (`/tmp/tobj/shots/hl_cross.png`).
  - **Done objectives:** done o4 → Server had no `ob-lit` in any open from Server, and no green line shows in `hl_open`.
  - **Selecting takes over:** a click on o3 left only its line to Guides thick and every other line faded (`hl_sel`). o1 and o2 lost `ob-lit`, and Guides moved under `Linked to “Write slides”`.
  - **Clearing brings it back:** a click in empty graph space brought back `ob-lit` on o1 and o2 and the same layers. Shot `hl_clear` is pixel for pixel `hl_open`.
  - **Origin tab unlinked:** opened from Scratch, no node had `ob-lit` and the only layer was `ob-e-all`, with no `ob-e-dim`.
  - **Selection "Select and clear":** from Scratch, o1 selected gave its bar, `ob-e-dim` plus `ob-e-sel`, and 4 link bars. Empty space then left no bar, no link bar and only `ob-e-all`.
  - **Origin pane moves:** opened from pane 4, then `move_to_tab` 4 → Guides. Within 1.2 s:
    - the ring and pane 4's row mark moved to Guides;
    - o3 had `ob-lit` and o1 and o2 didn't;
    - shot `hl_moved` shows o3's grey line thick and the lines to Server faded.

    Pane 4 went back to Server afterwards.
  - **Review mode:** opened from Server, "Review (2)" listed o5 and o6 with no `ob-lit` and no line layer. Selecting o5 drew only its strong layer. Leaving review mode kept o5 selected, so no node was tinted.
  - **Link lines, done objective:** from Scratch, done o5 selected (→ Benchmarks, live) drew `ob-e-dim` plus `ob-e-sel`, and empty space left only `ob-e-all`. There was no closed tab in this run; the dashed path is unchanged code.
  - **Highlighted and marked:**
    - `omp` in pane 10 was asked through the `ask` op to put a yes/no question, and went `waiting_input` within 3 s;
    - opened from Server, o1 and o2 had `ob-lit ob-att-wait` and "needs you";
    - shot `hl_marked` shows both with the amber ring on the tint, and done o4 with "needs you" and no tint.

    Pane 10 was closed afterwards, and this run's chat folder `~/.omp/agent/sessions/--private-tmp-tobj-w-extra--` removed.
  - **Node size unchanged:** in `hl_marked`'s layout data, o1–o6 are all 48 px tall, tinted or not.
  - **Light and dark:** in light, the tinted nodes read grey-teal with an accent border. In dark, they read dark blue with a blue border. In both, a selected o3 is a plain card with the outer ring and its bar, and o3 unselected is a plain card. All three look different (`/tmp/tobj/shots/hl_themes.png`, from `hl_light_*` and `hl_dark_*`).
  - **README:** the paragraph now ends "While nothing is selected, the lines of the tab you opened the graph from stand out instead, and the objectives they lead to are tinted."
  - **Log:** since the serve started, 48 renders, the longest 7.0 ms, and no objectives warnings or errors.

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
