# Proposal

## Why

The user asked for two refinements to 0.6.1:
- Renaming takes three steps: ⋯, then Rename, then the field. The side note is the same, through ⋯ › Side note. Double-clicking the text itself should open its field.
- When an objective is selected, its linked tabs can be anywhere in the right column, scattered across sessions and the closed and other-window groups. Selecting it should bring them together at the top.

## What Changes

1. **Double-click to edit.**
   - Double-clicking an objective's title opens the Rename field, filled with the title.
   - Double-clicking its second line, on the side note or the empty space where one goes, opens the side-note field, filled with the note.
   - These are the same fields as ⋯ › Rename and ⋯ › Side note, which stay. A canvas can't hold a text input, so the text isn't edited in place.
   - A double-click leaves the selection as it was before it.
   - Titles and side notes become unselectable text, so a double-click doesn't highlight a word. The node's tooltip still holds the full title and note.
2. **Linked tabs first while selected.**
   - Selecting an objective moves the tabs linked to it into a top section headed `Linked to "<title>"`: live tabs under their session headings, then linked closed tabs and other-window tabs under their usual headings.
   - A divider labelled `Other tabs` follows, then every other tab in today's order. A session with tabs in both sections shows its heading in both.
   - The tab the graph was opened from stays first within each section, and "This session" filters both sections.
   - The split is fixed when the objective is selected. Linking or unlinking while it stays selected updates the link bars and lines but moves no tab.
   - Deselecting returns the column to its normal order.
   - An objective with no shown linked tab gets no top section and no divider, for example one just made with ＋ New objective.
- Release as 0.7.0 and update the README.

Out of scope:
- editing a title or note in place, which a canvas can't do;
- double-click on the due chip or tag chips: the whole second line opens the side note, chips included;
- scrolling the graph to bring the top section into view, which the canvas API doesn't offer, and which would also scroll the clicked objective away;
- the known limits: the "Link to" menu's height, the origin lost on reload, and closed rows' types.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`:
  - "Controls don't select text" adds titles and side notes;
  - adds "Double-click to edit";
  - adds "Linked tabs first", which also sets its precedence over "Tab column". "Tab column" itself is unchanged, since its text is already near OpenSpec's 500-character limit.

## Impact

- **Code:**
  - `lib/view.luau`: the right column builds a top section and a divider from a fixed tab set, and the title and second line take double-click actions;
  - `lib/app.luau`: the selection keeps its fixed tab set, the new `ren=` and `note=` actions open the existing fields, and a double-click restores the selection that was in place before it;
  - `styles.css`: the section heading and divider, and unselectable titles and notes.
- **Docs:** the README's "Using the graph", and its screenshot if the selected state is shown.
- **Version:** 0.7.0.
