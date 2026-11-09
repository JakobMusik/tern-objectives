# Proposal

## Why

Asked by the user on 2026-11-09. Today every fresh open of the graph starts outside review mode, so a user working through due reviews has to click "Review (n)" again each time they come back to the graph.

## What Changes

1. **Review mode is remembered between opens.**
   - Closing the graph no longer ends review mode, whichever of the README's ways closes it: ⌃⌘O, a click outside, its ×, or Esc.
   - The next open in the same window shows review mode again, listing the objectives due at that moment.
   - The memory belongs to the window, as the selection does. Other windows keep their own, and it's forgotten when the plugin reloads, which happens on every Tern restart. The user chose this over storing it in `kv.json`.
2. **Review mode still ends** when its list is empty, including at an open where nothing is due, and when the active "Review (n)" is clicked. Once ended, it isn't remembered.
3. **"Objectives: New objective" (⌥N) ends review mode,** so the objective it creates shows selected in the list. Today, ⌥N in review mode creates an objective that review mode hides. Without this change, ⌥N from a shell would open the graph in remembered review mode, with the same problem.
4. **README:** one sentence in "Reviewing done objectives" saying that review mode stays on until you leave it.
5. **Release 0.18.0**, a minor release because behaviour changes.

Out of scope:
- Remembering the settings page. The next open after Configure still shows the graph.
- Storing review mode in `kv.json`, or sharing it between windows.
- The header's "＋ New objective" in review mode. It still creates an objective that review mode hides until review mode ends.
- Remembering the Undo notice, a move in progress, or an inline question across opens. A fresh open still clears them.
- Review mode's list, sort order, rating buttons and schedule.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objective-review`: Leaving review mode is modified. Closing the graph no longer ends review mode, the next open in the window shows it again, and a plugin reload forgets it.
- `objectives-graph`: New objective key is modified (⌥N ends review mode).

## Impact

- `lib/app.luau`:
  - `M.open` no longer clears `reviewing` on a fresh open;
  - `M.new_key` clears it before showing the graph;
  - the comments on `reviewing` are updated.
- `README.md`: the sentence in "Reviewing done objectives".
- `openspec/specs/*`: the deltas above.
- `plugin.toml`: version 0.18.0.
