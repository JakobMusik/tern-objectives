# Design

## Context

See proposal.md, "Why".

- **The origin** (`lib/app.luau`):
  - `M.open` (lines 189–216) sets `origin` to `cx.session:focused()` on a fresh open, unless that is the graph's own pane, and keeps it on the reopen after a picker or field.
  - `View.build` (`lib/view.luau` lines 617–634) finds `origin_tab`, the live tab whose rows hold that pane. From it comes `focus_tab`: the origin tab, with nothing selected, outside review mode, and only while the right column shows it (scope All, or the tab in the current session).
- **Objective nodes:** `objective_node` (lines 235–358) builds the first line `.ob-l1` from the grip, the done box, the badge, then `.ob-name` (the title lines and the creation time), then a done node's `.ob-trash`. `.ob-l1` aligns its children to the top, so the icons sit on the first 18 px line. Every node, open, done or in review mode, comes from `add_node` (lines 696–720).
- **Linking without a selection:** the tab menu's rows send `lnk=<objective>:<tab>` (`lib/app.luau` lines 1043–1053). That verb toggles the one link with `Store.toggle_link` and draws again. A gone objective gets the "no longer exists" toast. It goes through `M.action`, whose opening lines end a question, the Undo notice, a move and a priority hold for any click.
- **A control shown on hover:** the tab node's trash icon (close-tab-from-node D2) has `opacity: 0` until `.ob-tab:hover`. It keeps its place while hidden.

### Source record

| Claim | Evidence |
|---|---|
| While the graph is shown, focus is in the graph's own pane | `lib/surface.luau` `M.show`: `cx.layout:focus(pane)` after opening or updating the glimpse; objectives-graph "Opening the graph" ("with keyboard focus in the graph") |
| `:hover` with descendant selectors, and `opacity`, work in plugin CSS, and an element at opacity 0 still takes clicks | SDK "Supported CSS › Pseudo-classes" (`/tmp/ternsdk/book.txt` L27814–27823, fetched 2026-11-11); close-tab-from-node D2 and its task "Icon while pointing", which shipped `.ob-tab:hover .ob-tclose` |
| The innermost node with a click action takes the click, so a button inside the node doesn't select it | refine-graph-rows R7 (the jump button inside a row); the grip, done box, badge and trash icon inside `.ob-obj`'s `sel=` today |
| A lifted objective's drop zones cover the other nodes' content and take clicks on their inner buttons | custom-order-and-direct-controls task 1.1 spike: "A click on the node's inner button also gave `drop=1:before`, since the zone covers it" |
| `link` is a Tern icon name | SDK "Icon names" (`/tmp/ternsdk/book.txt` L13675) |
| The harness rests the pointer with `ctl hover <selector>` (at its centre) or `ctl move X Y`, and moves a pane with the helper's `move_to_tab` | close-tab-from-node and sort-by-priority tasks; highlight-origin-tab-links task 1.2 |

## Goals / Non-Goals

**Goals:**
- One new control and no new verb: the click reuses `lnk`, so it behaves exactly as a "Link to" menu row.
- No change to node heights, line ends or the right column.

**Non-Goals:**
- A second way to find "the current tab": the button follows the origin the graph already rings.

## Decisions

### D1. The tab the button links
`View.build` works out `quick_tab`: `origin_tab` when the right column shows it, by `focus_tab`'s own test (scope All, or the tab in the current session), but without its "nothing selected" and "not reviewing" parts. That is the tab the user sees ringed.

*Alternative:* `cx.session:focused()` at click time. Rejected: while the graph is shown, focus is in the graph's own pane (source record), so it would not name the pane the user was in.

### D2. The button on the node
`objective_node` takes `qlink: { tab: number, label: string, on: boolean }?`:
- **Who gets it:** `add_node` passes it for every node while `quick_tab` is set and no objective is lifted (`ui_state.moving == nil`). `on` is whether `o.tabs` holds the tab.
- **The node:** `span.ob-qlink`, plus `ob-qlink-on` when linked. It holds Tern's `link` icon. Its key is `qlink`, and its click is `lnk=<objective>:<tab>`.
- **Tooltip:** `Link to “<tab label>”`, or `Unlink from “<tab label>”` when linked.
- **Place:** in `.ob-l1`, after `.ob-name` and before a done node's trash icon, so it sits at the right end of the first line.
- **While moving:** no node gets it. The drop zones cover the other nodes and would take a click on it (source record).

