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

- [ ] 2.1 The fixed set (design D3) and the two sections (design D4), with styles for `.ob-linkhead` and `.ob-divider`.

  Verify with `order` and the kv dump, graph opened from api's "Benchmarks":
  - selecting X: `Linked to "Write release notes"`, api › Benchmarks, web › Components, "Other tabs", api › Server, web › App build (scenario "Linked tabs on top");
  - X also linked to a tab that is then closed: it shows under "Closed tabs" in the top section only ("Linked closed tab");
  - "＋ Link" on a tab below the divider, then "× Unlink" on one in the top section: `order` is unchanged, the bars swap, and the kv dump holds both changes ("Order kept while linking");
  - deselecting gives the normal order, and selecting again moves the two tabs to their new sections ("Deselect and select again");
  - "＋ New objective" "Write slides" shows no heading or divider ("Nothing linked");
  - under "This session", the top section holds only the current session's linked tabs ("This session").
- [ ] 2.2 Lines and appearance with the sections shown.

  Verify:
  - with X selected, `edgecheck.py` finds every line end within 2 px of its node's centre at 1400 and 460 px wide;
  - light and dark shots show the heading and divider readable, and the repeated session headings styled like the others;
  - the debug log's render lines stay at or under 20 ms with 30 objectives and X selected.

## 3. Double-click to edit

- [ ] 3.1 Double-click targets (design D1), the selection undo if 1.1 keeps D2 (design D2), and unselectable titles and notes.

  Verify:
  - `ctl dblclick` on o1's title, `ctl type` "Fix login timeout", then Enter: the node and the kv dump hold the new title ("Rename by double-click");
  - `ctl dblclick` on the second line of an objective with no note, `ctl type` "waiting on CI", then Enter: the node and the kv dump hold the note ("Side note by double-click");
  - with X selected, `ctl dblclick` on another objective's title, then Enter: X is still selected, `order` is unchanged, and the other title is unchanged ("Selection kept");
  - a shot taken right after a double-click shows no highlighted word, and `dragsel` across a title and a note shows no highlight ("Drag across a node's badge and chips").
- [ ] 3.2 README, "Using the graph": a double-click on a title renames it and one on the second line edits the side note; selecting an objective brings its tabs to the top under `Linked to "<title>"` until it's deselected, and links made meanwhile move nothing.

  Verify: `grep` finds "Double-click", "Linked to" and "Other tabs". Refresh `docs/graph.png` only if the shot it was taken from changed.

## 4. Release and live check

- [ ] 4.1 Version `0.7.0`: an isolated install prints `installed objectives 0.7.0`; commit, push `main`, tag `v0.7.0`; `tern plugin install github.com/JakobMusik/tern-objectives --force` live.

  Verify: the tags API lists `v0.7.0`, and live `tern plugin list` shows `objectives 0.7.0` ready.
- [ ] 4.2 **(live)** With the user:
  - double-click a title to rename it, and a second line to edit the side note;
  - a double-click leaves the selection as it was;
  - selecting an objective brings its tabs to the top under `Linked to "<title>"` and "Other tabs", and a session's heading shows in both sections when it has tabs in both;
  - links made while it stays selected move no tab, and deselecting restores the order.

  Record the findings here.

## Workflow follow-up

- Run the verify workflow, then archive the change into `openspec/specs/` and commit.
- Stop the harness services.
