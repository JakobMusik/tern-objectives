# Proposal

## Why

The user asked for this on 2026-11-09, as the next refinement. The window's VM keeps the selected objective after the graph closes, so a fresh open often starts on an objective picked minutes ago, somewhere unrelated. When the user opens the graph from a tab, the question is usually which objectives that tab works for. The graph marks the tab ("current", an accent ring), but its links look like every other link.

## What Changes

1. **A fresh open starts with nothing selected.** ⌃⌘O, ⌥N, Configure and any other command that shows the graph anew forget the selected objective. Only the selection is dropped:
   - review mode is still remembered (remember-review-mode);
   - the filters, the Done fold and open pane rows stay stored as now;
   - showing the graph again after one of its own pickers or fields keeps the selection;
   - ⌥N still selects the objective it creates.
2. **The origin tab's links stand out.** While no objective is selected, outside review mode, the lines between the tab the graph was opened from and the shown open objectives are drawn as a selected objective's lines are: thick, over the others, which fade.
   - Those objectives get an accent border on an accent tint. There is no selection ring, no action bar, and no link bars on the tabs.
   - The user chose this over also moving those objectives to the top of the list. The tab itself is already first in the right column.
3. **When it shows.** Selecting an objective replaces the tab's highlight, and clearing the selection brings it back (the user's choice). It follows the origin pane as the origin ring does. When no shown open objective links the tab, nothing fades.
4. **README:** the paragraph on selecting says both.
5. **Screenshot:** `docs/graph.png` was taken from "Guides", which "Read about rate limiting" links. That state now shows the new highlight, so the image is retaken from the same data.
6. **Release 0.22.0**, a minor release because behaviour changes.

Out of scope:
- Moving the linked objectives up the left column, or changing the tab node beyond its existing origin ring.
- Done objectives that link the origin tab. Their lines show only while they are selected ("Link lines"), so they get no line and no tint.
- Highlighting a tab other than the origin's. Clicking a tab header still jumps to it.
- Forgetting anything besides the selection on a fresh open.
- `docs/review.png`: review mode has no tab highlight, so it still shows this version.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`:
  - new requirement "Selection on a fresh open";
  - new requirement "Origin tab's links";
  - "Selection": its "Select and clear" scenario opens the graph from a tab no objective links, so clearing the selection leaves no line emphasised.

## Impact

- `lib/app.luau`: `M.open` clears `selected` on a fresh open.
- `lib/view.luau`: the origin's tab is looked up before the left column. Its open objectives get a node class, and the lines ending at it are drawn strong while nothing is selected.
- `lib/edges.luau`: the edge field `selected` becomes `strong`, since the origin tab's lines use it too.
- `styles.css`: the highlighted node's border and tint.
- `README.md` and `docs/graph.png`.
- `openspec/specs/objectives-graph/spec.md`: the delta above.
- `plugin.toml`: version 0.22.0.
- Stored data: none.
