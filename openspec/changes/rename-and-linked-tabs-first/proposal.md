# Proposal

## Why

The user asked for two refinements to 0.6.1:
- Renaming takes three steps: ⋯, then Rename, then the field. It should take one.
- When an objective is selected, its linked tabs can be anywhere in the right column, scattered across sessions and the closed and other-window groups. Selecting it should bring them together at the top.

0.7.0 made renaming a double-click on the title, and the side note a double-click on the second line. In the user's live check, the double-click was unreliable and sometimes moved the selection to another objective: its first press is also the card's select click, and putting the selection back depended on the presses' timing (design, "D1–D2, dropped"). The user asked to drop the double-click and rename by key instead, with R as the default if possible.

## What Changes

1. **Rename key** (0.8.0, replacing 0.7.0's double-click).
   - A new command, "Objectives: Rename selected objective", opens the Rename field for the selected objective, filled with its title. It is the same field as ⋯ › Rename, which stays.
   - Its default key is ⌃⌘R, the partner of ⌃⌘O. R can't be the default: Tern binds plain R itself, and a plugin's Shift+R would take every capital R typed in any pane (design D6). The key can be rebound as `plugin.objectives.rename`.
   - Without a selected objective, or without the graph shown, the key shows a hint toast and changes nothing.
   - Double-click does nothing special again, and titles and side notes are selectable text again, as in 0.6.1.
2. **Linked tabs first while selected** (0.7.0, unchanged).
   - Selecting an objective moves the tabs linked to it into a top section headed `Linked to “<title>”`: live tabs under their session headings, then linked closed tabs and other-window tabs under their usual headings.
   - A divider labelled `Other tabs` follows, then every other tab in today's order. A session with tabs in both sections shows its heading in both.
   - The tab the graph was opened from stays first within each section, and "This session" filters both sections.
   - The split is fixed when the objective is selected. Linking or unlinking while it stays selected updates the link bars and lines but moves no tab.
   - Deselecting returns the column to its normal order.
   - An objective with no shown linked tab gets no top section and no divider, for example one just made with ＋ New objective.
- Release 0.7.0 (both, with the double-click), then 0.8.0 (the rename key), and update the README.

Out of scope:
- editing a title in place, which a canvas can't do;
- a key for the side note, which stays in ⋯;
- plain R or Shift+R as the default (above);
- scrolling the graph to bring the top section into view, which the canvas API doesn't offer, and which would also scroll the clicked objective away;
- the known limits: the "Link to" menu's height, the origin lost on reload, and closed rows' types.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`:
  - adds "Rename key";
  - adds "Linked tabs first", which also sets its precedence over "Tab column". "Tab column" itself is unchanged, since its text is already near OpenSpec's 500-character limit.
- `plugin-package`:
  - "Palette commands" lists the fourth command and its ⌃⌘R key;
  - "README" names both keys.

## Impact

- **Code:**
  - `lib/view.luau`: the right column builds a top section and a divider from a fixed tab set;
  - `lib/app.luau`: the selection keeps its fixed tab set, and `M.rename_selected` opens the Rename field for the selection;
  - `window.luau`: registers the rename command on ⌃⌘R;
  - `styles.css`: the section heading and divider.
- **Docs:** the README's commands table and "Using the graph".
- **Version:** 0.7.0, then 0.8.0.
