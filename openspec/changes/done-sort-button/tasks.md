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

- [x] 1.1 The stored method, the order and the settings row (design D1, D2, D4, D6):
  - `Settings.done_sort` in `lib/store.luau`, read by `normalize` with the fallback on `sort`, and `"priority"` in `default_settings`;
  - `Store.sort_done` by `done_sort`;
  - the `setdsort` verb with the four methods, and the hold starting when either method is by priority, in `lib/app.luau`;
  - the settings page's "Sort Done by" row and the "Order" note in `lib/view.luau`.

  Verify:
  - plugin-settings "Done group sort method", every scenario, the Done group's button left to task 1.2. Write 0.28.2 stores with `sort` "own" and "created". Read the page in `ctl tree`, and the settings in a kv dump. For "Survives a reload", run `ctl plugins fixtures`;
  - plugin-settings "Sort method", "Picked and saved": the kv dump's settings hold `sort` and `done_sort` next to the starting priority and place;
  - objectives-graph "Done group sorting", every scenario, switching the method on the settings page and reading the open Done group in `ctl tree '.ob-obj'`. For "Review mode keeps its order", click "Review (2)";
  - objectives-graph "Sorting waits for another click", "Badge clicks hold the order", "Another click sorts", "Done badges hold it too" and "Only the Done group by priority";
  - a store with `done_sort` "oldest" reads as the copy of `sort`;
  - the settings page at `ctl resize 460 900`: a shot of the "Order" section with its four segments.

  Result (harness, 2026-11-18, Tern 0.9.21). A fresh serve in `/tmp/tobj/w/demo/guides` rebuilt the README demo with the same ids as before: docs (Guides 3, pane 2; Release notes 5, omp pane 4), web (App build 8, panes 7 and 9; Components 12, pane 11 and `todo.md` pane 20) and api (Server 15, pane 14 and omp pane 16; Benchmarks 19, pane 18). Both plugins loaded with no errors. The done objectives were "Set up CI", "Read docs" and "Tidy the backlog" with the scenario's dates; today was 11-18.
  - **"Done group sort method":**
    - **Read from Your order:** with a 0.28.2 store holding `sort` "own", the page had Your order and Recently done selected.
    - **Read from another method:** with `sort` "created", both rows had Newest first selected.
    - **Picked and saved:** from a store sorted by priority, a click on Next review selected it, and "Sort by" still had Priority. The kv dump's settings read `{"done_sort": "review", "new_place": "top", "sort": "priority", "start_priority": 3}`, which also covers "Sort method", "Picked and saved".
    - **Survives a reload:** after Newest first for "Sort Done by" and `ctl plugins fixtures`, the page still had it selected, and the Done group read "Tidy the backlog", "Set up CI", "Read docs".
  - **"Done group sorting":** picking each method on the page gave:
    - Recently done: "Read docs", "Tidy the backlog", "Set up CI";
    - Priority: "Set up CI", "Read docs", "Tidy the backlog";
    - Newest first: "Tidy the backlog", "Set up CI", "Read docs";
    - Next review: "Read docs", "Set up CI", "Tidy the backlog".

    "Next reviews on the same day", with both reviews on 11-20, listed "Tidy the backlog" right before "Set up CI". "Apart from the open objectives", sorted newest first and by priority: the open list read "Write slides", "Review pull requests", "Fix login bug", and the Done group "Set up CI" first. "Review mode keeps its order": the Done group, newest first, read "Set up CI", "Read docs"; after "Review (2)", review mode listed "Read docs", then "Set up CI", and no Done row showed.
  - **"Sorting waits for another click":**
    - **Badge clicks hold the order:** "Write slides" stayed third, P2 then P1, and the kv dump held 1;
    - **Another click sorts:** "Fix login bug", "Write slides", "Review pull requests";
    - **Done badges hold it too** (both lists by priority): "Read docs" stayed second, at P2, P1, then P0; after a click on empty space, the Done group read "Read docs", "Set up CI";
    - **Only the Done group by priority** (the open list newest first): the same, with the open list unchanged.
  - **An invalid method:** a store with `sort` "own" and `done_sort` "oldest" showed "Recently done" on the button and the page. `ctl` has no command that sends an arbitrary canvas action, so the verb's guard against `setdsort=oldest` was not run; every value the button and the page send is one of the four.
  - **At 460 px:** the first draw ran the four segments past the page (crop `ds_settings_460_crop`): "Next review" was cut, and the label read "Sort Don…". The row now wraps (design D6): at 460 px it is 44 px tall, with "Sort Done by" on the first line and the four segments under it, at the right, ending at the page's inner edge (x 406.7). At 1400 px it is one line, 32 px tall. The note, shortened (D6), fits on one line at 1400 px (crop `ds_settings_1400b_crop`).
