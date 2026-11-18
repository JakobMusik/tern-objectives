# Proposal

## Why

On 2026-11-18 the user asked that the header's "Close n done tabs" button highlight the tab nodes it is about to close, or at least make clear what will be closed. Today the button only turns into "Close n done tabs? · Close · Cancel". Those tabs look like any other tab that no open objective links: dashed and grey. A done objective's "Close n tabs", in its button row or in the "Marked done" notice, has the same gap. Its question gives a count of the tabs that close and the tabs that stay open, but not which tabs they are.

On 2026-11-18 the user chose:
- **When:** only while the question is showing, after the first click. Nothing closes before Close is clicked, so the question works as the preview.
- **Which buttons:** all three. These are the header's "Close n done tabs", and a done objective's "Close n tabs" in its button row and in its "Marked done" notice.

## What Changes

1. **The tabs a question would close are marked.** While one of the three questions is showing, each tab node it would close gets:
   - a red ring;
   - a red "Closes" chip, first on its second line.

   Tabs that stay open get no mark. For a done objective, those are the linked tabs an open objective also links.
2. **The question's tooltip names those tabs.** It starts with, for example, "Close “Guides” and “Notes”?", in place of the "Close n tabs?" that the bar's tooltip starts with today, and is followed by the rest of today's tooltip. A tab the graph doesn't show, such as one in another session under "This session", is still named there.
3. **The marks go when the question ends.** That happens on Close, on Cancel or on any other click. It also happens when the "Marked done" notice expires while it is asking.
4. **README:** the "Finish cleanly" item says the question marks the tabs it would close.
5. **Release 0.31.0**, a minor release, since this adds behaviour.

Out of scope:
- **Marking on hover**, before the first click. Tern sends plugins no hover events, and its CSS has no `:has()` or `~`. So pointing at the header button can't change the tab nodes unless the header is rebuilt, and the user chose not to rebuild it.
- **A tab's own trash icon:** its "Close tab?" question already sits on the tab node itself.
- **Scrolling** to a marked tab that is out of view. The tooltip names every tab instead.
- **Any change to what is closed**, or to the question's own text, buttons and counts.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`: a new requirement, "Tabs marked while a close asks". It covers the ring and chip on each tab the showing question would close, the tooltip that names those tabs, and the end of the marks. The existing requirements stay as they are: "Closing a done objective's tabs", "Closing tabs from the done notice", "Closing tabs of done objectives" and "Inline confirmation". Their text still holds, and the new requirement adds to all three questions at once.

## Impact

- **`lib/view.luau`:**
  - **`View.build`:** gathers the tabs the showing question would close, if any, and passes each tab node whether it closes.
  - **`tab_node`:** adds the `ob-tclosing` class and the "Closes" chip.
  - **The three questions:** their tooltips name the tabs.
- **`styles.css`:** the red ring (`outline`, which leaves node heights and the line layout alone) and the chip's red tint.
- **`README.md`**.
- **`plugin.toml`:** version 0.31.0.
- **Stored data:** none. **`lib/app.luau`:** no change, since the question state it passes is enough.
