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
- One selected objective and one selected tab at most, each set and cleared on its own, so a tab can be looked into without losing the objective it was reached from (0.28.1, after the user's check of 0.28.0).
- A selected tab reuses the focus-tab path the origin's tab already takes, so tint, thick lines and fading look the same.
- Jumping to a tab stays one click, on its own target.

**Non-Goals:**
- Reordering the left column, and showing objectives the filters hide.
- Changing what the origin's tab shows while nothing is selected.

## Decisions

### D1. The selected tab
A new `selected_tab: number?` in `lib/app.luau`, never stored, beside `selected`.
- **Verb:** a new `tsel=<tab>` sets it, or clears it when it is that tab already. It leaves `selected` as it is.
- **Selecting an objective keeps it:** `sel`, `reopen` and creating an objective set or clear `selected` only.
- **Clearing it:**
  - `bg` clears both selections, and its early return now also needs `selected_tab == nil`;
  - a fresh open clears it; the reopen after a picker or field keeps it, as it keeps `selected`;
  - the search keeps it: it hides objectives, not tabs.
- **Handover:** `build` passes it to the view as `Ui.selected_tab`. On the graph page, it sets `selected_tab = built.selected_tab`, the selected tab if the right column showed it, else nil. A tab the column stops showing is deselected this way: hidden by the scope, closed with no link left, or gone.

*Why both at once (0.28.1):* 0.28.0 kept one selection at a time, so `tsel` cleared `selected` and `sel` cleared `selected_tab`. The user checked it and found that clicking one of the selected objective's tabs dropped the objective. The `Linked to` section went with it, and the tab moved back down the column, so it read as deselected. The user wants that click to show which other objectives lead into the tab, with the objective still selected. Independent selections give exactly that, and need no new state.

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

A node is `lit` when it links the focus tab and, for the origin rule, is open. As today, `lit` draws `.ob-lit`: the accent border on the accent tint, with no ring and no action bar. The selected objective is never `lit`: it keeps its ring and action bar, untinted, while a tab is selected too.

*Why the origin keeps open only:* the user chose what a selected tab shows. The origin highlight is what a fresh open shows, and the proposal keeps it out of scope.

### D4. Lines to the selected tab
The open objectives' edges are added as today, `strong` when they belong to the selected objective or end at the focus tab. With both an objective and a tab selected, both sets are strong and everything else dims. With `sel_tab`, each listed done objective that links it gets one edge to it, `strong`. This covers the open Done group's nodes outside review mode, and the listed nodes in review mode. These edges are `done` (green), and dashed when the tab isn't live. Their other links get no edge. A selected done objective is skipped there, since `add_edges` already draws all its lines. `Edges.build` draws the strong layer over the dimmed one, as today.

### D5. The link buttons
`quick_tab` is `sel_tab` when there is one and nothing is lifted, else the origin rule as today. For a closed or other-window tab, its label comes from its snapshot through `ghost`, as its node's does. The verb stays `lnk=<objective>:<tab>`, which `Store.toggle_link` takes for any tab. A ghost passes no facts, so its snapshot stays as it is.

### D6. The tab node
`tab_node` takes `chosen: boolean`:
- **Selected class:** `ob-tsel` when chosen.
- **Header click:** `tsel=<id>`, or `cfx=` while it asks, as today. The trash icon (`tclose`) and Resume (`resume`) keep their own clicks.
- **Ghost rows:** a closed or other-window row's click becomes `tsel=<id>`. Live rows keep `exp=` and their jump buttons.
- **Foot row** (0.28.2): `div.ob-tfoot`, key `foot`, after the rows and their details, on every live tab, and on a ghost while it has a link bar. It holds two cells:
  - left: on a live tab, `span.ob-tgo`, key `go`, title "Go to this tab", click `tab=<id>`, holding the `arrow-right` icon and `span.ob-tgo-l` "Go to tab"; on a ghost, an empty `span.ob-tcell`;
  - right: the link bar while an objective is selected, else an empty `span.ob-tcell`.

  Two cells every time keep the Go button on the left half and the bar on the right half, whichever of them shows. `Layout.add_tab`'s last argument becomes `foot`, true when the row shows, and adds `link_h`, as the bar did.

*Why at the foot (0.28.2):* 0.28.0 and 0.28.1 ended the header's second line in a 28 × 18 px arrow. With 0.28.1 installed, the user found it too small and asked for it at the foot, left of the link bar, which had taken the full width. The user chose to show the row always: the Go button stays where the hand expects it, at the cost of 26 px per live tab.

`jump_tab` stays as it is. Its toasts now come only from a stale click: a tab that closed between the draw and the click on its Go button.

### D7. Style
- **`.ob-tab.ob-tsel`:** `border-color: var(--accent); box-shadow: 0 0 0 1px var(--accent)`, the selected objective's ring.
  - With the origin ring, both shadows: `0 0 0 1px var(--accent), inset 0 0 0 1.5px var(--accent)`.
  - With an attention mark, the mark's ring moves inside, as on objective nodes: `0 0 0 1px var(--accent), inset 0 0 0 2px var(--warn)` (or `--ok`).
  - Origin and a mark together: `0 0 0 1px var(--accent), inset 0 0 0 1.5px var(--accent), inset 0 0 0 3px var(--warn)` (or `--ok`).
  - The rules come after the origin and attention rules, so they win.
- **The unlinked tab's look stays:** an unlinked selected tab keeps its dashed border and grey fill under the ring.
- **The foot row:**
  - `.ob-tfoot` is a flex row with `gap: 6px` and `margin: 0 6px`, the margin the full-width bar had; its cells are `flex: 1 1 0; min-width: 0`;
  - the layout sheet sizes the row and its cells from `link_h`, in place of the bar's rule;
  - `.ob-tgo` is a centred flex row, `gap: 5px`, with a 6 px radius, weight 600, `--t2` text in a 1 px `--l2` ring, and no text selection. On hover it takes the accent colour and tint, as the pane rows' jump buttons do;
  - the link bar keeps its look, without its own margin;
  - on a ghost, the row is a child of the node like the bar was, so it fades with it;
  - `.ob-tl2-jump` and `.ob-tjump`, the 0.28.0 arrow's rules, go.

*Alternative:* an inset ring like the origin's. Rejected: the origin's tab is often the one selected, and two inset accent rings read as one.

## Risks / Trade-offs

- **Habit:** a click on a tab header no longer leaves the graph. → The user asked for it. "Go to tab" sits at the foot of every live tab, and the pane rows keep their arrows. The README says so.
- **Taller tab nodes:** the foot row adds 26 px to every live tab, so the right column is longer and the graph scrolls sooner. → The user chose this. The lines are drawn from the same layout table, and the harness checks their ends at 1400 and 460 px.
- **The ring at the lines' ends:** the outer 1 px ring covers the last pixel of a line's stub at the tab's left edge, as a selected objective's ring does at its right edge. → The line-end checks measure the centres, at 1400 and 460 px.
- **Hidden objectives:** objectives the filters, the search or a folded Done group hide don't show as linked. → As the origin highlight does today. The tab's lines still show which shown objectives link it.
- **Moving the right column's lists earlier** could change what `sel_obj` and `kept_closed` hold. → D2 computes them from the same lists `add_node` walks. The harness checks the `Linked to` section and the closed-tab rules again.
- **Cost:** one more pass over the listed objectives for the done edges, per render. → Tens of objectives. The harness checks renders stay within the 20 ms target.

## Migration Plan

None: nothing is stored. A rollback to 0.27.0 brings back the header's jump.
