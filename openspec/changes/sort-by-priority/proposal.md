# Proposal

## Why

The user asked for this on 2026-11-09: a setting on the settings page that sorts the open objectives by priority, on by default.

Since 0.17.0 (custom-order-and-direct-controls), open objectives stay in the order the user gives them, and priority never reorders them. A P0 that starts low in the list stays there until it is moved by hand.

The user also asked that the list not re-sort while a priority is being changed, only after a click elsewhere. A badge click steps one priority at a time (P3 → P2 → P1 → P0), so a node that moved at every click would leave the pointer before the user reached the priority they wanted.

## What Changes

1. **A "Sort by priority" setting.** The settings page gets a third section, "Order", with "Sort by priority" On or Off. It is On by default, including for stores written before this version. It is saved in `kv.json` with the other settings and holds in every window and after a reload.
2. **Sorted list.** With sorting on, open objectives are listed P0 first and P3 last. Within one priority they keep the user's own order.
   - The left column, the "Link this tab…" picker and the tab menu all follow it, as they already share one order.
   - The Done group and review mode keep their own order.
   - Sorting doesn't change the stored order, so turning it off shows the user's own order again, unchanged.
3. **No re-sort while changing a priority** (the user's request). After a click on a priority badge, the list keeps its order, and further badge clicks, on any objective, keep it too. The badge shows the new priority at once. The next click on anything else in the graph sorts the list, and so does the next fresh open of the graph. Redraws in between, such as live refreshes, keep the order.
4. **The grip moves within a priority** (the user's choice). With sorting on, a lifted objective can be dropped only among objectives of its own priority: only they show drop spots. With sorting off, the grip works as today.
5. **New objectives and reopened ones.** "Top" and "Bottom" in Configure, and reopening a done objective, still set the place in the user's order. With sorting on, that is the top or bottom of the objective's priority.
6. **README:** the order paragraph, the settings bullet and the screenshot's alt text.
7. **Release 0.24.0**, a minor release: new behaviour, and a new default order.

Out of scope:
- Sorting by anything else, such as due date or creation time, or by several keys.
- Sorting the Done group or review mode.
- Changing an objective's priority by dragging it into another priority's group.
- Keeping the order still after keyboard commands: the hold ends on clicks, as asked, and on a fresh open.
- Retaking `docs/graph.png`: its demo store already lists the open objectives P0, P1, P1, P2, P2, P2, P3, which is the sorted order, so the screenshot still shows this version.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`:
  - new requirement "Sorting by priority": the sorted order and where it applies;
  - new requirement "Sorting waits for another click": the hold while badges are clicked;
  - new requirement "Moving while sorted": with sorting on, drop spots only on objectives of the lifted one's priority. "Moving objectives" is left as it is: at 495 characters, it has no room for the exception, so the new requirement states it;
  - "Custom order": the user's order applies within each priority while sorting is on, and the scenario where badge clicks don't move a node now has sorting off.
- `plugin-settings`:
  - new requirement "Sort setting": the "Order" section, On by default, saved and shared;
  - "Settings page": the page lists the order setting too;
  - "New objective defaults": with sorting on, Top and Bottom place a new objective within its priority.

## Impact

- `lib/store.luau`: a `sort_priority` setting, On when absent; one function that lists the open objectives in the shown order.
- `lib/view.luau`: the left column and the tab menu take that order; drop spots only within the lifted objective's priority while sorting; the settings page's "Order" section.
- `lib/app.luau`: the hold after a badge click and its end; the picker takes the shared order; the `setsort` verb.
- `README.md`.
- `openspec/specs/objectives-graph/spec.md` and `openspec/specs/plugin-settings/spec.md`: the delta above.
- `plugin.toml`: version 0.24.0.
- Stored data: one new field, `settings.sort_priority`. Older versions drop it at their next write, since they rebuild the settings from the fields they know, and the next open of this version reads it as On again.
