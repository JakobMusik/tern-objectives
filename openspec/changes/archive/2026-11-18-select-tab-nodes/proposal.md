# Proposal

## Why

The user asked on 2026-11-18 that clicking a tab node select it, to show which objectives are connected to it, instead of jumping to the tab as it does today.

Today a click on a tab node's header leaves the graph at once ("Jump to a tab"). The graph only shows a tab's objectives for the tab it was opened from, while nothing is selected ("Origin tab's links"). To see which objectives link any other tab, the user has to follow its lines by eye, and a click on that tab takes them away from the graph.

The user chose on 2026-11-18:
- **Jumping:** a "Go to this tab" arrow at the right end of the header's second line, lined up with the pane rows' arrows. The rest of the header selects.
- **What a selected tab lights up:** every listed objective that links it: open ones, done ones while the Done group is open, with green lines, and the ones review mode lists.
- **Link buttons:** while a tab is selected, the link buttons on objective nodes link or unlink that tab, and their tooltips name it.
- **Left column order:** unchanged; linked objectives are tinted where they are.

After checking 0.28.0, the user reported on 2026-11-18 that a click on one of the selected objective's tabs deselected it. 0.28.0 cleared the objective when a tab was selected, so the `Linked to` section went and the tab moved back down. The user asked that the click instead keep the tab selected and show the other objectives' lines into it. They chose:
- **Both selections at once:** an objective and a tab can be selected together. Selecting one keeps the other, clicking either again clears only it, and empty graph space clears both.
- **Lines:** with both selected, the objective's lines and every line into the tab are thick.
- **Release:** 0.28.1.

With 0.28.1 installed, the user asked on 2026-11-18 for a bigger jump target: "the buttons for entering the tab is too small, change it to the bottom of the node block where the 'unlink' button is, and make it on the left, and the 'unlink' on the right." They chose:
- **Go button:** a "Go to tab" button in a row at the foot of every live tab, always shown, with the link bar beside it on the right while an objective is selected.
- **Release:** 0.28.2, with both README screenshots taken again.

## What Changes

1. **Selecting a tab.** A click on a tab node's header, anywhere but its trash icon and Resume button, selects the tab. It is then drawn as a selected objective is, with an accent border and ring. A click on a closed or other-window tab's pane row selects it too, since those rows have nothing to open.
   - **Together with an objective:** one objective and one tab can be selected at once. Selecting a tab keeps a selected objective, with its action bar, the `Linked to` section and the link bars, and selecting an objective keeps a selected tab. Selecting another tab replaces the selected one.
   - **Clearing:** a click on the selected tab's header again clears only the tab, and a click on empty graph space clears both.
   - **Fresh open:** each fresh open starts with no tab selected. Showing the graph again after one of its pickers or fields keeps it.
   - **Leaving the column:** a selected tab the right column no longer shows, for example after "This session" hides its session, is no longer selected.
   - **Closed tabs stay listed:** a selected closed tab stays listed under "Closed tabs" while it is selected, even when only done objectives link it.
2. **What a selected tab shows.**
   - **Lines:** the lines joining the tab to listed objectives are drawn thick, over the others, and every other line fades but a selected objective's own. This covers open objectives, done ones in the open Done group (green lines) and the objectives review mode lists.
   - **Objective nodes:** those objectives show the accent border on the accent tint the origin tab's objectives get today, except a selected one, which keeps its ring.
   - **Unchanged:** no node moves, and the tab adds no action bar or link bar of its own.
   - **Replaces the origin highlight:** while a tab is selected, the origin tab's highlight ("Origin tab's links") gives way, as it does for a selected objective.
