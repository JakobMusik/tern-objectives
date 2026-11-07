# Proposal

## Why

The user asked to prevent objectives with the same name. Instead of refusing a taken title, they chose on 2026-11-07 to tell same-named objectives apart by their creation date and time, shown after the title. That needs no duplicate handling at all.

Settled with the user:
- the time is drawn from the objective's creation time, never stored in the title, so Rename edits only the title and objectives created before this version get it too;
- the format is `11-07 14:32`: month-day and 24-hour time, in local time;
- it shows wherever an objective is picked: the graph's objective nodes, the tab's "Link to" menu and the "Link this tab" picker. Headings, toasts, the Undo notice and confirmations keep the plain title.

## What Changes

1. **Objective nodes:** the creation time follows the title, dimmed, as `11-07 14:32`. A long title is cut with "…" before the time is, so the time stays readable. It never changes, renaming included.
2. **Tab menu:** each "Link to" row reads `Write slides · 11-07 14:32`.
3. **"Link this tab" picker:** each row's dim text after the title reads `P2 · 11-07 14:32`.
4. Release as 0.14.0, with the README updated.

Out of scope:
- Refusing or renaming duplicate titles; titles stay as typed.
- Seconds in the time. Two objectives with one title created within the same minute still read alike.
- The time in headings (`Linked to “…”`), toasts, the Undo notice, the Delete and Close confirmations, and the ⋯ menu's title.
- The node's tooltip, which already gives the full creation time.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`: a new requirement for the creation time after the title on objective nodes.
- `tab-links`: a new requirement for the creation time in the tab menu's rows and the "Link this tab" picker.

## Impact

- `lib/dates.luau`: one formatter for the short creation time.
- `lib/view.luau`: the node's title line; the tab menu's row labels. `styles.css`: the time's look and how the title line shares its width.
- `lib/app.luau`: the "Link this tab" picker's row detail.
- `README.md`, `plugin.toml` (0.14.0).
