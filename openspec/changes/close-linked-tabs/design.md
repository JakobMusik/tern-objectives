# Design

## Context

See proposal.md, "Why".

- **The ⋯ menu** (`lib/app.luau`, `menu`) is one `cx:pick` with Rename, Side note, Due date, Tags and Delete, for open and done objectives alike. Delete asks first with a second picker (`delete`); every flow ends in `finish`, which shows the graph again if a picker closed it.
- **Which closed tabs show:** `View.build` lists a tab as closed when an objective links it, the window doesn't hold it, and its snapshot came from this window (`status_of`, `lib/view.luau:310`). Every such tab goes into `closed` (`lib/view.luau:520`), in scope, whatever objective links it. `closed` feeds the "Closed tabs" groups, the `Linked to` section's count, the "Prune closed tabs" button (`lib/view.luau:699`) and `prune` in `lib/app.luau:453`.
- **Prune** (`Store.prune`, `lib/store.luau:574`) removes every link to the given tabs, their snapshots and their panes' saved chats.
- **Lines:** outside review mode only open objectives draw lines; in review mode, the listed objectives (`lib/view.luau:643`). A selected done objective draws none.
- **Capture** (`lib/agents.luau`): `request()` runs one 0.5 s later unless one is under way, refreshes linked tabs' snapshots, then saves chats. Nothing reports back when it has finished.

### Source record

| Claim | Evidence |
|---|---|
| `cx.layout:close(pane)` closes a pane with no confirmation | `tern.d.luau:1754–1755` |
| There is no tab-closing call for plugins; a tab is its panes | `tern.d.luau` `LayoutCx` (`close`, `park`, `move_to_tab`…); SDK book: `close_tab` exists only as a palette action |
| A tab's panes are its layout's leaves and floats, which `Model.read` lists as rows; parked panes belong to the session's deck, not a tab | `lib/model.luau:44–117`; `tern.d.luau:1770–1771` |
| Picker rows take an `icon`; `x-circle` is one of Tern's icon names | SDK book, "Icon names" ("Status and alerts") |
| A picker opened from the graph can close the glimpse; `finish` reopens it | `lib/app.luau:187–199` |
| `tern.process.run` calls back with a fresh `cx` | `tern.d.luau:2129`; `resume-omp-chats` task 2.1 |
| Closing every pane of a tab, floating ones included, removes the tab | task 1.1: tab 7 (two side by side, one floating) was gone after closing its three panes in one call |
| A tab whose other panes all close survives while the graph's glimpse is over it, holding only the graph | task 1.1: tab 23 kept pane 26, kind "plugin" |

## Goals / Non-Goals

**Goals:**
- One confirmed action closes a finished objective's tabs, leaving each omp chat ready for Resume.
- A done objective's closed tabs survive Prune, for review, without cluttering the graph.

**Non-Goals:**
- Undo of a close.
- A setting to show done objectives' closed tabs all the time.

## Decisions

### D1. Which tabs close
For done objective X: X's linked tabs the window holds now (`Model.read`, `win.tabs`) that no open objective links. Tabs an open objective links are kept and counted. Closed and elsewhere tabs are left alone.

### D2. The menu row
In `menu`, for a done objective with at least one tab to close: `{ label = "Close linked tabs", detail = "2 open tabs", op = "close", icon = "x-circle" }`, placed before Delete.

### D3. The confirmation
A second picker, like Delete's:
- `Close 2 tabs` (icon `x-circle`), whose detail reads "ends their programs; omp chats come back with Resume", and, with kept tabs, also "1 linked to an open objective stays open";
- `Cancel`;
- placeholder `Close the tabs of “<title>”?`.

The tabs are worked out again on confirmation, so a tab opened, closed or linked meanwhile is counted right.

### D4. Save, then close
`Agents.save_now(cx, done)` runs the capture at once, not in 0.5 s, and whether or not one is already under way: one more capture writes the same values. It calls `done(ok, cx2)` once the snapshots are refreshed and the chats saved; also when no agent runs, after refreshing snapshots. `request()` stays as it is.

On `ok`, the plugin re-reads the window and closes every row's pane of each tab, with `cx2.layout:close`. It toasts "Closed 2 tabs of “X”" and calls `finish`. On failure it closes nothing and toasts "Objectives: couldn't save the omp chats, so no tab was closed".

Saving first refreshes each tab's snapshot, so its rows are current, and saves each omp chat's file, so the closed tab shows Resume (`resume-omp-chats`).

### D5. The graph's own tab
The graph is a glimpse over the current tab, and its pane is not one of the tab's rows (`Model.read` skips it). A tab whose other panes all close survives holding only the graph (task 1.1). So when that tab is among those closed, the plugin closes the graph first (`Surface.close`), then the tab's panes, and `finish` opens the graph over the tab Tern shows next.

### D6. Which closed tabs show
`View.build` keeps a closed tab in `closed` only when an open objective links it, the selected objective links it, or review mode lists an objective that links it. `Built` gains `prunable`: the tabs in `closed` that an open objective links. The Prune button shows when `#prunable > 0`, and `prune` in `lib/app.luau` passes `prunable`.

Lines need no change. A selected done objective draws none, as today; review mode draws the listed objectives' lines, now to their closed tabs too.

### D7. Prune keeps done objectives' links
`Store.prune(tabs)` removes links to those tabs from open objectives only. A tab's snapshot and its panes' saved chats go only when no done objective links it any more. It returns the number of links removed.

### D8. The done notice's button
- **When it shows:** `M.action`'s `done` branch, which already offers Undo, counts the tabs D1 would close for that objective. When there are any, the `Undo` entry also keeps the objective's id and the count, and `View.build` gets the count with the notice text (`ui_state`). The notice then ends with a `span` "Close 2 tabs", styled like Undo, with `click = "closetabs=<id>"`.
- **What a click does:** the click handler drops the notice on every click but Undo; `closetabs` is exempt too. It opens D3's confirmation for that objective, counting again. Confirming drops the notice, then runs D4. Cancelling leaves the notice, whose own 10 s timer may have ended it meanwhile. If no tab is left to close, it toasts and keeps the notice.
- **Why keep the notice on cancel:** done is final except through Undo (`objective-store`, "Final done state"), so a mis-click on the button must not cost the Undo.
- **The graph:** the confirmation can close the glimpse; `finish` reopens it with `M.open(cx, true)`, which keeps the notice (`lib/app.luau:136–139` drops it only on a fresh open).
- **Alternatives:** closing the tabs on marking done was rejected with the user: Undo couldn't bring them back, and the done box is a quick, frequent target.

### D9. Release
0.12.0, a minor release: a new action, and Prune behaves differently.

## Risks / Trade-offs

- **Closing ends programs without asking per tab:** builds, servers, agents of any kind. → The one confirmation names the count. omp chats can come back; nothing else can.
- **An omp chat in its first reply has no file yet** (`resume-omp-chats` source record), so its closed tab shows no Resume. → README limit.
- **Chats in sessions on another machine aren't saved** (capture reads this Mac), but their tabs still close. → README limit.
- **Hidden tabs can be forgotten:** a done objective's closed tabs show only when it is selected or in review. → The README says so; the trash icon or Delete removes them with the objective.
- **Mixed tabs:** a closed tab linked to open Y and done X loses Y's link on Prune and is then hidden, kept for X.
