# Proposal

## Why

The user asked on 2026-11-18 for a separate sort button for done objectives, so the Done group can be sorted differently from the open objectives. Since 0.27.0 ("sort-button"), one stored method sorts both lists: the header's sort button and Configure's "Sort by" change it, and the Done group follows.

The user chose on 2026-11-18:
- **Where:** in the "Done (n)" row, at its right end, shown only while the group is open.
- **Methods:** Recently done, Priority and Newest, as the Done group sorts today, plus **Next review**, the soonest review first.
- **After the upgrade:** the Done group starts sorted as it is now, by the current method, so nothing moves.

## What Changes

1. **A second stored method for the Done group,** apart from the open objectives' method:
   - **Recently done:** the most recently done first, as Your order shows the Done group today;
   - **Priority:** P0 first, the most recently done first within one priority, as today;
   - **Newest:** by creation time, newest first, as today;
   - **Next review:** by the date of the next review, the soonest first, so reviews already due come first, then the most recently done.
2. **A sort button in the open Done group's row,** at its right end. It shows the sort icon and the method's name: "Recently done", "Priority", "Newest" or "Next review". A click switches to the next method, Recently done → Priority → Newest → Next review → Recently done, re-sorts the Done group at once, keeps the selection and leaves the group open. Its tooltip names the current method and the next. While the group is closed, the row shows no button.
3. **The header's sort button sorts only the open objectives.** Its labels, cycle and tooltips stay as they are.
4. **Configure** gets a second row in its "Order" section, "Sort Done by", with Recently done, Priority, Newest first and Next review. It changes the same stored method as the Done group's button. The section's note says which button changes which row.
5. **Priority badge clicks** hold the order while either list is sorted by priority, so a badge click in the open Done group moves no node while the Done group is sorted by priority, whatever the open list uses.
6. **Stores from earlier versions:** a store without the Done group's method reads it from the open objectives' method, Your order as Recently done, so the Done group lists the same order as before.
7. **README:** the "Organize" bullet, the order paragraph and the Configure "Order" bullet describe the second button. `docs/graph.png` is taken again, since its open Done group now shows the button, and its alt text names it. `docs/review.png` shows review mode, which has no Done group, and stays as it is.
8. **Release 0.29.0**, a minor release for the new behaviour.

Out of scope:
- **Review mode's list:** it keeps its own order, the longest due first.
- **The open objectives' methods:** no "Next review" or "Recently done" for them; the header button is unchanged.
- **A button while the Done group is closed,** and a menu or picker for the methods. The button cycles.
- **Directions:** no oldest-first or latest-review-first variants.
- **The right column, the "Link this tab…" picker and the tab menu:** they list open objectives only, in the open method's order.
- **Per-window methods:** the Done group's method is shared like the other settings.
- **A keyboard shortcut or palette command** for the button.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`:
  - new requirement "Done group sort button": the button in the open Done group's row, its labels, cycle and tooltips;
  - new requirement "Done group sorting": the Done group's order under each of its four methods, its own method apart from the open objectives';
  - "Done group order" is removed. It tied the Done group to the open objectives' method and named it "Your order", so its scenarios can't carry over;
  - "Done objectives group": the group's order points to "Done group sorting";
  - "Sort button": it sorts the open objectives only;
  - "Sorting waits for another click": the hold applies while either list is sorted by priority.
- `plugin-settings`:
  - new requirement "Done group sort method": the "Sort Done by" row, shared with the Done group's button and read from earlier stores.

## Impact

- **`lib/store.luau`:** `Settings.done_sort`, one of `"recent"`, `"priority"`, `"created"` and `"review"`, read by `normalize` with the fallback on `sort`; `Store.sort_done` sorts by it.
- **`lib/view.luau`:** the button in the open Done group's row; the settings page's "Sort Done by" row and note.
- **`lib/app.luau`:** a `setdsort` verb; the badge hold starts when either method is by priority.
- **`styles.css`:** the button's size in the 24 px group row.
- **`README.md`**, **`docs/graph.png`**.
- **`plugin.toml`:** version 0.29.0.
- **Stored data:** `settings.done_sort` is added at the next write. A downgrade to 0.28.2 drops it at its next write; the Done group then follows the open method again.
