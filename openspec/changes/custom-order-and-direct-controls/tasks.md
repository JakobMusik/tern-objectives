# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:**
  - The wrapper scripts `/tmp/tobj/bin/serve`, `sync`, `ctl`, `op` and `kv` are gone, while the Python kernel's helpers still call them. Write them again first. Each runs `tern` with the isolated environment from `openspec/config.yaml` and `STENCIL_FIXTURE_ROOT=/tmp/tobj`:
    - `serve` starts `tern serve`;
    - `sync` copies the repo into `crates/plugins/fixtures/objectives`;
    - `ctl` passes its arguments to `tern ctl`;
    - `op` runs an op of the helper plugin `tobjh`;
    - `kv` prints `config/plugin-data/objectives/kv.json`.
  - Start the serve as a named service (ready on "serving"), then run `ctl plugins fixtures`. After each edit, run `sync` and `ctl plugins fixtures` again, and reopen the graph if it closed (`ctl tree '.ob-root'` tells). Never source `/tmp/tobj/bin/env.sh` in a persistent shell.
- **Reading:**
  - `ctl tree '.ob-obj'`: the left column's order and classes;
  - `kv`: the store;
  - `ctl state`: pickers, the palette and fields;
  - `op keys_all`: `cx.actions:keys()`;
  - `ctl shot NAME`: a PNG plus layout JSON;
  - `ctl move X Y` or `ctl hover <selector>`: rest the pointer.
- **Data:** demo names follow the specs: objectives "Fix login bug", "Review pull requests" and "Write slides"; sessions web, api and docs.
- **After the checks:** stop the harness service.

## 1. Spikes

- [x] 1.1 Rebuild the harness scripts, then probe the three untested assumptions in a throwaway copy of the plugin in the fixtures folder, not in the repo:
  - **Drop zones (D2):** two absolutely positioned children with click actions over one node's halves. `ctl click` on each half delivers its own action, not the node's `sel=`, and `ctl hover` on a half shows its `:hover` bar in a shot.
  - **⌥N (D5):** a command with `keys = { "alt+n" }`, then `ctl key Alt+n` with the graph focused and with a shell focused. Read `op keys_all`, and look in the log for `bind left out`. Try `alt+key_n` the same way.
  - **Keybinds (D7):** `cx.settings:set("keybinds", …)` with one string entry and one `tern.json.array({})` entry. Read back `cx.settings:keybinds()` and `op keys_all`, and press both chords with `ctl key`. Also try an unparsable chord and a chord Tern binds (`cmd+t`), and see what `set` and `keys()` do. Then restore the original map.

  If a probe fails, stop and update design D2, D5 or D7 before group 2.

  Result (harness; throwaway plugin `dspike`, kept at `/tmp/tobj/spike-dspike` and removed from the fixtures afterwards):
  - **Harness:** a cleanup of `/tmp` had removed `/tmp/tobj/bin/{serve,sync,ctl,op,kv}` and `crates/app`. They were written again, with `STENCIL_FIXTURE_ROOT=/tmp/tobj/crates/app`, since Tern looks for the fixtures in `<root>/../plugins/fixtures`. A fresh serve was built to the demo layout: docs ("Guides" 3, "Release notes" 5), web ("App build" 8, "Components" 10) and api ("Server" 13, "Benchmarks" 15). The 0.16.0 demo store was remapped to those tab ids and saved as `/tmp/tobj/kv.demo-0170.json`.
  - **Drop zones:** on a node with zones, clicks on its upper and lower halves delivered `drop=1:before` (node `…n1.zt`) and `drop=1:after` (`…n1.zb`). A click on the node's inner button also gave `drop=1:before`, since the zone covers it. A node without zones gave `sel=2`. With the pointer resting on the lower half, the bottom bar showed (shot `ds_hover_bot`). D2 stands.
  - **⌥N:**
    - `alt+n` bound with no `bind left out` warning (`keys`: `alt+n → plugin.dspike.nkey`).
    - `key Alt+n` ran it with the spike canvas focused (focused 17) and with the docs shell focused (focused 2), and the shell's text was unchanged.
    - `alt+key_n` also bound, and `key Alt+n` ran it.
    - The harness sends a synthetic key, so the dead key stays for the live check. D5 keeps `alt+n`.
  - **Keybinds:**
    - `set("keybinds", {["ctrl+alt+l"] = …, ["alt+n"] = []})` read back as written. ⌥N then did nothing, and ⌃⌥L ran the command.
    - `keys()` listed `ctrl+alt+l` as written: `alt+ctrl+l` found nothing, and `alt+n` showed `[]`. Chords keep their source's spelling, against design D7's assumption, so D7 now canonicalizes both sides.
    - `alt+` raised `` `alt+`: names no key `` and changed nothing.
    - `cmd+t` replaced `new_tab` in `keys()`, so the conflict check is needed.
    - `describe("new_tab").label` is "New tab".
    - New: after any keybinds write, `set` or `bind`, every plugin's binds were gone from `keys()`, `plugin.objectives.open` and `.rename` included, until a plugin reload. A run-time `tern.command` call registering an existing command again, or a run-time `tern.bind`, brought them all back.
    - D7 and its risks were updated: the plugin registers its commands again after each write. The other-window question goes to the live check.
    - The map was restored to `{}`, and the harness has no `settings.json`, because a headless session doesn't save.

