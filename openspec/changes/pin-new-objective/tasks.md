# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness:** `/tmp/tobj/bin/{env.sh,serve,ctl,sync,op,kv,pump}` and the helper plugin `tobjh` are in place from done-sort-button.
  - Start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then run `ctl plugins fixtures`.
  - After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells).
  - Never source `/tmp/tobj/bin/env.sh` in a persistent shell, and never run `tern serve --help`, which serves.
- **Layout:** the README demo, rebuilt in a fresh serve as done-sort-button built it, with the tab Guides in session docs.
- **Stores:** each check writes the objectives its scenario names into `/tmp/tobj/config/plugin-data/objectives/kv.json` (key `"state"`), with the settings it names (sort method, starting priority and place), then closes and opens the graph again.
- **Creating:** `ctl click` on "＋ New objective", or `ctl key alt+n` for ⌥N, then `ctl type` the title and `ctl key Enter`.
- **Reading:**
  - `ctl tree '.ob-obj'` for the left column's order, the selected node (`ob-sel`) and the chip (`.ob-newchip`);
  - `ctl click` for real hit-testing;
  - `ctl shot NAME` for a PNG and layout JSON;
  - kv dumps of `kv.json`;
  - the serve log, `/tmp/tobj/logs/tern-serve.log`, for render times and warnings.
- **After the checks:** stop the harness service, and remove the chat folders the checks created under `~/.omp/agent/sessions/`.

## 1. The new objective listed first

- [x] 1.1 The pin, its order and its end (design D1–D4):
  - `pinned` in `lib/app.luau`, set in `new_objective` with `selected` when no tab was given, cleared in `build` unless it equals `selected` and names an open objective, by `lift` and by a fresh `M.open`; passed to `View.build` and, in `M.link_tab`, to `Store.open_in_order`;
  - `Store.open_in_order(s, held?, pinned?)` in `lib/store.luau`, moving the pinned objective first;
  - `Ui.pinned` in `lib/view.luau`, passed to `Store.open_in_order` for the left column and the tab menu, and let through the tag filter in `visible`.

  Verify, reading the order in `ctl tree '.ob-obj'` and the store in kv dumps:
  - objectives-graph "New objective listed first", every scenario except the "New" chip, which task 1.2 checks. For "Link choices list it first", read the tab menu after `ctl click` with the right button on Guides' header, then run "Objectives: Link this tab…" from `ctl palette objectives` and read the picker. For "Fresh open ends it", press ⌃⌘O twice with `ctl key`;
  - plugin-settings "New objective defaults", "Start at P1, at the bottom", "Bottom of its priority" and "First when sorted newest first";
  - objectives-graph "Custom order", "New objective on top"; "Sorted by priority", "Sorted list"; "Sorting waits for another click", "Badge clicks hold the order" and "Another click sorts", unchanged.

  Result (harness, 2026-11-18, Tern 0.9.27). A fresh serve with one session, docs, holding the tab Guides (tab 3, shell pane 2), the only tab the scenarios name; with no omp pane, no chat folder was created. Each scenario started from a store with "Release" (P1, created 11-17 09:00) and "Fix login bug" (P3, 10:00), sorted by priority, new objectives at P3 on top, unless it says otherwise; the new objective got id o100.
  - **First when sorted by priority:** "Write slides" (selected), "Release", "Fix login bug"; the kv dump listed "Write slides" first.
  - **Its own controls keep it first:** after its badge (P2), "＋ Link" on Guides (kv `tabs` [3]) and Guides' header (drawn `ob-tsel`), the list read "Write slides" (selected), "Release", "Fix login bug" each time.
  - **Deselected, it takes its place:** "Release", "Write slides", "Fix login bug".
  - **Another objective selected:** a click on "Fix login bug" near the foot of its node gave "Release", "Write slides", "Fix login bug" (selected). A first try clicked the node's right end, its link button, which linked it to Guides without selecting it, so "Write slides" stayed first, as it should.
  - **A second new objective** (⌥N, `ctl key alt+n`): "Write notes" (selected), "Release", "Write slides", "Fix login bug".
  - **Bottom of Your order:** "Write slides" (selected), "Release", "Fix login bug"; after empty space, "Release", "Fix login bug", "Write slides", as the kv dump stores them.
  - **Lifting a grip ends it:** "Release", "Write slides" (selected, drawn `ob-lifted`), "Fix login bug".
  - **Marking it done ends it:** after the done box, "Release", "Fix login bug"; after the notice's Undo, "Release", "Write slides" (still selected), "Fix login bug".
  - **Under a tag filter** ("#api" on, only "Fix login bug" tagged): "Fix login bug" before; "Write slides" (selected), "Fix login bug" after creating; only "Fix login bug" after empty space.
  - **Link choices list it first:** the tab menu read "Write slides · 11-18 16:43", "Release · 11-17 09:00", "Fix login bug · 11-17 10:00", then Copy. The picker, opened with `ctl plugins run plugin.objectives.link_tab` from pane 2, read "Write slides", "Release", "Fix login bug". Escaping the menu left the graph and the order as they were.
  - **Fresh open ends it:** the first ⌃⌘O closed the graph, the second opened it with "Release", "Write slides", "Fix login bug" and nothing selected.
  - **Not for a tab's new objective:** "Objectives: New objective for this tab…" from pane 2 stored "Write slides" first, linked to tab 3; the graph opened with "Release", "Write slides", "Fix login bug", nothing selected.
  - **"New objective defaults":**
    - **Start at P1, at the bottom** (Your order, P1 and Bottom picked on the page): "Write slides" first while selected; after empty space, "Fix login bug", "Review pull requests", "Write slides" with a P1 badge. The kv dump held priority 1 for it and `start_priority` 1, `new_place` "bottom".
    - **Bottom of its priority:** after empty space, "Release", "Write slides", "Fix login bug".
    - **First when sorted newest first** (Release created at 10:00, after "Fix login bug"): "Write slides" (selected), "Release", "Fix login bug"; the kv dump listed "Write slides" last.
  - **Unchanged:** "New objective on top" (Your order, top): "Write slides", "Fix login bug", "Review pull requests". "Sorted list": "Update dependencies", "Review pull requests", "Fix login bug", "Write slides", the kv dump in its old order. "Badge clicks hold the order": "Write slides" third at P2, then P1; "Another click sorts": "Fix login bug", "Write slides", "Review pull requests", kv priority 1.
