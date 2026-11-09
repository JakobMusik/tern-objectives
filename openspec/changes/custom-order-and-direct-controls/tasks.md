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

- [x] 2.1 Stored order (D1) and new-objective defaults in the state (D8):
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

  Result (harness, demo layout of 1.1):
  - **Order kept from before:** with the graph closed, a store without `ordered` or `settings` went into `kv.json`, holding o1 "P2 due tomorrow", o2 "P2 no date", o3 "P0 no date" and o4 "P2 due today", in that order. The task said to stop the serve; closing the graph is enough, since nothing writes then.
    - The opened graph listed o3, o4, o1, o2.
    - The kv dump kept o1–o4 until the first write, a badge click, which stored o3, o4, o1, o2 with `ordered: true` and the settings `{start_priority 3, new_place "top"}`.
  - **Badge clicks don't move a node:** P3 o1 "Fix login bug", o2 "Review pull requests" and o3 "Write slides" read o1, o2, o3 after each of three badge clicks on o3, which then read P2, P1 and P0. They still read o1, o2, o3 after a click on empty space, and the kv dump held priority 0 for o3.
  - **Due date doesn't move a node:** with ⋯ › Due date › Today on o3 (⋯ goes in 3.1), the chip read "due today", and the order stayed o1, o2, o3.
  - **New objective on top:** "＋ New objective" with "Write slides" over o1 and o2 gave the column, and the kv dump, o3, o1, o2. o3 was selected with a P3 badge, and all 6 tab nodes had a link bar.
  - **Same order in link choices:** the "Link this tab…" rows read "Write slides", "Fix login bug" and "Review pull requests", and the tab menu read the same three with their times, then Copy.
  - **Creating an objective:** "  Fix login bug  " stored `{id o4, title "Fix login bug", done false, priority 3, created, tags [], tabs []}`.
  - **Record without a priority:** o1 stored without `priority` showed P3, and kept its first place.
  - **Create linked:** "New objective for this tab…" in "Release notes" (tab 5) stored o3 "Add caching layer" at priority 3, with tabs `[5]`, first in the list.
  - **Undo marking done:** o3, o1, o2 became o3, o2 when o1 was marked done, then o3, o1, o2 after Undo, with o1's record identical to before.
  - "Another window's objective kept" and "Order survives a reload" need moving, so they are recorded under 2.2.
- [x] 2.2 Pick and drop (D2): the grip, `moving`, the lifted look, the `Moving` notice with Cancel, the drop zones and their `:hover` bars, and the `lift`, `unlift` and `drop` clicks. Add README "Use" text on moving with the grip.

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

  Result (harness; o1 "Fix login bug" and o3 "Write slides" tagged `api`, o2 "Review pull requests" not):
  - **Move to the top:** after the grip of o3 was clicked, o3 had `ob-lifted`, the other two had four zones between them, and the header read `Moving “Write slides” ·` with Cancel. A click on o1's upper zone gave o3, o1, o2 in the column and in the kv dump, with nothing lifted and no zones left.
  - **Move below:** o3's grip, then o2's lower zone, gave o1, o2, o3.
  - **Insertion line:** with o3 lifted and the pointer resting on o1's lower zone, shot `mv_insertion` shows o3 with the accent bar down its left edge and an accent line along the bottom of o1 only.
  - **Cancelled move:** a click on empty space, Cancel, and a second click on the grip each left nothing lifted, no `Moving` notice and no zones, with the kv order unchanged.
  - **Moving under a tag filter:** with "#api" on, the column read o1, o3. After o3 was dropped on o1's upper zone and the filter cleared, the column and the kv dump read o3, o1, o2.
  - **No grip on done objectives:** with done o4 and o5 in the open Done group, the grips were on the three open nodes only, and the group read o5, o4, most recently done first.
  - **Order survives a reload:** after a move to o3, o1, o2, `ctl plugins fixtures` and a fresh open showed o3, o1, o2.
  - **Another window's objective kept:** o9 "Outside objective" was appended to `kv.json` by hand. Moving o2 above o3 then left the kv dump as o2, o3, o1, o4, o5, o9.
  - **Hit areas:** every grip was 22 × 18 px, and every objective node 48 px tall.
  - **No text selected:** with a press beside the `Moving` notice and a drag across it, and with a press on o1's second line and a drag across its title and grip, the notice's text and the grip were unchanged from clean shots (mean difference 0.0 each).
  - **Log:** 29 renders, the longest 4.6 ms, and no errors.

