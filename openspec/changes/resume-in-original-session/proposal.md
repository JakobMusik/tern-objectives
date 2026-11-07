# Proposal

## Why

The user checked Resume in 0.11.0: it works, but the chat comes back in a new tab of the session that has focus, which can be another session than the one the chat was in. The requirement asked for exactly that ("a new tab in the current session"). The user wants the chat back where it was. On 2026-11-07 they chose: back in its own session at its old position, Tern switching to that session; and when that session is gone, the current session.

Every closed tab's snapshot already holds what this needs: its session's id and name, and its position in that session (`TabSnap`, `lib/store.luau:31`). Tern's window API can show a session (`cx.sessions:switch`), move a pane into a new last tab of any session (`cx.layout:move_to_new_tab(pane, session)`) and reorder a tab within its session (`cx.layout:order_tab(tab, position)`) (`tern.d.luau:721`, `1765`, `1782`).

## What Changes

1. **Session:** Resume opens the new tab in the closed tab's session, found by the id it had, else by its name, so a renamed session or one recreated under the same name still counts. Tern switches to that session, so the user lands on the chat, as today.
2. **Position:** the new tab takes the position the closed tab had in that session, for example tab 3. When the session now has fewer tabs, it is the last.
3. **Session gone:** when no session matches, the chat comes back in the current session, as its last tab, and a toast names the missing session.
4. **Remote:** Resume refuses only when the session it would open in is on another machine, instead of whenever the current session is.
5. Release as 0.11.1, a fix to where Resume opens, with the README's Resume line updated.

Out of scope:
- Recreating a closed session under its old name (the user chose the current session instead).
- Restoring the old tab's name, colour, or its panes other than omp chats.
- Resuming in the background without switching sessions.
- "Close linked tabs" for done objectives: a later change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `agent-resume`: "Resuming a closed tab" opens in the closed tab's session instead of the current one; a new requirement says which session and position, the fallback, and the remote rule.

## Impact

- `lib/app.luau` (`resume`): picks the session, opens the tab there (switching first, or moving the new pane, whichever the spike shows works cleanly), orders the tab, and toasts when it falls back. The 250 ms snapshot timer stays.
- `README.md`, `plugin.toml` (0.11.1).
- No store change: the snapshot already holds the session and position.