3. **Link buttons follow the selected tab.** While a tab is selected, every objective node's link button links or unlinks that tab, its tooltip naming it. This includes closed and other-window tabs. Without a selected tab, the button links the origin pane's tab, as today.
4. **"Go to tab" at the foot** (0.28.2; 0.28.0 and 0.28.1 had a small arrow at the end of the header's second line). Each live tab node ends in a row under its pane rows, shown at all times. Its left half is a "Go to tab" button, with an arrow icon and the tooltip "Go to this tab". Clicking it jumps as the header did before: to the tab's session, the tab, and the pane last focused in it. While an objective is selected, the right half holds the "＋ Link" / "× Unlink" bar, which used to take the full width. Closed and other-window tabs show no Go button, and their link bar keeps the right half.
5. **No more "tab is closed" toasts on clicks.** A click on a closed or other-window tab's header or row selects it instead. It no longer says the tab can't be reached: the node's dimmed line already says where it is, and it has no Go button.
6. **README:**
   - the intro line, the "Jump anywhere" and "Link tabs to objectives" bullets and the selection paragraph describe tab selection, the Go button and the link buttons;
   - `docs/graph.png` and `docs/review.png` are taken again, since every live tab gains the Go button.
7. **Releases:**
   - **0.28.0**, a minor release for the new behaviour;
   - **0.28.1**, which lets an objective and a tab be selected together, after the user's check of 0.28.0;
   - **0.28.2**, which moves the jump to the "Go to tab" button.

Out of scope:
- **Reordering the left column** around the selected tab: the user chose tinting in place.
- **The origin tab's highlight** with nothing selected: it keeps showing open objectives only, as today.
- **Selecting several tabs** at once.
- **Keyboard selection** of tabs, and a palette command for it.
- **Double-click to jump,** and other gestures on tab nodes.
- **The right-click "Link to" menu**, the pane rows' jump buttons and their details: unchanged.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`:
  - new requirement "Selecting a tab": what selects a tab, what clears it, one selection at a time, its look, and when it ends;
  - new requirement "Selected tab's links": thick lines, faded others and tinted objectives, done and review objectives included;
  - "Origin tab's links": gives way to a selected tab as it does to a selected objective;
  - "Selection on a fresh open": no tab selected either;
  - "Done objectives' closed tabs": a selected closed tab stays listed.
- `tab-navigation`:
  - new requirement "Tab jump button": the "Go to tab" button at the foot of live tabs, its place and hit area;
  - "Jump to a tab": the Go button jumps, and the header doesn't;
  - "Closed tabs don't jump" and "Other-window tabs don't jump": a click selects the tab, with no toast.
- `tab-links`:
  - "Linking from the graph": the link bar takes the right half of the foot row, beside the Go button, instead of the full width;
  - "Link button on objective nodes" and "Link button clicks": the button follows the selected tab, else the origin's tab.
- `agent-resume`:
  - "Resume button" is removed, and "Resume button on a closed tab" takes its place: the rest of the header selects the tab instead of saying it is closed. Its scenario "Header click still toasts" can't carry over under its name.

## Impact

- **`lib/app.luau`:**
  - a never-stored `selected_tab`, cleared on a fresh open and kept by the reopen after a picker;
  - a `tsel` verb that toggles it and keeps the selected objective;
  - `sel`, `reopen` and creating an objective keep it, and `bg` clears both;
  - `build` drops it when the view reports the tab isn't shown.
- **`lib/view.luau`:**
  - `Ui.selected_tab`, and `Built.selected_tab`, the selected tab when the column shows it;
  - the right column's tab set worked out before the left column;
  - the focus tab, tint and link buttons following the selected tab;
  - done and review objectives' lines to the selected tab;
  - `tab_node`'s selected class, header and ghost-row clicks, and the foot row with the Go button and the link bar.
- **`lib/layout.luau`:** the foot row counted for every live tab, sized from `link_h`.
- **`styles.css`:** the selected tab's look and the foot row.
- **`README.md`**, **`docs/graph.png`**, **`docs/review.png`**.
- **`plugin.toml`:** version 0.28.0, then 0.28.1, then 0.28.2.
- **Stored data:** none. The selected tab is never stored.
