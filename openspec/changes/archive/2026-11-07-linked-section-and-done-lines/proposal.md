# Proposal

## Why

The user asked for two refinements on 2026-11-07:
- **Linking feels like it did nothing.** With an objective selected, a tab linked with "＋ Link" stays below the "Other tabs" divider until the objective is selected again. The divider is a 1 px grey rule with 11 px grey text, easy to miss.
- **Done objectives can still be linked and unlinked.** Selecting a done objective shows the "＋ Link" / "× Unlink" bar on every tab, and the bar works. Done objectives are meant to be immutable, kept only for review. They also draw no lines, so selecting one doesn't show what it was linked to.

Settled with the user on 2026-11-07:
- unlinking moves a tab below the divider at once too;
- in review mode, a done objective's lines also show only while it is selected;
- done objectives' lines are green, `#30a46c`;
- the divider becomes a bold accent rule: a 3 px accent bar across the column, with "Other tabs" on a pill in its middle.

## What Changes

1. **The top section follows the links:** while an objective is selected, the `Linked to “X”` section holds the tabs it links now. Linking a tab moves it into that section at once, and unlinking moves it below the divider at once. Unlinking the last one removes the heading and the divider; linking the first adds them. This replaces "Linking or unlinking … SHALL NOT move a tab".
2. **A bolder divider:** a 3 px accent-coloured bar across the right column, with "Other tabs" on an accent-outlined pill in its middle. The row grows from 24 px to 32 px, and the lines stay on their nodes.
3. **Done objectives' links are fixed:** selecting a done objective shows no link bar on any tab, and the plugin refuses link changes to a done objective from any path. The tab menu and "Link this tab" already list only open objectives.
4. **Done objectives' lines on selection:** while a done objective is selected, its lines show, thick, in green, dashed to closed or elsewhere tabs, with the other lines faded as for any selection. With no done objective selected, no done objective draws lines. Review mode follows the same rule, so it no longer draws every listed objective's lines.
5. Release as 0.13.0, with the README updated.

Out of scope:
- Reopening a done objective, or any other way to edit a done objective's links. Undo right after marking done stays as it is.
- Changing the lines of open objectives, their priority colours, or how they fade.
- Changing the "Closed tabs" and "Other windows" headings, the session headings, or the `Linked to` heading's look.
- Moving tabs when they are linked or unlinked with no objective selected: the column's normal order doesn't depend on links.
- The deferred Resume failure recorded in `close-linked-tabs` task 5.3.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`: "Linked tabs first" (the section follows the links; the divider's look); "Link lines" and "Done objectives group" (done objectives' lines only while selected, in green); "Selection" (no link bar for a done objective).
- `tab-links`: "Linking from the graph" (only an open objective shows the link bar; a done objective's links can't change).
- `objective-review`: "Review mode" and its closed-tab scenario: the listed objectives' lines show only for the selected one.

## Impact

- `lib/app.luau`: the fixed `pinned` set and its comment go; the `link=` action ignores a done objective.
- `lib/view.luau`: the top section from the selected objective's current links; the divider's markup; no link bar for a done objective; done objectives' edges.
- `lib/edges.luau`, `lib/layout.luau`: a done colour for edges; the divider's row height in the layout sheet and its stack helper.
- `lib/store.luau`: `toggle_link` leaves a done objective unchanged.
- `styles.css`: the divider.
- `README.md`, `plugin.toml` (0.13.0).
