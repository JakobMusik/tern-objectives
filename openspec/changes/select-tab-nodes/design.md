# Design

## Context

See proposal.md, "Why".

- **Selection today** (`lib/app.luau`): `selected: string?`, the selected objective's id, never stored. A fresh open (`M.open` without `keep_origin`) clears it, and the reopen after a picker or field keeps it. `sel` toggles it, `bg` clears it, `reopen` and creating an objective set it. `build` drops it when the objective is gone.
- **Tab header clicks today** (`tab_node` in `lib/view.luau`): the header's click is `tab=<id>`, or `cfx=` while it asks "Close tab?". A live pane row's click is `exp=<pane>`, and its jump button's is `pane=<pane>`. A ghost row's click is `tab=<id>`, which `jump_tab` answers with a toast for a closed or other-window tab.
- **The focus tab** (highlight-origin-tab-links D2, D3): in `View.build`, with nothing selected, outside review mode, the origin's tab when the right column shows it. Open objectives linking it get `lit` (`.ob-lit`), and their edges to it are `strong`. `Edges.build` dims every other edge while any edge is strong.
- **The link buttons** (quick-link-button D1, D2): `quick_tab`, the origin's tab while the right column shows it and nothing is lifted, gives every objective node a `QLink { tab, label, on }`, whose click is `lnk=<objective>:<tab>`.
- **The right column** is placed after the left column. `placed` holds the shown sessions and their live tabs. `closed` holds the linked closed tabs, kept by an open link or by `kept_closed`: the selected objective's tabs and the tabs of the objectives review mode lists. `elsewhere` holds the linked other-window tabs, shown under "All".
- **Edges:** open objectives' lines outside review mode, and the selected objective's when it is done. A done objective's lines are green (`Layout.done_color`).

### Source record

| Claim | Evidence |
|---|---|
| Clicks in the canvas arrive as `canvas_action` with `act` and `value` | `tern.d.luau:1497` (`CanvasAction`), `tern.d.luau:2252` |
| A node with a click action gets class `sf-act` and the pointing-hand cursor | SDK book, Node props `actions` (`/tmp/ternsdk/book.txt` L9369) |
| A control's own click inside the header wins over the header's click | close-tab-from-node task results: a click on the trash icon inside the header asked "Close tab?" and didn't jump (`openspec/changes/archive/2026-11-09-close-tab-from-node/tasks.md`, line 82) |
| An outer `box-shadow` ring on a node shows in the columns | `.ob-obj.ob-sel` draws one (`styles.css` lines 242–245); `.ob-col` sets no `overflow` (lines 19–23) |
| Tern's icon set has `arrow-right` | the pane rows' jump buttons use it (`lib/view.luau` line 458) |
| A tab header is 38 px: 2 px top padding, two 18 px lines; it pads 8 px left and right, and a pane row pads 0 on the right | `lib/layout.luau` `tab_head_h`; `styles.css` `.ob-thead`, `.ob-th1`, `.ob-tl2`, `.ob-row` |

## Goals / Non-Goals

**Goals:**
- One selection at a time, an objective or a tab, so the graph never shows two highlights.
- A selected tab reuses the focus-tab path the origin's tab already takes, so tint, thick lines and fading look the same.
- Jumping to a tab stays one click, on its own target.

**Non-Goals:**
- Reordering the left column, and showing objectives the filters hide.
- Changing what the origin's tab shows while nothing is selected.

## Decisions

### D1. The selected tab
A new `selected_tab: number?` in `lib/app.luau`, never stored, beside `selected`.
- **Verb:** a new `tsel=<tab>` sets it, or clears it when it is that tab already, and clears `selected`.
- **Clearing it:**
  - `sel`, `reopen` and creating an objective, which select an objective, clear it;
  - `bg` clears both selections, and its early return now also needs `selected_tab == nil`;
  - a fresh open clears it; the reopen after a picker or field keeps it, as it keeps `selected`;
  - the search keeps it: it hides objectives, not tabs.
- **Handover:** `build` passes it to the view as `Ui.selected_tab`. On the graph page, it sets `selected_tab = built.selected_tab`, the selected tab if the right column showed it, else nil. A tab the column stops showing is deselected this way: hidden by the scope, closed with no link left, or gone.

*Alternative:* one `selected` holding `"o:<id>"` or `"t:<id>"`. Rejected: every existing reader of `selected` (rename, link bars, the Linked section, `can_rename`) would need to parse it.

### D2. The right column's tabs first
`View.build` works out the tabs the right column shows before it builds the left column, since the left column needs to know whether the selected tab is shown (D3, D5):
- the listed objectives: review mode's list, else the open list and, while the Done group is open, the done list. `sel_obj` is the selected objective when it is listed, as `add_node` finds it today;
- `placed`, `closed` and `elsewhere` as today. `kept_closed` also takes the selected tab;
- `sel_tab`: `Ui.selected_tab` when one of those three holds it, else nil. It is returned as `Built.selected_tab`.

