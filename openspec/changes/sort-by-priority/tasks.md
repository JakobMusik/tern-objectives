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

- [ ] 1.1 The setting and the shared order (design D1, D2, D5, D6):
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
- [ ] 1.2 The hold (design D3): `held` in `lib/app.luau`, started by `prio`, ended by every other verb and by a fresh open, and passed to `View.build` and `link_tab`. The `bg=` early return draws when a hold ended.

  Verify objectives-graph "Sorting waits for another click", every scenario. Read `ctl tree '.ob-obj'` after each click, and take a kv dump after the badge clicks. For "Refresh keeps the order", open a tab with `ctl` and wait 1 s, so that the live refresh redraws (a render line in the log).
- [ ] 1.3 Drop spots while sorted (design D4): the node builder adds the drop zones only on objectives of the lifted one's priority when sorting is on, and the grip's tooltip names that priority.

  Verify:
  - objectives-graph "Moving while sorted": both scenarios. For "Another priority takes no drop", take a shot after `ctl hover` on the lower half of "Release", and check that `ctl tree` holds no `.ob-drop` inside it;
  - the grip's tooltip, "Move within P3: click, then click where it goes", in `ctl tree`;
  - objectives-graph "Moving objectives" with sorting off: "Move to the top" and "Cancelled move" still hold;
  - render times in the serve log stay within the 20 ms target, with no objectives warnings or errors.

## 2. Release 0.24.0

- [ ] 2.1 Version `0.24.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.24.0`. Tick this box, then commit, push `main` and tag `v0.24.0` (annotated, message "objectives 0.24.0").
- [ ] 2.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.24.0 … ready`, with the other plugins untouched.
- [ ] 2.3 **(live)** With the user:
  - the open objectives are listed P0 first, and the settings page shows "Order" with "Sort by priority" On;
  - clicking a badge several times keeps the node in place, and the next click elsewhere sorts it;
  - with sorting on, the grip drops only among objectives of the same priority, and Off shows your own order.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive sort-by-priority --yes`), run `openspec validate --specs --strict`, commit and push.