*Alternative:* in the action bar. Rejected: the bar shows on the selected node only, and the user asked for a quick button on the nodes.

### D3. The click
`lnk` as it is (Context):
- the opening lines of `M.action` end a question, the Undo notice and a hold;
- `selected` is untouched, the link toggles, and the graph draws again;
- no toast, as for the menu rows and link bars. An open objective linked with nothing selected turns tinted, with a thick line, since it now links `focus_tab`.

The click links the tab the button was drawn for. When the origin pane has just moved, that can be the old tab for up to a second, until "Live refresh" draws again. That is also the tab the tooltip named.

*Alternative:* a new verb that finds the origin tab when clicked. Rejected: a click should do what the tooltip said, and a second toggle path would duplicate `lnk`.

### D4. The look (`styles.css`)
- **Box:** `.ob-qlink` takes `.ob-trash`'s box: `flex: none`, 22 × 18 px, the icon centred, 4 px radius, `--t3`, `user-select: none`.
- **Hover reveal:**
  - `.ob-obj .ob-qlink { opacity: 0; }`;
  - `.ob-obj:hover .ob-qlink, .ob-obj .ob-qlink-on { opacity: 1; }`.

  Its place is kept while it is hidden, so the title doesn't shift when the pointer arrives.
- **Under the pointer:** the icon in `--accent` on a 12 % accent tint, as the pane row's jump button looks.
- **Highlighted:** `.ob-qlink-on` is `--accent` on a 16 % accent tint at rest. Under the pointer it turns `--bad` on a 12 % tint, as the trash icon does, since its click removes the link.

### D5. README and screenshots
- **README:** the "Link tabs to objectives" feature gains one sentence: point at an objective and click its link icon to link the tab you opened the graph from, or click it again to unlink.
- **`docs/graph.png`:** taken again as search-and-tab-marks task 3.1 took it: the same demo layout and store, window size and crop, opened from Guides with the Done group open and the pointer off the graph. "Read about rate limiting", which links Guides, now shows the highlighted button.
- **`docs/review.png`:** taken again as custom-order-and-direct-controls task 5.3 took it: review mode with "Restyle the docs site" and "Profile slow search queries" due, the latter selected, opened from Guides, cropped to the header, the two review nodes and the `Linked to` section (1828 px wide).
  - "Restyle the docs site" links Guides, so it shows the highlighted button.
  - The header gains the Search button that 0.25.0 added.
- Both alt texts name the button, and both drafts are shown to the user before they are committed.

## Risks / Trade-offs

- **[Narrower first line]** While there is an origin tab, the first line is 22 px narrower on every node, even with the button hidden. At narrow widths a long first line is cut with "…" sooner. Title breaks don't move, since they count characters. → The trade-off close-tab-from-node D2 made for tab labels. Task 1.2 checks a 36-character title at 460 px wide.
- **[A hidden button takes clicks]** At opacity 0 it still takes a click, but the pointer must be on the node to reach it, and the node then shows it. → As for the tab trash icon.
- **[One click, no Undo]** A stray click links or unlinks at once. → The same button undoes it, as the link bars and menu rows have worked since 0.1.
- **[Done objectives show little]** Linking a done objective draws no line until it is selected, since done objectives' lines show only then. → The button turns highlighted, which the shot and the kv dump check.
- **[Untested look]** Nothing records how a 16 % accent tint reads on a tinted (`ob-lit`) node, or in the dark appearance. → Task 1.2 takes shots in light and dark (`ctl appearance`). If the button can't be told apart there, stop and update D4.
- **[Rebuilt screenshot data]** The demo's chats are generated anew, so their titles and replies read differently. → As in search-and-tab-marks 3.1; the user approves the drafts.

## Migration Plan

Nothing is stored or migrated. A downgrade drops only the button. Links made with it are ordinary links.
