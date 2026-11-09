# Proposal

## Why

The user asked for this on 2026-11-09, as the next refinement: a trash icon on the tab nodes, so a tab can be closed straight from the graph. Today the graph closes tabs only in bulk:
- a done objective's "Close n tabs";
- the done notice's "Close n tabs";
- the header's "Close n done tabs".

A single tab, linked or not, has to be closed outside the graph: jump to it, then close it with Tern's own keys.

## What Changes

1. **A trash icon on each live tab node.** It sits at the right end of the header's first line, after the label, and shows only while the pointer is over that tab node (the user's choice). Closed and other-window tab nodes have none. Clicking it doesn't jump to the tab.
2. **It asks in place first** (the user's choice). The header's first line turns into "Close tab?" with Cancel and Close, and Close takes the icon's place at the right end. Cancel, or any other click in the graph, ends the question. A click on the rest of the header while it asks ends the question too, without jumping.
3. **Close works as the other closes do:**
   - it saves the omp chats first, then closes every pane of the tab;
   - it changes no links;
   - a graph sitting over that tab closes first and shows again over the next tab;
   - if the chats can't be saved, it closes nothing and says so.

   A linked tab then shows under "Closed tabs", with Resume for its saved omp chats. A tab no objective links is simply gone.
4. **README:** "Finish cleanly" mentions the icon.
5. **Release 0.23.0**, a minor release: a new action.

Out of scope:
- Closing without asking, and Undo of a close.
- A trash icon on closed tabs, to forget them, or on other-window tabs.
- Closing a single pane from its row.
- A "Close tab" row in the tab node's right-click menu.
- Retaking `docs/graph.png`: the icon shows only while the pointer is over a tab node, and the screenshot has no pointer over one, so it still shows this version.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`: new requirement "Closing a tab from its node". It asks in place, as "Inline confirmation" requires of every action that asks. That requirement is left as it is: adding the icon to its list would take it past 500 characters, so the new requirement's own scenarios cover Cancel and other clicks.
- `tab-navigation`:
  - "Jump to a tab": clicking the trash icon, or the header while it asks, doesn't jump.

## Impact

- `lib/view.luau`: `tab_node` gets the trash icon on live tabs, and the question in place of the header's first line while it asks.
- `lib/app.luau`:
  - the `tclose` verb asks;
  - `cfm` closes that one tab through `close_tabs`;
  - `close_tabs` takes its whole toast from its caller, so a single tab reads "Closed “<label>”".
- `styles.css`: the icon is hidden until the tab node is hovered, plus the question's buttons.
- `README.md`.
- `openspec/specs/objectives-graph/spec.md` and `openspec/specs/tab-navigation/spec.md`: the delta above.
- `plugin.toml`: version 0.23.0.
- Stored data: none.