## 2. Custom order and moving

- [ ] 2.1 Stored order (D1) and new-objective defaults in the state (D8):
  - `ordered` and its migration in `normalize`;
  - `Store.move`;
  - `state.settings` with defaults;
  - `Store.create` taking the priority and place from the settings;
  - `View.sort_open`, the held order and their callers removed.

  Add a README "Use" line saying open objectives keep the order you give them.

  Verify, reading `ctl tree '.ob-obj'` and the kv dump:
  - objectives-graph "Order kept from before": stop the serve, put a store written by 0.16.0 with those four records into the harness `kv.json`, start the serve again and open the graph. Then "Badge clicks don't move a node", "Due date doesn't move a node", "New objective on top" and "Same order in link choices" (picker rows and tab menu rows from `ctl state`).
  - objective-store "Creating an objective" (priority 3 and no other fields), "Record without a priority" (badge P3), "Another window's objective kept" (`Store.move` after an outside write to `kv.json`), and "Order survives a reload" (`ctl plugins fixtures`).
  - tab-links "Create linked": a P3 record linked to the tab, first among the open records.
  - objective-review "Undo after done or remove": "Undo marking done" puts the objective back in its place.
- [ ] 2.2 Pick and drop (D2): the grip, `moving`, the lifted look, the `Moving` notice with Cancel, the drop zones and their `:hover` bars, and the `lift`, `unlift` and `drop` clicks. Add README "Use" text on moving with the grip.

  Verify each objectives-graph "Moving objectives" scenario, with `ctl click` on the grip and on the zones (`.ob-drop-top`, `.ob-drop-bot`), and the order from `ctl tree` and the kv dump:
  - "Move to the top" and "Move below";
  - "Insertion line": `ctl hover` on the lower zone of "Fix login bug", then a shot;
  - "Cancelled move", once with empty space, once with Cancel and once with the grip again;
  - "Moving under a tag filter";
  - "No grip on done objectives".

  Also:
  - "Measured hit areas" for the grip, from the shot's layout data;
  - "Direct controls don't select text" for the grip and the `Moving` notice, with `ctl down`/`move`/`up` across them and a shot;
  - render times from the log, and no errors.

## 3. Action bar and questions in place

