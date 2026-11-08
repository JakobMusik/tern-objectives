# Proposal

## Why

Asked by the user on 2026-11-08:
- Nothing in the left column says which objectives have an omp chat that needs you, or one that has just replied. You have to scan the tab nodes' pane rows for it.
- A long title is cut to one line, so similar objectives are hard to tell apart.
- Renaming takes ⌥R after selecting, or the ⋯ menu. The user wants a single click on the title.

Settled with the user on 2026-11-08:
- Titles: the plugin breaks lines itself, at most 36 characters a line and up to 3 lines.
- Attention: two looks, "needs you" (amber) and "replied" (green).
- Rename: only the title's text takes the rename click.

## What Changes

1. **Attention marks.** An objective node is marked when a live tab it links, in this window, holds an omp chat that needs you:
   - **needs you:** the chat waits for your input (it asked a question). Amber ring, and a "needs you" chip first on the node's second line.
   - **replied:** the chat finished a reply you haven't seen. Green ring and a "replied" chip.

   If both apply, "needs you" wins, in one tab or across tabs. "Replied" goes once you focus the pane that replied, as Tern's own unseen-reply marker does; looking at a split tab while another pane there has focus doesn't clear it. "Needs you" goes once the chat stops waiting. The chip's tooltip names the tab or tabs. Done and review nodes get marks too, and a selected node keeps its selection ring alongside the mark.
2. **Titles wrap.** A title breaks at spaces into lines of at most 36 characters, up to three lines.
   - A title needing more ends its third line in "…", and the node's tooltip still holds it whole.
   - Each extra line makes the node 18 px taller, and its link lines still meet it at its vertical centre.
   - The breaks are the same at every graph width; in a graph too narrow for a line, that line ends in "…".
   - The creation time follows the last line.
3. **Click the title to rename.**
   - A click on the title's text opens the same Rename field as ⋯ › Rename and ⌥R, on open, done and review nodes. The selection doesn't change.
   - The rest of the node still selects: beside a short title, the second line, and the padding.
   - Titles stop being selectable text. Until now a double-click highlighted a word, and a click now opens the field instead.
4. **README:** one Features line for the marks, and the click-to-rename beside ⌥R.
5. **Release 0.16.0**, a minor release because behaviour changes.

Out of scope:
- Marks for agents other than omp, and for tabs that are closed or in another Tern window. The plugin can't read other windows' panes.
- Marks on tab nodes. Their pane rows already show `omp · waiting for input` or `omp · idle`.
- Editing the title inside the node. A canvas allows no text inputs, so a click opens Tern's one-line field.
- Wrapping side notes, or a line width that follows the window. The plugin can't learn the canvas width, and edges need exact node heights.
- Sounds or notifications. Tern has its own.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`:
  - modified: Objective node content, Selection, Live refresh, Light and dark themes, Larger hit areas and Creation time after the title;
  - new: Title lines, Rename by clicking the title, Attention marks and Attention marks clear;
  - replaced: Controls don't select text becomes Controls and titles don't select text, since its "Titles stay selectable" scenario no longer holds.

## Impact

- `lib/text.luau`: a word-wrapping helper.
- `lib/layout.luau` and `styles.css`: nodes with two- and three-line titles, the title line rows, and the attention rings and chips.
- `lib/view.luau`: title lines with their click, the attention mark per objective.
- `lib/details.luau`: an omp pane's attention state, from the agent state and the pane's unseen alert.
- `lib/refresh.luau`: alerts in the change signature.
- `lib/app.luau`: the `ren` click.
- `README.md`, `plugin.toml` (0.16.0).
