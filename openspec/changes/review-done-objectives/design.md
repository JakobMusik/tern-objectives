# Design

## Context

See proposal.md, "Why".

- **Done today:**
  - `Store.toggle_done` flips `done`, and sets or clears `done_at` (`lib/store.luau:260`).
  - The box's click sends `done=<id>` (`lib/view.luau:118`), and the title reads "Reopen" on done objectives.
  - The Done group is sorted by `done_at`, newest first (`sort_done`, line 67).
  - Lines are built from the open list only (line 547), and `linked_open` ignores done objectives (line 259).
- **Delete today** goes through a confirming picker (`lib/app.luau:350`). `Store.delete` drops the objective, then the snapshots no objective links any more (`drop_orphans`, `lib/store.luau:317`).
- **Layout:** every left-column item has a fixed height from `Layout.px` (`lib/layout.luau:8`). Line ends are computed from those heights, so a node's height must be known before rendering.
- **App state:** the selection and the origin live in `lib/app.luau`'s memory, not in the store. Each window's VM keeps its own.

### Source record

| Claim | Evidence |
|---|---|
| SM-2-OSR's Easy, Good and Hard arithmetic; interval rounded to one decimal | obsidian-spaced-repetition 1.15.4, `src/scheduling/algorithms/osr/note-scheduling.ts`, `osrSchedule` |
| Default settings: `baseEase` 250, `lapsesIntervalChange` 0.5, `easyBonus` 1.3, `maximumInterval` 36525 | same release, `src/data/settings.ts:166–170` |
| A new item's interval is 1.0; the due date is `today.add(interval, "d")` | same release, `srs-algorithm-osr.ts:35`, `87`, `179` |
| Moment rounds fractional days to the nearest whole day in `add` | Moment.js docs, "Add" (`momentjs.com/docs/moment/03-manipulating/01-add.md:131`): "As of 2.12.0 when decimal values are passed for days and months, they are rounded to the nearest integer." |
| `tern.timer(ms, fn)` calls `fn` once with a fresh `cx`, and returns a handle with `cancel` | `tern.d.luau:2080–2081`, `1402–1405` |
| A toast takes a level, text and a second line, and no buttons | `tern.d.luau:1898` |
| The canvas gets no keys of its own | rename-and-linked-tabs-first, design D6 |
| A click on an inner node with its own action sends that action, not its parent's | refine-graph-rows, design R7 (the jump button inside a row) |
| View icons are `{ k = "icon", p = { name = … } }`; pickers already use the `trash` icon | `lib/view.luau:174`; `lib/app.luau:351` |
| The harness clock drives `tern.timer` and moves only on `ctl wait` | harness notes; earlier changes' tasks |

## Goals / Non-Goals

**Goals:**
- One scheduling module with no Tern calls, so its arithmetic can be checked with plain inputs.
- Undo restores the kv record field for field.

**Non-Goals:**
- Tabs linked only to done objectives keep looking unlinked in review mode. "Unlinked tabs look different" stays about open objectives.
- Several Undo steps, or Undo for other edits.

## Decisions

### D1. The record
`Objective.review: { due: string, interval: number, ease: number, reps: number }?`:
- `due` is `YYYY-MM-DD`, like due dates;
- `interval` is in days, with one decimal;
- `ease` is in percent.

For a done objective without `review`, `normalize` fills `{ due = <day after done_at>, interval = 1, ease = 250, reps = 0 }`. Without a `done_at`, the next review is today. The filled value is written by the next change, as `normalize` already does for other fields. `VERSION` stays 1.

Alternative: obsidian's `<!--SR:!date,interval,ease-->` string. That suits a Markdown file, while the store is JSON.

### D2. Store operations
`toggle_done` goes. In its place:
- **`mark_done(id)`:** works only on an open objective. It sets `done`, `done_at` and `review`, and returns a copy of the record before the change.
- **`rate(id, grade, today)`:** works only on a done objective whose next review is today or earlier, and applies `Review.rate`.
- **`remove(id)`:** works only on a done objective, which guards against a stale click. It returns the record, its index, and the snapshots that `drop_orphans` dropped with it. From 0.9.0 on it also returns the saved agent sessions dropped with it (change `resume-closed-agents`, design D3).
- **`restore(saved)`:** re-reads the state.
  - After done: it replaces the record by id with the saved copy, or inserts it at its old index if it has gone since.
  - After remove: it inserts the record at its index, clamped to the list's length, if its id is absent. Then it puts back each saved snapshot and session whose key is absent.

