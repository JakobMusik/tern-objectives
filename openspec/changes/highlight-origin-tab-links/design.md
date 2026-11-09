# Design

## Context

See proposal.md for the request and the user's two choices: lines over the others with the objectives tinted in place, and a highlight that shows whenever nothing is selected. The current code:

- **Selection** (`lib/app.luau:29`) is a module local in each window's VM: `local selected: string? = nil`. `M.open` (`app.luau:174–198`) resets `moving`, `confirm`, the Undo notice and the page on a fresh open, and takes the focused pane as `origin`, but leaves `selected` alone. `keep_origin` marks the reopen after one of the graph's pickers (`finish`, `app.luau:230–239`).
  - `M.new_key` (⌥N) opens fresh, then prompts. Its answer sets `selected = id` before `finish` reopens with `keep_origin` (`app.luau:243–274`).
  - `M.configure` opens fresh, then switches the page.
- **The origin's tab** is looked up in `View.build` by scanning `win.tabs` rows for `ui_state.origin` (`lib/view.luau:712–722`). It is used only to put that tab first. The tab node's ring and the row's bar come from `tab_node` (`view.luau:386–420`).
- **Lines** (`view.luau:880–906`): `add_edges` sets `selected = o.id == selected` on each edge. `Edges.build` (`lib/edges.luau:74–98`) puts selected edges on their own 3 px layer, after the 1.5 px layer, and gives that one `ob-e-dim` (opacity 0.25, `styles.css:47–49`) when any selected edge exists.
- **Node classes:** `objective_node` (`view.luau:213–246`) adds `ob-sel`, `ob-acts-on`, `ob-att-<kind>` and others. CSS: `.ob-obj` has a 1 px border on `var(--card)` (`styles.css:176–185`). `.ob-sel` adds an accent border and a 1 px outer accent ring. The attention rules after it set the border colour and an inset ring (`styles.css:186–207`).
- **The origin row's colours:** `.ob-row-origin` is an inset 3 px accent bar on a 10 % accent tint (`styles.css:635–638`).

### Source record

| Claim | Evidence |
|---|---|
| `cx.session:focused()` gives the focused pane id, which `M.open` takes as the origin | `tern.d.luau:1735–1736`; `app.luau:180–183` |
| `cx.layout:move_to_tab(pane, tab, reveal)` moves a pane into another tab, for the "Origin pane moves" check | `tern.d.luau:1762–1763`; the harness helper's `move_to_tab` op, used for polish-graph-ui task 4.1 |
| `rgb(from var(--accent) r g b / 10%)` renders as a tint | `.ob-row-origin` uses it, and `docs/graph.png` shows the tinted "guides" row |
| Later rules of equal specificity win, so the attention rings' borders override a border set before them | `styles.css:186–207`: `.ob-sel` then `.ob-att-*` |
| A later sibling layer in the gap paints over an earlier one | not checked on its own: the selected layer has always come last, and no shot so far looked at a crossing. **Risk**, checked in task 2.1. |

## Goals / Non-Goals

**Goals:**
- One reset in `M.open`, no new stored state.
- The highlight is worked out per render from `selected`, the origin and the filters, so it follows every change those already follow.
- The selection's own look (ring, action bar, link bars, `Linked to` section) stays the selection's.

**Non-Goals:**
- Any change to how the origin is taken, to the tab column's order, or to the origin's ring and row bar.
- Lines for done objectives that aren't selected.

## Decisions

### D1. A fresh open clears the selection
`M.open`'s fresh branch sets `selected = nil` beside the other resets. The `keep_origin` reopen skips that branch, so a picker's reopen keeps the selection. ⌥N still selects its objective, since its answer sets `selected` after the fresh open. Review mode, `page` handling and stored view state are untouched. The comment above `selected` says when it resets.

Alternative: clear the selection when the graph closes. Rejected: a picker's field closes the glimpse too (`finish`'s comment, `app.luau:227–229`), and `keep_origin` already tells the two kinds of open apart.

### D2. The focus tab
`View.build` looks up the origin's tab before building the left column; the existing lookup moves up. The **focus tab** is that tab's id when all of these hold:
- `selected == nil`;
- review mode is off (`reviewing`);
- the origin tab is live;
- it is placed in the right column: scope "All", or its session is the current one.

Otherwise there is no focus tab. A selected objective that a tag filter hides is still selected, so it leaves no focus tab, as today it leaves no strong lines.

### D3. Strong lines
`Edges.Edge.selected` becomes `strong`: the selected objective's lines, or, with a focus tab, every line ending at it. `Edges.build` keeps its layers: strong lines on the 3 px layer after the others, which fade with `ob-e-dim` once any strong line exists. With a focus tab but no shown open objective linking it, no line is strong and nothing fades. The comments in `edges.luau` say what `strong` covers.

### D4. Tinted objectives
`objective_node` adds `ob-lit` to an open node outside review mode that links the focus tab. That is the same set whose lines D3 draws, since `add_edges` draws every shown open objective's line to a placed tab.

`.ob-obj.ob-lit`, placed before the attention rules, sets `border-color: var(--accent)` and `background: rgb(from var(--accent) r g b / 10%)`. These are the origin row's tint and accent, so both ends of "where you came from" share one look. There is no box-shadow, which keeps:
- the outer ring for the selection;
- the inset rings for the attention marks, whose border colour wins (later rule) over the tint.

The border width doesn't change, so the node keeps its 48 px.

Rejected:
- the selection's ring, which would read as selected though no action bar shows;
- a bar like the origin row's, which the attention rings' inset shadow would replace.

### D5. README and screenshot
- **README:** the "Click an objective to select it" paragraph gains: each open starts with nothing selected; meanwhile the lines of the tab the graph was opened from stand out, and the objectives they lead to are tinted.
- **Screenshot:** `docs/graph.png` is retaken as 0.17.0 took it:
  - layout and store: `/tmp/tobj/kv.readme-0170.json`, its dates moved so the chips read as now;
  - opened from "Guides";
  - window size and crop: the same.

  It now shows "Read about rate limiting" tinted, with its line to Guides thick and the others faded. The alt text says so, and the draft goes to the user before it is committed.

### D6. Release
0.22.0, a minor release: behaviour changes.

## Risks / Trade-offs

- [Opening from a linked tab fades most lines, so the overview is quieter until the user selects something] → the user chose this. Clicking an objective, then empty space, cycles between the two looks. A tab no open objective links fades nothing.
- [The tinted node could be read as selected] → no outer ring, no action bar and no link bars. Task 2.1 checks shots of a selected node beside a tinted one in both appearances.
- [A strong layer painted under the faded one would show the faded line on top] → task 2.1 checks a crossing in a shot.
- [A tint on `var(--card)` nodes in dark mode] → the same tint already works for the origin row in both appearances. Task 2.1 checks both.
- [Users who relied on the selection surviving a close] → ⌥⇧R and the action bar need a click first. The user asked for it.

## Migration Plan

None: nothing is stored. To roll back, reinstall 0.21.0.
