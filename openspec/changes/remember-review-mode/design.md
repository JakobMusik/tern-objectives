# Design

## Context

See proposal.md for the request and the user's choice: memory in the window, not in `kv.json`. The current code:

- **The flag:** `reviewing` is a module local in `lib/app.luau` (lines 74–76), next to the selection, the origin and the settings page's `page`. The archived review-done-objectives design keeps such state in the window's memory, not in the store (its Context, "App state").
- **Turning it on and off:** the header's "Review (n)" sends `rev=`, which flips it (lines 890–891).
- **Ending:**
  - `build()` sets it to false once the review list is empty (lines 134–136). `View.build` shows review mode only while the flag is set and the list has objectives (`lib/view.luau:507`).
  - `M.open` sets it to false on every fresh open (line 175), together with the Undo notice, a move, an inline question and `page`.
  - The reopen after the graph's own pickers (`finish`, lines 229–238) calls `M.open(cx, true)`, which skips those resets. That's why review mode outlives a picker today.
- **⌥N:** `M.new_key` (lines 262–270) opens the graph fresh if it isn't shown here, or else switches `page` back to the graph. Then it asks for the title. Review mode hides open objectives (`lib/view.luau:594`), so an objective made from review mode isn't shown.
- **Closing:** nothing in the plugin runs when the graph closes, so a close itself clears no state. The resets all happen in `M.open`.

### Source record

The SDK's line numbers below refer to `/tmp/ternsdk/book.txt`, the text of `https://docs.stencil.so/tern/print.html` fetched 2026-11-09.

| Claim | Evidence |
|---|---|
| A window half runs one VM per plugin per window, so a module local is per window | SDK "Architecture" (L249–250); "Window context" (L35664–35665) |
| A plugin reload starts the window half's module state empty | SDK workspace example: "Each window has its own VM, so each window has its own table, and a plugin reload starts it empty" (L28930–28931) |
| Tern reloads plugins on every restart | `openspec/specs/tab-links/spec.md`, scenario "Reload is not a close" |
| The harness reloads the plugin with `ctl plugins fixtures`, and toggles the graph with `plugins run plugin.objectives.open` | `openspec/config.yaml`; raise-priority-in-place, task 1.3 |
| `kv.json` written from outside the window is read on the next render | objective-store, scenario "Another window's objective kept"; custom-order-and-direct-controls, task 2.2 |
| `key Alt+n` in the harness runs the command bound to `alt+n` | custom-order-and-direct-controls, task 1.1 |

## Goals / Non-Goals

**Goals:**
- Review mode outlives closing the graph, with no new state and no store write.

**Non-Goals:**
- Any review state in `kv.json`.
- Changing what a fresh open clears, apart from review mode.

## Decisions

### D1. Keep the window's flag across opens
`M.open` stops clearing `reviewing` on a fresh open. Everything else it clears (the Undo notice, a move, an inline question, `page`, the origin) stays as it is.

The flag stays a module local, so each window has its own and a reload forgets it (source record).

Rejected: `state.view.reviewing` in `kv.json`, beside `done_open`. The user chose the window-only memory. Stored, it would also be shared by every window. The review list depends on each window's filters ("This session" reads that window's session), so a window with nothing due under its filters would turn review mode off for all of them.

### D2. Forgetting stays where it is
`build()` already clears the flag when the review list is empty. A flag left set while the graph is closed costs nothing. At the next open, the first `build()` either shows review mode or, with nothing due, clears the flag before the view is drawn. Once cleared it stays cleared, so a later due objective doesn't bring review mode back.

Rejected: clearing at close. No close hook runs (Context), and checking the list at close would just repeat what the next `build()` does.

### D3. ⌥N ends review mode
`M.new_key` sets `reviewing = false` before it opens or renders. The graph shows the list while the title field is open, and a dismissed field leaves review mode ended. The settings page already works this way.

Rejected: leaving review mode alone for ⌥N, the behaviour so far. With D1, ⌥N from a shell would then reopen review mode and create an objective it hides, breaking New objective key's "From a shell" scenario.

The header's "＋ New objective" is unchanged (proposal, out of scope).

## Risks / Trade-offs

- [Review mode can greet the user after a long time] → the "Review (n)" button is drawn active, and one click leaves it. An open with nothing due shows the graph as before.
- [Second window untested] → the headless harness has one window. The per-window claim rests on the SDK's one-VM-per-window rule (source record). Release task 2.3 has the user open the graph in a second window.
- [Configure, then Back to graph] → shows review mode if the window remembers it. That's the graph as it was left, which the settings page's requirement allows ("the next open SHALL show the graph").

## Migration Plan

None. Nothing is stored. To roll back, reinstall 0.17.0.