- [ ] 3.1 Action bar (D3):
  - `div.ob-acts` on the selected node, with Note, Due, Tags and Delete on open nodes, and Note, Tags and "Close n tabs" on done ones;
  - `closable` moved into the view;
  - `px.acts_h` and the layout CSS;
  - `Store.remove` for open records, with Undo;
  - `menu()`, ⋯, `Store.delete` and their CSS removed.

  Update the README's features and "Use" for the bar, and its rename line, which still names ⋯.

  Verify:
  - objectives-graph "Action bar": all five scenarios, with `ctl click` on `.ob-act` buttons and fields and pickers from `ctl state`;
  - objectives-graph "Selection" ("Select and clear", with shots), "Objective node content" (no ⋯, the trash icon on done nodes), "Graph returns after its pickers" ("Dismissing by clicking the graph" from Note), "Rename key" and "Rename by clicking the title" (all their scenarios), and "Larger hit areas" ("Measured hit areas" with one node selected; "Review nodes");
  - a selected node's lines still meet its vertical centre: `edgecheck.py` on a shot at 1400 and at 460 px. At 460 px, read whether the labels clip and the icons show;
  - objective-store "Delete from the bar", and objective-review "Undo deleting an open objective" (its place comes back);
  - objective-review "Picker from review mode", from the bar's Tags.
