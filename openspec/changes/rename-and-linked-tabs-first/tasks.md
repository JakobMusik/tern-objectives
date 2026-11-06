# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Demo:** the harness restarts with one session, so group 1 rebuilds:
  - session "web" with tabs "App build" and "Components";
  - session "api" with tabs "Server" and "Benchmarks";
  - objectives o1–o8 from `/tmp/tobj/kv.pre-tighten.json`, with X = o2 "Write release notes" relinked to "Components" and "Benchmarks" by the right-click menu.
- **Kv dump** reads `/tmp/tobj/config/plugin-data/objectives/kv.json`.
- **Layout** is the JSON that `ctl shot NAME` writes beside its PNG. `/tmp/tobj/bin/rects.py` lists its rectangles, and `/tmp/tobj/bin/order` the right column's order.

## 1. Spike

- [x] 1.1 Double-click delivery in the canvas (design, "Not yet known").

  In the fixtures copy only, give `.ob-title` `dblclick = "ren=<id>"` and `.ob-l2` `dblclick = "note=<id>"`, and log every `canvas_action` `act` with `tern.now()`.

  Verify, with `ctl dblclick` on an objective's title and then on its second line:
  - the log's sequence of acts (`sel`, `sel`, `ren`, or `ren` alone, or nothing);
  - the gap between the presses' acts;
  - whether the Rename and side-note fields open.

  Record the result in design.md's source record, and keep or drop D2 by it. If `ren` doesn't arrive, stop and update the artifacts before group 2.

  Result (harness, demo rebuilt with sessions web 4 and api 9, graph opened from Benchmarks):
  - on o1's title: `sel=o1` from the card, then `ren=o1` from `…o:o1.l1.title` 4.4 ms later;
  - on o6's empty second line: `sel=o6`, then `note=o6` from `…o:o6.l2` 7.0 ms later;
  - no second `sel=` in either case, so a double-click toggles the selection once. D2 is kept, with its cases rewritten for one `sel=`;
  - the fields didn't open, because the spike copy's `App.action` ignores unknown acts. Task 3.1 wires them and checks them open.

## 2. Linked tabs first

