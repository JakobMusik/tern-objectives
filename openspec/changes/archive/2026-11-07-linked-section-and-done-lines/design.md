# Design

## Context

See proposal.md, "Why".

- **The top section** (`rename-and-linked-tabs-first` D3/D4): `select(id)` in `lib/app.luau` sets `selected` and `pinned`, the objective's `tabs` read at that moment. `pinned` reaches `View.build` as `ui_state.pinned`. There `place(keep)` emits the column for the tabs `keep` accepts. With a selected objective and at least one shown pinned tab, the column is: heading, `place(pinned)`, divider, `place(not pinned)` (`lib/view.luau:615–661`). `View.build` already collects the selected objective's current links as `sel_tabs` (`lib/view.luau:443`).
- **The divider** is a `.ob-group.ob-divider` row reading "Other tabs", stacked with `Layout.add_group` (24 px plus a 14 px margin). Its rule is a 1 px inset shadow, so it needs no layout of its own (`styles.css:342`).
- **The link bar:** `link_of(tab)` returns a bar whenever an objective is selected, open or done (`lib/view.luau:449`). `Layout.add_tab` adds `link_h` when there is a bar. The `link=` action toggles a link of `selected` with no done check (`lib/app.luau:853`), and so does `Store.toggle_link` (`lib/store.luau:520`).
- **Lines:** `View.build` makes edges for `open_list`, or in review mode for `due_list` (`lib/view.luau:663–680`). `Edges.build` draws the selected objective's edges 3 px wide on their own layer and the rest 1.5 px, dimmed by `.ob-e-dim` while a selected layer exists (`lib/edges.luau:73`, `styles.css:47`). Each edge's colour is `Layout.palette[priority + 1]`.
- **Done nodes:** the Done group's loop stacks each node with `Layout.add_obj(left)` and discards the returned centre (`lib/view.luau:430`), so done objectives have no `obj_cy` entry outside review mode.

### Source record

| Claim | Evidence |
|---|---|
| Line colours must be literal: they live in SVG data URLs, and Tern's renderer ignores `url()` masks | `lib/edges.luau:2–4`; `add-objectives-plugin` task (masks fallback) |
| Tern lays out a flex row of `flex: 1 1 0` children, centres them with `align-items: center`, and paints a small box's `background` | shipped rules: `.ob-rate` (`styles.css:193`), `.ob-group` (`styles.css:319`), `.ob-check::before` (`styles.css:247`) |
| Line ends stay on their nodes as long as the stack and the layout sheet use the same height | `lib/layout.luau:1–3`; `edgecheck.py` results in `rename-and-linked-tabs-first` and `review-done-objectives` |
| Marking done keeps the selection | `lib/app.luau:797–807`: the `done` action never calls `select` |
| A selected objective is found only when its node is drawn; in a collapsed Done group it isn't | `lib/view.luau:394–435` |
| `edgecheck.py` finds lines by saturation and brightness, not by palette | `/tmp/tobj/bin/edgecheck.py:49` |

## Goals / Non-Goals

**Goals:**
- One rule for the top section: it holds the selected objective's links as they are now.
- A done objective's links can't change, and are shown only on request.

**Non-Goals:**
- Scrolling the graph to a tab that moved.
- Animating the move.

## Decisions

### D1. The top section from the current links
- `pinned` and its comment go from `lib/app.luau`, and `pinned` goes from `View.Ui`. `select(id)` then does nothing but set `selected`, so it goes too: its call sites assign `selected` directly.
- In `View.build`, the top section's test is `sel_tabs[tab] == true`, and the counts of shown tabs above and below the divider use it too. The heading shows when at least one shown tab is linked, and the divider when at least one shown tab isn't. `place` is unchanged.
- Every link change renders the graph again (`lib/app.luau`, action handler), so a linked tab moves on that render, whatever made the link: the bar, the tab's right-click menu, or "Link this tab".

Alternative: keep `pinned` and add newly linked tabs to it, so an unlinked tab stays put. The user chose that unlinking moves too, which leaves `pinned` with no purpose.

### D2. The divider
- A new layout constant, `divider_h = 32`, with `group_m` above it, and `Layout.add_divider(s)`. The layout sheet sets `.ob-divider`'s height, line height and top margin, as for the other rows.
- The row is `.ob-divider`, no longer `.ob-group`, so its height is its own: a flex row with `align-items: center`, holding `.ob-drule`, `.ob-dpill` ("Other tabs") and `.ob-drule`.
- `.ob-drule`: `flex: 1 1 0`, 3 px tall, rounded, `background: var(--accent)`.
- `.ob-dpill`: 18 px tall, 9 px radius, 8 px side padding, 6 px gap on both sides, 11 px semibold text in `--accent`, a 1 px inset accent ring, and an 8% accent fill: the same ring and fill as the link bar and "Resume". It is unselectable, like the group headings.

Alternatives: a thicker inset shadow on the old row. It can't sit in the row's middle, and it carries no label shape. A gradient bar behind the label: no shipped rule shows that Tern paints gradients.

### D3. Done objectives' links are fixed
- `link_of` returns nil while the selected objective is done, so there is no bar and `Layout.add_tab` gets `bar = false`.
- `Store.toggle_link` returns `"done"` and writes nothing when the objective is done.
  - The `link=` and `lnk=` actions treat `"done"` as nothing to do; the render that follows drops a stale bar.
  - `link_tab` ("Link this tab") lists only open objectives, but one may be marked done in another window while its picker is open. It answers `"done"` with an info toast, `“X” is done; its links can't change`.
- The tab menu (`menu_of`) and "New objective for this tab" are unchanged: they already offer only open objectives.

### D4. Done objectives' lines
- `Edges.Edge` gets `done: boolean`. `path` uses `Layout.done_color = "#30a46c"` for a done edge, and the priority colour otherwise.
- The Done group's loop stores `obj_cy[o.id]`, as the open loop does.
- `View.build` draws the edges of `open_list` outside review mode, as today. In both modes it adds the selected objective's edges when that objective is done and its node is drawn, with `selected = true`. Review mode stops drawing every listed objective's edges.
- A done objective's lines are then always selected lines, 3 px on their own layer, and the open objectives' lines dim as for any selection.

## Risks / Trade-offs

- **[A tab moves under the pointer]** After "＋ Link", the tab leaves the spot that was clicked, and a second click there hits another tab. → The user's choice. The moved tab shows "× Unlink" in its new place.
- **[A moved tab may be out of view]** Linking a tab far down moves it to the top, and the graph doesn't scroll. → Accepted, as for the section today. The selected lines still run to it.
- **[Line ends drift]** The divider's new height must match the stack. → `Layout.add_divider` and the sheet read the same constant. `edgecheck.py` checks it at 1400 and 460 px wide.
- **[Untested look]** Nothing records Tern drawing a 3 px flex child or the pill centred on the bar. → A shot in task 1.2, light and dark. If either fails, stop and update D2.
- **[Review mode loses its overview]** Review mode starts with no lines. → The user's choice. Selecting a listed objective shows its lines.
- **[Silent refusal]** A click on a stale bar of a now-done objective changes nothing, and only the bar's disappearance shows it. → It can only follow a change in another window, within the second before the live refresh.

## Migration Plan

Nothing stored changes. Release 0.13.0. To roll back, install `v0.12.0` again.
