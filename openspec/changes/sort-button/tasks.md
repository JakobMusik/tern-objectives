# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness:** `/tmp/tobj/bin/{env.sh,serve,ctl,sync,op,kv,pump}` and the helper plugin `tobjh` are in place from quick-link-button.
  - Start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then run `ctl plugins fixtures`.
  - After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells).
  - Never source `/tmp/tobj/bin/env.sh` in a persistent shell, and never run `tern serve --help`, which serves.
- **Layout:** the README demo, rebuilt in a fresh serve as quick-link-button built it:
  - session docs: Guides (a shell) and Release notes (an omp pane);
  - session web: App build (panes app and tests) and Components (a shell and `todo.md`);
  - session api: Server (a shell and an omp pane) and Benchmarks (a shell).
- **Stores:** each check writes the objectives its scenario names into `/tmp/tobj/config/plugin-data/objectives/kv.json` (key `"state"`), with the `created` and `done_at` times it names, then closes and opens the graph again. Group 2 starts from the demo store saved in `/tmp/tobj/kv.demo-0250.json`, with its tab ids remapped if the rebuilt layout's differ.
- **Reading:**
  - `ctl tree '.ob-obj'` for the left column's order, classes and tooltips, and `ctl tree '.ob-head'` for the header;
  - `ctl click` for real hit-testing;
  - `ctl shot NAME` for a PNG and layout JSON;
  - kv dumps of `kv.json`;
  - the serve log, `/tmp/tobj/logs/tern-serve.log`, for render times and warnings.
- **After the checks:** stop the harness service, and remove the chat folders the checks created under `~/.omp/agent/sessions/`.

## 1. Sort methods and the sort button

- [ ] 1.1 The stored method and the orders (design D1, D2, D4, D5, D7):
  - `Settings.sort` in `lib/store.luau`, read by `normalize` with the fallback on `sort_priority`;
  - `Store.open_in_order` by method, and `Store.sort_done`, which replaces the view's `sort_done`;
  - the `setsort` verb with the three methods, and the hold recording done objectives too, in `lib/app.luau`;
  - the settings page's "Sort by" row and note.

  Verify:
  - plugin-settings "Sort method", every scenario, the sort button's label left to task 1.2. Write the 0.23.0 store without `sort_priority`, and the 0.26.0 store with `sort_priority: false`. Read the page in `ctl tree`, and the settings in a kv dump;
  - plugin-settings "New objective defaults", every scenario, by `ctl tree '.ob-obj'` and a kv dump;
  - objectives-graph "Sorted by priority" and "Sorting newest first", every scenario but "No grips", which task 1.2 checks. "Link choices sorted too" and "Link choices newest first too" use shots of the picker, run as `plugin.objectives.link_tab`, and of a tab node's right-click menu. "Created in the same second" stores two equal `created` values;
  - objectives-graph "Done group order", every scenario, switching the method on the settings page;
  - objectives-graph "Sorting waits for another click", every scenario, "Done badges hold it too" among them. For "Refresh keeps the order", open a tab with the helper and wait 1.2 s for render lines in the log;
  - objectives-graph "Custom order", "Badge clicks don't move a node" and "New objective on top".
- [ ] 1.2 The header button, grips and look (design D3, D6, D8):
  - the button in `View.build`'s header, after the search control;
  - `Sorting` as `{ by, lifted }` in `objective_node`: no grip newest first;
  - `.ob-sortbtn` in `styles.css`;
  - README:
    - the order paragraph: the three methods, the header button, the Done group following them, and no grips newest first;
    - the "Organize" bullet: the sort button;
    - the Configure "Order" bullet: "Sort by" with its three choices.

  Verify:
  - objectives-graph "Sort button", every scenario, each click with `ctl click` on `.ob-sortbtn`. Read the label and tooltip in `ctl tree '.ob-head'` and the order in `ctl tree '.ob-obj'`. For "Drag across the sort button", use `ctl down`/`move`/`up` across it and a shot;
  - plugin-settings "Sort method": the button reads "Priority" with the 0.23.0 store, "Your order" with the 0.26.0 store whose sorting was off, and "Newest" after Newest first is picked on the page;
  - the button in review mode: it shows, and a click changes its label only;
  - objectives-graph "Moving objectives", every scenario, "Switching the sort ends a move" among them, sorted in Your order; and "No grips" newest first, with no `.ob-grip` in `ctl tree`;
  - objectives-graph "Moving while sorted", both scenarios;
  - the icon (design risk): a crop of the button in light and dark (`ctl appearance`). Record whether `swap` stayed or `list` replaced it;
  - the header width (design risk): at 460 px wide, a shot of the wrapped header, and "Link lines" "Alignment at two widths": every line end within 2 px of its node and tab header centres at 1400 and 460 px wide, read from the layout JSON;
  - the README paragraphs, read back;
  - render times in the serve log stay within the 20 ms target, with no objectives warnings or errors.

## 2. The README screenshots

- [ ] 2.1 Take `docs/graph.png` and `docs/review.png` again, from the store saved in `/tmp/tobj/kv.demo-0250.json`, sorted by priority, so the header shows the sort button reading "Priority":
  - **`graph.png`:**
    - Release notes' omp chat replies while Guides has focus, and Server's waits for input;
    - the same window size (`ctl resize 1045 928`) and crop (914 × 808);
    - opened from Guides, with nothing selected, the Done group open and the pointer off the graph.
  - **`review.png`:**
    - review mode with "Restyle the docs site" and "Profile slow search queries" due, and the latter selected;
    - opened from Guides, and cropped to the header, the two review nodes and the `Linked to` section, 1828 px wide.

  Update both alt texts to name the sort button. Show both drafts to the user before committing them.

  Verify:
  - plugin-package "README": "README contents" and "Graph screenshot first";
  - plugin-package "Screenshots match this version": open nodes show grips, and no node in either image shows ⋯;
  - both headers show the sort button reading "Priority", right after the Search button;
  - every line end in both shots sits within 2 px of its node and tab header centres, read from the layout JSON;
  - the user approved both drafts.

## 3. Release 0.27.0

- [ ] 3.1 Version `0.27.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.27.0`. Tick this box, then commit, push `main` and tag `v0.27.0` (annotated, message "objectives 0.27.0").
- [ ] 3.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.27.0 … ready`, with the other plugins untouched.
- [ ] 3.3 **(live)** With the user:
  - the graph's header shows the sort button after the Search button, reading "Priority" (or "Your order" if "Sort by priority" was off);
  - each click moves to the next method, Priority → Newest → Your order, and re-sorts the open objectives and the open Done group at once; newest first, the nodes have no grip;
  - the settings page's "Sort by" row shows the same method.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive sort-button --yes`), run `openspec validate --specs --strict`, commit and push.
