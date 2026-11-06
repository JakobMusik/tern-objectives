# Proposal

## Why

Using 0.4.0 day to day, the user found the graph harder to read than it should be:
- the tab the graph was opened from is ringed but can sit far down the right column;
- unlinked tabs are drawn at 55 % opacity, so their text is hard to read;
- the ▸/▾ toggle is small, every pane row starts open, and the toggle's glyph can be selected and copied;
- a row doesn't say what kind of pane it is;
- agent details cut the tail of long messages, which hides how a reply ends;
- the tag chips, header buttons and P0–P3 badges still have selectable text (a known limit since 0.2.0).

0.5.0 shipped items 1–6 below with a larger ▸/▾ toggle. After using it, the user asked to drop the toggle: clicking a row's name should open its details, and a separate button at the row's right end should jump (item 7).

## What Changes

1. **Origin tab first.** On open, the session holding the origin pane comes first in the right column, and the origin's tab first inside it. Other sessions and tabs keep Tern's order.
2. **Unlinked tabs at full strength.** Unlinked tabs keep normal text, with a light grey fill and a dashed border. Linked tabs stay white cards with a solid border. The opacity goes.
3. **Folded rows.** Pane rows start folded. The graph remembers the rows the user opened, instead of those they folded. Rows folded under 0.4.0 start folded anyway, so the old list is dropped.
4. **Pane type.** Each pane row starts with its type:
   - the agent's name (`omp`…) for agents;
   - `shell` for terminals;
   - `note` for notes and `file` for other files;
   - `browser`;
   - the native kind (`git`, `board`…) for the rest.
5. **Agent details.**
   - An agent's state moves into the row, after its name ("omp · working"), so it shows even when the row is folded.
   - The details hold two lines, `you: <last message>` and `<agent>: <last reply>`.
   - A message too long for the line loses its middle, not its tail: the line shows its beginning, "…", then its end.
6. **Unselectable controls.** Tag and due chips, the header's scope buttons, "Prune closed tabs", "＋ New objective", the P0–P3 badges and pane rows no longer select text when dragged across.
7. **Row clicks.** The ▸/▾ toggle goes, and no arrow is left on the row.
   - A click on a live row's type or name opens its details, and another click folds them. That click no longer jumps.
   - A jump button with an arrow icon at the row's right end goes to the pane.
   - Rows in closed or other-window tabs keep their toast on click and get no jump button.
- Release 0.5.0 (items 1–6, with the toggle), then 0.6.0 (item 7), and update the README.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`:
  - "Tab column" puts the origin's session and tab first;
  - "Unlinked tabs look different" drops the fade for a grey fill;
  - "Larger hit areas" covers the jump button instead of the toggle;
  - adds "Controls don't select text".
- `pane-details`:
  - "Expandable pane rows" gives way to "Folded pane rows", opened and folded by a click on the row, which remembers opened rows;
  - "Agent state" moves into the row;
  - "Agent last reply" and "Agent last user message" use `<agent>:` and `you:` with a middle cut;
  - adds "Pane type".
- `tab-navigation`: "Jump to a pane" moves from the row's name to its jump button.
- `objective-store`: "Remembered view settings" keeps the opened rows instead of the folded ones.

## Impact

- **Code:**
  - `lib/view.luau`: column order, row type and state, detail line spans, the row's click and its jump button;
  - `lib/details.luau`: type names, agent name, the `you:` and `<agent>:` lines;
  - `lib/store.luau` and `lib/app.luau`: `view.expanded` replaces `view.collapsed`;
  - `styles.css`: unlinked style, row and jump button, type label, middle-cut lines, `user-select`;
  - `plugin.toml` (0.5.0, then 0.6.0) and `README.md`.
- **Stored data:** `kv.json`'s `view.collapsed` is replaced by `view.expanded` on the next write. Objectives and links are unchanged.
- **Not affected:** links, navigation, the canvas surface, terminal and file details.

## Out of scope

- Moving the origin's tab inside Tern's own tab bar; only the graph's order changes.
- Middle cuts for terminal commands, paths and addresses; they keep the tail cut.
- A tooltip with the whole message.
- Telling notes apart in closed tabs: a ghost row only has the stored pane kind, so a closed note reads `file`.
- The right-click menu overflow with about 30 objectives, and the origin lost on plugin reload (other known limits).
