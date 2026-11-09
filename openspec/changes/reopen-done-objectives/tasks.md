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

- [ ] 1.1 Store and schedule (design D2, D3):
  - `Review.resume` in `lib/review.luau`;
  - `Store.reopen(id, keep)`, which moves the record last, clears `done` and `done_at`, and with `keep` false also `review`;
  - `Store.mark_done` carries a kept schedule on;
  - normalizing drops a non-table `review` on open records.

  Verify `Review.resume` with a throwaway Luau script run through a helper op, as review-done-objectives task 1.1 did, on copies of `review.luau` and `dates.luau`: a stored date 11 days after today stays; one 4 days before today, one today, and an unreadable one each become tomorrow; interval, ease and count are unchanged every time. The store is checked through the clicks in 1.2.
- [ ] 1.2 The question (design D1, D4): the done box's `reopen=` and tooltip, `confirm` kind "reopen", the `rkeep` and `rreset` answers in `lib/app.luau`, the bar's "Reopen?" in `lib/view.luau`, and `.ob-acts-reopen` in `styles.css`.

  Verify with `ctl click`, `ctl tree`, the kv dump and shots:
  - objectives-graph "Reopening a done objective": every scenario, the review mode ones with the two due objectives;
  - objectives-graph "Box of a done objective" and "Another click ends the reopen question";
  - objective-store "Done and reopening": "Done until reopened", "Reopened keeping its review" (schedule set to reviewed twice by hand), "Reopened resetting its review";
  - objective-review "Review schedule starts at done": "Done again with its review kept", "Kept review already due" and "Done again after a reset", each by reopening, then clicking the open box;
  - tab-links "Reopening keeps the links": the closed tab shows under "Closed tabs" with a dashed line;
  - Undo after marking a kept-review objective done again: the kv record equals the copy taken before that click, kept schedule included;
  - unchanged: "Marking done", "Undo marking done", and the "Close 2 tabs?" bar's "Asked in the bar" and "Another click cancels".

  Shots of the asking bar at 1400 and 460 px wide (`ctl resize`): "Reopen?" and the three answers' icons show, nothing overflows the node, and the node is as tall as a selected node with a bar. After Keep review, the reopened node's lines meet its vertical centre on both shots, checked as custom-order-and-direct-controls task 3.1 did (shot pixels at the gap column's edges against the layout rects; `edgecheck.py` is gone). Also check the render times in `/tmp/tobj/logs/tern-serve.log`, with no errors.
- [ ] 1.3 README: the "Finish cleanly." bullet in Features gains a sentence: click a done objective's box to reopen it, keeping its review schedule or starting it over. Verify by reading the bullet, then following it in the harness.

## 2. Release 0.19.0

- [ ] 2.1 Version `0.19.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.19.0`. Tick this box, then commit, push `main` and tag `v0.19.0` (annotated, message "objectives 0.19.0").
- [ ] 2.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.19.0 … ready`, with `tabnav 0.1.0` and `omp-narration 0.1.0` untouched.
- [ ] 2.3 **(live)** With the user:
  - a done objective's box asks "Reopen?", and Cancel leaves it done;
  - Keep review puts it last in the open list, and marking it done again shows its old "review in Nd" chip, or "review in 1d" if that date had passed;
  - Reset review, then marking done again, shows "review in 1d".

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive reopen-done-objectives --yes`), run `openspec validate --specs --strict`, commit and push.