- [x] 2.1 The fixed set (design D3) and the two sections (design D4), with styles for `.ob-linkhead` and `.ob-divider`.

  Verify with `order` and the kv dump, graph opened from api's "Benchmarks":
  - selecting X: `Linked to “Write release notes”`, api › Benchmarks, web › Components, "Other tabs", api › Server, web › App build (scenario "Linked tabs on top");
  - X also linked to a tab that is then closed: it shows under "Closed tabs" in the top section only ("Linked closed tab");
  - "＋ Link" on a tab below the divider, then "× Unlink" on one in the top section: `order` is unchanged, the bars swap, and the kv dump holds both changes ("Order kept while linking");
  - deselecting gives the normal order, and selecting again moves the two tabs to their new sections ("Deselect and select again");
  - "＋ New objective" "Write slides" shows no heading or divider ("Nothing linked");
  - under "This session", the top section holds only the current session's linked tabs ("This session").

  Result (`/tmp/tobj/bin/order2`, which adds `{group}` texts to `order`; links made with the helper `menulink`):
  - **Unselected:** `[api] Benchmarks Server [web] App build Components`.
  - **X selected, linked to Benchmarks (13) and Components (8):** `{Linked to “Write release notes”} [api] Benchmarks [web] Components {Other tabs} [api] Server [web] App build`.
  - **X also linked to a spare tab 17, then closed:** `{Linked to “Write release notes”} [api] Benchmarks [web] Components {Closed tabs} extra {Other tabs} [api] Server [web] App build`. (A helper `new_tab` in the background docked the glimpse into Benchmarks's tab, which Tern does for any tab opened behind a glimpse; the checks ran in the docked graph.)
  - **While X was selected,** "＋ Link" on Server (11) and "× Unlink" on Components (8) left the order as it was. The bars read `× Unlink` and `＋ Link` afterwards, and the kv dump went from `[13, 8, 17]` to `[13, 17, 11]`.
  - **Deselected:** `[api] Benchmarks Server [web] App build Components {Closed tabs} extra`. **Selected again:** `{Linked to “Write release notes”} [api] Benchmarks Server {Closed tabs} extra {Other tabs} [web] App build Components`.
  - **"Write slides" (o33), created and selected:** the normal order, with no heading or divider.
  - **X linked to App build (6) too:**
    - under "This session" (api): `{Linked to “Write release notes”} [api] Benchmarks Server {Closed tabs} extra`, with no divider since no other tab shows;
    - under "All": `… [web] App build {Closed tabs} extra {Other tabs} [web] Components`.
  - **Load:** no errors or warnings in the log.
- [x] 2.2 Lines and appearance with the sections shown.

  Verify:
  - with X selected, `edgecheck.py` finds every line end within 2 px of its node's centre at 1400 and 460 px wide;
  - light and dark shots show the heading and divider readable, and the repeated session headings styled like the others;
  - the debug log's render lines stay at or under 20 ms with 30 objectives and X selected.

  Result (glimpse again, X selected with its top section of Benchmarks, Server, App build and the closed "extra"; o1 linked to Components below the divider):
  - **`edgecheck.py`:** PASS for every line end at both widths, within 0.6 px at window 1400 (graph 1200 px, shot `e2_1400`) and within 0.2 px at window 460 (graph 380 px, `e2_460`). That includes o1's line to Components, below the divider. Linking o1 moved no tab.
  - **Themes:** in the light and dark shots (`t_light`, `t_dark`), `Linked to “Write release notes”` reads in the accent colour, the divider shows its rule above "Other tabs", and the repeated "WEB" heading matches the other session headings.
  - **Render time:** with 31 open objectives, 23 of them linked to tabs 11 and 13, six renders during select and deselect took 4.8–6.2 ms (build 1.8–2.4), with no over-20 ms or budget line. The saved `kv.json` was put back afterwards.

## 3. Double-click to edit

- [x] 3.1 Double-click targets (design D1), the selection undo if 1.1 keeps D2 (design D2), and unselectable titles and notes.

  Verify:
  - `ctl dblclick` on o1's title, `ctl type` "Fix login timeout", then Enter: the node and the kv dump hold the new title ("Rename by double-click");
  - `ctl dblclick` on the second line of an objective with no note, `ctl type` "waiting on CI", then Enter: the node and the kv dump hold the note ("Side note by double-click");
  - with X selected, `ctl dblclick` on another objective's title, then Enter: X is still selected, `order` is unchanged, and the other title is unchanged ("Selection kept");
  - a shot taken right after a double-click shows no highlighted word, and `dragsel` across a title and a note shows no highlight ("Drag across a node's badge and chips").

  Result (the fixtures reload cleared the selection, a known limit, and the graph was reopened from Benchmarks; `ctl type` needs its text quoted for the protocol, `'"…"'`):
  - **Rename:** a double-click on o1's title opened the field filled with "Fix login bug". "Fix login timeout" then shows on the node and is in the kv dump. Nothing was selected before or after; without D2, o1 would have been left selected.
  - **Side note:** a double-click on "Write slides"'s empty second line opened the field empty. "waiting on CI" then shows on the line and is in the kv dump.
  - **Selection kept** (helper `dblren`: double-click, then Enter without a change; a real `sleep 1` before each double-click, since `ctl wait` runs on the harness clock):
    - (a) with X selected, a double-click on o3's title left X selected, `order2` identical before and after, and o3's title unchanged;
    - (b) with Components linked to X while X stayed selected, a double-click on X's own title left X selected and Components still below the divider, so the undo restored the old fixed set instead of recomputing it;
    - (c) after a single click on o3 and a pause of over 700 ms, a double-click on o3's title left o3 selected.
  - **No highlight:** a shot taken while the field was open shows o1's title unchanged (mean pixel change 0.0 against the shot before). Every `dragsel` drag shows 0.0 change on every control, including o1's side note and title, which used to be selectable.
  - **Flash:** the double-click's two acts arrive 4–7 ms apart in the harness, so the one-click re-sort shows for a frame at most, and shots taken after it show the restored order. The live check watches the real interval.
- [x] 3.2 README, "Using the graph": a double-click on a title renames it and one on the second line edits the side note; selecting an objective brings its tabs to the top under `Linked to “<title>”` until it's deselected, and links made meanwhile move nothing.

  Verify: `grep` finds "Double-click", "Linked to" and "Other tabs". Refresh `docs/graph.png` only if the shot it was taken from changed.

  Result: the README has "Double-click", `Linked to “` and "Other tabs" once each. The "Click an objective" bullet describes the top section, its divider, the repeated headings and the fixed order, and the priority bullet the two double-clicks. `docs/graph.png` shows the graph with nothing selected, which this change doesn't alter, so it stays.

## 4. Release and live check

- [x] 4.1 Version `0.7.0`: an isolated install prints `installed objectives 0.7.0`; commit, push `main`, tag `v0.7.0`; `tern plugin install github.com/JakobMusik/tern-objectives --force` live.

  Verify: the tags API lists `v0.7.0`, and live `tern plugin list` shows `objectives 0.7.0` ready.

  Result:
  - The isolated install printed `installed objectives 0.7.0` (`0 blocks, 0 lenses, window ready`). The release commit is `c7ffc3b`, and the tags API lists `v0.7.0` first.
  - The first "live" install landed in `/tmp/tobj/config`, because the shell still held the harness's `TERN_CONFIG_DIR` and `TERN_DAEMON_SOCKET` from an earlier `. env.sh` ("no daemon running"). That stray copy was removed, the variables were unset, and the install was run again.
  - The second install wrote `~/Library/Application Support/Tern/plugins/objectives`. Live `tern plugin list` shows `objectives 0.7.0 … ready`, with `tabnav 0.1.0` untouched.

  The user's check of 0.7.0 found the double-click unreliable: it sometimes left another objective selected. The user asked to drop it and rename by key, with R as the default if possible (group 5). The live check moved to 5.5.

## 5. Rename key instead of double-click

- [x] 5.1 Spike: which default key a plugin can give the rename command (design D6, "Keys").

  Verify, in the fixtures copy only, with a command whose `available` is true only while the graph has focus:
  - `keys = { "r" }`: is the bind accepted;
  - `keys = { "shift+r" }`: does Shift+R in a shell still type "R";
  - `keys = { "ctrl+cmd+r" }`: does the bind take, and does it run with the graph focused.

  Result (recorded in design.md's key facts):
  - `r` was refused with `plugin bind left out: the preset binds these keys`, since Tern's defaults bind it to `canvas.tool_rect`, `git.refresh` and `notebook.to_raw`;
  - `shift+r` bound, but ran with focus in Benchmarks's shell (`focused=12`), and the prompt showed no "R": a plugin key runs whatever `available` returns;
  - `ctrl+cmd+r` bound with no warning, and ran with the graph focused (`focused=27`).

  So the default is ⌃⌘R, and R isn't possible.
- [x] 5.2 Take out design D1–D2: the double-click actions, the press log and the `ren`/`note` actions, and `user-select: none` on titles and notes. Add the rename command (design D6).

  Verify:
  - `cx.actions:keys()` maps `ctrl+cmd+r` to `plugin.objectives.rename`, and the log holds no `bind left out` for it;
  - "Rename by key": o1 selected, ⌃⌘R opens the field filled with o1's title; "Fix login timeout" and Enter put it on the node and in the kv dump, and o1 stays selected;
  - "Nothing selected": with no selection, ⌃⌘R shows the info toast and opens no field;
  - "Letters still reach the panes": in Benchmarks's shell, typing "r" and "R" shows "rR" at the prompt, with no toast;
  - `ctl dblclick` on a title opens no field, and the selection changes once, as a single click does: only the first press sends the card's click (task 1.1), as in 0.6.1;
  - `dragsel` highlights text across a title and a note again, as in 0.6.1, and none on the chips and badge.

  Result:
  - **Code:** `lib/view.luau` and `styles.css` match the group 2 commit `fab3508` again. `lib/app.luau` keeps D3 and adds `M.rename_selected` and `M.can_rename`. `window.luau` registers `rename` on `ctrl+cmd+r`.
  - **Keymap:** `ctrl+cmd+r` maps to `plugin.objectives.rename`, `shift+r` is free again, and `r` is Tern's own (`canvas.tool_rect`, `git.refresh`, `notebook.to_raw`). The load logged no warning.
  - **Rename by key:** with o1 ("Fix login timeout", left by task 3.1) selected, ⌃⌘R opened the field filled with "Fix login timeout". "Fix login bug" and Enter put the original title back on the node and in the kv dump. o1 stayed selected, and the graph came back after the field.
  - **Nothing selected:** ⌃⌘R opened no field, and the shot `k_none` shows the info toast "Select an objective in the graph to rename it".
  - **Letters:** with the graph closed and Benchmarks's shell focused, `r` then Shift+R showed `rR` at the prompt (shot `k_letters`), with no toast. Both characters were then deleted with Backspace.
  - **Double-click:** on o3's title, it opened no field and selected o3 once.
  - **`dragsel`:** o1's note and title change (mean 9.7 and 3.4), and the crop shows a text highlight on each. The chips, badge and header controls stay at 0.0.
- [x] 5.3 README: the commands table lists "Objectives: Rename selected objective" with ⌃⌘R, "Using the graph" says to select an objective and press ⌃⌘R, and the double-click sentence goes.

  Verify: `grep` finds "⌃⌘R" in the table and in "Using the graph", and no "Double-click".

  Result: the table has a "Rename selected objective" row with ⌃⌘R, and "Using the graph" says "With an objective selected, **⌃⌘R** renames it". "double-click" appears nowhere. The key note now names `plugin.objectives.rename` too, and says why a plain R can't be the key.
- [x] 5.4 Version `0.8.0`: an isolated install prints `installed objectives 0.8.0`; commit, push `main`, tag `v0.8.0`; `tern plugin install github.com/JakobMusik/tern-objectives --force` live, from a shell with no harness variables.

  Verify: the tags API lists `v0.8.0`, and live `tern plugin list` shows `objectives 0.8.0` ready.

  Result: the isolated install printed `installed objectives 0.8.0` (`0 blocks, 0 lenses, window ready`). The release commit is `7226826`, and the tags API lists `v0.8.0` first. The live install, run only after checking the shell had no `TERN_CONFIG_DIR` or `TERN_DAEMON_SOCKET`, wrote `~/Library/Application Support/Tern/plugins/objectives`. `tern plugin list` shows `objectives 0.8.0 … ready`, with `tabnav 0.1.0` untouched.

  The user's check of 0.8.0 found ⌃⌘R already bound to "rename session". The user asked for another key, and said R was meant inside the open graph with an objective selected (group 6). The live check moved to 6.4.

## 6. Move the rename key

- [x] 6.1 Spike: can R work only inside the open graph; and which chord is free in the user's Tern (design D6, source record).

  Verify, in the fixtures copy only and from the user's `settings.json`, read only:
  - a `shift+r` command whose `available` always returns false: does it run;
  - `tern.override("canvas.tool_rect", …)`: does it register;
  - which candidate chords are free in Tern's defaults and in the user's `keybinds`.

  Result:
  - the always-unavailable command ran with the graph focused (`focused=30`), so `available` never gates a key;
  - the override raised ``unknown command `canvas.tool_rect` ``;
  - the SDK gives canvases no key handler, so R inside the graph only isn't possible;
  - the user's `keybinds` map `ctrl+cmd+r` to `rename_session`. `cmd+shift+r` is free there and in Tern's defaults, and becomes the key.
- [ ] 6.2 The rename command's key becomes `cmd+shift+r` (design D6), in `window.luau`, the comments of `window.luau` and `lib/app.luau`, and the README's table and "Using the graph".

  Verify:
  - `cx.actions:keys()` maps `cmd+shift+r` to `plugin.objectives.rename`, and `ctrl+cmd+r` no longer to it, with no `bind left out` in the log;
  - "Rename by key" with ⌘⇧R: o1 selected, the field opens filled with its title, Enter keeps it, and o1 stays selected;
  - "Nothing selected" with ⌘⇧R: the toast, and no field;
  - "Letters still reach the panes": "r" and "R" in Benchmarks's shell show "rR";
  - the README has ⌘⇧R in the table and in "Using the graph", and no ⌃⌘R.
- [ ] 6.3 Version `0.8.1`: an isolated install prints `installed objectives 0.8.1`; commit, push `main`, tag `v0.8.1`; `tern plugin install github.com/JakobMusik/tern-objectives --force` live, from a shell with no harness variables.

  Verify: the tags API lists `v0.8.1`, and live `tern plugin list` shows `objectives 0.8.1` ready.
- [ ] 6.4 **(live)** With the user:
  - select an objective and press ⌘⇧R to rename it; without a selection, ⌘⇧R shows the hint;
  - ⌃⌘R renames the session again, as the user's keybind says;
  - "r" and "R" still type normally in panes;
  - double-click no longer renames;
  - selecting an objective brings its tabs to the top under `Linked to “<title>”` and "Other tabs", and a session's heading shows in both sections when it has tabs in both;
  - links made while it stays selected move no tab, and deselecting restores the order.

  Record the findings here.

## Workflow follow-up

- Run the verify workflow, then archive the change into `openspec/specs/` and commit.
- Stop the harness services.
