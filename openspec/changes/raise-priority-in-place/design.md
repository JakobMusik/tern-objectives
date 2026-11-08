# Design

## Context

- **Cycle:** `Store.cycle_priority` sets `o.priority = (o.priority + 1) % 4` (`lib/store.luau:371–376`), so a click lowers the priority and P3 wraps to P0. The badge's click sends `prio=<id>` (`lib/view.luau:145–149`), handled in `M.action` (`lib/app.luau:830–833`).
- **Defaults:** `Store.create` writes `priority = 2` (`lib/store.luau:271`). Both "＋ New objective" and "New objective for this tab…" go through it. The loader fills a missing priority with 2 (`lib/store.luau:112`).
- **Order:**
  - `View.build` sorts the shown open objectives with `M.sort_open` (`lib/view.luau:365`): priority, due date, created, id. It then lays them out top to bottom.
  - The tab menu sorts its own list with the same function (`lib/view.luau:468`).
  - "Link this tab" uses `sorted_open` in `lib/app.luau:230–239`, which calls it too.
- **Per-window state:** `selected`, `undo` and `reviewing` are module locals of `lib/app.luau` (lines 16, 27, 54). They are never stored, so each window has its own and a plugin reload clears them.
  - A fresh `M.open` (no `keep_origin`) drops `undo` and `reviewing` (`lib/app.luau:133–141`).
  - `M.action` drops `undo` on every click but Undo and "Close <n> tabs" (lines 771–776). Every handled click then ends in `M.render` (line 907), except `bg` with nothing to clear, which returns early (lines 779–782).
- **Node identity:** each objective node is keyed `o:<id>` (`lib/view.luau:182`), so reordering the column moves nodes rather than rebuilding them.

### Source record

| Claim | Evidence |
|---|---|
| A badge click sends only `prio=`, not also the node's `sel=` | Not in `tern.d.luau`. The badge and the node each declare their own `click` action (`lib/view.luau:148, 182`), and the archived "Cycle wraps" check passed with a single click. Treated as a risk and checked first in 1.3. |
| Store changes from another window re-render this window's graph from the store | `config.yaml` context: every window runs its own VM against the same `kv.json`; `lib/app.luau` `M.render` reads `Store.read()` in `build` |
| No version wrote a record without `priority` | `Store.create` has set it since 0.1.0 (`lib/store.luau:271`); only a hand-edited `kv.json` lacks it |

## Goals / Non-Goals

**Goals:**
- A badge click raises the priority, wrapping from P0 to P3.
- One default priority, P3, for new objectives and for records without one.
- The node the user is clicking stays put until the user does something else.

**Non-Goals:**
- Changing the sort rules, badge colours, the picker's or tab menu's order, or any stored priority.
- A key binding or a "lower" action.

## Decisions

### D1. Raise on click
`cycle_priority` sets `o.priority = (o.priority + 3) % 4`: 3 → 2 → 1 → 0 → 3. The badge's tooltip stays "Priority: click to change".

Alternative: a separate "lower" click (right-click or modifier). Rejected: four values cycle in at most three clicks, and the hold (D3) keeps those clicks on one spot.

### D2. One default: P3
- `Store.create` writes `priority = 3`.
- The loader fills a missing priority with 3.
- Stored priorities are never rewritten.

Alternative: keep the loader at 2. Rejected: two defaults for the same field, for records no version writes.

### D3. A held order per window, ended by any other click
- **State:** `held: { string }?`, a module local of `lib/app.luau` beside `selected`. It holds open objective ids in the order last drawn, and is never stored.
- **Start:** act `prio`. If `held` is nil, set it to the ids of `sorted_open(Store.read())`, taken before `Store.cycle_priority` changes anything.
  - That is the order on screen: filters hide objectives but don't change the relative order of the rest.
  - Further `prio` clicks, on any objective, leave it as it is.
- **End:**
  - At the top of `M.action`, any act other than `prio` sets `held = nil`, beside the existing `drop_undo`.
  - `bg` no longer returns early when it cleared a hold, so a click on empty space re-renders sorted.
  - `menu`, `new`, `tab`, `resume`, `pane` and `prune` leave drawing to their own flow, or close the graph, and returned before `M.render`. They now set a `later` flag instead. `M.action` ends with `M.render` unless `later` is set and no hold just ended, so the click that ends a hold always draws the column sorted. `M.render` does nothing once the graph is closed, as after a jump.
  - A fresh `M.open` clears it, like `reviewing`. A plugin reload clears it, as for every module local.
- **View:** `View.Ui` gets `held: { string }?`, passed by `build`. After `M.sort_open(open_list)`, when `held` is set:
  - objectives whose id is in `held` take the held order;
  - the rest follow in sorted order, for example an objective made with the palette command or restored in another window.
- **Unchanged:** the Done group, review mode's list, the tab menu (`menu_objs`) and "Link this tab" keep `sort_open`.

Alternatives:
- A timer that re-sorts after a few seconds. Rejected: the node would jump while the user decides, which is the problem being fixed.
- Holding until the graph closes. Rejected: other clicks would keep acting on a stale order with no way to sort short of reopening.
- Pinning only the clicked node. Rejected: the others would still shift around it, so a second badge's position changes after the first click.
- Storing the hold in `kv.json`. Rejected: it would freeze other windows' graphs and survive reloads, and the hold belongs to one window's clicks, like the selection.

## Risks / Trade-offs

- **[Click dispatch]** If a badge click also delivers the node's `sel=`, that click would end the hold at once. → 1.3's first check reads the selection and the order after a badge click. If `sel=` fires, stop and update this design (for example, have `sel` keep the hold when it arrives with a `prio`).
- **[An unsorted column]** While held, a P0 can sit below a P3. → Intended. It lasts only until the next other click, and the lines still join each node to its tabs.
- **[Picker and column differ]** During a hold, "Link this tab" and the tab menu list the new priorities sorted, while the column keeps the old order. → Accepted and stated in the spec. Those lists are read top to bottom, not clicked repeatedly.
- **[Render cost]** One extra sort of the open objectives per render while held. → Tens of objectives, far under the 50 ms budget. 1.3 records the render times from the log.

## Migration Plan

Nothing stored changes, and existing objectives keep their priorities. Only objectives created after the update start at P3. Release 0.15.0. To roll back, install `v0.14.1` again.
