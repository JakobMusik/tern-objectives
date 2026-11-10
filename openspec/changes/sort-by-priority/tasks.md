# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:**
  - Start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then run `ctl plugins fixtures`.
  - After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells).
  - Never source `/tmp/tobj/bin/env.sh` in a persistent shell.
- **Layout:** session "web" with tabs "App build" and "Components"; session "misc" with tab "Scratch".
- **Store:** written as 0.23.0 writes it, so `settings` holds only `start_priority` and `new_place`. Each check sets the open objectives and priorities its scenario names, plus two done objectives, "Set up CI" (P0) and "Read docs" (P3), with "Read docs" done later. The store goes in through `/tmp/tobj/config/plugin-data/objectives/kv.json` (key `"state"`), then the graph is closed and opened again.
- **Reading:**
  - `ctl tree '.ob-obj'` for the left column's order, classes and tooltips;
  - `ctl shot NAME` for a PNG and layout JSON;
  - `ctl hover <selector>` before a shot of an insertion line;
  - kv dumps of `kv.json`;
  - the serve log for render times and warnings.
- **After the checks:** stop the harness service.

## 1. Sorting by priority

- [x] 1.1 The setting and the shared order (design D1, D2, D5, D6):
  - `sort_priority` in `normalize`, read as On unless it is `false`;
  - `Store.open_in_order(s, held?)`, used by the left column and the tab menu in `View.build` and by `link_tab`, replacing `open_in_order` in `lib/app.luau`;
  - the settings page's "Order" section and the `setsort` verb;
  - README:
    - the order paragraph: sorted by priority by default, your order within a priority, badge clicks sort after the next click elsewhere, Off in Configure;
    - the Configure bullets: a third one for "Order";
    - the screenshot's alt text: "on the left by priority" instead of "in your own order".

  Verify:
  - plugin-settings "Sort setting":
    - "On by default": a shot of the settings page with the 0.23.0 store;
    - "Turned off and saved": a kv dump after the click on Off;
    - "Off survives a reload": `ctl plugins fixtures` again, then a shot of the page and `ctl tree '.ob-obj'`;
  - plugin-settings "Settings page", "From the header": the three section headings in `ctl tree`;
  - plugin-settings "New objective defaults": "Start at P1, at the bottom" with sorting off, and "Bottom of its priority" with sorting on, each by `ctl tree '.ob-obj'` and a kv dump;
  - objectives-graph "Sorting by priority": every scenario. "Link choices sorted too" is checked with shots of the picker and of the tab menu;
  - objectives-graph "Custom order": "Badge clicks don't move a node" with sorting off, and "New objective on top" with sorting on;
  - the README paragraphs and alt text, read back.

  Result (harness, 2026-11-10). A fresh serve in `/tmp/tobj/w/web` held "web" (App build, tab 3; Components, tab 5) and "misc" (Scratch, tab 8). The helper plugin's `plugin.toml` had gone from `/tmp`, so it was written again before the layout was built. Every store had the done objectives "Set up CI" (P0) and "Read docs" (P3), with "Read docs" done an hour later.
  - **On by default:** with the 0.23.0 store (settings without `sort_priority`), shot `sp_settings_on` shows the section "Order" after "New objectives", holding "Sort by priority" with On selected and the note "Within one priority, objectives keep your order. Off shows your order as it is."
  - **Turned off and saved:** after a click on Off, Off was selected, and the kv dump's settings read `{"new_place": "top", "sort_priority": false, "start_priority": 3}`.
  - **Off survives a reload:** after `ctl plugins fixtures`, the page still had Off selected (shot `sp_settings_off_reload`). The column read "Fix login bug", "Review pull requests", "Write slides", "Update dependencies", the stored order.
  - **From the header:** the page's headings read "Shortcuts", "New objectives", "Order", with no `.ob-obj` or `.ob-tab` node.
  - **Start at P1, at the bottom** (sorting off; P3 "Fix login bug" and "Review pull requests"): P1, Bottom and Off picked on the page, then "Write slides" was created with "＋ New objective". It was last, with a P1 badge, and the kv dump held priority 1 for it plus `start_priority` 1 and `new_place` "bottom".
  - **Bottom of its priority** (sorting on; "Release" P1, "Fix login bug" P3): after P1 and Bottom, "Write slides" showed between them: "Release", "Write slides", "Fix login bug". In the list it was stored last.
  - **Sorted list:** with "Fix login bug" (P3), "Review pull requests" (P1), "Write slides" (P3) and "Update dependencies" (P0) stored in that order, the column read "Update dependencies", "Review pull requests", "Fix login bug", "Write slides", and the kv dump kept o1, o2, o3, o4.
  - **Link choices sorted too:** the "Link this tab…" picker (shot `sp_picker`, run as `plugin.objectives.link_tab` from App build) and the right-click menu of App build's node (shot `sp_menu`) both list "Update dependencies", "Review pull requests", "Fix login bug", "Write slides".
  - **Sorting turned off:** Off, then "Back to graph", showed "Fix login bug", "Review pull requests", "Write slides", "Update dependencies".
  - **Done group keeps its order:** "Read docs" (P3) was listed before "Set up CI" (P0) in the open Done group, with sorting on and off.
  - **Badge clicks don't move a node** (sorting off; three P3s): "Write slides" stayed third after each of three badge clicks and after a click on empty graph space. The kv dump held priority 0 for it.
  - **New objective on top** (sorting on; P3 "Fix login bug" and "Review pull requests"): "Write slides" was created first.
  - **README:** besides the order paragraph, the "Order" bullet and the alt text ("open objectives on the left by priority, P0 first"), two other sentences now speak of priorities. "Organize" says priorities sort the list, and "Finish cleanly" says a reopened objective goes "last in your order (last of its priority, while sorting)".
