# Proposal

## Why

The user asked to make the "Done (n)" header's text unselectable, because it gets highlighted too often. In the harness, a double-click on "Done (3)" highlighted the word "Done" (shot `d_after`, 2026-11-06). The group header rule in `styles.css` has no `user-select: none`, unlike the `Linked to` heading, the `Other tabs` divider and every control. With that line added to a fixtures copy, the same double-click left no highlight (shot `d_fixed`).

## What Changes

- Group and session headings stop being selectable text:
  - "Done (n)";
  - "Closed tabs" and "Other windows";
  - the session headings in the right column;
  - the `Linked to “<title>”` heading and the `Other tabs` divider, which already were.
- Objective titles, side notes, tab labels and pane details stay selectable, as the user asked in 0.8.0.
- Release as 0.8.3, a patch.

Out of scope:
- what a double-click on "Done (n)" does to the group: its presses still act as clicks, as today;
- review mode, one-click remove and the done changes (change `review-done-objectives`);
- resuming closed agents (change `resume-closed-agents`);
- the Done list's order: it already puts the most recently done first (`sort_done`, `lib/view.luau:67`). In the harness, marking o3 then o5 done listed o5, o3, then o7.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`: "Controls don't select text" also covers the group and session headings.

## Impact

- `styles.css`: `user-select: none` on `.ob-group` and `.ob-session`.
- `plugin.toml`: version 0.8.3.
- No Luau, store or README change.
