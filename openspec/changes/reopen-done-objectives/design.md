# Design

## Context

See proposal.md for the request and the user's three choices: ask in place, carry a kept schedule on, put the reopened objective last. The current code:

- **The done box** (`lib/view.luau:240–245`) sends `done=<id>` on an open objective and `noop=` on a done one. `noop` only drops the Undo notice (`lib/app.luau:891–892`), and since the box has its own click, it doesn't select the node.
- **Marking done** (`Store.mark_done`, `lib/store.luau:445–465`) refuses a done record, saves a copy for Undo, then sets `done`, `done_at` and `review = Review.start(day)`. Undo (`Store.restore`, 576–603) puts the saved copy back in place of the record with its id.
- **Normalizing** (`lib/store.luau:167–175`) gives a done record without a table `review` a schedule. Open records' `review` is never read: the view reads it only for done records (`lib/view.luau:87–91`, 222–223, 490–495).
- **Order:** the open objectives' order is their order in `state.objectives`. Done records keep their slots, which only Undo reads (custom-order-and-direct-controls D1).
- **Questions asked in place** (custom-order-and-direct-controls D4): `confirm` in `lib/app.luau:37–38` holds `{ kind, id?, where? }`. Every click clears it first (788–792); `cfm=` and `cfx=` answer the one that was asked. A fresh open clears it (177). The view draws the bar's question only on the selected node (`add_node`, `lib/view.luau:557–575`), whose height grows by `acts_h` through `Layout.add_obj(..., acts ~= nil)`.
- **The asking bar's CSS** (`styles.css:443–457`): `.ob-ask` takes the room and is cut with "…"; in `.ob-acts-ask` the answers are `flex: none`, so they stay whole.

### Source record

The SDK line numbers below refer to `/tmp/ternsdk/book.txt`, the text of `https://docs.stencil.so/tern/print.html` fetched 2026-11-09.

| Claim | Evidence |
|---|---|
| `history`, `eraser` and `x` are Tern icon names | SDK "Icon names" (L11324–11346) |
| A span with its own click action takes the click instead of the node under it | shipped: the done box's `noop=` doesn't select its node (`lib/view.luau:240`); objectives-graph "Selection" |
| A flex item with `min-width: 0` and `text-overflow: ellipsis` is cut with "…" | shipped: `.ob-ask` and `.ob-act-l` (`styles.css:430–454`) |
| An objective selected while hidden by review mode draws no lines and no link bars | `lib/view.luau:572–574`, 623–628: `sel_obj` is set only when its node is drawn |
| The harness can set a record's fields by editing its `kv.json`, which the next render reads | remember-review-mode, task 1.1 ("Nothing due at the next open") |

## Goals / Non-Goals

**Goals:**
- One more state change, open ← done, through the store's existing write path, with no new stored field.
- The question reuses the bar question's state, drawing and click rules.

**Non-Goals:**
- Changing marking done, its notice, or Undo.
- Any reopen path outside the graph.

## Decisions

### D1. The box asks in the bar
- **Click:** a done box sends `reopen=<id>`, replacing `noop=`. Its tooltip reads "Done <time> · click to reopen".
- **State:** the `reopen` branch sets `selected = id` and `confirm = { kind = "reopen", id = id, where = "bar" }`. Selecting is what makes the bar show: the layout gives the bar's height to the selected node only, and "Larger hit areas" keeps unselected nodes 48 px tall.
- **Drawing:** in `add_node`, the selected node asks when `confirm` is `reopen` for its id and the record is still done. `Acts.asking` becomes `Acts.ask: "close" | "reopen" | nil`. `action_bar` draws `span.ob-ask` "Reopen?" (tooltip: "Reopen “<title>”. Keep review: its schedule carries on when it is done again. Reset review: it starts over."), then:
  - Keep review: `rkeep=`, icon `history`;
  - Reset review: `rreset=`, icon `eraser`;
  - Cancel: `cfx=`, icon `x`.
- **Fitting:** three answers don't fit a narrow left column whole. The bar gets `ob-acts-reopen` beside `ob-acts-ask`, and there the answers are `flex: 0 1 auto` with their labels cut with "…", so the icons always show. The two-answer "Close n tabs?" bar is unchanged.
- **Answers:** `rkeep` and `rreset` act on `asked` when it is `reopen`: `Store.reopen(asked.id, keep)`, and `toast_gone` if the record is gone. The selection stays. Any other click has already ended the question, as for "Close n tabs?".
- **Rejected:**
  - Asking in the header, like "Close n done tabs?": far from the box, and the header already holds the Undo and Moving notices.
  - Showing the bar on an unselected node: it breaks the 48 px rule and gives the layout a second bar to place.

### D2. `Store.reopen(id, keep)`
In one `mutate`:
- find the record. If it is gone, return false. If it is already open, as when another window reopened it, write nothing and return true;
- otherwise, take it out of `state.objectives` and append it, so it is the last open objective (the user's choice). Done records' slots don't matter (Context, "Order");
- set `done = false` and `done_at = nil`, and with `keep` false also `review = nil`. Links, tags, note, due date and priority stay.

No Undo is saved: the question is the guard (proposal).

Rejected: putting it back at its old slot, which the record still holds. The user chose last, where a reopened objective is easy to find.

### D3. A kept schedule carries on
- **`Review.resume(s, day)`:** returns `{ due, interval, ease, reps }` with interval, ease and reps unchanged, and `due` the later of `s.due` and the day after `day`. An unreadable `s.due` counts as passed.
- **`Store.mark_done`:** `o.review = if type(o.review) == "table" then Review.resume(o.review, day) else Review.start(day)`. A reset record has no `review`, so it starts over as before. Undo of marking done restores the copy taken before, kept schedule included.
- **Normalizing:** an open record whose `review` isn't a table loses it, so a hand-edited value can't reach `resume`.
- **Rejected:** restoring the schedule exactly (the user's choice), which makes an objective due on the day it is marked done again when its date has passed.

### D4. Review mode
The box is on review nodes too, so the same question shows in the bar under the rating buttons (`lib/view.luau`, D3 of custom-order-and-direct-controls). After reopening:
- the objective is open, so it leaves the review list. If the list is now empty, `build()` ends review mode (`lib/app.luau:135–137`) and the column shows the open objectives, the reopened one last and selected;
- otherwise review mode goes on with the others, and the reopened objective stays selected but hidden: it draws no lines and no link bars (source record), and shows selected once review mode ends.

### D5. Release
0.19.0, a minor release: behaviour changes.

## Risks / Trade-offs

- [A mis-click on the small box, then a mis-click on an answer] → two clicks are needed, and Keep review loses nothing but the done time. Reset review drops the schedule with no Undo; its tooltip says so.
- [Labels cut in a narrow column] → icons and tooltips stay. Task 1.2 checks a screenshot at the narrowest graph.
- [Another window acts between the question and the answer] → the answer re-reads the store (D2): a removed objective toasts, an already open one changes nothing.
- [An open objective carries a schedule it doesn't show] → out of scope (proposal). It shows again once the objective is done.
- [Downgrade] → 0.18.0 ignores `review` on open records and starts a new schedule when one is marked done (Context), so nothing breaks.

## Migration Plan

None: no stored field is added, and existing records read as before. To roll back, reinstall 0.18.0.
