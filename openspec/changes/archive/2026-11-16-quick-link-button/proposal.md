# Proposal

## Why

The user asked on 2026-11-11 for a quick link button on objective nodes that links the tab holding the current focused pane.

Linking that tab takes several steps today:
- select the objective, find the tab's node in the right column, and click its "＋ Link";
- right-click the tab's node and pick the objective in its "Link to" menu;
- or close the graph and run "Objectives: Link this tab…", then pick the objective.

While the graph is shown, keyboard focus is in the graph itself ("Opening the graph"). So the focused pane the user means is the graph's origin: the pane that had focus when the graph opened, whose tab node already carries the accent ring ("Origin highlight").

The user chose how the button works on 2026-11-11:
- **Toggle:** on an objective already linked to that tab, the button stays, highlighted, and a click unlinks.
- **Shown on hover:** it shows only while the pointer is over the node, like the tab nodes' trash icon. A linked node keeps it visible.
- **Every node:** open and done objectives, in the Done group and in review mode.

## What Changes

1. **A link button on objective nodes.** While the right column shows the origin pane's tab, every objective node gets a link icon at the right end of its first line, before a done node's trash icon:
   - On an objective not linked to that tab, it shows only while the pointer is over the node. A click links the two.
   - On a linked objective, it always shows, highlighted. A click unlinks the two.
   - Its tooltip names the tab: `Link to “Guides”` or `Unlink from “Guides”`.
2. **A click acts at once.**
   - It doesn't select the node, change the selection, or jump.
   - Like any other click in the graph, it ends a question asked in place, the Undo notice and a priority hold.
   - An open objective linked with nothing selected turns tinted, with a thick line to the origin tab, as "Origin tab's links" already draws it.
3. **When nodes have no button:**
   - without an origin tab, for example once the origin pane has closed;
   - while the right column doesn't show the origin tab;
   - while an objective is lifted, since the drop zones cover the nodes.
4. **README:**
   - "Link tabs to objectives" names the button.
   - `docs/graph.png` and `docs/review.png` are taken again. In both, an objective linked to Guides, the tab the graph was opened from, now shows the highlighted button. `review.png`'s header also gains the Search button it lacked.
5. **Release 0.26.0**, a minor release for the new behaviour.

Out of scope:
- **Other tabs:** linking a tab other than the origin's from an objective node. The tab nodes' link bars and menus do that.
- **More controls:** a keyboard shortcut or palette command for the button, an Undo notice for its click, and a confirmation.
- **Live focus with a docked graph:** following focus as it changes while a docked graph stays visible. The origin is fixed at a fresh open, as for the origin highlight.
- **The tab nodes' controls:** their link bars, "Link to" menu and the "Link this tab…" picker are unchanged.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `tab-links`:
  - new requirement "Link button on objective nodes": where the button shows and how it looks when linked;
  - new requirement "Link button clicks": a click toggles the link to the origin tab and leaves the selection alone;
  - "Links of done objectives": the node's link button changes a done objective's links too.
- `objectives-graph`:
  - "Objective node content": the link button joins the first line;
  - "Selection": a click on the link button doesn't select;
  - "Larger hit areas": the link button takes clicks over 22 × 18 px, like the trash icon.

## Impact

- **`lib/view.luau`:**
  - the origin tab the button links, when the right column shows it;
  - `objective_node` draws the button.
- **`lib/app.luau`:** none. The button's click is the tab menu's `lnk=<objective>:<tab>` verb, which already toggles one link without a selection.
- **`styles.css`:** the button, its hover reveal and its highlighted look.
- **`README.md`**, **`docs/graph.png`**, **`docs/review.png`**.
- **`plugin.toml`:** version 0.26.0.
- **Stored data:** nothing new. A click changes `objectives[].tabs` and the tab snapshot, as a link bar does.
