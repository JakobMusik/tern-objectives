# Proposal

## Why

The user asked for two features on 2026-11-11:

1. **A text search for the objective nodes.** Today the left column narrows only by scope and by one tag. Finding an objective by a word of its title or note means reading down the whole list, open and done.
2. **The objective nodes' status display on tab nodes as well.** An objective node shows "needs you", "replied" or "working" for the omp chats in the tabs it links (attention-marks-and-titles, working-mark). A tab node shows none of it. Its pane rows name an agent's state ("omp · waiting for input", "omp · working", "omp · idle"), but a chat with an unseen reply still reads "omp · idle", and nothing marks the node itself.

The user chose how both work on 2026-11-11:
- searching filters the graph;
- a search lasts until the graph is opened again;
- the search command gets ⌃⌥F by default. The user first chose ⌥F, but Tern binds ⌥F itself (`canvas.fill_solid`) and leaves out a plugin's default on a key it binds (task 1.3's spike), so the user picked ⌃⌥F instead;
- tab nodes get the same marks as objective nodes.

## What Changes

1. **Search button and field.** The header gets a Search button (Tern's `search` icon) after the scope filter. It opens Tern's one-line field. A canvas can't hold a text input, so the text is typed there, as for Rename and Note.
2. **Filtering.** With a search on, the left column lists only the objectives whose title, side note or tags contain every word entered, ignoring case. This covers open and done objectives, and review mode too. The scope and tag filters still apply. The tab column doesn't change, and lines show only for the objectives listed. When nothing matches, the column says "No objectives match this filter.", as it does for the other filters.
3. **The search chip.** While a search is on, a chip showing its text replaces the Search button. A click on the chip opens the field again, holding the text, and its × ends the search. Entering empty text ends it too, and dismissing the field changes nothing.
4. **Selection and lifetime.**
   - Entering a search clears the selection.
   - While searching, the selected objective stays listed even when it doesn't match, so an objective created or renamed during the search doesn't vanish while selected.
   - The search ends on a fresh open of the graph (the user's choice). Showing the graph again after one of its fields or pickers keeps it.
   - The search is never stored, and each window has its own.
5. **"Objectives: Search…", default key ⌃⌥F** (the user's choice). It opens the same field. If the graph isn't shown over the current tab, the graph opens there first; if the settings page is shown, it switches back to the graph. Like ⌥N, it runs in every pane, so ⌃⌥F no longer reaches the panes anywhere in Tern. Configure lists it as a seventh shortcut row, where it can be changed or removed.
6. **Marks on tab nodes** (the user's choice: the same as objective nodes).
   - A live tab node shows the strongest call of the omp chats in its panes: an amber ring with "needs you", a green ring with "replied", or a "working" chip with no ring.
   - The chip comes first on the node's second line, before "<session> · tab <n>", and its tooltip names the panes.
   - Marks clear as on objective nodes. Closed and other-window tabs show none. On the origin tab, the origin ring and the mark show together.
   - Unlinked tabs are marked too, so a chat in a tab no objective links is seen.
7. **README:**
   - the commands table and the keys note gain ⌃⌥F;
   - a paragraph on searching;
   - the "See what needs you" feature names tab nodes;
   - `docs/graph.png` is taken again. Its Server tab, whose omp chat waits for input, and its Release notes tab, with an unseen reply, now carry marks, and its header shows the Search button. Its alt text is updated to match.
8. **Release 0.25.0**, a minor release for the new behaviour.

Out of scope:
- **Searching as you type in the graph:** a canvas view can't hold an input node (tern.d.luau, `CanvasSpec.view`: "input, editor and image kinds are not allowed").
- **Searching other things:** tabs or pane contents, fuzzy matching, patterns, and case folding beyond ASCII letters.
- **Keeping a search:** across fresh opens, or after a reload.
- **The Done group's fold:** a search doesn't open the group. Its count shows the matches, as it does under the tag filter.
- **More on pane rows:** a mark per pane row, an "omp · replied" state text, or a jump from the tab's chip to the calling pane. The chip names the panes, and the header still jumps to the tab.
- **Marks for agents other than omp,** as on objective nodes.
- **Retaking `docs/review.png`:** its tab nodes carry no marks, and only its header lacks the Search button.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`:
  - new requirement "Search": the button, the filter, the chip, ending a search;
  - new requirement "Search and other filters": the search applies with the scope and tag filters and in review mode, and how it treats the selection and fresh opens;
  - new requirement "Search key": ⌃⌥F;
  - new requirement "Tab attention marks": the marks on tab nodes;
  - "Selection on a fresh open": a fresh open also ends the search, while the scope and tag filters stay.
- `objective-review`:
  - "Review button": the count takes the search into account, as it does the scope and tag filters.
- `plugin-package`:
  - "Palette commands": seven commands, "Objectives: Search…" with ⌃⌥F;
  - "README": the seven commands with ⌃⌥F, how searching works, and a marked tab in the graph screenshot.
- `plugin-settings`:
  - "Shortcut rows": seven rows, Search with ⌃⌥F by default.

## Impact

- **`lib/store.luau`:** a function that tells whether an objective matches the search's words.
- **`lib/view.luau`:**
  - the search in the filters;
  - the header's Search button or chip;
  - each live tab's mark, worked out once and shared with the objective marks;
  - the tab node's chip and ring.
- **`lib/app.luau`:** the search state and its end on a fresh open, the search field, the `search` and `unsearch` verbs, and the key's entry point.
- **`lib/keys.luau`** and **`window.luau`:** the new command and its default key.
- **`styles.css`:** the Search button and chip, the tab node's second line as a row, and the tab rings.
- **`README.md`**, **`docs/graph.png`**.
- **`plugin.toml`:** version 0.25.0.
- **Stored data:** nothing new; the search is never stored. A changed Search shortcut is saved in Tern's keybinds, like the other shortcuts.
