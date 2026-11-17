# Design

## Context

See proposal.md, "Why".

- **The setting today** (sort-by-priority D1): `state.settings.sort_priority`, a boolean. `normalize` in `lib/store.luau` reads it as `set.sort_priority ~= false` and rebuilds `settings` from its known fields, so an unknown field goes at the next write. The verb `setsort=on|off` changes it through `Store.set_settings`. The settings page draws it with `segments` and `setting_row` in `M.build_settings` (`lib/view.luau`).
- **One open order** (sort-by-priority D2): `Store.open_in_order(s, held?)` gives the open objectives' order to the left column and the tab menu in `View.build`, and to `link_tab` in `lib/app.luau`.
- **The Done group** sorts in the view: `sort_done` in `lib/view.luau`, most recently done first, ties by id. Review mode's list is built from the Done group's objectives and sorted on its own: due first, then most recently done.
- **The hold** (sort-by-priority D3): `held` in `lib/app.luau`. The first `prio` click with sorting on records every open objective's priority, and every other verb clears it at the top of `M.action`.
- **Grips and drops** (sort-by-priority D4): `objective_node` draws a grip on open objectives outside review mode. `Sorting = { lifted: number? }` is passed only while sorting by priority, and limits the drop zones to the lifted objective's priority.
- **The header** (`View.build`): the scope segments, then the Search button or the search chip, the tag chips, a spacer, the notices, Review, ⚙ and "＋ New objective". `.ob-head` is a wrapping flex row (`styles.css` lines 52–59).
- **Creation time:** `Store.create` sets `created = os.time()`, whole seconds (`lib/store.luau` line 398). Every record has it; nothing else writes it.

### Source record

| Claim | Evidence |
|---|---|
| Clicks in the canvas arrive as `canvas_action` with `act` and `value` | `tern.d.luau:1497`, `tern.d.luau:2252`; `window.luau` |
| Icon nodes take a name from Tern's set of 208 icons, which has no sort arrows; it has `list`, `swap`, `arrow-down` and `clock` | SDK book "Icon names" (`docs.stencil.so/tern/print.html`, fetched 2026-11-18) |
| The header wraps when it runs out of width | `styles.css` `.ob-head { flex-wrap: wrap }` |
| `tern.kv` is one JSON file shared by every window, each running its own VM | `tern.d.luau:2086`; `openspec/config.yaml` |

## Goals / Non-Goals

**Goals:**
- One stored method, read by one order function for open objectives and one for done objectives, so the column, the menu, the picker and the Done group can't disagree.
- The header button and the settings page change the same field, through the same verb.

**Non-Goals:**
- Storing the method per window or per session.
- Changing review mode's order.

## Decisions

### D1. The stored method
`state.settings.sort`, one of `"own"`, `"priority"` and `"created"`, replaces `sort_priority`. `normalize` keeps a valid `set.sort`. Without one, it reads the old field: `false` gives `"own"`, anything else `"priority"`. Since `normalize` rebuilds `settings` from known fields, `sort_priority` goes at the next write.

*Alternatives:*
- A second boolean beside `sort_priority`: rejected, since two flags allow a fourth, meaningless state.
- Storing it in `view`, beside the scope and tag filters: rejected. The settings page already shows it, and both places are shared by every window anyway.

### D2. The order functions
`Store.open_in_order(s, held?)` switches on the method:
- `"own"`: list order;
- `"priority"`: as today, by `held[id] or priority`, ties by list index;
- `"created"`: by `created`, larger first, ties by list index, so the result doesn't rest on `table.sort` being stable.

A new `Store.sort_done(s, list, held?)` sorts a list of done objectives in place, replacing the view's `sort_done`:
- `"own"`: by `done_at`, larger first;
- `"priority"`: by `held[id] or priority`, then by `done_at`, larger first;
- `"created"`: by `created`, larger first, then by `done_at`, larger first.

Each ends on `id`, as `sort_done` does today. It takes a list rather than building one, because the view filters the done objectives first (`visible`) and review mode builds its list from the filtered ones.

*Alternative:* a `Store.done_in_order(s)` that builds the list: rejected, since the view would then filter after sorting and review mode would need the unsorted list again.

