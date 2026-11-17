# Proposal

## Why

The user asked on 2026-11-18 for a button that changes how objective nodes are sorted, with sorting by time as one of the choices. The button must be reachable directly from the graph.

Today the open objectives sort two ways, your own order or by priority. That On/Off choice ("Sort by priority") lives only on the settings page, two clicks and a page away from the list it changes. There is no way to list objectives by when they were created, although each node already shows its creation time after its title ("Creation time after the title").

The user chose on 2026-11-18:
- **Time:** creation time, newest first.
- **The button:** one compact button in the header that shows the current method; each click moves to the next method.
- **The Done group:** follows the method too, instead of always listing the most recently done first.

## What Changes

1. **Three sort methods** replace the On/Off switch:
   - **Your order:** the order the user sets with the grips, as "Sort by priority" Off shows it today.
   - **Priority:** P0 first, the user's order within one priority, as "Sort by priority" On shows it today. This stays the default.
   - **Newest:** by creation time, newest first. Objectives created in the same second keep the user's order.
2. **A sort button in the graph's header**, after the Search button. It shows a sort icon and the current method's name: "Your order", "Priority" or "Newest". A click switches to the next method, Your order → Priority → Newest → Your order, and re-sorts the list at once. The tooltip names the current method and the next one. Like Configure, the click stores the method with the objectives, so every window and later opens use it. The selection is kept.
3. **The settings page** shows the same choice as a three-way "Sort by" row in its "Order" section, in place of "Sort by priority" On/Off. Both controls change the same stored method.
4. **The Done group follows the method:**
   - Your order: the most recently done first, as today, since done objectives have no order of the user's;
   - Priority: P0 first, the most recently done first within one priority;
   - Newest: by creation time, newest first.
5. **Priority badge clicks** hold the order while sorted by priority, as today. The hold now covers done objectives too, so a badge click in the open Done group doesn't move a node either.
6. **Sorted newest first, nodes have no grip**, since a move couldn't change what the list shows. The other methods keep the grips as today: free moves in Your order, moves within one priority in Priority.
7. **Stores from earlier versions:** a store whose "Sort by priority" was turned off reads as Your order; every other store reads as Priority.
8. **README:** the order paragraph, the "Organize" bullet and the Configure "Order" bullet describe the three methods and the button. `docs/graph.png` and `docs/review.png` are taken again, since the header gains the button.
9. **Release 0.27.0**, a minor release for the new behaviour.

Out of scope:
- **Other times:** sorting by due date, by done time for open objectives, or oldest first. The user picked creation time, newest first.
- **A direction toggle,** and choosing a method from a menu or picker. The button cycles.
- **Review mode's list:** it keeps its own order, the longest due first.
- **The right column:** tabs keep their order.
- **A keyboard shortcut or palette command** for the button.
- **Per-window methods:** the method is shared, like the other settings.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`:
  - new requirement "Sort button": the header button, its label, its cycle and its tooltip;
  - new requirement "Sorting newest first": the order by creation time, also in the link picker and tab menu, and no grips;
  - new requirement "Done group order": the Done group's order under each method;
  - "Sorting by priority" is removed, and the new "Sorted by priority" takes its place as one method among three. The old requirement kept the Done group in its own order, so its scenarios can't carry over;
  - "Sorting waits for another click": named as a method, and the hold covers done objectives;
  - "Moving while sorted": named as a method;
  - "Moving objectives": no grip while sorted newest first;
  - "Custom order": named as a method;
  - "Done objectives group": the group's order points to "Done group order".
- `plugin-settings`:
  - "Sort setting" is removed, and the new "Sort method" takes its place: a three-way "Sort by" choice, shared with the header button and read from earlier stores;
  - "New objective defaults": where a new objective shows under each method.

## Impact

- **`lib/store.luau`:**
  - `Settings.sort`, one of `"own"`, `"priority"` and `"created"`, replaces `sort_priority`; `normalize` reads it, falling back on the old field;
  - `Store.open_in_order` sorts by the method;
  - a new `Store.sort_done` sorts the Done group's objectives, replacing the view's `sort_done`.
- **`lib/view.luau`:**
  - the header's sort button;
  - the Done group sorted through the store;
  - no grip while sorted newest first;
  - the settings page's "Sort by" row.
- **`lib/app.luau`:** the `setsort` verb takes the three methods; the badge hold records done objectives too.
- **`styles.css`:** the sort button.
- **`README.md`**, **`docs/graph.png`**, **`docs/review.png`**.
- **`plugin.toml`:** version 0.27.0.
- **Stored data:** `settings.sort` replaces `settings.sort_priority` at the next write. A downgrade to 0.26.0 reads the missing `sort_priority` as On, so it shows Priority.
