# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Demo:** the harness store from `/tmp/tobj/kv.pre-explore.json` (o1–o8 and o33; o7 done 2026-11-04 with no schedule), the demo sessions, and the graph opened with ⌃⌘O.
- **Kv dump** reads `/tmp/tobj/config/plugin-data/objectives/kv.json`. "Today" below is the machine's date when the check runs. Schedules for a scenario are set by editing a copy of the kv file, then `ctl plugins fixtures` and reopening the graph.
- **Timers:** `tern.timer` runs on the harness clock, which moves only on `ctl wait`.
- **Shots:** `ctl shot NAME` writes a PNG and its layout JSON. `/tmp/tobj/bin/rects.py` lists rectangles, and `/tmp/tobj/bin/edgecheck.py` checks line ends.

## 1. Schedule and store

- [x] 1.1 `lib/review.luau` (design D3).

  Verify with a throwaway Luau script run through a helper op, against "Rating arithmetic":
  - from interval 1, ease 250, due today: Good gives 2.5 / 250, Easy 3.5 / 270, Hard 1 / 230;
  - from interval 4, ease 250, due three days ago: Good gives 13.8;
  - `preview` of a fresh schedule gives 1, 3 and 4 days.

  Result (helper op `review_test` on copies of `review.luau` and `dates.luau`, 2026-11-06):
  - Good gave 2.5 / 250, next 2026-11-09; Easy 3.5 / 270, next 2026-11-10; Hard 1 / 230, next 2026-11-07;
  - three days overdue, Good gave 13.8, next 2026-11-20;
  - `preview` gave 1, 3 and 4. `start` scheduled the next day, which `is_due` says isn't due today.
- [x] 1.2 Store (design D1, D2): the `review` field and its default in `normalize`; `mark_done`, `rate`, `remove` and `restore`, with `toggle_done` gone.

  Verify by kv dump:
  - o7 reads as due the day after its done date ("Done before this version");
  - after `mark_done`, the record holds next review tomorrow, interval 1, ease 250, reps 0 ("Marked done");
  - `restore` after each operation gives back the earlier record exactly, compared field by field.

  Result (helper op `store_test` on copies of the store's modules, against the helper's own kv seeded from `kv.pre-explore.json`; then the plugin itself):
  - o7 read, and was stored after the next change, as `{due 2026-11-05, interval 1, ease 250, reps 0}`;
  - `mark_done("o1")` stored `{due 2026-11-07, interval 1, ease 250, reps 0}`, and a second `mark_done` was refused;
  - `restore` after it gave back o1 field for field, at the same index, with no done time and no schedule;
  - o5 (done, the only link of closed tab 900, whose pane 901 had a saved session) was removed with the snapshot. An open objective's `remove` was refused. After the sweep had dropped the session, `restore` brought back the record, its index, the snapshot and the session, each equal field for field;
  - `rate("o7", "good")`, one day overdue, gave interval 3.8, next 2026-11-10, reps 1. A not-due objective was left alone;
  - in the plugin, clicking o4's box stored `{due 2026-11-07, interval 1, ease 250, reps 0}`, and the log showed no errors;
  - found on the way: `table.clone` refuses stored values (protected metatables from JSON), so the store copies field by field.

  `dates.luau` gained `day_of`, and the done box calls `mark_done` until group 2 adds its Undo.

## 2. Done is final, trash and Undo

- [x] 2.1 Done box, trash icon and Undo notice in `lib/view.luau`, `lib/app.luau` and `styles.css` (design D6, D7).

  Verify:
  - "Box of a done objective" and "Done stays done": `ctl click` a done objective's box. It stays done in the kv dump, and the count is unchanged;
  - "Undo marking done": click o1's box, then `ctl click '.ob-undo .ob-undo-btn'`. The kv record equals the pre-click copy, and a shot shows o1 open with its lines;
  - "Trash icon" and "Undo removing": remove a done objective that was the only one linked to a closed tab, then Undo. Its index, links and the tab's snapshot are back;
  - "Notice expires": `ctl wait 10500`, then a shot shows no notice;
  - "Notice dropped by another click": `ctl click` another title, then a shot shows no notice;
  - ⋯ › Delete still asks first ("Confirmed delete", "Cancelled delete").

  Result (store from `kv.pre-explore.json`):
  - "Box of a done objective": clicking o7's box left "Done (1)", o7 done, and nothing selected. Its title reads "Done 2026-11-04 22:03";
  - "Undo marking done": o1's box showed "Marked done “Fix login bug” · Undo". Undo gave back o1's kv record and index exactly (`jq -S` compare), and shot `v_undo_done` shows o1 open with its dashed line to closed tab 8;
  - "Trash icon" and "Undo removing": o2, marked done, was the only link of closed tabs 6, 11, 13 and 17. Its trash icon (22 × 18) removed it with those four snapshots, keeping tab 8 for o1, and showed "Removed “Write release notes” · Undo". Undo brought back o2 at index 1 with its links and the four snapshots, equal field for field;
  - "Notice expires": o3's notice was still there after about 7 s and gone after about 13 s, with o3 still done. The harness ran timers only with `/tmp/tobj/bin/pump` keeping the window active (see resume-closed-agents, task 2.2);
  - "Notice dropped by another click": o4's notice went at a click on o5's title, and o4 stayed done;
  - ⋯ › Delete: o6's confirm picker opened (shot `v_delete_confirm`); Escape left the objectives unchanged, and confirming removed o6.
