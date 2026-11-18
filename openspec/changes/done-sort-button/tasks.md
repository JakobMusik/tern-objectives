# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness:** `/tmp/tobj/bin/{env.sh,serve,ctl,sync,op,kv,pump}` and the helper plugin `tobjh` are in place from select-tab-nodes.
  - Start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then run `ctl plugins fixtures`.
  - After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells).
  - Never source `/tmp/tobj/bin/env.sh` in a persistent shell, and never run `tern serve --help`, which serves.
- **Layout:** the README demo, rebuilt in a fresh serve as select-tab-nodes built it:
  - session docs: Guides (a shell) and Release notes (an omp pane);
  - session web: App build (panes app and tests) and Components (a shell and `todo.md`);
  - session api: Server (a shell and an omp pane) and Benchmarks (a shell).
- **Stores:** each check writes the objectives its scenario names into `/tmp/tobj/config/plugin-data/objectives/kv.json` (key `"state"`), with the `created`, `done_at` and review dates it names, counted from today, then closes and opens the graph again. A "0.28.2 store" has `settings` without `done_sort`. Group 2 starts from the demo store in `/tmp/tobj/kv.demo-0270.json`, with its dates counted from today.
- **Reading:**
  - `ctl tree '.ob-obj'` for the left column's order, `ctl tree '.ob-donegrp'` for the Done row, and `ctl tree '.ob-head'` for the header;
  - `ctl click` for real hit-testing;
  - `ctl shot NAME` for a PNG and layout JSON;
  - kv dumps of `kv.json`;
  - the serve log, `/tmp/tobj/logs/tern-serve.log`, for render times and warnings.
- **After the checks:** stop the harness service, and remove the chat folders the checks created under `~/.omp/agent/sessions/`.

## 1. The Done group's own sort method and button

- [ ] 1.1 The stored method, the order and the settings row (design D1, D2, D4, D6):
  - `Settings.done_sort` in `lib/store.luau`, read by `normalize` with the fallback on `sort`, and `"priority"` in `default_settings`;
  - `Store.sort_done` by `done_sort`;
  - the `setdsort` verb with the four methods, and the hold starting when either method is by priority, in `lib/app.luau`;
  - the settings page's "Sort Done by" row and the "Order" note in `lib/view.luau`.

  Verify:
  - plugin-settings "Done group sort method", every scenario, the Done group's button left to task 1.2. Write 0.28.2 stores with `sort` "own" and "created". Read the page in `ctl tree`, and the settings in a kv dump. For "Survives a reload", run `ctl plugins fixtures`;
  - plugin-settings "Sort method", "Picked and saved": the kv dump's settings hold `sort` and `done_sort` next to the starting priority and place;
  - objectives-graph "Done group sorting", every scenario, switching the method on the settings page and reading the open Done group in `ctl tree '.ob-obj'`. For "Review mode keeps its order", click "Review (2)";
  - objectives-graph "Sorting waits for another click", "Badge clicks hold the order", "Another click sorts", "Done badges hold it too" and "Only the Done group by priority";
  - a store with `done_sort` "oldest" reads as the copy of `sort`, and `setdsort=oldest`, sent with `ctl` as a canvas action, writes nothing;
  - the settings page at `ctl resize 460 900`: a shot of the "Order" section with its four segments.
- [ ] 1.2 The Done row's button, its style and the README (design D3, D5):
  - the button in the open Done group's row in `View.build`, with `DSORTS`;
  - `.ob-dsortbtn` in `styles.css`;
  - README:
    - the "Organize" bullet: the Done group's own sort button;
    - the order paragraph: the header's button sorts the open objectives, and the Done group's button and its four methods;
    - the Configure "Order" bullet: "Sort Done by" with its four choices.

  Verify:
  - objectives-graph "Done group sort button", every scenario, each click with `ctl click` on `.ob-dsortbtn`. Read the label and tooltip in `ctl tree '.ob-donegrp'`, and the order in `ctl tree '.ob-obj'`;
  - objectives-graph "Sort button", "Each click moves on" and "Done group keeps its order";
  - objectives-graph "Done objectives group", both scenarios, and a click on the row's text still closing the group;
  - plugin-settings "Done group sort method": the button reads "Recently done" with the 0.28.2 store whose `sort` is "own", and "Next review" after Next review is picked on the page;
  - the row's height (design risk): 24 px in the layout JSON, with the button 18 px tall inside it, open and closed;
  - the button's look: crops of the row in light and dark (`ctl appearance`), and at `ctl resize 460 900`, recording what of the label shows;
  - "Link lines" "Alignment at two widths": with a done objective selected, every line end within 2 px of its node and tab header centres at 1400 and 460 px wide, read from the layout JSON;
  - the README paragraphs, read back;
  - render times in the serve log stay within the 20 ms target, with no objectives warnings or errors.

## 2. The README screenshot

- [ ] 2.1 Take `docs/graph.png` again, as select-tab-nodes 7.1 took it (`ctl resize 1045 1060`, the same crop), from the demo store with both methods by priority, so the open Done group's row ends in the button reading "Priority". Update its alt text to name the button. `docs/review.png` shows review mode, which has no Done group, and stays. Show the draft to the user before committing it.

  Verify:
  - plugin-package "README": "README contents" and "Graph screenshot first";
  - plugin-package "Screenshots match this version": open nodes show grips, and no node in either image shows ⋯;
  - the Done row ends in "⇅ Priority", and the header still shows its sort button after the Search button;
  - every line end in the shot sits within 2 px of its node and tab header centres, read from the layout JSON;
  - the user approved the draft.

## 3. Release 0.29.0

- [ ] 3.1 Version `0.29.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.29.0`. Tick this box, then commit, push `main` and tag `v0.29.0` (annotated, message "objectives 0.29.0").
- [ ] 3.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.29.0 … ready`, with the other plugins untouched.
- [ ] 3.3 **(live)** With the user:
  - the Done group lists the same order as before the upgrade, and, while open, its row ends in a sort button showing that method;
  - each click moves to the next method, Recently done → Priority → Newest → Next review, and re-sorts only the Done group;
  - the header's sort button re-sorts only the open objectives;
  - the settings page's "Sort Done by" row shows the Done group's method.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive done-sort-button --yes`), run `openspec validate --specs --strict`, commit and push.
