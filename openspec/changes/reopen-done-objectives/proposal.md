# Proposal

## Why

Asked by the user on 2026-11-09. Since 0.10.0 done is final: once the 10-second Undo after marking it done has gone, nothing makes a done objective open again, and its done box does nothing. An objective marked done too early, or that needs more work later, has to be created again, and loses its links, notes and review history.

## What Changes

1. **A done objective's box reopens it after asking.** **BREAKING** for the "done is final" rule (objective-store, "Final done state").
   - Clicking the box of a done objective, in the Done group or in review mode, selects it and turns its action bar into the question "Reopen “<title>”?" above **Keep review**, **Reset review** and **Cancel**. The user chose this in-place question over a one-click reopen with Undo, and over a Reopen button in the bar.
   - Cancel, or any other click in the graph, ends the question and leaves the objective done. Reopening offers no Undo: the question already guards against a mis-click.
2. **Reopened, the objective is open again**, still selected, with its links unchanged. It leaves the Done group (or review mode's list) and shows **last** in the open list, which the user chose over its old place or the top.
3. **What happens to its review:**
   - **Reset review:** it is as if it had never been done: no done time and no schedule. Marked done again, it starts over, first review the next day.
   - **Keep review:** the done time goes, the schedule stays in the record while it is open. Marked done again, the schedule carries on: interval, ease and review count kept, next review on its stored date, or the next day if that date is today or earlier. The user chose this over restoring the schedule exactly, which could make it due at once.
4. **Questions in the action bar take two rows:** the question on its own row, its answers on the row below. This applies to "Reopen?" and to the existing "Close n tabs?". Added during apply, at the user's request: in a 460 px window, three answers left "Reopen?" no room on one row, and "Close n tabs?" already lost its question there while its Cancel ran past the node's edge.
5. **README:** the Features list says how to reopen a done objective.
6. **Release 0.19.0**, a minor release because behaviour changes.

Out of scope:
- An Undo notice after reopening.
- A palette command or key to reopen.
- Showing a kept schedule on an open objective (chip or tooltip). It shows again once the objective is done.
- The open box: marking done, its Undo notice and "Close n tabs" are unchanged, apart from the two-row question (item 4).
- Reopening from another window while this one asks: the answer acts on the store as it is then (design D2).

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objective-store`: "Final done state" is replaced by "Done and reopening": a done objective can be reopened, which clears its done time, keeps or drops its schedule, puts it last in the stored order and leaves its links.
- `objective-review`: "Review schedule starts at done" is modified: a kept schedule carries on when the objective is marked done again.
- `objectives-graph`: "Done objectives group" (a done box asks instead of doing nothing) and "Inline confirmation" (the new question) are modified; "Reopening a done objective" is added.
- `tab-links`: "Links of done objectives" is modified to list reopening among what leaves links alone.

## Impact

- `lib/store.luau`: new `M.reopen(id, keep)`; `M.mark_done` carries a kept schedule on.
- `lib/review.luau`: new `M.resume(schedule, day)`.
- `lib/app.luau`: the done box's click asks (`confirm` kind "reopen"), and the two answers reopen.
- `lib/view.luau`: the done box's click and tooltip, and the action bar's reopen question.
- `README.md`: the Features list.
- `openspec/specs/*`: the deltas above.
- `plugin.toml`: version 0.19.0.
- Stored data: no new field. A reopened objective may keep its `review` while open; versions before 0.19.0 ignore it on open records and start a new schedule when it is marked done.
