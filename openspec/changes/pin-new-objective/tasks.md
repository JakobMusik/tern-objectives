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

- [ ] 1.1 The pin, its order and its end (design D1–D4):
  - `pinned` in `lib/app.luau`, set in `new_objective` with `selected` when no tab was given, cleared in `build` unless it equals `selected` and names an open objective, by `lift` and by a fresh `M.open`; passed to `View.build` and, in `M.link_tab`, to `Store.open_in_order`;
  - `Store.open_in_order(s, held?, pinned?)` in `lib/store.luau`, moving the pinned objective first;
  - `Ui.pinned` in `lib/view.luau`, passed to `Store.open_in_order` for the left column and the tab menu, and let through the tag filter in `visible`.

  Verify, reading the order in `ctl tree '.ob-obj'` and the store in kv dumps:
  - objectives-graph "New objective listed first", every scenario except the "New" chip, which task 1.2 checks. For "Link choices list it first", read the tab menu after `ctl click` with the right button on Guides' header, then run "Objectives: Link this tab…" from `ctl palette objectives` and read the picker. For "Fresh open ends it", press ⌃⌘O twice with `ctl key`;
  - plugin-settings "New objective defaults", "Start at P1, at the bottom", "Bottom of its priority" and "First when sorted newest first";
  - objectives-graph "Custom order", "New objective on top"; "Sorted by priority", "Sorted list"; "Sorting waits for another click", "Badge clicks hold the order" and "Another click sorts", unchanged.
- [ ] 1.2 The "New" chip, the button in review mode and the README (design D5, D6):
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
