# Design

## Context

See proposal.md, "Why".

- **One method today** (sort-button D1, D2): `state.settings.sort`, one of `"own"`, `"priority"` and `"created"`. `normalize` in `lib/store.luau` rebuilds `settings` from its known fields. `Store.open_in_order(s, held?)` and `Store.sort_done(s, list, held?)` both switch on it. `View.build` sorts the filtered done objectives with `Store.sort_done`, and review mode builds its own list from them, sorted by due date.
- **The header button** (sort-button D3): `SORTS` in `lib/view.luau` maps each method to its label, tooltip and the next method. The click sends `setsort=<next>`, the verb Configure's "Sort by" row also sends.
- **The hold** (sort-button D5): the first `prio` click records every objective's priority in `held` when `settings.sort == "priority"`; both order functions read it only in their priority branch.
- **The Done row:** `View.build` draws `div.ob-group.ob-donegrp` (key `donegrp`, click `donegrp=`), holding the caret and "Done (n)". Its height comes from the layout sheet, `.ob-group { height: 24px; line-height: 24px }` (`lib/layout.luau` line 67), and `styles.css` makes it a nowrap flex row with `overflow: hidden`.
- **Review schedules:** `normalize` gives every done objective a `review` table, whose `due` is a `YYYY-MM-DD` string (`lib/review.luau` line 12).

### Source record

| Claim | Evidence |
|---|---|
| Clicks in the canvas arrive as `canvas_action` with `act` and `value` | `tern.d.luau:2252`; `window.luau` |
| A click on an element with its own action, inside an element with another, runs only the inner one | select-tab-nodes task 6.1: "Go to tab" (`tab=<id>`), inside a tab node whose click selects it, went to the tab and closed the graph |
| The renderer applies the rotated `swap` icon from plugin CSS | sort-button task 1.2, crop `sb_icon_light_crop` |
| Plugin CSS adds padding to a flex item's basis | select-tab-nodes task 6.1, "Halves" |

## Goals / Non-Goals

**Goals:**
- Two stored methods, each read by one function: `open_in_order` by `sort`, `sort_done` by `done_sort`. The column, the menu and the picker keep reading the open method only.
- The Done row's button and Configure's new row change the same field, through one verb.
- The Done row keeps its 24 px height, so the lines of the done objectives below it stay on their nodes.

**Non-Goals:**
- Changing review mode's order or the open method's cycle.

## Decisions

### D1. The stored method
`state.settings.done_sort`, one of `"recent"`, `"priority"`, `"created"` and `"review"`. `normalize` works out `sort` first, then keeps a valid `set.done_sort`. Without one, it copies `sort`, with `"own"` read as `"recent"`, so the Done group lists the same order as before the upgrade. `default_settings` holds `"priority"`, the open method's default.

*Alternatives:*
- `"own"` as the Done group's first method name: rejected. Done objectives have no order of the user's; the stored name should say what the list shows.
- A fixed default, Recently done, for upgrades: the user chose to keep the current order.

### D2. The order
`Store.sort_done(s, list, held?)` switches on `s.settings.done_sort`. Each ends with `done_at`, larger first, then `id`, as today:
- `"recent"`: no key before `done_at`;
- `"priority"`: `held[id] or priority`, smaller first;
- `"created"`: `created`, larger first;
- `"review"`: `review.due`, smaller first. `YYYY-MM-DD` strings compare as dates do. A record without a schedule comes last, which `normalize` makes unreachable for done records.

The view and review mode call it as today.

### D3. The Done row's button
While `view_state.done_open`, the row gets a third child after "Done (n)": an `el("span")` with classes `ob-btn ob-btn-quiet ob-sortbtn ob-dsortbtn` and key `sort`, holding the `swap` icon and `span("ob-sortt", label)`. Its click is `setdsort=<next>`, which, per the Source record, runs instead of the row's `donegrp=`, so the group stays open.

`DSORTS` maps each method, as `SORTS` does:

| Method | Label | Tooltip | Click |
|---|---|---|---|
| `recent` | Recently done | Most recently done first · click to sort by priority | `setdsort=priority` |
| `priority` | Priority | Sorted by priority · click to sort newest first | `setdsort=created` |
| `created` | Newest | Sorted newest first · click to sort by next review | `setdsort=review` |
| `review` | Next review | Soonest review first · click for the most recently done first | `setdsort=recent` |

The click names the next method, as the header's button does (sort-button D3), so a stale window writes what its label promised.

*Alternatives:*
- The button while the group is closed: the user chose open only.
- The header, beside the open method's button: the user chose the Done row, next to the list it sorts.

### D4. The verb and the hold
`setdsort=<method>` accepts the four methods and ignores anything else. `Store.set_settings` writes nothing when the value is already set. Like every verb but `prio`, it ends the hold, a move, a question and the Undo notice at the top of `M.action`, and keeps the selection.

`prio` starts the hold when `sort` or `done_sort` is `"priority"`. Each order function reads `held` only in its priority branch, so a hold started for one list doesn't touch the other.

### D5. Style
`.ob-dsortbtn` sits at the row's right end with `margin-left: auto`. It inherits the row's 11 px text, with `font-weight: 400` so it reads as a control rather than a heading. Inside the 24 px row it sets `line-height: 16px` and `padding: 1px 8px 1px 6px`, making it 18 px tall, so the row's height doesn't change. It may shrink (`flex: 0 1 auto; min-width: 0`), and its label is cut with "…", so on a narrow graph the icon stays and the label shortens. `.ob-sortt` in it gets `overflow: hidden; text-overflow: ellipsis`. The caret and "Done (n)" don't shrink.

### D6. The settings page
The "Order" section gains `setting_row("dsort", "Sort Done by", …)` after "Sort by", with `segments` Recently done, Priority, Newest first and Next review on `setdsort`. The note becomes: "Priority keeps your order within each priority. The sort button in the graph's header changes "Sort by", and the one in the open Done group's row changes "Sort Done by"."

## Risks / Trade-offs

- **A narrow graph.** At 460 px the left column is about 140 px wide. "▾ Done (3)" and "⇅ Recently done" don't both fit. → D5: the label is cut, the icon stays. The harness records what shows at 460 px.
- **The row's height.** A button taller than 24 px would be clipped by the row's `overflow: hidden`, and a taller row would move the done nodes off their lines. → D5's 18 px button; the harness checks the row's height and the done nodes' line ends at 1400 and 460 px.
- **The settings row's width.** Four segments are wider than "Sort by"'s three. → The harness shoots the page at 460 px.
- **Two buttons reading "Priority".** With both lists sorted by priority, the header and the Done row show the same label. → Each sits by the list it sorts; their tooltips say what a click does.
- **Downgrade.** 0.28.2 drops `done_sort` at its next write, and its Done group follows `sort`. An upgrade back copies `sort` again. → Acceptable for a preference.
- **Cost:** one sort of the done objectives per render, as today. → The harness checks renders stay within the 20 ms target.

## Migration Plan

D1's fallback reads every earlier store: `done_sort` copies `sort`, Your order as Recently done, so nothing moves on upgrade. A rollback to 0.28.2 shows the Done group in the open method's order.
