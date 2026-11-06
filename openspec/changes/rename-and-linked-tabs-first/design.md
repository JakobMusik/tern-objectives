# Design

## Context

Motivation is in proposal.md, and the behaviour in `specs/objectives-graph/spec.md`. Code as of 0.6.1:

- **Objective node** (`lib/view.luau` 110–126): the card `div.ob-obj` carries `click = "sel=<id>"`. Inside it, line 1 (`.ob-l1`) holds the done box (`done=`), the badge (`prio=`), the title span `.ob-title` and ⋯ (`menu=`), and line 2 (`.ob-l2`) holds the note `.ob-note`, the due chip and the tag chips.
  - `.ob-l1` and `.ob-l2` are 18 px flex rows across the card's width, even when empty (`styles.css` 147–156).
  - `.ob-title` grows to fill line 1 between the badge and ⋯ (`flex: 1 1 auto`, 196–202).
  - Title and note text is selectable: neither is in a `user-select: none` rule.
- **Selection** is `selected` in `lib/app.luau` (15), kept in memory only (archived P5). It changes in five places:
  - `sel=` toggles it (447);
  - `bg=` clears it (448–452);
  - ＋ New objective selects the new objective (150);
  - Delete clears it (336–337);
  - `build` clears it when the objective is gone (29–31).

  A fresh open of the graph keeps it (`M.open`, 77–95).
- **Fields:** `rename(cx, o)` (229) and `side_note(cx, o)` (242) open `cx:prompt` filled with the current value, then call `finish(cx2, true)`, which shows the graph again (requirement "Graph returns after its pickers").
- **Right column** (`view.luau` 389–460):
  - sessions come in `win.sessions` order with the origin's session moved first, then each session's tabs with the origin's tab first (archived R1);
  - then the "Closed tabs" and "Other windows" ghost groups;
  - every item advances a `Layout.stack`, and `add_tab` returns the header centre that the lines end at.
- **The selected objective** is found while the left column is built (`sel_obj`, 326 and 342). A done objective is found only while the Done group is open, so with the group folded its selection draws no bars.

### Source record

| Fact | Source |
|---|---|
| Any `el` takes `actions = {click, dblclick, menu}`, one action id per trigger, and a node with `click` or `dblclick` gets `.sf-act` and the pointing hand | SDK "Actions on any `el`" (book L17878–17888); common props table (L7068) |
| A canvas delivers only `action` events to its owner, as `canvas_action`, in the clicking window | SDK "Canvas cx" (L32347); `tern.d.luau` L1496–1513, L2252 |
| A canvas view can't hold `input` or `editor` nodes, and an `el` `input` is a checkbox or radio only | `tern.d.luau` L1443, L2208–2209 |
| The harness has `dblclick <X> <Y>`: "Clicks twice, with the second press marked as a double-click" | SDK "tern ctl" table (L26502) |
| `tern.now()` is monotonic milliseconds | `tern.d.luau` L2074 |
| A canvas can't be scrolled by the plugin: only a `scroll` node's `stick = "end"` and a table's `selected` row move a view | SDK `scroll` (L7796–7810), `table` (L1739) |
| View state such as scroll position follows a node's key | SDK "Keys" (L3217–3222) |
| `user-select: none` works in the canvas | SDK "Supported CSS"; in use since 0.5.0 |
| A double-click sends the card's `click` from its first press, then only the inner node's `dblclick` from its second press: `sel=o1`, then `ren=o1` from node `…o:o1.l1.title` 4.4 ms later; `sel=o6`, then `note=o6` from `…o:o6.l2` 7.0 ms later. No second `sel=` arrives. The second line takes the double-click even when it holds no note | spike, task 1.1: harness 2026-11-06, `ctl dblclick` on o1's title and o6's empty second line, every `canvas_action` logged with `tern.now()` |

[INFERENCE] The harness's `dblclick` is synthetic, so a live double-click may space its presses 100–300 ms apart, and might also send a second `sel=`. D2's rule covers both.

## Goals / Non-Goals

**Goals:** the two refinements in the proposal. Node heights, row heights and line ends stay as they are.

**Non-Goals:**
- editing text in place;
- scrolling the graph by itself;
- storing the selection or its fixed set in `kv.json`.

## Decisions

