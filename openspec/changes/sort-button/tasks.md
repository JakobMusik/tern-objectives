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

- [x] 1.1 The stored method and the orders (design D1, D2, D4, D5, D7):
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

  Result (harness, 2026-11-18, Tern 0.9.21). A fresh serve in `/tmp/tobj/w/demo/guides` rebuilt the README demo with the same ids as before: docs (Guides 3, pane 2; Release notes 5, omp pane 4), web (App build 8, panes 7 and 9; Components 12, pane 11 and `todo.md` pane 20) and api (Server 15, pane 14 and omp pane 16; Benchmarks 19, pane 18). Both plugins loaded with no errors. Unless a check says otherwise, objectives were created on 2026-11-17 at the hours given.
  - **"Sort method":**
    - **Priority by default:** with the 0.23.0 store, the page showed "Shortcuts", "New objectives" and "Order", with P3, Top and Priority selected. The note reads "Priority keeps your order within each priority. The Done group follows this choice, and the sort button in the graph's header changes it too." The column read "Review pull requests" (P1), "Fix login bug", "Write slides".
    - **Turned off before this version:** with the 0.26.0 store holding `sort_priority: false`, the page had Your order selected, and the column was in the stored order.
    - **Picked and saved:** after a click on Newest first, it was selected, and the kv dump's settings read `{"new_place": "top", "sort": "created", "start_priority": 3}`, with no `sort_priority`.
    - **Survives a reload:** after Your order and `ctl plugins fixtures`, the page still had Your order selected, and the column showed the stored order.
  - **"New objective defaults":**
    - **Start at P1, at the bottom** (Your order): "Write slides" came last with a P1 badge; the kv dump held priority 1 for it and `start_priority` 1, `new_place` "bottom".
    - **Bottom of its priority:** "Release", "Write slides", "Fix login bug".
    - **First when sorted newest first:** "Write slides", "Release", "Fix login bug", with "Write slides" stored last. The first try gave "Release" the older time, against the scenario, so "Fix login bug" came second; it was run again with the scenario's data.
    - **Defaults survive a reload:** P1 and Bottom picked, then `ctl plugins fixtures`: the page still had both selected.
  - **"Sorted by priority":** "Sorted list" gave "Update dependencies", "Review pull requests", "Fix login bug", "Write slides", with the kv dump still o1–o4. "Link choices sorted too": stepping through the "Link this tab…" picker from App build read the same four in that order, and the right-click menu of App build's node (crop `sb_menu_prio_crop`) lists them under "Link to" in that order. "Your order chosen" gave "Fix login bug", "Review pull requests", "Write slides", "Update dependencies".
  - **"Sorting newest first":** "Newest on top" gave "Review pull requests", "Write slides", "Fix login bug", the kv dump still o1–o3; the picker and the menu (crop `sb_menu_new_crop`) list them the same way. "Created in the same second" listed "Fix login bug" right before "Write slides", and stored the other way round, "Write slides" before "Fix login bug".
  - **"Done group order":** with "Set up CI", "Read docs" and "Tidy the backlog" as in the scenario, the open Done group read "Read docs", "Tidy the backlog", "Set up CI" in Your order; "Set up CI", "Read docs", "Tidy the backlog" by priority; and "Tidy the backlog", "Set up CI", "Read docs" newest first.
  - **"Sorting waits for another click":** "Badge clicks hold the order": "Write slides" stayed third, P2 then P1, and the kv dump held 1. "Another click sorts": "Fix login bug", "Write slides", "Review pull requests". "Other badges hold it too": no node moved and "Review pull requests" read P1; then "Fix login bug", "Review pull requests", "Write slides". "Done badges hold it too": "Read docs" stayed second at P2, P1, then P0; after a click on empty space the Done group read "Read docs", "Set up CI". "Refresh keeps the order": a new tab opened with the helper drew the graph twice in 1.2 s, and "Write slides" stayed third, also after that tab closed. "Fresh open sorts": two ⌃⌘O presses closed and reopened the graph, which listed "Fix login bug", "Write slides", "Review pull requests". A first attempt right after closing the helper's tab needed a third press, since the first left the graph open.
  - **"Custom order":** "Badge clicks don't move a node" (Your order): "Write slides" stayed third after each of three badge clicks and the click on empty space, read P0, and the kv dump held 0. "New objective on top" (by priority): "Write slides", "Fix login bug", "Review pull requests".