## 3. Action bar and questions in place

- [x] 3.1 Action bar (D3):
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

  Result (harness; "Write slides" etc. as in 2.1, tab ids from 1.1):
  - **Open objective's bar:** a click beside o1's title selected it, and its row read Note, Due, Tags and Delete. No other node had a row, and the graph had no `.ob-more`. o1 was 78 px tall, the others 48.
  - **Note directly:** Note opened Tern's field (`picker.mode` "prompt") with no picker before it. "check the session cookie" became o1's side note, and the graph came back with o1 still selected. Due and Tags opened their pickers directly ("Today" and "New tag…" first).
  - **Dismissed field:** Note, then Escape, left the kv dump unchanged and the graph shown.
  - **Done objective with tabs to close:** done o4, linked to App build (8) and Components (10), which no open objective links, read Note, Tags and "Close 2 tabs". Open o1's row had no Close. When o4's only open tab was also linked to open o1, its row read Note and Tags only.
  - **Select and clear:** selecting o1 gave `ob-sel`, its row, a link bar on all 6 tab nodes, and two edge layers (shot `sel_on`). A click on empty space removed all three (shot `sel_off`).
  - **Objective node content:** a 200-character note left the node 48 px tall, with the whole note in the tooltip. Done o2 (due today) showed a trash icon and only a "review in 1d" chip, and its tooltip ended "Reviewed 0× · next 2026-11-10".
  - **Dismissing by clicking the graph:** Note, then a click into the field (the glimpse closed), then a click where the graph was: the field closed, the kv dump was unchanged, and the graph was back.
  - **Rename key:** ⌥R (`key Alt+r`) with o1 selected opened the field holding "Fix login bug". "Fix login timeout" was stored and shown, and o1 stayed selected. With nothing selected, ⌥R opened no field and the toast read "Select an objective in the graph to rename it".
  - **Rename by clicking the title:**
    - a click on o1's title opened the field with its title, without selecting;
    - with o3 selected, a click on o1's title and Escape left o3 selected;
    - a click beside o2's short title selected o2 with no field;
    - a click on the second line of "Write the onboarding guide for new / contributors to the API" opened the field with the whole title.
  - **Hit areas:** with o1 selected, grips and done boxes were 22 × 18 px, a done node's trash icon 22 × 18, bar buttons 22 px tall, jump buttons 28 × 22, and pane rows 22. Unselected one-line nodes were 48 px tall, the selected one 78, and the selected two-line one 96.
  - **Review nodes:** Hard, Good and Easy were 22 px tall. Both listed nodes were 78 px tall, and the selected one 108, with its row (Note, Tags, "Close 1 tab") under the rating row.
  - **Lines:** with a two-line o2 selected (its node 96 px tall), the ends of the 3 left and 4 right lines sat within 0.05 px of the node and tab-header centres at 1400 px (shot `eb_1400_sel`) and at 460 px (`eb_460_sel`). The check compares the shot's pixels at the gap column's edges with the layout rects; it replaces the lost `edgecheck.py`. In review mode with o4 selected, the result was the same (`rev_sel`). At 460 px each button showed only its icon, its label hidden; at 1400 px the icons and labels "Note", "Due", "Tags" and "Delete" showed (crops `eb_460_bar.png`, `eb_1400_bar.png`).
  - **Delete from the bar:** with "Write the onboarding guide…" (o2) selected between o1 and o3, Delete opened no picker. It removed o2 from the column and the kv dump, and the header read "Removed “…” ·" with Undo.
  - **Undo deleting an open objective:** Undo brought o1, o2, o3 back, with o2's link to tab 8.
  - **Picker from review mode:** with review mode listing o4 and o5, o4 selected and Tags in its bar, Escape left review mode on with both listed.
  - **README:** the Features "Organize." line names your own order and the bar's buttons, and "Use" says what selecting an objective shows. The commands table's rename row never named ⋯, so it stays as it is.
