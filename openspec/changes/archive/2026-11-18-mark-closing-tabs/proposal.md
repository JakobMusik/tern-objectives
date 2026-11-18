# Proposal

## Why

On 2026-11-18 the user asked that the header's "Close n done tabs" button highlight the tab nodes it is about to close, or at least make clear what will be closed. Today the button only turns into "Close n done tabs? · Close · Cancel". Those tabs look like any other tab that no open objective links: dashed and grey. A done objective's "Close n tabs", in its button row or in the "Marked done" notice, has the same gap. Its question gives a count of the tabs that close and the tabs that stay open, but not which tabs they are.

On 2026-11-18 the user chose:
- **When:** only while the question is showing, after the first click. Nothing closes before Close is clicked, so the question works as the preview.
- **Which buttons:** all three. These are the header's "Close n done tabs", and a done objective's "Close n tabs" in its button row and in its "Marked done" notice.

After 0.31.0 shipped the marks, the user asked on 2026-11-18 to "also put the tab to the front of the list if possible". They confirmed the plan: a "Closes" section at the top of the tab column for all three questions, and release 0.32.0, with their live check covering both releases.

## What Changes

1. **The tabs a question would close are marked.** While one of the three questions is showing, each tab node it would close gets:
   - a red ring;
   - a red "Closes" chip, first on its second line.

   Tabs that stay open get no mark. For a done objective, those are the linked tabs an open objective also links.
2. **The question's tooltip names those tabs.** It starts with, for example, "Close “Guides” and “Notes”?", in place of the "Close n tabs?" that the bar's tooltip starts with today, and is followed by the rest of today's tooltip. A tab the graph doesn't show, such as one in another session under "This session", is still named there.
3. **The marks go when the question ends.** That happens on Close, on Cancel or on any other click. It also happens when the "Marked done" notice expires while it is asking.
4. **The tabs a question would close are listed first** (0.32.0). While the question shows, those tab nodes move to the top of the tab column. They sit under a red "Closes" heading, with their session headings. The rest of the column follows as it would without them:
   - with an objective selected, the `Linked to “X”` section comes next and holds its other linked tabs, then the "Other tabs" divider;
   - otherwise, the "Other tabs" divider comes next.

   When the question ends, every tab goes back to its place. Only the tab column moves: each question's answers are in the header or the objective's buttons, so nothing moves under the pointer.
5. **README:** the "Finish cleanly" item says the question marks the tabs it would close and lists them first.
6. **Release 0.31.0**, a minor release for the marks; **release 0.32.0**, a minor release for the order.

Out of scope:
- **Marking on hover**, before the first click. Tern sends plugins no hover events, and its CSS has no `:has()` or `~`. So pointing at the header button can't change the tab nodes unless the header is rebuilt, and the user chose not to rebuild it.
- **A tab's own trash icon:** its "Close tab?" question already sits on the tab node itself. It neither marks nor moves the tab, since moving it would move its Close button from under the pointer.
- **Tabs the scope hides,** such as tabs in another session under "This session": they stay hidden, and the tooltip names them.
- **Scrolling** the window to the top of the tab column.
- **Any change to what is closed**, or to the question's own text, buttons and counts.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`:
  - a new requirement, "Tabs marked while a close asks". It covers the ring and chip on each tab the showing question would close, the tooltip that names those tabs, and the end of the marks;
  - a new requirement, "Closing tabs listed first", covering the "Closes" section at the top of the tab column and what follows it;
  - "Linked tabs section": its section comes after any "Closes" section, and holds the selected objective's other linked tabs. Its scenarios stay.

  The other close requirements stay as they are: "Closing a done objective's tabs", "Closing tabs from the done notice", "Closing tabs of done objectives" and "Inline confirmation". Their text still holds, and the new requirements add to all three questions at once.

## Impact

- **`lib/view.luau`:**
  - **`View.build`:** gathers the tabs the showing question would close, if any, and passes each tab node whether it closes. Before placing the tab column, it puts the shown ones in a "Closes" section ahead of the linked section or the divider.
  - **`tab_node`:** adds the `ob-tclosing` class and the "Closes" chip.
  - **The three questions:** their tooltips name the tabs.
- **`styles.css`:** the red ring (`outline`, which leaves node heights and the line layout alone), the chip's red tint, and the "Closes" heading's colour.
- **`README.md`**.
- **`plugin.toml`:** version 0.31.0, then 0.32.0.
- **Stored data:** none. **`lib/app.luau`:** no change, since the question state it passes is enough.
