# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness:** `/tmp/tobj/bin/{env.sh,serve,ctl,sync,op,kv,pump}` and the helper plugin `tobjh` are in place from sort-button.
  - Start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then run `ctl plugins fixtures`.
  - After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells).
  - Never source `/tmp/tobj/bin/env.sh` in a persistent shell, and never run `tern serve --help`, which serves.
- **Layout:** the README demo, rebuilt in a fresh serve as sort-button built it:
  - session docs: Guides (a shell) and Release notes (an omp pane);
  - session web: App build (panes app and tests) and Components (a shell and `todo.md`);
  - session api: Server (a shell and an omp pane) and Benchmarks (a shell).
  - A session "misc" with one shell tab, for the jump checks.
- **Stores:** each check writes the objectives its scenario names into `/tmp/tobj/config/plugin-data/objectives/kv.json` (key `"state"`), then closes and opens the graph again.
  - A closed tab is a snapshot under `tabs` with this window's key and no live tab. An other-window tab is a snapshot with another window's key.
  - Group 2 starts from the demo store saved in `/tmp/tobj/kv.demo-0270.json`, with its dates counted from the day of the shot and its tab ids remapped if the rebuilt layout's differ.
- **Reading:**
  - `ctl tree '.ob-tab'` and `ctl tree '.ob-obj'` for classes, tooltips and order;
  - `ctl click` for real hit-testing;
  - `ctl shot NAME` for a PNG and layout JSON;
  - `ctl state` for the shown session, tab and focus, and toasts;
  - kv dumps of `kv.json`;
  - the serve log, `/tmp/tobj/logs/tern-serve.log`, for render times and warnings.
- **After the checks:** stop the harness service, and remove the chat folders the checks created under `~/.omp/agent/sessions/`.

## 1. Selecting tabs

- [ ] 1.1 Selecting a tab and the jump arrow (design D1, D2, D6, D7):
  - `selected_tab` and the `tsel` verb in `lib/app.luau`, with `sel`, `reopen`, creating an objective, `bg` and a fresh open clearing it, and `build` taking `Built.selected_tab`;
  - in `View.build`, the listed objectives and the right column's tabs worked out before the left column, `kept_closed` taking the selected tab, and `Built.selected_tab`;
  - `tab_node`'s `ob-tsel` class, the header's and ghost rows' `tsel` clicks, and the jump arrow;
  - `.ob-tab.ob-tsel` and its combinations, and `.ob-tjump`, in `styles.css`.

  Verify:
  - objectives-graph "Selecting a tab", every scenario. Read the classes in `ctl tree '.ob-tab'` and `ctl tree '.ob-obj'`, focus and the shown session in `ctl state`, and take a shot for "Select and clear";
  - objectives-graph "Done objectives' closed tabs", every scenario, "Kept while selected" among them;
  - objectives-graph "Selection on a fresh open": "Closed and opened again", "Selected tab cleared" and "Selected tab kept after a field";
  - tab-navigation "Tab jump arrow", both scenarios, with the sizes and right edges read from the shot's layout JSON; "Jump to a tab", every scenario, from session "misc"; "Closed tabs don't jump" and "Other-window tabs don't jump", every scenario, with no toast in `ctl state`;
  - tab-navigation "Jump to a pane": "Second pane of a split" and "Row name doesn't jump" still hold;
  - agent-resume "Resume button on a closed tab", every scenario, with a saved omp chat from the Server tab's omp pane;
  - objectives-graph "Linked tabs section": "Linked tabs on top" and "Linked closed tab" still hold, since the right column's lists moved (design risk);
  - objectives-graph "Closing a tab from its node": "Asked in the header" and "Header clicked while asking" still hold;
  - the selected look in light and dark (`ctl appearance`), on a linked tab, an unlinked tab, the origin's tab, and a tab marked "needs you", from crops;
  - render times in the serve log stay within the 20 ms target, with no objectives warnings or errors.
- [ ] 1.2 What a selected tab shows (design D3, D4, D5):
  - the focus tab and `lit` following `sel_tab`, for every listed objective;
  - the done and review objectives' edges to the selected tab;
  - `quick_tab` following `sel_tab`, with a ghost's label from its snapshot;
  - README:
    - the intro line: a click on a tab shows its objectives, and its arrow or a pane's goes there;
    - the "Link tabs to objectives" bullet: the link icon links the selected tab, else the tab the graph was opened from;
    - the "Jump anywhere" bullet: the → on a tab's header or a pane's row;
    - the selection paragraph: clicking a tab selects it, what it shows, and that selecting one clears the other.

  Verify:
  - objectives-graph "Selected tab's links", every scenario. Take shots for "Open objectives" and the done and review lines, read the line ends from the layout JSON, and capture "Line ends at two widths" at 1400 and 460 px wide;
  - objectives-graph "Origin tab's links", every scenario, "Selecting a tab takes over" among them;
  - tab-links "Link button on objective nodes" and "Link button clicks", every scenario, the selected-tab ones among them, with `ctl move` for the pointer, shots for the buttons and kv dumps for the links;
  - the README paragraphs, read back;
  - render times in the serve log stay within the 20 ms target, with no objectives warnings or errors.

## 2. The README screenshots

- [ ] 2.1 Take `docs/graph.png` and `docs/review.png` again, as sort-button took them, since every live tab header now shows its arrow:
  - **`graph.png`:**
    - Release notes' omp chat replies while Guides has focus, and Server's waits for input;
    - the same window size (`ctl resize 1045 928`) and crop (914 × 808);
    - opened from Guides, with nothing selected, the Done group open and the pointer off the graph.
  - **`review.png`:**
    - review mode with "Restyle the docs site" and "Profile slow search queries" due, and the latter selected;
    - opened from Guides, and cropped to the header, the two review nodes and the `Linked to` section, 1828 px wide.

  Update both alt texts to name the arrows on live tab headers. Show both drafts to the user before committing them.

  Verify:
  - plugin-package "README": "README contents" and "Graph screenshot first";
  - plugin-package "Screenshots match this version": open nodes show grips, and no node in either image shows ⋯;
  - every live tab header in both shots ends in its arrow, and no closed tab's does;
  - every line end in both shots sits within 2 px of its node and tab header centres, read from the layout JSON;
  - the user approved both drafts.

## 3. Release 0.28.0

- [ ] 3.1 Version `0.28.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.28.0`. Tick this box, then commit, push `main` and tag `v0.28.0` (annotated, message "objectives 0.28.0").
- [ ] 3.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.28.0 … ready`, with the other plugins untouched.
- [ ] 3.3 **(live)** With the user:
  - clicking a tab's header keeps the graph open and selects the tab: thick lines to it, its objectives tinted, done ones too while the Done group is open;
  - the arrow at the right end of the header's second line goes to the tab;
  - while a tab is selected, an objective's link icon links or unlinks that tab.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive select-tab-nodes --yes`), run `openspec validate --specs --strict`, commit and push.
- In the same commit, update tab-navigation's Purpose, which still says a click on a tab's header takes the user there, to name the header's arrow.