### D1. Double-click targets
- `.ob-title` gets `actions = { dblclick = "ren=<id>" }`, and `.ob-l2` gets `actions = { dblclick = "note=<id>" }`. The card keeps `click = "sel=<id>"`.
- `ren` calls `rename(cx, o)` and `note` calls `side_note(cx, o)`, so answering and dismissing work as from the ⋯ menu, including the graph's return after the field. A missing objective toasts "That objective no longer exists", as the menu does.
- Line 2 is a full-width 18 px row even with no note, so an objective without a note can get one this way.
- The due and tag chips sit inside line 2 and have no actions of their own, so a double-click on them opens the side note too (proposal, out of scope).
- `.ob-title` and `.ob-note` join the `user-select: none` rules, so a double-click doesn't highlight a word. The card's tooltip keeps the full title and note.

Alternatives:
- `dblclick` on the whole card: one target, but it would also catch double-clicks on the badge and ⋯.
- Inline editing: impossible in a canvas (source record).

### D2. A double-click leaves the selection alone
The spike (source record) shows the first press also sends `sel=`, so a double-click toggles the selection once before `ren` or `note` arrives:
- with nothing selected, it selects the objective;
- with the same objective selected, it deselects it;
- with another objective A selected, it selects B, so A's selection is lost.

If a live double-click also sends a second `sel=`, the outcomes differ, but the selection still isn't left as it was.

So `app.luau` records, for each `sel=`, the selection and fixed set from just before it, with `tern.now()`. When `ren=<id>` or `note=<id>` arrives, every `sel=<id>` within the last 700 ms is undone: the selection and fixed set go back to what they were before the first of them.
- 700 ms is above macOS's default double-click interval (500 ms). A deliberate single click on the same objective more than 700 ms before is kept.
- One or two `sel=` before the double-click are undone the same way.

### D3. The fixed set
- `app.luau` keeps `pinned: { [number]: boolean }?` beside `selected`. One helper sets both: selecting objective `id` sets `pinned` to its `tabs` read from the store at that moment, and clearing sets both to nil.
- The five places in Context call that helper. D2's undo restores both values together.
- `pinned` reaches the view as `ui_state.pinned`. Like the selection, it is never written to `kv.json`, and a plugin reload forgets it (README known limit).
- Links made while the objective stays selected change `o.tabs` and so the bars and lines, but not `pinned`. The order moves only when the selection changes. The right-click "Link to" menu works the same way.

### D4. Two sections from one ordering
- `View.build`'s right column becomes one function, `place(keep)`, that emits the current order (sessions with origin first, their tabs, then the ghost groups) for the tabs where `keep(tab)` is true.
- With a selected objective found (`sel_obj`) and at least one shown tab in `pinned`:
  1. a heading row `.ob-group.ob-linkhead` reading `Linked to “<title>”`, the quotes as in Delete's “…”;
  2. `place(pinned)`;
  3. a divider row `.ob-group.ob-divider` reading "Other tabs", only when at least one shown tab follows;
  4. `place(not pinned)`.

  Otherwise `place(all)`, as today.
- The heading and divider take `Layout.add_group` (24 px plus 14 px margin). The divider's rule is a 1 px inset shadow along its top, not a border, so the stack arithmetic and line ends need nothing new.
- Keys stay unique among siblings: tab nodes keep `t:<id>` (a tab appears once), and the top section's session headings and ghost groups take the prefix `l`: `ls:<id>`, `lclosedgrp`, `lelsegrp`.
- Scope applies inside `place`, as now: "This session" keeps only the current session's tabs and its closed linked tabs, and drops other windows.
- A done objective selected while the Done group is folded isn't found, so there's no top section, just as there are no bars.

Alternatives:
- Copy the linked tabs to the top and keep them below as well: no tab would move, but every linked tab would draw twice and its lines would have two ends.
- Re-sort the whole column by link count: no divider needed, but tabs would move on every link.

### D5. Release 0.7.0
A minor version, since behaviour changes. The README's "Using the graph" covers the double-click and the top section, and its screenshot is refreshed only if the change shows in it.

## Risks / Trade-offs

- **[The first press sends `sel=`]** (confirmed, task 1.1) → D2 restores the selection. Between the two presses, the right column shows that one click's result: a re-sort, then the old order once the double-click lands, behind the field as it opens. The user accepted that flash. Task 3.1 records what a shot shows.
- **[A live double-click spaces its presses by more than 700 ms]** → It can't by macOS's default setting (500 ms). A user who set a longer interval in System Settings would see the one-click result kept. The live check (4.2) watches for it.
- **[The top section scrolled out of view]** → Accepted, with no automatic scrolling (proposal, out of scope). The lines from the selected objective still run up to the section.
- **[A stale fixed set]** → A pinned tab that closes becomes a ghost in the top section's "Closed tabs". A new tab, which isn't pinned, goes below the divider. Pruning removes closed tabs from both.
- **[Two passes over the tabs]** → Same node count as today; the render budget isn't affected.
