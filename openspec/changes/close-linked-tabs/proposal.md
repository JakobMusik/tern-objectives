# Proposal

## Why

The user asked for an option on done objectives that closes the tabs the objective was linked to. Finishing an objective today leaves its tabs open, and closing them means finding each one by hand.

Two choices were settled with the user on 2026-11-07:
- tabs still linked to an open objective stay open, and the plugin asks before closing;
- with the plugin's recommendations: the option is a row in the done objective's ⋯ menu, and done objectives' closed tabs are kept for review rather than pruned.

The second point matters because Tern can't reopen a closed tab. What survives a close is the plugin's snapshot of the tab, its links, and, since 0.11.0, each omp chat's file, which Resume uses. Today "Prune closed tabs" deletes all of that for every closed tab, done objectives' included, so a pruned done objective comes up in review with no lines and no Resume. Done objectives draw no lines outside review mode, so their closed tabs sit unconnected in "Closed tabs", which invites that prune.

## What Changes

1. **Close linked tabs:** a done objective's ⋯ menu gets "Close linked tabs", with the number of its tabs open in this window, when there is at least one. Choosing it asks first, naming how many tabs close and how many stay open because an open objective links them. On confirmation, the plugin saves the omp chats in those tabs, as it does at a turn, then closes every pane of each tab. The links stay, so the tabs become closed tabs with Resume.
2. **Done objectives' closed tabs are tucked away:** a closed tab that only done objectives link no longer shows in "Closed tabs". It shows while one of those objectives is selected, and in review mode for the objectives listed, with their lines.
3. **Prune keeps them:** "Prune closed tabs" removes only open objectives' links. A closed tab's snapshot and saved chats go only when no done objective links it. The button counts, and shows for, closed tabs linked to an open objective.
4. Release as 0.12.0, with the README updated.

Out of scope:
- Closing tabs of open objectives, or of tabs held by another window.
- Undo of a close: Tern can't reopen tabs. Resume brings back the omp chats.
- Closing the tabs at the moment an objective is marked done, from the "Marked done" notice.
- Showing done objectives' tabs held by another window differently: "Other windows" is unchanged.
- Restoring a resumed tab's layout beyond today's side-by-side splits.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`: the ⋯ menu's new row; closing a done objective's tabs; which closed tabs the right column shows; when "Prune closed tabs" shows.
- `objective-store`: "Pruning closed tabs" keeps done objectives' links and their tabs' snapshots.
- `objective-review`: review mode's right column adds the listed objectives' closed tabs.
- `tab-links`: "Link status" covers the linked tabs the graph shows, not every linked tab.

## Impact

- `lib/app.luau`: the menu row, the confirmation, the close flow, and the prune count.
- `lib/agents.luau`: a capture that reports when it has saved, for closing right after.
- `lib/view.luau`: which closed tabs are shown, and a list of the ones Prune may touch.
- `lib/store.luau`: `prune` keeps done objectives' links and snapshots.
- `README.md`, `plugin.toml` (0.12.0).