- [x] 3.2 Questions in place (D4): `confirm`, its bar and notice drawings, and the `cfm` and `cfx` clicks; the header drawing comes with 3.4. The confirmation picker in `confirm_close` is removed. Update the README's "Finish cleanly" line if its wording assumes a picker.

  Verify:
  - objectives-graph "Inline confirmation" ("Asked in the bar": `ctl state` shows no picker; "Another click cancels");
  - "Closing a done objective's tabs" (all four scenarios, in the harness's split and omp tabs, as the archived close-linked-tabs checks did);
  - "Closing tabs from the done notice" (all four scenarios);
  - a click on "All" while the notice asks ends both the question and the notice, as any click but Undo ends the notice today;
  - "Direct controls don't select text": "Drag across the action bar", plus a drag across the questions' buttons;
  - render times, and no errors.

  Result (harness; tabs "Alpha" 44, "Bravo" 47 and "Charlie" 49 added to docs; Alpha ran omp, which answered "ok"):
  - **Asked in the bar:** done o4 "Ship release" linked Alpha, Bravo and Charlie, and open o1 linked Charlie. A click on "Close 2 tabs" opened no picker, and the row read `Close 2 tabs? · 1 stays open`, Close and Cancel. Its tooltip, after a wording fix, reads "Close 2 tabs? 1 tab linked to an open objective stays open. Closing ends their programs; omp chats come back with Resume."
  - **Another click cancels:** a click on empty space removed the question, all three tabs stayed open, and selecting o4 again showed "Close 2 tabs".
  - **Cancelled:** "Close 2 tabs", then Cancel, brought the row's buttons back, left all three tabs open, and left `kv.json` byte for byte unchanged.
  - **Close two, keep one:** "Close 2 tabs", then Close, saved the chats ("chat capture … 1 saved"). The headless serve runs plugin callbacks only with window activity, so `pump 5` followed. Alpha and Bravo were then gone, Charlie stayed, the graph was shown, and o4 still linked 44, 47 and 49.
  - **Chat ready to resume:** with o4 selected, the column read `{Linked to “Ship release”} [docs] Charlie {Closed tabs} Alpha Bravo {Other tabs} …`. Alpha's node had "Resume", and its row read `omp`.
  - **The graph's own tab:** with the graph opened over the new tab "Delta", which only done o4 linked, "Close 1 tab" and Close closed Delta and showed the graph again, with no tab left holding only the graph.
  - **Closing tabs from the done notice:**
    - **Offered after marking done:** marking o2 "Ship release" (tabs Echo, Foxtrot) done gave `Marked done “Ship release” · Undo · Close 2 tabs`, with both tabs open.
    - **Asking:** "Close 2 tabs" turned the notice into `Close 2 tabs of “Ship release”? · Close · Cancel`, with no picker.
    - **Cancel keeps Undo:** Cancel brought the notice back as it was, and Undo made o2 open again, with both tabs open.
    - **Confirmed from the notice:** done again, then "Close 2 tabs", then Close (and `pump 5`): both tabs closed, o2 stayed done and still linked both, and the header showed no notice.
    - **Nothing to close:** "Write slides", with no tabs, gave `Marked done “Write slides” · Undo`.
  - **A click elsewhere:** with the notice asking, a click on "All" removed the question and the notice. Both tabs stayed open, and o2 stayed done.
  - **No text selected:** a drag from o1's note across its Note, Due and Tags buttons left the buttons and the note unchanged against a clean shot (0.0), and opened no field.
    - A drag across the question's row left the question's text unchanged (0.0).
    - Close and Cancel differed only by their hover look (crops), with no highlight. The pointer had just clicked where Close sits, and Close lost its red under the pointer, so `.ob-act-cfm:hover` now keeps it red.
  - **Log:** 142 renders, the longest 6.5 ms, and no errors.
- [x] 3.3 Link bars for done objectives (D10): `Store.toggle_link` without its done check, `link_of` for any selected objective, and the "Link this tab…" picker's "done" toast removed. Remove Prune entirely: `prune()`, `Store.prune`, `Built.prunable`, the header button and its CSS. Update the README's link line: link bars work for done objectives too.

  Verify:
  - tab-links "Links of done objectives": "Unlink from a done objective", "Link a done objective" (kv dump, `ctl tree` for the bars and the divider, a shot for the green line) and "Resume moves a done objective's link";
  - tab-links "Linking from the graph", both scenarios, once with an open objective and once with a done one;
  - objectives-graph "Selection": "Selecting a done objective" shows a link bar on every tab node;
  - objective-review "Closed tab in review": after selecting, every tab node has a bar, the closed tab's reading "× Unlink";
  - agent-resume "Unlinked with its tab": close a tab holding an omp chat, wait past the saved chat's 10 s grace, unlink it, and read the kv dump after the next redraw;
  - no "Prune closed tabs" in the header, even with a closed tab linked to an open objective (`ctl tree '.ob-head'`), and `grep` finds no `prune` in `lib/` or `styles.css`;
  - the tab menu and "Link this tab…" still list open objectives only (`ctl state`).

  Result (harness):
  - **Selecting a done objective:** done o4 "Ship release", linked to "Release notes" (5) and "Charlie" (49), showed a link bar on all 9 tab nodes. The column read `{Linked to “Ship release”} [docs] Release notes Charlie {Other tabs} …`.
  - **Unlink from a done objective:** "× Unlink" on Release notes left o4 linking 49 only, still done and selected. Release notes moved below the divider with "＋ Link".
  - **Link a done objective:** "＋ Link" on "App build" (8) stored `[49, 8]` and turned that bar to "× Unlink". A green line joined o4 to App build, and both visible line ends sat within 0.05 px of their centres (shot `dl_link_done`). The edge check now ignores the glimpse's footer, which a graph taller than the window reaches.
  - **Resume moves a done objective's link:** Alpha's snapshot and its saved chat (the chat of 3.2, whose entry earlier checks had overwritten) were stored again. With o4 linking closed Alpha (44), its node showed "Resume" and "× Unlink". After Resume (and `pump 3`), o4 linked only the new tab 115, which was live, and stayed done.
  - **Linking from the graph:**
    - "Add then remove a link" on App build gave `[8]`, then `[]`, with the objective still selected and the graph shown, for open o1 and for done o4.
    - "Press that drifts across the bar": a press on Release notes' "＋ Link", moved 40 px along it and released, gave `[5]` for both.
    - A first try on a tab below the window's fold missed, since its bar was outside the glimpse.
  - **Closed tab in review:** done o4, due for review and linked only to closed Alpha, listed Alpha in review mode with "Resume" and no bars. Once o4 was selected, all 11 tab nodes had bars, and Alpha's read "× Unlink". The green line's ends sat within 0.05 px of their centres (shot `rv_review_sel`).
  - **Unlinked with its tab:** with open o1 linked to closed Alpha, whose chat was saved 120 s earlier, "× Unlink" on Alpha removed its snapshot and its saved chat from the kv dump. The redraw after the click had already done it.
  - **No Prune:** with that closed tab linked to an open objective, the header's only button was "＋ New objective", and `grep -i prune` finds nothing in `lib/` or `styles.css`.
  - **Link choices stay open-only:** with open o1 and done o4, the tab menu read "Fix login bug · 11-07 05:21" and Copy, and "Link this tab…" listed only "Fix login bug".
  - **Log:** 43 renders, the longest 6.5 ms, and no errors.
- [x] 3.4 "Close n done tabs" (D11): `done_tabs` in `View.build`, the header button and its question (D4's header drawing), the `closedone` click, and `close_tabs` split to take a counter. Add a README "Finish cleanly" line on closing every tab that only done objectives link.

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

  Result (harness; A = "Echo" 102, B = "Foxtrot" 105, C = "Charlie" 49):
  - **Button shows:** done o4 linked A, done o5 and open o1 both linked B, and C was linked to nothing. The header read "Close 1 done tab" beside "＋ New objective".
  - **Inline confirmation:** a click on it turned it into `Close 1 done tab? · Close · Cancel`, with no picker. A click on empty space ended the question and brought the button back.
  - **Cancelled:** Cancel brought the button back, with A, B and C all open.
  - **Closed after asking:** Close (and `pump 5`) closed A, kept B and C, and left o4 linking `[102]`. The graph stayed shown, and the header showed no "done tab" button.
  - **Only the tabs the graph shows:** with done o4 linking App build (8, session web) and the scope "This session" in docs, the header had no "done tab" button. With All it read "Close 1 done tab".
  - **The graph's own tab:** with the graph opened over "Delta", which only done o4 linked, Close closed Delta and showed the graph again.
  - **A chat tab:** tab 115, running the omp chat that Resume brought back in 3.3 and linked only to done o4, was closed this way. Selecting o4 then showed it under "Closed tabs" with "Resume", its row reading `omp`.
  - **No text selected:** drags across the header both ways, over "Close 1 done tab", "＋ New objective", "All" and the tag chip, left all four unchanged against a clean shot (0.0 each). That is "Drag across the header" without Prune, plus the new button.
  - **README:** "Finish cleanly" names "Close n tabs", the notice, "Close n done tabs" and their asking in place. It never assumed a picker, the check 3.2 left open.
  - **Log:** 44 renders, the longest 5.4 ms, and no errors.

## 4. ⌥N

- [x] 4.1 The `new` command on `alt+n`, or the spelling 1.1 settled on, with `App.new_key` (D5). Add the README commands table row and the known limit: Option+N runs the command in every pane, and Configure moves or removes the key.

  Verify:
  - each objectives-graph "New objective key" scenario with `ctl key Alt+n`: "In the graph", "From a shell" (the graph shown, then the new node selected) and "Letters still reach the panes" (`ctl type nN` in the Benchmarks shell);
  - with the settings page shown (after group 5, rerun there), ⌥N shows the graph's columns and the field;
  - plugin-package "Palette commands" ("Commands listed" with ⌥N, read from the palette's rows in `ctl state`).

  Result (fresh harness rebuilt to the README layout: docs "Guides" 5 and "Release notes" 7, web "App build" 10 and "Components" 14, api "Server" 19 and "Benchmarks" 23, with omp chats in Release notes and Server):
  - **Keymap:** `alt+n → plugin.objectives.new`, beside `alt+r` and `ctrl+cmd+o`, with no `bind left out`.
  - **In the graph:** ⌥N in the graph shown over Guides opened the field. "Write slides" became o3, at the top and selected, and was stored first in the kv dump.
  - **From a shell:** with no graph shown and the Benchmarks shell focused (session api), ⌥N showed the graph over Benchmarks with the field open. "Update docs" became o4, at the top and selected, and the shell's text was unchanged.
  - **Letters still reach the panes:** "nN" typed into the Benchmarks shell showed `nN` at its prompt, with no field or toast. The two letters were then deleted.
  - **Palette:** with o1 selected in the shown graph, the palette for "objectives" listed Open graph ⌃⌘O, Rename selected objective ⌥R, New objective ⌥N, Link this tab… and New objective for this tab…. Configure comes in group 5, which also reruns ⌥N with the settings page shown.
  - **README:** the commands table has the ⌥N row, and the keys note covers ⌥N, either Option key and `plugin.objectives.new`. Group 5 points it at Configure.

## 5. Configure

- [x] 5.1 The settings page (D6) and the new-objective defaults (D8):
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

  Result (harness, README layout of 4.1; o1 "Fix login bug" and o2 "Review pull requests"):
  - **From the header:** with o2 selected, the 30 × 22 px gear button showed the settings page: "Settings", "Back to graph", the "Shortcuts" and "New objectives" sections, and no objective or tab nodes (shot `cfg_page`).
  - **Back to graph:** the columns came back with o2 still selected.
  - **From the palette:** with no graph shown, `plugins run plugin.objectives.configure` showed the settings page over the current tab.
  - **Next open shows the graph:** ⌃⌘O (`key Meta+Ctrl+o`) closed the settings page, and a second ⌃⌘O showed the graph's two objectives.
  - **⌥N from the settings page:** it showed the graph's columns and the New objective field (rerun from 4.1).
  - **Start at P1, at the bottom:** P1 and Bottom drew active. After "Back to graph", "Write slides" came out as o3, P1, last in the column. The kv dump held priority 1 for o3 and `settings {start_priority 1, new_place "bottom"}`.
  - **Defaults survive a reload:** after `ctl plugins fixtures` and a fresh open, P1 and Bottom were still active. They were then set back to P3 and Top.
  - **Hit areas on the graph page:** grips and done boxes 22 × 18 px, bar buttons 22 px tall, jump buttons 28 × 22, rows 22, unselected nodes 48 px tall and the selected one 78.
  - **Look:** the shortcut keys first used the mono face, where ⌃ and ⌥ drew small, so they now use the UI face at 13.5 px.
- [x] 5.2 Shortcuts (D7): `lib/keys.luau` (commands table, parse, display, conflict check, keybinds edits, verify and restore), the rows' Change, Remove and Reset, and `window.luau` taking its defaults from the table. Add the README text on changing shortcuts in Configure, and the data section's note that they are saved in Tern's keybinds.

  Verify every scenario of plugin-settings "Shortcut rows", "Changing a shortcut", "Refused shortcuts" and "Removing and resetting a shortcut", reading the rows with `ctl tree`, the palette with `ctl state` and `op keys_all`, and pressing keys with `ctl key` in the Benchmarks shell and in the graph. After each, `cx.settings:keybinds()` (via `op`) holds only the entries D7 describes. Then reset everything and check that the map equals the starting one.

  Also:
  - objective-store "Where data lands": no new file in the package or the panes' folders;
  - plugin-package "Palette commands", all three scenarios with six commands;
  - plugin-package "README contents" and "Direct controls explained": `grep` the README for ⌥N, Configure, grip and keybinds;
  - `openspec validate --strict custom-order-and-direct-controls` passes.

  Result (harness; the keybinds map started as `{}`):
  - **Defaults:** the rows read Open graph ⌃⌘O, Rename selected objective ⌥R, New objective ⌥N, and "none" for the other three, with no Reset.
  - **New key for New objective:**
    - Change opened the field holding `alt+n`; `ctrl+alt+n` turned the row into ⌃⌥N and the toast into "New objective: ⌃⌥N".
    - The map became `{"alt+n": [], "ctrl+alt+n": "plugin.objectives.new"}`, and the palette listed "Objectives: New objective ⌃⌥N".
    - In the Benchmarks shell, ⌃⌥N showed the graph and the field, while ⌥N did nothing.
  - **Key for a command without one:** Link this tab's field opened empty, and `ctrl+alt+l` made the row ⌃⌥L. ⌃⌥L in the shell opened the "Link this tab" picker.
  - **Field dismissed:** Change on Open graph, then Escape, left ⌃⌘O, the same map and the settings page shown. ⌃⌘O then closed and opened the graph.
  - **Refused shortcuts:**
    - `cmd+t` gave "⌘T is already in use · It runs “New tab”…", the row kept ⌃⌘O, and ⌘T still opened a new tab (6 tabs became 7; the extra one was closed);
    - `n` gave "A shortcut needs ⌃, ⌥ or ⌘";
    - `alt+` gave "“alt+” isn't a shortcut".

    The map was unchanged after each.
  - **Remove the rename key:** Remove made the row "none", with Reset, and added `"alt+r": []`. ⌥R in the shell opened nothing and showed no toast.
  - **Reset after a change:** Reset on New objective made the row ⌥N without Reset, and left the map holding only `"alt+r": []` and `"ctrl+alt+l": …`. ⌥N in the shell then showed the graph and the field, and ⌃⌥N did nothing.
  - **Back to the start:** Reset on Rename and on Link this tab left the map `{}`, equal to the starting one. The keymap held `alt+n`, `alt+r` and `ctrl+cmd+o` for the plugin again.
  - **Found on the way:**
    - The first runs drew every row "none" right after a write, and a Reset failed its own check and put the old map back. Both had the same cause: `cx.actions:keys()` lacks every plugin's keys until the keymap rebuilds, a moment after the registration.
    - The rows and the Change field now layer the keys from the user's keybinds (`Keys.in_effect`). The check after a write only asks that nothing but the intended chord runs the command, and that a changed shortcut, a user entry, already does.
    - Design D7 says so. A redraw timer was tried first and dropped, since the headless serve doesn't fire timers.
  - **Where data lands:** `diff -rq` finds the fixtures' copy of the package identical to the repo. The plugin's data folder holds only `kv.json`. Nothing under the panes' folders `/tmp/tobj/w/demo` changed after the store was loaded.
  - **Palette commands:**
    - with no graph shown, the palette listed five commands, without Rename;
    - with the graph shown and nothing selected, the same five;
    - with o1 selected, all six, with ⌃⌘O, ⌥R and ⌥N.
  - **README:** it has ⌥N (2), Configure (7), grip (1) and keybinds (2), and `openspec validate --strict custom-order-and-direct-controls` passes.
- [x] 5.3 Take `docs/graph.png` and `docs/review.png` again, as their 0.16.0 versions were taken: the same harness data, crops and alt text, now with grips, no ⋯, and the header's gear button. Show both drafts to the user before committing them. (This was 3.5; it moved here because group 5 adds the gear button to the header, which a group 3 shot would miss.)

  Verify:
  - plugin-package "Screenshots match this version": open nodes in `graph.png` show grips, and neither image shows ⋯;
  - "Graph screenshot first": the README's first image is still `docs/graph.png`;
  - every line end in `graph.png` sits within 2 px of its node and tab-header centres (the edge check of 3.1).

  Result:
  - **Harness data:** the layout was rebuilt as in 0.16.0: docs (Guides; Release notes with omp idle and an unseen reply), web (App build split into app and tests; Components with a shell and `todo.md`), and api (Server with a shell and omp waiting for input; Benchmarks). The 0.16.0 demo store went in, with its due, done and review dates moved one day later, so the chips read as they did on 2026-11-08 (`/tmp/tobj/kv.readme-0170.json`). The window was 1045 × 928, so the glimpse matches the old crop's 914 × 808.
  - **`graph.png`** (1828 × 1616): nothing selected, the Done group open. Every open node has a grip, and no node has ⋯. The header shows "Review (2)", the gear and "＋ New objective"; "Fix login bug" has the amber "needs you" ring and "Write release notes" the green "replied" ring. All 7 left and 6 right line ends sit within 0.3 px of their centres.
  - **`review.png`** (1828 × 853): review mode with "Profile slow search queries" selected, its Note and Tags row under the ratings, and the Benchmarks tab under `Linked to` with "× Unlink". The green line's ends sit within 0.3 px. It is 100 px taller than in 0.16.0, because the selected node's row and the tabs' link bars are new.
  - **Approval:** the user approved both drafts before they were committed. Both alt texts now name the grips, the gear button, the Note and Tags row, and the link bars.
  - **Graph screenshot first:** the README's first image is still `docs/graph.png`, and the title bar reads `tobj/w/demo/guides` (the serve's folder) where it read `demo/guides`.

## 6. Release 0.17.0

- [x] 6.1 Version `0.17.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.17.0`. Tick this box, then commit, push `main` and tag `v0.17.0` (annotated, message "objectives 0.17.0").

  Result: the install into `/tmp/tobj-inst170/config` printed `installed objectives 0.17.0 → /tmp/tobj-inst170/config/plugins/objectives`, and `tern plugin list` there shows `objectives 0.17.0 … 0 blocks, 0 lenses, window ready`.
- [x] 6.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify that `tern plugin list` shows `objectives 0.17.0 … ready`, with `tabnav 0.1.0` and `omp-narration 0.1.0` untouched.

  Result: `installed objectives 0.17.0 → ~/Library/Application Support/Tern/plugins/objectives`. `tern plugin list` shows `objectives 0.17.0 … window ready`, beside `omp-narration 0.1.0 … ready` and `tabnav 0.1.0 … ready`. The tag `v0.17.0` (`fc04311`) is signed and on GitHub.
- [ ] 6.3 **(live)** With the user:
  - Option+N (left Option) creates an objective in the graph, from the graph and from a shell. If it doesn't, follow design D5's fallback in a patch;
  - moving with the grip, the insertion line, and the order kept after reopening;
  - the action bar's buttons, Delete with Undo, and "Close n tabs" asked in place;
  - Configure: change a shortcut, then check `settings.json` (read only) and Tern's Keyboard page, then Reset; and the new-objective defaults;
  - with a second Tern window open, change a shortcut in one window, then press ⌃⌘O in the other. If the other window's plugin keys are gone, follow design D7's risk.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive custom-order-and-direct-controls --yes`), run `openspec validate --specs --strict`, commit and push.
