# Design

## Context

See proposal.md, "Why".

- **The question state** (`lib/app.luau`): `confirm` is per window VM and never stored. The header's button sets `{kind = "done_tabs"}` (`closedone` verb). A done objective's bar sets `{kind = "close", id, where = "bar"}` (`close`), and its notice sets `{kind = "close", id, where = "notice"}` (`closetabs`). `M.action` clears `confirm` at the top of every click, so Close (`cfm`), Cancel (`cfx`) and any other click end the question. `View.build` receives it as `Ui.confirm`.
- **What each Close closes:**
  - **Bar and notice:** `View.closable(state, win, o)`, the done objective's linked tabs that this window holds and that no open objective links. It counts tabs in every session of the window, whatever the scope.
  - **Header:** `Built.done_tabs`, the live tabs the graph shows that only done objectives link, gathered in `add_tab`. `close_done_tabs` counts them again from a fresh `build`.
- **When each question is drawn** (`View.build`):
  - **Bar:** in `add_node`, for the selected objective only, when `confirm` names it and `closable` finds tabs (`ask = "close"`).
  - **Notice:** in the header, when the Undo notice carries `undo_close` for the objective that `confirm` names. The notice's 10 s timer drops the Undo, and the question with it, even while it asks.
  - **Header:** in the header, when `#done_tabs > 0`.

  The left column is built before the right one, and the header last.
- **The tab column's order** (`View.build`, linked-section D1):
  - `placed` lists the shown sessions, the origin's first, each with its live tabs.
  - `place(keep, prefix)` draws a session heading and that session's tabs for every session that has a tab `keep` accepts, then the "Closed tabs" and "Other windows" groups. `prefix` keeps the heading keys of the two passes apart.
  - With an objective selected and one of its tabs shown, the column is `Linked to “X”` with `place(sel_tabs)`, then, if other tabs are shown, the "Other tabs" divider with `place(not sel_tabs)`; otherwise it is `place(nil)`.
  - `Layout.add_group`, `add_divider`, `add_session` and `add_tab` stack each part's height in order, and each line's end comes from the tab's place in that stack. So a tab placed elsewhere takes its lines along.
- **The tab node** (`tab_node`):
  - `.ob-tab`, `overflow: hidden`, with a 1 px border;
  - **origin ring:** an inset box-shadow;
  - **attention ring:** a border colour plus an inset box-shadow;
  - **selected tab:** an outer 1 px box-shadow;
  - **second line:** `.ob-tl2`, an 18 px nowrap flex row holding the attention chip, then `.ob-line` "where", which ends in "…".

### Source record