- [x] 1.2 The header button, grips and look (design D3, D6, D8):
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

  Result (harness, 2026-11-18, the same serve as 1.1):
  - **"Sort button":**
    - **Shown with the current method:** with a 0.26.0 store holding `sort_priority: true`, the header's children read `ob-seg`, `ob-searchbtn`, `ob-sortbtn` "Priority", then the gear and "＋ New objective" (no tags in that store). The tooltip read "Sorted by priority · click to sort newest first".
    - **Each click moves on:** "Newest" with "Write slides", "Review pull requests", "Fix login bug"; "Your order" with "Fix login bug", "Review pull requests", "Write slides"; "Priority" with "Review pull requests", "Fix login bug", "Write slides". The kv dump then held `sort` "priority".
    - **Selection kept:** with "Write slides" selected, a click gave Newest: "Write slides" stayed selected, now first, with its action bar and the edge layers `ob-e-all ob-e-dim` and `ob-e-sel`.
    - **Same method on the settings page:** after clicks up to "Newest", ⚙ showed Newest first selected, and the kv dump held `sort` "created".
    - **Drag across the sort button:** `ctl down` in the header's empty space, `move` leftwards across the button, `up` below the header: crop `sb_drag_crop` shows no highlight, and nothing changed.
  - **"Sort method", the button:** it read "Priority" with the 0.23.0 store, "Your order" with the 0.26.0 store whose sorting was off, and "Newest", tooltip "Sorted newest first · click for your order", after Newest first was picked on the page.
  - **Review mode:** with three done objectives due, review mode listed "Read docs", "Set up CI", "Tidy the backlog". Three clicks on the button read Newest, Your order, Priority, and the list and "Review (3)" stayed the same each time.
  - **"Moving objectives"** (Your order; "Fix login bug", "Review pull requests", "Write slides", plus done "Set up CI"):
    - 3 grips, none on the done node, and the grip's tooltip "Move: click, then click where it goes";
    - "Move to the top": "Write slides", "Fix login bug", "Review pull requests", nothing lifted, the same kv order;
    - "Move below": "Fix login bug", "Review pull requests", "Write slides";
    - "Insertion line": with the pointer on the lower half of "Fix login bug", crop `sb_insert_crop` shows "Write slides" lifted and an accent line along the bottom of "Fix login bug" only; the header read `Moving “Write slides” · Cancel`;
    - "Cancelled move": nothing lifted, no notice, kv objectives unchanged;
    - "Moving under a tag filter": with "#api" on, the column held "Fix login bug" and "Write slides"; after the move and clearing the filter, "Write slides", "Fix login bug", "Review pull requests";
    - "No grip on done objectives": 0 grips in done nodes;
    - "Switching the sort ends a move": with "Write slides" lifted, the first click read Priority with nothing lifted, no notice and the same kv order; the second read Newest.
  - **"No grips":** newest first, `ctl tree` held 0 `.ob-grip`. Crop `sb_newest_crop` shows each open node starting with its box, as done nodes do.
  - **"Moving while sorted":** tooltips "Move within P1: …" and "Move within P3: …". With "Write slides" lifted, the drop zones were 0 in "Release" and 2 in each other P3. "Move within a priority" gave "Release", "Write slides", "Fix login bug", "Review pull requests", stored that way. "Another priority takes no drop": with the pointer on the lower half of "Release", 0 drop zones there, and crop `sb_nodrop_crop` shows no line. The click ended the move and selected "Release", with the kv objectives unchanged.
  - **Icon:** `swap` drew two horizontal arrows, ⇄, which read as "switch" (crop `sb_drag_crop`). A rule in `styles.css` turns the button's `svg` 90°. The layout JSON reads that matrix on `svg.ico`, and crop `sb_icon_light_crop` shows ⇅ before "Newest". In dark (crop `sb_icon_dark_crop`), the icon, label and border follow the quiet button's colours, like the search button beside it. The design's D3, D8 and risks now say so; `list` wasn't needed.
  - **Header width and line ends:** with the demo store, at `ctl resize 1400 900` (graph 1200 px) the header stayed one row, 22.5 px tall. At `ctl resize 460 900` (graph 379.5 px), it wrapped into three rows, 83.5 px: scope, Search and the sort button; the tag chips, "Review (2)" and ⚙; then "＋ New objective" (crop `sb_narrow_head`). Pixels 3 px inside the gap column's edges placed all 7 left and 6 right line ends within 0.55 px of their objective node and tab header centres at both widths.
  - **README:** read back. "Organize" names the sort button and its three methods. The order paragraph explains the button and its cycle, the Done group under each method, badge clicks, where new objectives go, and that newest first has no grips. The Configure "Order" bullet names "Sort by" with its three choices, and the Configure command row says it covers sorting. "Finish cleanly" reads "last of its priority, sorted by priority".
  - **Log:** 141 renders since the serve started, the longest 11.9 ms, and no objectives warnings or errors.

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
