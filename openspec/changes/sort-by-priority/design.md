# Design

## Context

See proposal.md, "Why".

- **Order today** (custom-order-and-direct-controls D1): the open objectives' order is their order in `state.objectives`. Three places read it, each with its own loop:
  - `View.build`, the left column: `open_list`, filtered by `visible`;
  - `View.build`, the tab menu: `menu_objs`, every open objective;
  - `open_in_order` in `lib/app.luau`, the "Link this tab…" picker.
- **Settings** (custom-order-and-direct-controls D8): `state.settings` holds `start_priority` and `new_place`. `normalize` in `lib/store.luau` rebuilds it from those fields alone, and `Store.set_settings` changes it. The settings page draws each choice with `segments` and `setting_row` (`lib/view.luau`), and the action verbs `setprio` and `setplace` change them.
- **Badge clicks:** `prio=<id>` runs `Store.cycle_priority`, P3 → P2 → P1 → P0 → P3, and redraws.
- **UI state that a click ends:** `M.action` in `lib/app.luau` first ends a question (`confirm`) and a move (`moving`) for every verb but their own. A `bg=` click with nothing to end returns without drawing.
- **Redraws that are not clicks:** the live refresh calls `App.render` from its timers (`lib/refresh.luau` lines 72–73 and 93–96). A plugin reload's timer does the same (`window.luau` line 23), and so does the reopen after one of the graph's pickers (`M.open(cx, true)`). Only a fresh `M.open` resets the VM's UI state.

### Source record

| Claim | Evidence |
|---|---|
| Clicks in the canvas arrive as `canvas_action` with `act` and `value` | `tern.d.luau:1497`, `tern.d.luau:2252`; `window.luau:96–100` |
| `tern.kv` is one JSON file shared by every window, each running its own VM | `tern.d.luau:2086`; `openspec/config.yaml` |
| Segmented choices and their rows are drawn with plain plugin CSS | `styles.css` "Configure's settings page" rules, used by Start at and Place since 0.17.0 |

## Goals / Non-Goals

**Goals:**
- One function that gives the shown order, so the column, the menu and the picker can't drift apart.
- The stored order stays the user's own, so Off brings it back and moves keep their meaning.

**Non-Goals:**
- Storing the hold, or sharing it across windows: it lives in the window where the badge was clicked.

## Decisions

### D1. The setting
`state.settings.sort_priority`, a boolean. `normalize` reads it as `set.sort_priority ~= false`: absent means On, as the user asked for the default, and stores from before this version are absent. A verb `setsort=on|off` changes it through `Store.set_settings`, and writes nothing when the value is already set.

*Alternative:* a string, like `new_place`. A boolean is enough for two states, and reading anything but `false` as On keeps the default robust.

### D2. One order function
`Store.open_in_order(s, held?)` returns the open objectives in the shown order:
- With sorting off, it returns them in list order.
- With sorting on, it sorts by priority, using `held[id]` when the hold has one (D3) and `o.priority` otherwise. Ties go by list index, so the result doesn't depend on whether `table.sort` is stable.

It replaces the three loops in Context: the left column filters its result with `visible`, the tab menu takes it whole, and `link_tab` takes it whole, as each does today. The Done group's `sort_done` and review mode's list are untouched.

*Alternatives:*
- Writing the sorted order into the list at each badge click: rejected, since it would lose the user's order for good, and Off couldn't bring it back.
- Sorting in the view only: rejected, since the picker would need its own copy.

### D3. The hold
`held: { [string]: number }?` in `lib/app.luau`, beside `moving`. It is never stored.
- **Start:** `prio` with sorting on and no hold yet first records every open objective's priority from `Store.read()`, then cycles. Later badge clicks keep that record, so no node moves while badges are clicked.
- **End:** every verb but `prio` clears it at the top of `M.action`, as it ends a move. A `bg=` click that ended a hold draws, which today's early return would skip. A fresh `M.open` clears it too.
- **Kept:** redraws from the live refresh, the reload timer and the pickers' reopen keep it, since they don't pass through `M.action` or the fresh open.
- **Passed on:** `View.build` gets it as `ui_state.held`, and `link_tab` passes it to `open_in_order`.

*Why priorities, not a list of ids:* an objective missing from the record sorts by its own priority. That covers objectives created meanwhile, by ⌥N or in another window, with no extra code, and removed ones simply drop out.

*Keyboard commands* (⌥N, ⌥⇧R) don't go through `M.action`, so they keep the hold until the next click. The user asked for sorting after a click elsewhere, so the proposal leaves this out of scope.

### D4. Drop spots while sorted
In the node builder, while a node is lifted and sorting is on, a node gets the two drop zones only when its priority equals the lifted objective's. A click on any other node is an ordinary `sel=` and ends the move, as "Moving objectives" already says of other clicks.

`Store.move` needs no change. Putting the record before or after a target of the same priority in the list puts it in that same place within the priority, whatever records of other priorities lie in between.

The grip's tooltip with sorting on reads "Move within P<n>: click, then click where it goes", so the limit is visible before the lift.

*Alternative:* hiding the grip on an objective with no other shown objective of its priority. Rejected: the badge and title would shift sideways whenever a priority changed. A lone objective can still be lifted, and Cancel ends the move.

### D5. The settings page
A third section `ob-ssec` keyed `order`, after "New objectives":
- a heading "Order";
- a row "Sort by priority" with `segments` On and Off on `setsort`;
- a dim note, "Within one priority, objectives keep your order. Off shows your order as it is."

It reuses the page's existing classes, so `styles.css` doesn't change.

### D6. New and reopened objectives
No code change. `Store.create` and `Store.reopen` place the record at the top or bottom of the list. With sorting on, it then shows at the top or bottom of its priority, as "New objective defaults" now says.

## Risks / Trade-offs

- **The node a user clicks to select can move under the pointer**, when that click ends a hold. → This is the user's request: sorting happens after the click elsewhere. Only the first click after badge clicks can move nodes.
- **The hold is per window.** Another window's graph sorts at once on its next redraw. → Each window's VM has its own UI state already (selection, moves), and the stored priorities are the same everywhere.
- **A new default order.** Users of 0.23.0 see their list re-sorted after updating. → The user asked for On by default. The stored order is untouched, and Off brings it back.
- **Downgrade.** 0.23.0 drops `sort_priority` at its next write (it rebuilds the settings from the fields it knows), so a later upgrade reads On again. → Acceptable for a preference. Nothing else is lost.
- **Cost:** one sort of the open objectives per render and per picker. → The lists hold tens of objectives. The harness checks that renders stay within the 20 ms target.

## Migration Plan

None beyond D1: an absent field reads On. A rollback to 0.23.0 ignores the field and shows the stored order.