Every change still re-reads before writing ("Read before write").

### D3. `lib/review.luau`
- **`rate(r, grade, today) → Review`:**
  - d is the whole days from `r.due` to `today`, and at least 0;
  - it applies the source's arithmetic for the grade;
  - it rounds the interval with `math.round(x * 10) / 10`;
  - it sets `due` to `today + math.max(1, math.round(interval))` days and adds 1 to `reps`.
- **`preview(r, today) → { hard, good, easy }`:** the whole days each grade would give, for the buttons' labels.
- **Rounding:** Luau's `math.round` rounds halves away from zero, which for positive values matches JavaScript's `Math.round` and moment's rounding. Day arithmetic goes through `lib/dates.luau`'s calendar days.
- **Not ported:** "Again", load balancing and the maximum interval. 36525 days is never reached by objectives.

### D4. Review mode state and building
- `lib/app.luau` keeps `reviewing: boolean`, beside `selected`:
  - `rev=` toggles it;
  - a fresh `M.open` clears it;
  - the reopen after a picker (`keep_origin`) keeps it.
- `View.build` receives `ui_state.reviewing`. Its `visible(o)` filter, which applies the scope and tag filters, also gives the due list.
- While reviewing:
  - the left column holds only the due list, sorted by `review.due`, then `done_at` newest first;
  - each node is drawn with `objective_node` plus a third line of three buttons, `rate=<id>:hard|good|easy`;
  - the edge loop runs over that list instead of `open_list`.
- `build` returns the due count. `app` clears `reviewing` when a render finds the count at 0, so the mode ends with its last rating.
- **Header:** "Review (n)" goes left of "Prune closed tabs" when n > 0, drawn `ob-on` while reviewing.

### D5. Layout
- New constant: `Layout.px.review_h = 30`, a 22 px button row plus its gap.
- `Layout.add_obj(s, review)` adds it to the node's height and returns the new vertical centre.
- The layout sheet gains `.ob-obj.ob-review { height: 78px }`, generated from the same constants.
- Lines end at the node's centre, as now.

### D6. Undo notice
- **State:** `lib/app.luau` keeps `undo = { text, saved, timer }`. `mark_done` and `remove` set it, cancelling any earlier timer.
- **Clearing:** `M.action` clears it before handling any act except `undo=`. A fresh `M.open` clears it too. `tern.timer(10000, …)` clears it and renders when the graph is shown.
- **Drawing:** the header shows `span.ob-undo` with the text and an "Undo" button (`undo=`), left of the Review button.
- **Why in the header:** a toast can't hold a button (source record). The header is the one place that doesn't shift the line geometry.

### D7. Trash icon and the done box
- **Trash icon:** done nodes get `span.ob-trash` before the ⋯. It holds the `trash` icon, with `rm=<id>`, a 22 × 18 hit area and the title "Remove".
- **Done box:** a done objective's box gets `click = "noop="`, which `M.action` ignores apart from clearing the Undo notice. Without its own action, a click on the box would select the objective through the card's `sel=`. Its title becomes "Done <date>".
- **Text selection:** `.ob-trash`, `.ob-rate`, `.ob-undo` and the Review button get `user-select: none`.

### D8. Review chip and tooltip
- **Chip:** on done nodes it replaces the due chip:
  - "review due" in the accent colour when `review.due` is today or earlier;
  - else "review in <n>d", muted.
- **Tooltip:** adds "Reviewed <reps>× · next <date>".

### D9. Release
0.10.0, a minor release. It ships after 0.9.0 (`resume-closed-agents`), so D2's `remove` returns saved sessions too.

## Risks / Trade-offs

- **The `trash` icon in a canvas node** is untested; pickers have it. → Task 3.1 checks it in a shot. If it doesn't draw, use the text "×".
- **Undo can overwrite another window's edit** made to the same objective within those 10 seconds. → Accepted: it is one window's 10-second step.
- **Downgrading to 0.9.x** brings Reopen back on done objectives, which keep their `review`. → Harmless: a later 0.10.x reads it.
- **Under "This session",** done objectives linked only to pruned tabs are hidden, and not counted for review. → The scope's existing rule. The README says that All shows every due objective.
- **Many done objectives become due at once** on upgrade (D1). → The user's store holds none today (read 2026-11-06).
- **Review nodes are 30 px taller,** so a long review list scrolls sooner. → Accepted.