### D3. The header button
After the Search button or the search chip, before the tag chips: an `el("span")` with classes `ob-btn ob-btn-quiet ob-sortbtn` and key `sort`, holding an icon node and `span("ob-sortt", label)`.

| Method | Label | Tooltip | Click |
|---|---|---|---|
| `own` | Your order | In your order · click to sort by priority | `setsort=priority` |
| `priority` | Priority | Sorted by priority · click to sort newest first | `setsort=created` |
| `created` | Newest | Sorted newest first · click for your order | `setsort=own` |

The click names the next method rather than "next", so it reuses the settings page's verb and a stale window can't skip a method: it writes what its label promised.

It shows in review mode too, so the header doesn't shift on entering review. There a click changes only the label, and the order the graph shows once review mode ends.

**Icon:** Tern's set has no sort arrows (Source record). The button uses `swap`. If the harness shot shows it reads poorly as sorting, `list` takes its place, and the task's Result records which.

*Alternatives:*
- A picker or segments: the user chose a cycling button.
- A new verb `sortnext`: rejected. The value-carrying verb already exists and stays testable from the settings page.

### D4. The verb
`setsort=<method>` accepts the three methods and ignores anything else, writing nothing. As today, `Store.set_settings` writes nothing when the value is already set. Like every verb but `prio`, it ends the hold, a move, a question and the Undo notice at the top of `M.action`, and it keeps the selection.

### D5. The hold
`prio` starts the hold when the method is `"priority"`, and now records every objective's priority, open and done. `Store.sort_done` reads it like `open_in_order`, so a badge click in the open Done group moves no node either. Sorted newest first or in your order, priority doesn't place a node, so no hold starts.

### D6. Grips and drops
`Sorting` becomes `{ by: string, lifted: number? }`, passed for every node:
- no grip and no drop zones when `by == "created"`;
- drop zones only on the lifted objective's priority when `by == "priority"`, as today;
- free drops when `by == "own"`.

The grip's tooltip keeps "Move within P<n>: …" for `"priority"`.

*Why no grip at all, newest first:* a move rewrites the stored order, which this method shows only among objectives created in the same second. A grip that lifts a node with no drop spot would be a dead control. The badge and title shift left by the grip's width when the method changes. That is acceptable, since every node is redrawn in a new order at the same moment anyway.

*Alternative:* a grip that is dimmed with a tooltip: rejected as a control that does nothing.

### D7. The settings page
The "Order" section's row becomes "Sort by", with `segments` Your order, Priority and Newest first on `setsort`. Its note reads: "Priority keeps your order within each priority. The Done group follows this choice, and the sort button in the graph's header changes it too." The classes are the page's existing ones.

### D8. Style
`.ob-sortbtn` is a flex row, `align-items: center`, `gap: 5px`, `padding: 3px 9px 3px 7px`, in the quiet button's chrome (`ob-btn ob-btn-quiet`, which already sets `user-select: none`). The label doesn't wrap.

## Risks / Trade-offs

- **The Done group's default order changes.** With the default Priority, 0.26.0 users see their Done group re-sorted by priority. → The user asked for the Done group to follow. Your order shows it as before.
- **Header width.** The button adds about 100 px ("Your order" is the longest label). On a narrow graph the header wraps sooner. → The columns sit below the header, and the edges are drawn inside `.ob-graph`, so the lines don't depend on the header's height. The harness checks the line ends at 460 px.
- **Icon (untested):** `swap` may draw horizontal arrows. → D3's fallback; the harness shot decides.
- **Ties within a second:** two objectives created in the same second keep the user's order. → Rare, and deterministic.
- **Downgrade.** 0.26.0 reads the missing `sort_priority` as On and shows Priority, whatever the method was. Its next write drops `sort`, so an upgrade back reads Priority too. → Acceptable for a preference.
- **Cost:** one sort of the open and one of the done objectives per render, as today. → Tens of objectives. The harness checks renders stay within the 20 ms target.

## Migration Plan

D1's fallback reads every earlier store: `sort_priority` false becomes Your order, anything else Priority. A rollback to 0.26.0 shows Priority.
