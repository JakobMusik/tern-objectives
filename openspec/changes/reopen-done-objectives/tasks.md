# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:** start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then `ctl plugins fixtures`. After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells). Never source `/tmp/tobj/bin/env.sh` in a persistent shell. Wait with plain sleeps, not `/tmp/tobj/bin/pump`, whenever the glimpse must stay a glimpse: `pump`'s scratch tabs dock it (remember-review-mode, task 1.1).
- **Reading:**
  - `ctl tree '.ob-obj'` for the left column, `ctl tree '.ob-acts'` for the bar, `ctl tree '.ob-undo'` for the notice, and `ctl tree '.ob-revbtn'` for the Review button and its `ob-on` class;
  - `/tmp/tobj/bin/kv` for the store;
  - `ctl shot NAME` for a PNG and layout JSON.
- **Data:** a store with open "Fix login bug" and "Review pull requests", done "Write slides" linked to a live tab and to a tab closed with "Close n tabs", and two more done objectives due today. Restore it from a copy under `/tmp/tobj` before each scenario that reopens, marks done or rates. Schedules and dates in the scenarios are shifted to the harness's today, written by hand into its `kv.json`.
- **After the checks:** stop the harness service.

## 1. Reopen done objectives

- [x] 1.1 Store and schedule (design D2, D3):
  - `Review.resume` in `lib/review.luau`;
  - `Store.reopen(id, keep)`, which moves the record last, clears `done` and `done_at`, and with `keep` false also `review`;
  - `Store.mark_done` carries a kept schedule on;
  - normalizing drops a non-table `review` on open records.

  Verify `Review.resume` with a throwaway Luau script run through a helper op, as review-done-objectives task 1.1 did, on copies of `review.luau` and `dates.luau`: a stored date 11 days after today stays; one 4 days before today, one today, and an unreadable one each become tomorrow; interval, ease and count are unchanged every time. The store is checked through the clicks in 1.2.

  Result (helper op `resume_test`, today 2026-11-09, kept schedule interval 9.5, ease 270, count 2): a stored 2026-11-20 stayed 2026-11-20. Stored 2026-11-05, 2026-11-09 and 2026-11-10, "someday" and the number 42 each gave 2026-11-10. Interval, ease and count were 9.5, 270 and 2 every time.