| Claim | Evidence |
|---|---|
| A plugin canvas gets only click actions, with no hover events | `tern.d.luau` L1932–1933 ("a canvas takes only action events and delivers them to its owner as clicks"), regenerated for Tern 0.9.27 |
| Plugin CSS has no `~` and no `:has()` | SDK book "Supported CSS › Selectors" (`/tmp/ternsdk/book.txt` L27802, L27850) |
| `outline`, `outline-offset` and `box-shadow` are supported | SDK book "Supported CSS" (L27271–27277, L27292, L27575) |
| `--bad` is the red the graph already uses for closing and deleting | `styles.css` `.ob-trash:hover` and the action bar's Close and Delete on hover |
| A `title` on a span shows as its tooltip, and `ctl tree` lists it | pin-new-objective task 1.2 (`ctl tree '.ob-newchip'` read the chip's tooltip) |
| A chip in a tab node's second line renders and keeps the 18 px line | search-and-tab-marks D7 (the attention chip) |

## Goals / Non-Goals

**Goals:**
- The marks come from the same lists that Close closes, so the two can't disagree.
- They show exactly while a question shows, and go with it, without new app state.
- No change to node heights, so the lines between nodes stay where they are.

**Non-Goals:**
- Marking on hover, a tab's own "Close tab?", scrolling to a marked tab, and any change to what Close closes.

## Decisions

### D1. Which tabs are marked
`View.build` keeps a set, `closing: {[number]: boolean}`, filled from the list the drawn question's Close uses:
- **Bar:** in `add_node`, when it sets `ask = "close"`: the `tabs` that `M.closable` returned there.
- **Notice:** before the columns, when `ui_state.undo_close` and `confirm` (`kind = "close"`, `where = "notice"`) name the same objective: `M.closable` for it. The header then reuses this list for its question rather than calling `closable` again.
- **Header:** before the tab column is placed, when `confirm.kind == "done_tabs"`, each shown live tab (in `placed`) that only done objectives link: the same test `add_tab` uses to gather `done_tabs`. D7 needs the whole set before the first tab is drawn.

Only live tab nodes are marked: `closable` and `done_tabs` hold only tabs that this window holds.

*Alternatives:*
- **Computing the set in `lib/app.luau`:** rejected. The app would need the column-building conditions, which live in the view, and two copies could drift.

### D2. When the marks go
They go with the question, through the same conditions. A click clears `confirm`. When the notice's timer drops the Undo, `undo_close` is nil on the next render, so the notice's tabs are no longer gathered. Nothing new is stored or timed.

### D3. The ring
`.ob-tab.ob-tclosing { outline: 2px solid var(--bad); outline-offset: -2px; }`, over the border.
- An outline takes no space, so node heights and the lines stay as they are.
- It is drawn inside. Task 1.2 found an outline outside the border (offset 1 px) cut on the right at 760 and 460 px, where the graph fills the window and the canvas clips past the right column's edge. Inside, it covers the 1 px border, and the origin and attention rings, while the question shows. The selected tab's outer ring still shows; the origin tab keeps its row's accent bar, and an attention mark its chip.

*Alternatives:*
- **Outside the border** (offset 1 px), which keeps every ring visible. Rejected after task 1.2's shots, as above.
- **Padding on the right column,** so an outside ring fits. Rejected: it narrows every tab node for a mark that shows only while a question asks.
- **Border colour and box-shadow,** as the attention rings use. Rejected: every combination with origin, attention and selected needs its own rule, as the 11 tab-ring rules already show.
- **Fading the other tabs.** Rejected: it hides their own marks, and doesn't name the tabs the scope hides.

### D4. The chip
- `span("ob-chip ob-closechip", "Closes", { key = "closes", title = "This tab closes if you click Close" })`, first in `.ob-tl2`, before the attention chip.
- `.ob-closechip`: `--bad` text on a 12% `--bad` tint, bold, as "working" is drawn in the accent colour.
- `.ob-chip` is `flex: none`, so in a narrow column `.ob-line`, the "where" text, is cut first.

### D5. The tooltip names the tabs
A helper, `quote_list(labels)`, quotes labels as the attention chip's tooltip does: “A”; “A” and “B”; “A”, “B” and “C”. It isn't named `names`, since `tab_mark` has a local of that name. Each question's tooltip starts with "Close " .. quote_list(…) .. "?":
- **Bar** (`.ob-askrow`): this replaces today's "Close n tabs?". The kept-tab and Resume sentences follow as today.
- **Notice** (`.ob-undo-text`): this goes before "Closing ends their programs; omp chats come back with Resume."
- **Header** (`.ob-undo-text`): this goes before "Closing ends their programs; omp chats come back with Resume. No link changes."

The labels come from `win.tabs[tab].label` for the bar and the notice, and from the tab nodes in `add_tab` for the header. The question's visible text stays as it is.

### D6. No marking on hover
The user chose marking only while the question shows. Marking on hover would need the button to be the DOM sibling just before `.ob-graph` (`.ob-closedone:hover + .ob-graph .ob-tclosing`), since `~` and `:has()` don't exist and a canvas gets no hover events. The header would then have to be rebuilt with CSS `order`.

### D7. Listed first
While `closing` holds a shown live tab, the column starts with a "Closes" section:
- a group heading, `div.ob-group.ob-closehead` with the text "Closes" and the tooltip "These tabs close if you click Close", in `--bad` as `.ob-linkhead` is in the accent colour (`Layout.add_group`);
- `place(closing, "c")`: the closing tabs under their session headings, in the column's usual session and tab order.

The rest follows as the column would be without them, with each `keep` also refusing closing tabs:
- **With an objective selected:** if any of its other tabs is shown, `Linked to “X”` and `place(sel_tabs and not closing, "l")` come next, then, if other tabs are shown, the divider and `place(neither, "")`.
- **Otherwise,** if any other tab is shown, the divider and `place(not closing, "")`.

The counts that decide on the heading and the divider (`n_top`, `n_rest`) leave closing tabs out. A session whose tabs all close shows its heading only in the "Closes" section.

Only the tab column moves. The bar's answers are in the left column and the notice's and the header's are in the header, so nothing moves under the pointer. A tab's own "Close tab?" (`confirm.kind == "tab"`) sets no `closing` and moves nothing. Its Close button sits on the node, which must stay where it is.

*Alternatives:*
- **Closing tabs first inside the `Linked to` section** for the bar's question only. Rejected: the header's and the notice's tabs can be anywhere, and one rule for all three is easier to read.
- **Scrolling to the first marked tab.** Rejected: `tern.d.luau` has no scroll call for a canvas (its only "scroll" lines, L496, L537 and L646, are about block and lens views), and the section is at the top anyway.

## Risks / Trade-offs

- **The outline is clipped** past the right column's edge when the graph fills the window (task 1.2). → D3 draws it inside the border.
- **Marked tabs out of view.** The right column can be taller than the window. → D7 lists them first, and the tooltip names every tab, including those the scope hides.
- **The column jumps** when a question starts and ends. → This is the point of D7, and only the tab column moves, never the control under the pointer.
- **A long tooltip** when many tabs close. → Acceptable: it is shown only on hover, and the count stays in the visible text.
- **Cost:** one extra `closable` call per render, and only while the notice asks. → The harness checks renders stay within the 20 ms target.

## Migration Plan

Nothing is stored. A rollback to 0.31.0 keeps the marks and drops the order; a rollback to 0.30.0 drops the marks and the names in the tooltips.
