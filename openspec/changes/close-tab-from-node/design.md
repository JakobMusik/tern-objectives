# Design

## Context

See proposal.md, "Why".

- **Tab nodes** (`lib/view.luau`, `tab_node`):
  - the header `ob-thead` jumps on click (`tab=<id>`) and holds two lines: `ob-th1` (the label, plus "Resume" on closed tabs) and the dimmed "<session> · tab <n>";
  - the node's right-click menu is the "Link to" list;
  - the header is 38 px (`Layout.px.tab_head_h`), and `ob-th1` is an 18 px flex row.
- **Closing tabs** (`lib/app.luau`): `close_tabs(cx, count)` runs `Agents.save_now`, re-reads the window, closes the graph first when it sits over one of the tabs, closes every row's pane with `cx.layout:close`, toasts, then calls `finish(cx2, true)`, which shows the graph again if it closed. It serves "Close n tabs" (bar and notice) and "Close n done tabs".
- **Questions in place** (custom-order-and-direct-controls D4): `confirm` holds the question. Any click ends it first in `M.action`, `cfm=` answers Close and `cfx=` Cancel. The view draws the question where `ui_state.confirm` says.
- **A done objective's trash icon** is `ob-trash`: 22 × 18 px, `--t3`, red on hover.

### Source record

| Claim | Evidence |
|---|---|
| `cx.layout:close(pane)` closes a pane with no confirmation | `tern.d.luau:1755` |
| Closing every pane of a tab removes the tab; a tab holding only the graph survives | close-linked-tabs, task 1.1 |
| Closing a session's last tab leaves the session there, empty | SDK book L38902 ("session_ended") |
| `:hover` and descendant selectors work in plugin CSS | SDK book L22769, L22783; `.ob-jump:hover` tints the button when the pointer is on its icon, a child (refine-graph-rows R7) |
| `opacity` and `visibility` are supported properties | SDK book L22215, L22273 |
| The harness rests the pointer with `ctl hover <selector>` and clicks with real hit-testing | SDK book L29662–29668; `openspec/config.yaml` |

## Goals / Non-Goals

**Goals:**
- Close one tab from the graph with two clicks in one place, with the same safety as the other closes: chats saved first, no link changes.
- Keep the right column as calm as today when the pointer isn't on a tab.

**Non-Goals:**
- Closing without asking, and Undo.
- Forgetting closed tabs, closing single panes, a menu row.

## Decisions

### D1. Which nodes get the icon
Every live tab node, in either part of the right column, the origin's tab included. Closed and other-window nodes don't: a closed tab is already closed, and another window's panes aren't this window's to close.

### D2. The icon
- **Where:** `tab_node` adds `span.ob-trash.ob-tclose` with Tern's `trash` icon after the label in `ob-th1`, with `click = "tclose=<tab>"` and the tooltip "Close this tab; asks first". Its own click wins over the header's, as "Resume" does on closed tabs.
- **Look:** the `ob-trash` rules, so it matches a done objective's icon (22 × 18 px, red on hover).
- **Showing it only on hover:** `.ob-tab .ob-tclose { opacity: 0; }` and `.ob-tab:hover .ob-tclose { opacity: 1; }`. Its place is kept while it's invisible, so the label doesn't shift under the pointer. The trade-off is that a long label is always cut 28 px earlier.
- **Why opacity and not `visibility`:** a hidden icon still takes a click, but the pointer has to be on the node to click it, and the node then shows it. The harness's `ctl click` on the icon also works without a `hover` first.

### D3. The question
`tclose` sets `confirm = { kind = "tab", id = "<tab>" }`. The question shows when `add_tab` sees that confirm for a live tab. While it asks:
- `ob-th1` holds the fixed text "Close tab?", which can be cut, then Cancel (`cfx=`) and Close (`cfm=`), so Close ends where the icon did, as the user was told. The line gets the class `ob-th1-ask`.
- Cancel and Close are 22 px pills on the 18 px line, inside the header's top padding, as "Resume" is (`margin: -2px 0`). Close is red like the bar's Close (`ob-act-cfm`), and Cancel is quiet. Neither text can be selected.
- The header's own click becomes `cfx=`, so a click near the question ends it without jumping.
- Nothing changes height: the header stays 38 px, and lines stay on their nodes.
- The tooltip on the question reads "Closing ends its programs; omp chats come back with Resume." when an objective links the tab. Otherwise it reads "Closing ends its programs. No objective links it, so it won't show under Closed tabs."

### D4. Close
`cfm` with a `tab` question calls `close_tab(cx, tab)`, which runs `close_tabs` with a count that returns `{ tab }` when the window still holds it, else `{}`. `close_tabs` already toasts "No open tab left to close" for an empty list.

`close_tabs`' `count` now returns the whole success toast instead of its ending:
- "Closed 2 tabs of “X”" and "Closed 1 done tab" read as today, with `plural` moved into the callers;
- one tab reads "Closed “Guides”".

No link, snapshot or saved chat changes beyond what `save_now` writes, as for the other closes.

### D5. Ending the question
The rule in `M.action` stays: any click ends a question, and only `cfm` acts on it. A live refresh while it asks keeps it. If the tab closes some other way meanwhile, its node is gone, and so is the question, until the next click clears `confirm`.

### D6. The session's last tab
The tab the graph sits over is often the one closed, and it can be its session's only tab. Closing it leaves the session empty (Source record), with no tab to show the graph over. `close_tabs` then shows the graph again only when the current session still has a tab (`cx.session:sessions()`, the current entry's `tabs`). Otherwise it just toasts.

This is untested: task 1.1 probes what `finish` does today in that case, and whether the session's tab list is current right after the closes. If the reopen already ends quietly, D6 is dropped and this design says so.

### D7. Release
0.23.0, a minor release: a new action.

## Risks / Trade-offs

- **Two quick clicks close a tab**, since Close takes the icon's place: the user chose that. The question also shows the tab's place underneath ("web · tab 2"), and the tab's rows stay visible.
- **Closing ends programs**: builds, servers, agents of any kind. → It asks first. omp chats come back only if an objective links the tab. Otherwise there is no Resume, which the question's tooltip says.
- **A narrow graph cuts the question to "Clo…"** before the answers shrink. → The answers always fit (scenario "Narrow graph"), and the tooltip has the whole question.
- **An omp chat in its first reply has no file yet**, so it can't come back. The other closes have the same limit (close-linked-tabs, Risks).