- [x] 1.2 The "New" chip, the button in review mode and the README (design D5, D6):
  - the chip in `objective_node`, after the creation time on the title's last line, and `.ob-newchip` in `styles.css`;
  - the `new` verb ends review mode;
  - README: the order paragraph says a new objective made with "＋ New objective" or ⌥N is listed first, with a "New" chip, while it stays selected, then moves to its place; the review-mode paragraph says "＋ New objective" leaves review mode as ⌥N does.

  Verify:
  - the chip in "New objective listed first": present on "Write slides" in "First when sorted by priority" and after each click of "Its own controls keep it first", on "Write notes" only in "A second new objective", and on no node after each scenario that ends the pin (`ctl tree '.ob-newchip'`);
  - a shot at 1400 px (`ctl resize 1400 900`): a crop of the node shows the chip after the creation time, and the node is 48 px tall like its neighbours of one title line;
  - a shot at 460 px (`ctl resize 460 900`): record what the title line shows, and that any cut takes the chip before the time;
  - a shot in light and dark (`ctl appearance light`, `ctl appearance dark`) with the chip's tint;
  - objectives-graph "New objective button", "Create and select" and "From review mode", with two due done objectives in the store; "New objective key", "From review mode", unchanged; "Graph returns after its pickers", "Clicking into a field";
  - render times in the serve log stay within the 20 ms target.

  Result (harness, as task 1.1):
  - **The chip:** `ctl tree '.ob-newchip'` found one chip, "New", with the tooltip "Just created · listed first while it stays selected". It was on "Write slides" in "First when sorted by priority" and after each click of "Its own controls keep it first", only on "Write notes" in "A second new objective", and on no node after deselecting, selecting another, the grip, done and Undo, empty space under the tag filter, and the fresh open.
  - **At 1400 px** (crop `pn_1400_crop`): "P3 Write slides 11-18 16:44 New" on the title line, the chip 16 px tall, 5.9 px after the time, in the 18 px line. The node is 78 px tall, as the same node is when selected without the chip: 48 px plus its action bar. The unselected nodes are 48 px.
  - **At 460 px** (crop `pn_460_crop`): the nodes are 117 px wide, and the grip, done box and badge fill the line, so no node shows its title, time or chip. "Release", with no chip, looks the same (`pn_460_release`), so this was already so.
  - **The cut at middle widths:** at 760 px the time is whole and the chip is cut (`pn_760_crop`). At 700 and 640 px the chip is hidden and the time cut to "11-18 16:4" and "11-18". The same node unpinned at 700 px cuts the time at the same place (`pn_700_nopin_crop`), so the chip goes first and doesn't cost the time anything.
  - **Light and dark** (`pn_light_crop`, `pn_dark_crop`): accent text on an accent tint, readable in both, like "review due".
  - **"New objective button":** "Create and select" read P3 and the single tab node's "＋ Link". "From review mode" (two due done objectives, "Review (2)" active and listing them): after "＋ New objective" and "Write slides", the left column read "Write slides" (selected), "Release", "Fix login bug", the Done row and its two objectives, with "Review (2)" not active. The same with ⌥N ("New objective key", "From review mode").
  - **"Clicking into a field":** a click on the field's input (`ctl tree input`), "Write slides" and Enter showed the graph with "Write slides" selected and first, with its chip. In this serve the click didn't close the graph.
  - **Render times:** 87 renders on the small stores, the longest 1.7 ms. With the 10-objective demo store, creating, a badge click and empty space took 5 renders, the longest 6.0 ms. The only warning was the helper plugin's Esc probe, as before.

## 2. Release 0.30.0

- [ ] 2.1 Version `0.30.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.30.0`. Tick this box, then commit, push `main` and tag `v0.30.0` (annotated, message "objectives 0.30.0").
- [ ] 2.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.30.0 … ready`, with the other plugins untouched.
- [ ] 2.3 **(live)** With the user:
  - "＋ New objective" and ⌥N list the new objective first, selected, with a "New" chip after its creation time;
  - its badge, Note, Due, Tags, the tabs' link bars and selecting a tab keep it first;
  - clicking empty space or another objective moves it to its sorted place, and the chip goes;
  - under a tag filter it shows until it is deselected.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive pin-new-objective --yes`), run `openspec validate --specs --strict`, commit and push.