The column is still drawn after the left column, from the same lists.

### D3. The focus tab and the tint
- With `sel_tab`: the focus tab is `sel_tab`, for every listed objective, open or done, in review mode too.
- Without it: the origin rule as today, for open objectives only, outside review mode, with nothing selected.

A node is `lit` when it links the focus tab and, for the origin rule, is open. As today, `lit` draws `.ob-lit`: the accent border on the accent tint, with no ring and no action bar.

*Why the origin keeps open only:* the user chose what a selected tab shows. The origin highlight is what a fresh open shows, and the proposal keeps it out of scope.

### D4. Lines to the selected tab
The open objectives' edges are added as today, `strong` when they end at the focus tab. With `sel_tab`, each listed done objective that links it gets one edge to it, `strong`. This covers the open Done group's nodes outside review mode, and the listed nodes in review mode. These edges are `done` (green), and dashed when the tab isn't live. Their other links get no edge. `Edges.build` draws the strong layer over the dimmed one, as today.

### D5. The link buttons
`quick_tab` is `sel_tab` when there is one and nothing is lifted, else the origin rule as today. For a closed or other-window tab, its label comes from its snapshot through `ghost`, as its node's does. The verb stays `lnk=<objective>:<tab>`, which `Store.toggle_link` takes for any tab. A ghost passes no facts, so its snapshot stays as it is.

### D6. The tab node
`tab_node` takes `chosen: boolean`:
- **Selected class:** `ob-tsel` when chosen.
- **Header click:** `tsel=<id>`, or `cfx=` while it asks, as today. The trash icon (`tclose`), Resume (`resume`) and the arrow keep their own clicks.
- **Ghost rows:** a closed or other-window row's click becomes `tsel=<id>`. Live rows keep `exp=` and their jump buttons.
- **Jump arrow:** on a live tab, the header's second line ends in `span.ob-jump.ob-tjump`, key `jump`, title "Go to this tab", click `tab=<id>`, holding the `arrow-right` icon. It comes after the mark chip and the "where" line.

`jump_tab` stays as it is. Its toasts now come only from a stale click: a tab that closed between the draw and the click on its arrow.

### D7. Style
- **`.ob-tab.ob-tsel`:** `border-color: var(--accent); box-shadow: 0 0 0 1px var(--accent)`, the selected objective's ring.
  - With the origin ring, both shadows: `0 0 0 1px var(--accent), inset 0 0 0 1.5px var(--accent)`.
  - With an attention mark, the mark's ring moves inside, as on objective nodes: `0 0 0 1px var(--accent), inset 0 0 0 2px var(--warn)` (or `--ok`).
  - Origin and a mark together: `0 0 0 1px var(--accent), inset 0 0 0 1.5px var(--accent), inset 0 0 0 3px var(--warn)` (or `--ok`).
  - The rules come after the origin and attention rules, so they win.
- **The unlinked tab's look stays:** an unlinked selected tab keeps its dashed border and grey fill under the ring.
- **`.ob-tjump`:** `margin-left: auto; margin-right: -8px`. It sits at the line's right end, and its right edge meets the node's inner edge, where the pane rows' jump buttons end. From `.ob-jump` it takes the 28 px width, the hover tint and `align-self: stretch`, which gives it the line's 18 px height. The header keeps its 38 px.

*Alternative:* an inset ring like the origin's. Rejected: the origin's tab is often the one selected, and two inset accent rings read as one.

## Risks / Trade-offs

- **Habit:** a click on a tab header no longer leaves the graph. → The user asked for it. The arrow sits on the header, and the pane rows keep their arrows. The README says so.
- **Smaller jump target:** the header was about 38 px tall; the arrow is 28 × 18 px. → At least the grip's and link button's size. The harness measures it.
- **The ring at the lines' ends:** the outer 1 px ring covers the last pixel of a line's stub at the tab's left edge, as a selected objective's ring does at its right edge. → The line-end checks measure the centres, at 1400 and 460 px.
- **Hidden objectives:** objectives the filters, the search or a folded Done group hide don't show as linked. → As the origin highlight does today. The tab's lines still show which shown objectives link it.
- **Moving the right column's lists earlier** could change what `sel_obj` and `kept_closed` hold. → D2 computes them from the same lists `add_node` walks. The harness checks the `Linked to` section and the closed-tab rules again.
- **Cost:** one more pass over the listed objectives for the done edges, per render. → Tens of objectives. The harness checks renders stay within the 20 ms target.

## Migration Plan

None: nothing is stored. A rollback to 0.27.0 brings back the header's jump.