- [ ] 3.2 Questions in place (D4): `confirm`, its bar and notice drawings, and the `cfm` and `cfx` clicks; the header drawing comes with 3.4. The confirmation picker in `confirm_close` is removed. Update the README's "Finish cleanly" line if its wording assumes a picker.

  Verify:
  - objectives-graph "Inline confirmation" ("Asked in the bar": `ctl state` shows no picker; "Another click cancels");
  - "Closing a done objective's tabs" (all four scenarios, in the harness's split and omp tabs, as the archived close-linked-tabs checks did);
  - "Closing tabs from the done notice" (all four scenarios);
  - a click on "All" while the notice asks ends both the question and the notice, as any click but Undo ends the notice today;
  - "Direct controls don't select text": "Drag across the action bar", plus a drag across the questions' buttons;
  - render times, and no errors.
- [ ] 3.3 Link bars for done objectives (D10): `Store.toggle_link` without its done check, `link_of` for any selected objective, and the "Link this tab…" picker's "done" toast removed. Remove Prune entirely: `prune()`, `Store.prune`, `Built.prunable`, the header button and its CSS. Update the README's link line: link bars work for done objectives too.

  Verify:
  - tab-links "Links of done objectives": "Unlink from a done objective", "Link a done objective" (kv dump, `ctl tree` for the bars and the divider, a shot for the green line) and "Resume moves a done objective's link";
  - tab-links "Linking from the graph", both scenarios, once with an open objective and once with a done one;
  - objectives-graph "Selection": "Selecting a done objective" shows a link bar on every tab node;
  - objective-review "Closed tab in review": after selecting, every tab node has a bar, the closed tab's reading "× Unlink";
  - agent-resume "Unlinked with its tab": close a tab holding an omp chat, wait past the saved chat's 10 s grace, unlink it, and read the kv dump after the next redraw;
  - no "Prune closed tabs" in the header, even with a closed tab linked to an open objective (`ctl tree '.ob-head'`), and `grep` finds no `prune` in `lib/` or `styles.css`;
  - the tab menu and "Link this tab…" still list open objectives only (`ctl state`).
- [ ] 3.4 "Close n done tabs" (D11): `done_tabs` in `View.build`, the header button and its question (D4's header drawing), the `closedone` click, and `close_tabs` split to take a counter. Add a README "Finish cleanly" line on closing every tab that only done objectives link.

  Verify each objectives-graph "Closing tabs of done objectives" scenario, setting the links up with the bars and reading the window's tabs with `ctl state`:
  - "Button shows";
  - "Closed after asking": the kv dump keeps X's link to A;
  - "Cancelled";
  - "Only the tabs the graph shows", with "This session" on;
  - "The graph's own tab".

  Also:
  - "Inline confirmation": the header's question, then a click elsewhere ends it;
  - a done-only tab holding an omp chat shows "Resume" under "Closed tabs" once the done objective is selected;
  - "Controls and titles don't select text": "Drag across the header", now without Prune;
  - "Direct controls don't select text": a drag across the header button;
  - render times, and no errors.
- [ ] 3.5 Take `docs/graph.png` and `docs/review.png` again, as their 0.16.0 versions were taken: the same harness data, crops and alt text, now with grips and no ⋯. Show both drafts to the user before committing them.

  Verify:
  - plugin-package "Screenshots match this version": open nodes in `graph.png` show grips, and neither image shows ⋯;
  - "Graph screenshot first": the README's first image is still `docs/graph.png`;
  - `edgecheck.py` passes on `graph.png`.

## 4. ⌥N

- [ ] 4.1 The `new` command on `alt+n`, or the spelling 1.1 settled on, with `App.new_key` (D5). Add the README commands table row and the known limit: Option+N runs the command in every pane, and Configure moves or removes the key.

  Verify:
  - each objectives-graph "New objective key" scenario with `ctl key Alt+n`: "In the graph", "From a shell" (the graph shown, then the new node selected) and "Letters still reach the panes" (`ctl type nN` in the Benchmarks shell);
  - with the settings page shown (after group 5, rerun there), ⌥N shows the graph's columns and the field;
  - plugin-package "Palette commands" ("Commands listed" with ⌥N, read from the palette's rows in `ctl state`).

## 5. Configure

- [ ] 5.1 The settings page (D6) and the new-objective defaults (D8):
  - `page`;
  - the `configure` command and the header's gear button;
  - `View.build_settings`;
  - the `setprio` and `setplace` clicks;
  - "Back to graph".

  Add the README section on Configure, without shortcuts yet.

  Verify:
  - plugin-settings "Settings page": all four scenarios, with `ctl click` and `ctl tree '.ob-root'`;
  - "New objective defaults": "Start at P1, at the bottom" (kv dump) and "Defaults survive a reload";
  - "Measured hit areas" still holds on the graph page afterwards.
- [ ] 5.2 Shortcuts (D7): `lib/keys.luau` (commands table, parse, display, conflict check, keybinds edits, verify and restore), the rows' Change, Remove and Reset, and `window.luau` taking its defaults from the table. Add the README text on changing shortcuts in Configure, and the data section's note that they are saved in Tern's keybinds.

  Verify every scenario of plugin-settings "Shortcut rows", "Changing a shortcut", "Refused shortcuts" and "Removing and resetting a shortcut", reading the rows with `ctl tree`, the palette with `ctl state` and `op keys_all`, and pressing keys with `ctl key` in the Benchmarks shell and in the graph. After each, `cx.settings:keybinds()` (via `op`) holds only the entries D7 describes. Then reset everything and check that the map equals the starting one.

  Also:
  - objective-store "Where data lands": no new file in the package or the panes' folders;
  - plugin-package "Palette commands", all three scenarios with six commands;
  - plugin-package "README contents" and "Direct controls explained": `grep` the README for ⌥N, Configure, grip and keybinds;
  - `openspec validate --strict custom-order-and-direct-controls` passes.

## 6. Release 0.17.0

- [ ] 6.1 Version `0.17.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.17.0`. Tick this box, then commit, push `main` and tag `v0.17.0` (annotated, message "objectives 0.17.0").
- [ ] 6.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify that `tern plugin list` shows `objectives 0.17.0 … ready`, with `tabnav 0.1.0` and `omp-narration 0.1.0` untouched.
- [ ] 6.3 **(live)** With the user:
  - Option+N (left Option) creates an objective in the graph, from the graph and from a shell. If it doesn't, follow design D5's fallback in a patch;
  - moving with the grip, the insertion line, and the order kept after reopening;
  - the action bar's buttons, Delete with Undo, and "Close n tabs" asked in place;
  - Configure: change a shortcut, then check `settings.json` (read only) and Tern's Keyboard page, then Reset; and the new-objective defaults;
  - with a second Tern window open, change a shortcut in one window, then press ⌃⌘O in the other. If the other window's plugin keys are gone, follow design D7's risk.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive custom-order-and-direct-controls --yes`), run `openspec validate --specs --strict`, commit and push.