- [x] 1.2 The Done row's button, its style and the README (design D3, D5):
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

  Result (harness, 2026-11-18, the same serve as 1.1):
  - **"Done group sort button":**
    - **Shown while open:** with a 0.28.2 store sorted by priority and the group closed, the row read "▸Done (3)" with no button. After a click on "Done (3)", it read "▾Done (3)" and ended in the button "Priority", tooltip "Sorted by priority · click to sort newest first".
    - **Each click moves on** and **Tooltips:** from "Recently done", four clicks read "Priority", "Newest", "Next review" and "Recently done", with the scenario's four orders and tooltips. The group stayed open after each click (`done_open` true), so the button's click ran instead of the row's.
    - **Open objectives keep their order:** with the header reading "Your order", a click on the Done group's button left "Fix login bug", "Review pull requests", "Write slides", and the header still read "Your order".
    - **Selection kept:** with "Read docs" selected, a click left it selected with its action bar, the group open.
    - **Same method on the settings page:** after clicks up to "Next review", ⚙ showed Next review for "Sort Done by", "Sort by" still Your order, and the kv dump held `sort` "own" and `done_sort` "review".
  - **"Sort button":** from "Priority", three clicks read "Newest", "Your order" and "Priority", with the scenario's orders. Through all of them the Done group read "Read docs", "Tidy the backlog", "Set up CI", and its button "Recently done".
  - **"Done objectives group":** with the demo store, marking "Update dependencies" done moved it into the group, "Done (3)" became "Done (4)", the kv dump held it done, and its line was gone (7 left line ends before, 6 after, `o5` no longer among them). A click on "Set up CI"'s box left the count at 4 and the record done, and its action bar showed Keep review, Reset review and Cancel. A click on "Done (4)" closed the group, with no button; another opened it again.
  - **"Done group sort method", the button:** "Recently done" with the 0.28.2 store whose `sort` is "own", and "Next review" after Next review was picked on the page (task 1.1).
  - **Row height:** the row was 24 px tall, open and closed, at both widths; the button was 18 px tall, 3 px from the row's top and bottom.
  - **Look:** at 1400 px the button sits at the row's right end, the upright arrows then the label (crop `ds_row_1400`), 106.9 px wide for "Recently done" and 94.5 px for "Next review". In dark (crop `ds_row_dark`) it follows the quiet button's colours. At 460 px the row is 116.8 px wide, "Done (3)" keeps its 43.6 px, and the button shrinks to 55.8 px: the icon stays and the label reads "Pri…" or "Re…" (crops `ds_row_460`, `ds_row_460_recent`).
  - **Line ends:** with the demo store and "Set up CI" selected, at `ctl resize 1400 1400` and `ctl resize 460 1400`, all 8 left and 6 right line ends sat within 0.05 px of their objective node and tab header centres. At 900 px high, the glimpse's footer covered the gap's bottom and added marks there, so the window was made taller.
  - **README:** read back. "Organize" says the open Done group has its own sort button. The order paragraph says each click of the header's button moves to the next, then describes the Done group's button at the right of its row and its four methods. The Configure "Order" bullet names "Sort Done by" with its four choices, and that it starts out as "Sort by" was.
  - **Log:** 532 renders since the serve started, the longest 17.4 ms, and no objectives warnings or errors.

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