- [x] 1.2 The question (design D1, D1a, D4): the done box's `reopen=` and tooltip, `confirm` kind "reopen", the `rkeep` and `rreset` answers in `lib/app.luau`; the question row and answers row in `lib/view.luau`, for "Reopen “<title>”?" and "Close n tabs?"; `px.ask_h` and the asking heights in `lib/layout.luau`; `.ob-askrow` in `styles.css`.

  Verify with `ctl click`, `ctl tree`, the kv dump and shots:
  - objectives-graph "Reopening a done objective": every scenario, the review mode ones with the two due objectives;
  - objectives-graph "Box of a done objective" and "Another click ends the reopen question";
  - objective-store "Done and reopening": "Done until reopened", "Reopened keeping its review" (schedule set to reviewed twice by hand), "Reopened resetting its review";
  - objective-review "Review schedule starts at done": "Done again with its review kept", "Kept review already due" and "Done again after a reset", each by reopening, then clicking the open box;
  - tab-links "Reopening keeps the links": the closed tab shows under "Closed tabs" with a dashed line;
  - Undo after marking a kept-review objective done again: the kv record equals the copy taken before that click, kept schedule included;
  - unchanged: "Marking done", "Undo marking done", and the "Close 2 tabs?" bar's "Asked in the bar" and "Another click cancels".

  Shots of both asking bars at 1400 and 460 px wide (`ctl resize`), for objectives-graph "Questions in a narrow graph": the question's row starts with "Reopen" or "Close 2 tabs?", every answer and its icon sits inside the node, and the asking node is 28 px taller than a selected node with a bar (106 px with a one-line title, more in review mode). With the question showing, and after Keep review, the node's lines meet its vertical centre on both shots, checked as custom-order-and-direct-controls task 3.1 did (shot pixels at the gap column's edges against the layout rects; `edgecheck.py` is gone). Also check the render times in `/tmp/tobj/logs/tern-serve.log`, with no errors.

  Result (harness, today 2026-11-09). The store (`/tmp/tobj/kv.rdo.json`) held open o1 "Fix login bug" and o2 "Review pull requests", and done o3 "Write slides" (next review 11-20, interval 9.5, ease 270, count 2). o3 was linked to live tab 5 "Slides" and to tab 7 "notes", closed after linking. It also held done o4 (due 11-13), o5 (due 11-08) and o6 (due 11-09), so "Review (2)". The Done group was open. A first pass with a one-row bar passed every scenario but the widths. At 460 px, three icon-only answers left "Reopen?" 2.8 px, and the existing "Close 2 tabs?" bar showed no question while its Cancel ran 37 px past the node. The user chose two rows for both questions (design D1a). Everything below is from the rerun with two rows, at 1400 px unless a width is given.
  - **Asking to reopen / Box of a done objective:** o3's box tooltip read "Done 2026-11-08 23:00 · click to reopen". A click opened no picker. o3 became selected (`ob-acts-on ob-asking`) and stayed in "Done (4)". Its question row read `Reopen “` `Write slides` `”?`, over Keep review, Reset review and Cancel, 152 px each. The kv dump was unchanged.
  - **Keep review / Reopened keeping its review:** the column read o1, o2, o3 (selected, bar Note, Due, Tags, Delete), then "Done (3)", with no `.ob-undo`. The kv dump listed o1, o2, o4, o5, o6, o3, with o3 not done, no `done_at`, the same schedule and tabs [5, 7]. o3's lines (`ob-e-sel`) ran to Slides and, dashed, to notes under "Closed tabs".
  - **Cancelled:** box, then Cancel. o3 stayed in "Done (4)" and selected, back to 78 px, its bar Note, Tags, "Close 1 tab". The kv dump was unchanged.
  - **Another click ends the reopen question:** box, then a click on empty graph space. Nothing was selected, there was no bar, o3 was still done, and the kv dump was unchanged.
  - **Reopened resetting its review / Reopening keeps the links:** o3 had no `done_at` and no `review`, and tabs [5, 7], last in the list. With the selection cleared, notes still showed under "Closed tabs", with the `ob-e-all` layer's dashed line.
  - **Done again after a reset:** o3's open box gave next review 2026-11-10, interval 1, ease 250, count 0, and the notice `Marked done “Write slides” · Undo · Close 1 tab`.
  - **Done again with its review kept, and Undo:** Keep review, then the open box, gave 2026-11-20, 9.5, 270, 2. Undo gave back a record equal to the copy taken before that click, kept schedule included, open and selected in the list.
  - **Kept review already due:** with o3's schedule set by hand to 2026-11-05, interval 4, ease 250, count 1, Keep review kept it on the open record. The open box then gave 2026-11-10, 4, 250, 1.
  - **Done until reopened:** o1, linked to tab 5, was marked done. In the first pass, the notice still showed after `ctl wait 10500`: this harness fires plugin timers only with window activity, and `pump` would dock the glimpse. The box click drops the notice as any click does. After box and Cancel, o1 was still done, with the same done time and tabs [5], in both passes.
  - **From review mode:** "Review (2)" listed o5 and o6. o6's box selected it and asked under its rating buttons ("Reopen “Profile slow search queries”?"), in a 136 px node (48 + 30 + 30 + 28). Reset review left o5 only, with "Review (1)" `ob-on`, and o6 open with no `done_at` and no `review`. Clicking "Review (1)" then showed o1, o2, o6 (selected), and the Done group.
  - **Last one in review mode:** with o5 moved to 11-12, "Review (1)" listed o6. Its box, then Keep review, showed o1, o2, o6 (selected) and "Done (3)", with no Review button. o6 kept its schedule.
  - **Unchanged:** o1, linked to tab 5, was marked done. It went to "Done (5)" and its line went; Undo gave back the exact record, open. o3 linked to tabs 5 and 3 showed "Close 2 tabs" in its bar. A click asked "Close 2 tabs?" on its own row, over Close and Cancel (231 px each), with no picker. A click on empty space ended it with all 3 panes still there. With o3 linked to a scratch tab 40, "Close 1 tab?" and Close closed that tab, and o3 still linked tab 40.
  - **Questions in a narrow graph (460 px):** both asking nodes were 117 px wide and 106 px tall. The reopen row read `Reopen “` `Write…` `”?`, ending at x 148 against the node's right edge at 157, over three 29 px answers showing their icons. The close row read "Close 2 tabs?" whole, over Close and Cancel at 46 px each, icon and "…". Every answer ended at x 148 or less.
  - **Heights:** asking nodes were 106 px with a one-line title (48 + 30 + 28) and 136 px in review mode; after an answer or Cancel, 78 px.
  - **Lines:** with the question showing, the left line end sat at 357.8 against the node's centre at 357.2, at 1400 px (reopen and close). At 460 px it was 387.8 against 387.7. After Keep review: 305.8 against 305.2 at 1400 px, and 335.8 against 335.7 at 460 px. The right ends sat at 242.8 and 380.8 against tab headers at 242.2 and 380.2 (1400 px), and 272.8 and 410.8 against 272.7 and 410.7 (460 px).
  - **Log:** since the serve started, 154 renders, the longest 6.0 ms, and no objectives warnings or errors.
- [x] 1.3 README: the "Finish cleanly." bullet in Features gains a sentence: click a done objective's box to reopen it, keeping its review schedule or starting it over. Verify by reading the bullet, then following it in the harness.

  Result: the bullet ends "Not done after all? Click a done objective's box to reopen it: **Keep review** carries its review schedule on when it's done again, **Reset review** starts it over. It goes to the bottom of your list, with its links." Followed in the harness under 1.2: the box asked, both answers reopened o3 at the bottom of the list with its links, and Keep review's schedule carried on.

## 2. Release 0.19.0

- [x] 2.1 Version `0.19.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.19.0`. Tick this box, then commit, push `main` and tag `v0.19.0` (annotated, message "objectives 0.19.0").

  Result: the install into `/tmp/tobj-inst190/config` printed `installed objectives 0.19.0 → /tmp/tobj-inst190/config/plugins/objectives`.
- [ ] 2.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.19.0 … ready`, with `tabnav 0.1.0` and `omp-narration 0.1.0` untouched.
- [ ] 2.3 **(live)** With the user:
  - a done objective's box asks "Reopen “<title>”?" above Keep review, Reset review and Cancel, and Cancel leaves it done;
  - Keep review puts it last in the open list, and marking it done again shows its old "review in Nd" chip, or "review in 1d" if that date had passed;
  - Reset review, then marking done again, shows "review in 1d".

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive reopen-done-objectives --yes`), run `openspec validate --specs --strict`, commit and push.
