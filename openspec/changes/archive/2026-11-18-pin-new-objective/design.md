# Design

## Context

See proposal.md, "Why".

- **Selection** (`lib/app.luau`): `selected` is per window VM and never stored. `new_objective` sets it to the new id when no tab was given, which is the "＋ New objective" (`new` verb) and ⌥N (`M.new_key`) path. "New objective for this tab…" passes a tab and only toasts. A fresh `M.open` clears it; the reopen after a field (`finish` → `M.open(cx, true)`) keeps it.
- **The hold** (sort-by-priority D3): `held` is the same kind of state: never stored, passed to `View.build` and to `Store.open_in_order(s, held?)`, cleared at the top of `M.action` and by a fresh open.
- **One order function:** `Store.open_in_order` gives the left column (`View.build`), the tab menu (`menu_objs` in `View.build`) and the "Link this tab…" picker (`M.link_tab`). The Done group and review mode build their own lists.
- **Filters** (`visible` in `View.build`): the search and "This session" let the selected objective through; the tag filter doesn't.
- **Review mode:** `M.new_key` sets `reviewing = false` before asking. The `new` verb doesn't, so the left column keeps listing only the due objectives.
- **The title line** (`objective_node`): each line is a `div.ob-tline`, a nowrap flex row, 18 px tall, `overflow: hidden`. The last line holds `span.ob-title` (`flex: 0 1 auto; min-width: 3em`) and `span.ob-created` (`flex: none`). `.ob-chip` is 16 px tall (`line-height: 16px`); `.ob-review-due` tints a chip with the accent colour.

### Source record

| Claim | Evidence |
|---|---|
| Clicks in the canvas arrive as `canvas_action` with `act` and `value` | `tern.d.luau:2252`; `window.luau` |
| A click on an element with its own action, inside an element with another, runs only the inner one | select-tab-nodes task 6.1 |
| A click on part of a node without its own action selects the node | objectives-graph "Rename by clicking the title", "Beside a short title" |
| A field opened from the graph can close the graph, and `finish` shows it again with the selection kept | objectives-graph "Graph returns after its pickers", "Clicking into a field" |
| The accent-tinted chip renders in the node's second line | `docs/graph.png`, the "review due" chips |

## Goals / Non-Goals

**Goals:**
- One piece of state, `pinned`, read by the one order function, so the left column, the tab menu and the picker agree.
- Every way the selection changes or the objective stops being open ends the pin, without each verb having to know about it.
- No stored data and no change to the stored order.

**Non-Goals:**
- Changing the Done group, review mode's list or the other filters.

## Decisions

### D1. The state
`local pinned: string? = nil` in `lib/app.luau`, next to `held`. `new_objective` sets it, with `selected`, in the branch where the title created an objective and no tab was given. An empty title creates nothing and pins nothing.

*Alternatives:*
- A field in `kv.json`: rejected. Other windows would list it first too, and the user tied it to the selection, which is per window.
- A time limit: the user chose the selection.

### D2. What ends it
- **`build`**, after it checks `selected`: `pinned` becomes nil unless it equals `selected` and names an open objective. This one check covers a click on another node or on empty space, a search (which clears the selection), Delete, marking done, and other windows' changes seen on a refresh. Since every click draws through `build`, marking done and then Undo brings the objective back at its sorted place.
- **`lift`**, any grip: `pinned = nil` in `M.action`. A move works on the stored order, so it shows the stored order. Drop zones never point at a node out of its place.
- **A fresh `M.open`**, which clears `selected`, clears `pinned` with it.

*Alternative:* clearing it in each verb that changes the selection. Rejected: there are many, and a missed one would leave a node pinned while something else is selected.

### D3. The order
`Store.open_in_order(s, held?, pinned?)` sorts as today, then moves the pinned objective, if the list holds it, to index 1. `View.build` passes `ui_state.pinned` for the left column and the tab menu; `M.link_tab` passes `pinned`. The Done group and review mode don't call it, so they don't change. Badge clicks on the pinned objective change its priority under the hold, and it stays first.

*Alternative:* writing the objective to the top of the stored order. Rejected: it would change the user's order, which Configure's place decides.

### D4. Filters
`visible` skips the tag check for `o.id == ui_state.pinned`. The search and "This session" already let it through, since it is selected.

### D5. The chip
In `objective_node`, when `ui_state.pinned == o.id`, the last title line gets `span("ob-chip ob-newchip", "New", { key = "new", title = "Just created · listed first while it stays selected" })` after the creation time. `.ob-newchip` takes the accent tint of `.ob-review-due`. The chip is 16 px tall in the 18 px line, so the node's height doesn't change.

It comes after the time, so the time stays right after the title (objectives-graph "Creation time after the title"). When the line is too narrow, the title shrinks to 3em first, then the line's `overflow: hidden` cuts from the right: the chip before the time.

The chip has no action. A click on it is a click on the selected node, which clears the selection, as anywhere else on the node.

### D6. The button and review mode
The `new` verb sets `reviewing = false` before `new_objective`, as `M.new_key` does. Its draw comes from `finish`, so dismissing the field also leaves review mode, as with ⌥N.

## Risks / Trade-offs

- **The node moves when the pin ends.** Deselected, it goes to its sorted place, possibly far down. → That is the user's choice; the "New" chip says why it is on top until then.
- **A narrow column.** At 460 px the title line is short, and the chip may be cut. → D5 cuts the chip before the time. The harness records what shows at 460 px.
- **The palette picker while the graph is hidden.** `selected` lasts until the next fresh open, so "Link this tab…" run while the graph is closed lists the pinned objective first until then, as it already follows `held`. → Acceptable: it was just created.
- **Other windows** list it at its sorted place. → The pin is per window, like the selection.
- **Cost:** one removal and insertion per order call. → The harness checks renders stay within the 20 ms target.

## Migration Plan

Nothing is stored. A rollback to 0.29.0 lists new objectives at their sorted place, and the "＋ New objective" button leaves review mode on again.