- [x] 2.2 Review chip and tooltip (design D8).

  Verify "Done node" by the node's text (`ctl tree`) and its `title`: a trash icon, "review in 1d", no due chip, and the tooltip's "Reviewed 0× · next <tomorrow>".

  Result: o4, which had shown "overdue 1d", once done shows a trash icon and the chips "review in 1d" and "#api", and no due chip. Its title ends "Done 2026-11-06 23:39" and "Reviewed 0× · next 2026-11-07". o7, done 2026-11-04, shows "review due". Shot `v_done_nodes` shows the trash icon drawn on every done node, so the icon risk in design.md is settled.

## 3. Review mode

- [x] 3.1 Review button, review mode, review nodes and lines (design D4, D5).

  Verify, with o7 due and a second done objective due today with a fresh schedule:
  - "One due" and "Nothing due" read from the header in shots;
  - "Two due": the left column lists only those two, the fresh one's buttons read "Hard · 1d", "Good · 3d", "Easy · 4d", and there is no Done group;
  - "Lines in review mode": `edgecheck.py` finds each listed objective's lines within 2 px of both centres, at 1400 and 460 px wide;
  - "Review nodes": every rating button is at least 22 px tall, and the listed nodes share one height. Outside review mode, "Measured hit areas" still holds, the trash icon included;
  - the trash icon draws in the shot (design, risks).

  Result (2026-11-06; schedules set in the kv file. A redraw was forced by clicking "All", because a click on empty space doesn't redraw when nothing is selected):
  - "Nothing due" (o7 and o2 due 2026-12-01): no Review button (shot `v_nothing_due`). "One due" (o7 due 2026-11-05): "Review (1)" (shot `v_one_due`). With o2 also given a fresh schedule due today: "Review (2)";
  - "Two due": the button drawn active, and only "Set up CI" (o7) then "Write release notes" (o2) listed, with no Done group. o2's buttons read "Hard · 1d", "Good · 3d", "Easy · 4d"; o7's, a day overdue, "Hard · 1d", "Good · 4d", "Easy · 7d";
  - "Lines in review mode": `edgecheck.py` passed at 1400 and at 460 px wide. o2's five dashed lines to its closed tabs end within 0.2 px of both centres;
  - "Review nodes": both listed nodes are 78 px tall and every rating button 22 px. Outside review mode (shot `v_hit`), the done box, trash icon and ⋯ are 22 × 18, nodes 48 px, pane rows 22 px, and jump buttons 28 × 22;
  - the trash icon draws (task 2.2, shot `v_done_nodes`).
- [x] 3.2 Ratings and leaving (design D2, D4).

  Verify:
  - "Good on <today>": `ctl click` Good on the fresh one. The kv dump shows the next review three days on and reps 1, and it leaves the list;
  - "Last one rated": Easy on the last one ends review mode;
  - "Button clicked again": clicking the active button ends the mode with the count unchanged;
  - a fresh ⌃⌘O open after closing the graph starts outside review mode;
  - "Drag across review buttons": `dragsel` across the three buttons shows no highlight, and the schedule is unchanged.

  Result:
  - "Good on 2026-11-06": o2's schedule became `{due 2026-11-09, interval 2.5, ease 250, reps 1}`. o2 left the list, and the button read "Review (1)";
  - "Last one rated": Easy on o7, a day overdue, gave `{due 2026-11-13, interval 7, ease 270, reps 1}`. Review mode ended: no Review button, with the four open objectives and "Done (4)" back;
  - "Button clicked again": with two listed, the active button ended the mode, still reading "Review (2)", with the open objectives and the Done group back;
  - a fresh ⌃⌘O open started outside review mode, with "Review (1)" inactive;
  - "Drag across review buttons": a drag from Hard across Easy, released past them, left each button unchanged (0.00 with `hl.py`), o2's schedule unchanged, and review mode on.
- [x] 3.3 README: "Using the graph" describes:
  - done being final, the trash icon and Undo;
  - the review chip;
  - review mode and the three ratings, with the schedule credited to obsidian-spaced-repetition's SM-2-OSR.

  "Known limits": no keys in review, and no Undo of a rating. Verify by reading the README.

  Result:
  - the box bullet now says done is final, with the Undo notice (next click or 10 s) and the trash icon;
  - a new bullet describes review: the chip, "Review (n)", the three buttons with their days, what each rating does, and when the mode ends. It credits obsidian-spaced-repetition's SM-2-OSR with a link;
  - "Known limits" adds no keys in review, no Undo of a rating, and that "Review (n)" counts what the filters show.

## 4. Release 0.10.0

- [ ] 4.1 Version `0.10.0` in `plugin.toml`. Verify an isolated `tern plugin install` of the repo folder prints `installed objectives 0.10.0`, then commit, push `main` and tag `v0.10.0`.
- [ ] 4.2 **(live)** `tern plugin install github.com/JakobMusik/tern-objectives --force`, from a shell with no harness variables. Verify `tern plugin list` shows `objectives 0.10.0 … ready`, with `tabnav 0.1.0` untouched.
- [ ] 4.3 **(live)** With the user:
  - marking done offers Undo, which works;
  - a done objective's box does nothing, and its trash icon removes it with Undo;
  - the next day, "Review (n)" lists it with its lines, and a rating moves it out.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive review-done-objectives --yes`), run `openspec validate --specs --strict`, commit and push.
- Stop the harness services.
