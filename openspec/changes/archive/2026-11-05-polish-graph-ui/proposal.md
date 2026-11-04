# Proposal

## Why

Using 0.1.2 day to day showed three problems:
- Pane details stay hidden until each row is opened by hand.
- Nothing shows which tab and pane the graph was opened from.
- Linking means selecting an objective and then hitting a 16 px ＋/× box in a tab node's corner.

On top of that, Esc doesn't close the graph once the user has clicked inside it, because Tern canvases take no keys. Spikes in the headless Tern (recorded in design.md) showed that a plugin block shown as a glimpse receives Esc. It can also show the same element tree, CSS and line backgrounds, and it can pass every click back to the window half. Moving the graph onto a block fixes Esc without losing anything the canvas does.

## What Changes

- **Graph surface:** the graph moves from a window-authored canvas to a plugin block, `objectives.graph`, still shown as a glimpse over the current tab.
  - The window half keeps building the view and handling every click.
  - The block, a new host half (`host.luau`), only shows the view and passes clicks back.
  - Esc closes the graph on the first press, whether or not the user has clicked inside it. ⌃⌘O still toggles it.
- **Pane details open by default:** every live pane row shows its details without a click. ▾ still folds a row, and the store remembers the folded rows instead of the opened ones. **BREAKING** for stored view settings: rows opened under 0.1.x are forgotten, which is harmless because every row now starts open.
- **Origin highlight:** the tab node holding the pane that had focus when the graph was opened gets an accent ring, and that pane's row gets an accent bar. The highlight follows the pane if it moves to another tab, and goes away once the graph closes.
- **Easier linking:**
  - While an objective is selected, every tab node shows a full-width bar: "＋ Link" when the tab isn't linked to it, "× Unlink" when it is. The bar replaces the corner box.
  - Right-clicking a tab node opens a menu with one checked row per open objective. Choosing a row links or unlinks that objective, with no selection needed.
- **Larger hit areas:** the done box, the ⋯ button and the ▸/▾ toggle get bigger hit areas, without changing node or row heights, so lines keep their alignment.
- **Release:** version 0.2.0. The README drops the Esc limit, and it explains the host half and the limit on sessions from other machines.

## Capabilities

### New Capabilities

None. Every change modifies an existing capability.

### Modified Capabilities

- `objectives-graph`:
  - "Opening the graph" now speaks of the graph block rather than a canvas;
  - "Selection" and "New objective button" show link bars instead of ＋/× buttons;
  - new requirements: closing with Esc, the origin highlight and larger hit areas.
- `tab-links`: "Linking from the graph" gains the link bar and the tab right-click menu.
- `pane-details`: "Expandable pane rows" start open, and folded rows are remembered.
- `objective-store`: "Remembered view settings" keeps folded rows instead of expanded ones.
- `plugin-package`:
  - "Manifest" gains a host entry and the `graph` block, and moves to version 0.2.0;
  - "README" no longer calls the plugin window-half only, and documents Esc.

## Impact

- **Code:**
  - new `host.luau` (the display block);
  - `plugin.toml` gains `host` and one `[[blocks]]` entry;
  - `lib/canvas.luau` becomes the block surface, `lib/surface.luau` (open, find, close and view hand-off);
  - `window.luau` replaces the `canvas_action` handler with a `tern.route.link` handler for the block's `objectives://` links;
  - `lib/view.luau` (link bar, origin classes, open-by-default rows, right-click menus);
  - `lib/app.luau` (origin, link actions);
  - `lib/store.luau` (folded rows);
  - `lib/layout.luau` (link bar height);
  - `styles.css`, whose scope moves to the block's surface;
  - `README.md`.
- **Runtime data:**
  - `kv.json` gains one key per window holding the current view tree, written by that window's half and read by the block;
  - `view.expanded` becomes `view.collapsed`.
- **Tern APIs newly used:**
  - window half: `cx:new_block`, `tern.route.link`;
  - host half: `tern.block.define`, `tern.kv` (read only), `tern.timer`, `cx:open`, `cx:exit`.
- **Behaviour on other machines:** the block opens on the window's current host. In a session on another machine the graph doesn't open, and a toast says so (design.md).
- **Not affected:** stored objectives, links and snapshots; the palette commands; navigation; pane-detail sources.

## Out of scope

- Drag-to-connect. Tern's plugin elements take only click, double-click and right-click; the native whiteboard can bind arrows but sends no clicks and shows no rich nodes (spike in design.md).
- Keyboard navigation inside the graph beyond Esc.
- Restyling the graph beyond the link bar, the origin highlight and the hit areas.
- Opening the graph in sessions on other machines.
- Changing Tern's glimpse footer text.