- [x] 1.2 The hold (design D3): `held` in `lib/app.luau`, started by `prio`, ended by every other verb and by a fresh open, and passed to `View.build` and `link_tab`. The `bg=` early return draws when a hold ended.

  Verify objectives-graph "Sorting waits for another click", every scenario. Read `ctl tree '.ob-obj'` after each click, and take a kv dump after the badge clicks. For "Refresh keeps the order", open a tab with `ctl` and wait 1 s, so that the live refresh redraws (a render line in the log).

  Result (harness, 2026-11-10). Store: "Fix login bug" (P0), "Review pull requests" (P2), "Write slides" (P3), in that order, with sorting on. Each scenario started from this store, with the graph opened fresh.
  - **Badge clicks hold the order:** after the first and the second click on the badge of "Write slides", the column read "Fix login bug" P0, "Review pull requests" P2, "Write slides" P2, and then the same with "Write slides" P1. The kv dump held priority 1 for it.
  - **Another click sorts:** a click on empty graph space then gave "Fix login bug", "Write slides", "Review pull requests".
  - **Other badges hold it too:** after the two clicks, a click on the badge of "Review pull requests" left every node in place, with its badge at P1. Then a click on empty space gave "Fix login bug", "Review pull requests", "Write slides".
  - **Refresh keeps the order:** after the two clicks, a new tab was opened in "web" with the helper. Over the next 1.2 s the graph drew three times (render lines in the log), and "Write slides" stayed third. That tab was closed afterwards.
  - **Fresh open sorts:** then ⌃⌘O. The first pair of presses left the graph closed, since the new tab had taken the focus, and one more press opened it. The reopened graph listed "Fix login bug", "Write slides", "Review pull requests".
- [x] 1.3 Drop spots while sorted (design D4): the node builder adds the drop zones only on objectives of the lifted one's priority when sorting is on, and the grip's tooltip names that priority.

  Verify:
  - objectives-graph "Moving while sorted": both scenarios. For "Another priority takes no drop", take a shot after `ctl hover` on the lower half of "Release", and check that `ctl tree` holds no `.ob-drop` inside it;
  - the grip's tooltip, "Move within P3: click, then click where it goes", in `ctl tree`;
  - objectives-graph "Moving objectives" with sorting off: "Move to the top" and "Cancelled move" still hold;
  - render times in the serve log stay within the 20 ms target, with no objectives warnings or errors.

  Result (harness, 2026-11-10). Store: "Release" (P1), "Fix login bug", "Review pull requests" and "Write slides" (P3), in that order, with sorting on.
  - **Grip tooltips:** "Move within P1: click, then click where it goes" on "Release", and "Move within P3: …" on the other three. With sorting off, it reads "Move: click, then click where it goes".
  - **Move within a priority:** with "Write slides" lifted, `.ob-drop` counts were 0 in "Release", 2 in "Fix login bug" and 2 in "Review pull requests". A click on the upper drop zone of "Fix login bug" gave "Release", "Write slides", "Fix login bug", "Review pull requests", nothing lifted, and kv order o1, o4, o2, o3.
  - **Another priority takes no drop:** "Write slides" was lifted again, and the pointer was put on the lower half of "Release" with `ctl move`, since `ctl hover` aims at the centre. `ctl tree` showed no `.ob-drop` inside "Release" and one `.ob-lifted` node. In crop `sp_nodrop_crop.png`, "Write slides" is drawn lifted and no insertion line shows anywhere. A click there ended the move: no lifted node and no Moving notice, the same order, and the kv objectives identical to before.
  - **Sorting off:** with "Fix login bug" (P3), "Review pull requests" (P1) and "Write slides" (P2), lifting "Write slides" gave drop zones on both other objectives, whatever their priority. A click on the upper half of "Fix login bug" moved it to the top (kv order o3, o1, o2). Lifting it again and clicking empty space ended the move with the order and the kv objectives unchanged.
  - **Log:** 62 renders since the serve started, the longest 4.8 ms, and no objectives warnings or errors.
  - **Cleanup:** the serve was stopped with `ctl quit`.

## 2. Release 0.24.0

- [x] 2.1 Version `0.24.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.24.0`. Tick this box, then commit, push `main` and tag `v0.24.0` (annotated, message "objectives 0.24.0").

  Result: the install into `/tmp/tobj-inst240/config` printed `installed objectives 0.24.0 → /tmp/tobj-inst240/config/plugins/objectives`.
- [x] 2.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.24.0 … ready`, with the other plugins untouched.

  Result: `installed objectives 0.24.0 → ~/Library/Application Support/Tern/plugins/objectives`. `tern plugin list` shows `objectives 0.24.0 … window ready`. The other plugins are all ready and untouched by this install: `external-editor 0.1.0`, which is new since 0.23.0's install and was installed by the user, `omp-narration 0.1.0`, `open-below 0.2.0`, `reply-selection 0.1.0` and `tabnav 0.1.0`. The tag `v0.24.0` (`9203207`) is signed and on GitHub.
- [ ] 2.3 **(live)** With the user:
  - the open objectives are listed P0 first, and the settings page shows "Order" with "Sort by priority" On;
  - clicking a badge several times keeps the node in place, and the next click elsewhere sorts it;
  - with sorting on, the grip drops only among objectives of the same priority, and Off shows your own order.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive sort-by-priority --yes`), run `openspec validate --specs --strict`, commit and push.
