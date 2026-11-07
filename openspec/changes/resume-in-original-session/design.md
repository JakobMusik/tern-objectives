# Design

## Context

See proposal.md, "Why".

- **Resume today** (`lib/app.luau`, `resume`; `resume-closed-agents` D5, D6 and `resume-omp-chats` D5): it refuses unless `cx.hosts:current().kind` is "local". It then closes the graph, opens `cx.layout:new_tab({ cwd })`, types `omp --resume '<file>'`, splits for further chats, calls `Store.adopt`, and refreshes the new tab's snapshot from a 250 ms timer.
- **What the snapshot holds:** `TabSnap` keeps `session` (id), `session_name` and `position` (one-based, within its session) as of the last time the graph or a capture saw the tab (`lib/store.luau:31`).

### Source record

| Claim | Evidence |
|---|---|
| `cx.layout:new_tab` opens in the current session, reveals by default, and returns the new shell pane's id | `tern.d.luau:1748–1749`; `resume-closed-agents` task 1.2 |
| In the call that opened it, the new tab isn't listed by `cx.session:tabs`, `layout` or `panes`, but `cx.session:tab_of(pane)` gives it | `resume-closed-agents` task 1.2 |
| `cx.sessions:switch(spec)` shows a session by id, exact name or "@current" | `tern.d.luau:720–721` |
| `cx.layout:move_to_new_tab(pane, session, reveal)` moves a pane to a new last tab of a session and returns the tab | `tern.d.luau:1764–1765` |
| `cx.layout:order_tab(tab, position)` reorders a tab at a one-based position within its session | `tern.d.luau:1781–1782` |
| `cx.session:sessions()` lists this window's sessions with `id`, `name`, `current` and ordered `tabs` | `tern.d.luau:1099`, `1708` |
| `cx.session:find_session(spec)` tries the spec as an id before names | `tern.d.luau:1713` ("Session by id, exact name, then name ignoring case") |
| `cx.sessions:list()` gives each session's `host`; `cx.hosts:list()` each host's `kind` | `tern.d.luau:706–715`; `lib/agents.luau` `local_panes` |

## Goals / Non-Goals

**Goals:**
- The resumed chat lands where its tab was: same session, same position.
- No tab ever opens and stays in the wrong session.

**Non-Goals:**
- Recreating a missing session, or restoring the tab's name and colour.

## Decisions

### D1. Which session
From `cx.session:sessions()`:
1. the session whose `id` equals the snapshot's `session`;
2. else the first, in Tern's order, whose `name` equals `session_name`;
3. else the first whose name equals it ignoring case;
4. else the current session, and after opening, the toast `Session “<name>” is gone: resumed here`.

The plugin matches names itself instead of calling `find_session`, which tries a spec as an id first: a session named "3" would match session id 3.

[INFERENCE] Session ids may not survive a daemon restart. The name steps cover that.

### D2. The machine check
Resume refuses when the chosen session's host (`cx.sessions:list()`, `host`) isn't a local host (`cx.hosts:list()`, `kind` "local"), with the toast "Resume works in a session on this Mac". Today's check, on the current host, goes: a chat from a local session can now come back there even while a remote session is shown. Chats are saved only in local sessions (`resume-omp-chats` D1), so step 4's fallback is the only way to reach a remote session.

### D3. Opening the tab there
Two ways; task 1.1 picks one:
- **A. Switch first:** `cx.sessions:switch(id)`, then `cx.layout:new_tab({ cwd })`. No tab ever exists in the wrong session, and the switch is wanted anyway. Risk: the window may apply the switch only after the call returns, as it lists a new tab only then; `new_tab` would then open in the old session.
- **B. Open, then move:** `new_tab` in the current session, then `cx.layout:move_to_new_tab(pane, id)`. Risks: the pane may not be movable within the call that opened it, and the emptied tab may linger.

Further chats split from the first pane, wherever it is, after it has been placed. When the target is the current session, neither is needed.

### D4. Position
`cx.layout:order_tab(tab, p)`, with `p` the snapshot's `position` capped at the session's tab count, the new tab included. A new tab is the last, so a position at or past the count needs no call. If `order_tab` can't see the tab within the opening call (as `tabs` can't), it runs in the 250 ms timer that already refreshes the new tab's snapshot. Task 1.1 checks which.

### D5. Release
0.11.1, a patch release. The requirement changes, but this fixes where Resume opens, as the user reported.

## Risks / Trade-offs

- **The snapshot's position is from the last time the plugin saw the tab.** Tabs opened or moved after that can make "tab 3" a different neighbourhood. → It is still the slot the user last saw the tab in.
- **Two sessions with the same name:** the first in Tern's order wins, after the id.
- **Switching sessions moves the user** away from where they clicked. → They chose this; the chat is what they asked for.
- **The graph:** it is closed before anything opens, as today, so no glimpse is left in the old session.
