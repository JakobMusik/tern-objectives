# Proposal

## Why

Asked by the user on 2026-11-08. Today a click on an objective's priority badge steps P0 → P1 → P2 → P3 → P0, which is downward, and a new objective starts at P2. Worse, every click re-sorts the graph, so the node jumps away. Changing a priority by more than one step means finding the node again before each click.

## What Changes

1. **Clicks raise the priority:** P3 → P2 → P1 → P0, then back to P3.
2. **New objectives start at P3**, the lowest priority. This covers both "＋ New objective" and "Objectives: New objective for this tab…". A stored record without a priority reads as P3 too, so the plugin has one default. Existing objectives keep their priorities.
3. **The order holds while priorities change.**
   - After a badge click, the left column keeps the order it had, through any further badge clicks on any objective, so the node stays under the pointer.
   - The next click in the graph on anything else sorts it again, and so does opening the graph fresh.
   - An objective that appears during the hold, for example one made with the palette command, is listed after the held ones.
   - The "Link this tab" picker and the tab menu stay sorted.
4. **Release 0.15.0**, a minor release because behaviour changes.

Out of scope:
- A key for changing the priority, or a way to lower it other than wrapping from P0 to P3.
- The badge colours, and the order rules themselves (priority, then due date, then created time).
- A timer that re-sorts a held column. It would move the node while the user is still deciding, the thing this change removes.
- Changing the priorities of existing objectives.
- The README. It names the priorities but not the click order or the default.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`:
  - Priority badge, Objective ordering and New objective button are modified;
  - Order held while changing priority is new.
- `objective-store`: Objective record is modified (the P3 default); Missing priority is new (a record without one reads as P3).
- `tab-links`: New objective for this tab command (P3), and Creation time in link choices, whose picker scenario shows `P3 · ` for objectives made at the new default.

## Impact

- `lib/store.luau`:
  - `cycle_priority` steps upward;
  - `create` and the record loader default to P3.
- `lib/app.luau`:
  - the window's held order, set by the first badge click and cleared by any other click or a fresh open;
  - an empty-space click re-renders while a hold is set.
- `lib/view.luau`: the open objectives follow the held order when one is given.
- `openspec/specs/*`: the deltas above.
- `plugin.toml`: version 0.15.0.
