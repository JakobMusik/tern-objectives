# Design

## Context

See proposal.md, "Why". The review's findings, with file:line evidence, are summarised there; the three code fixes are the only behaviour changes.

- **Tag filter:**
  - `View.build` hides every objective not holding `view.tag` (`lib/view.luau:344`).
  - The header's chips come only from `Store.all_tags` (`lib/store.luau:202`), the tags some objective holds.
  - Only a chip click changes the filter (`lib/app.luau`, act `tag`), and the filter is stored with the view settings (`Store.set_view`, `lib/store.luau:704`).
  - So once the filtered tag's last holder loses it, no chip can clear the filter.
- **"you: …":** `agent_lines` (`lib/details.luau:122`) shows `you: …` for any agent row whose transcript entry hasn't been read. `M.tick` then reads one transcript per tick, for any agent. For agents without an omp chat the read finds no user message, and the line disappears.
- **Sorting:** `sort_open` in `lib/view.luau:53` orders open objectives by priority, due date, created time, then id. `sorted_open` in `lib/app.luau:216`, used by "Link this tab", is a copy without the id tie-break.
- **Agent names:** `agent_name` (`lib/details.luau:88`) returns "claude" for Claude Code, else the command's base name, else "omp".

### Source record

| Claim | Evidence |
|---|---|
| `Store.set_view(fn)` writes the view settings through `mutate`, only when `fn` returns true | `lib/store.luau:704–707` |
| `build` in `lib/app.luau` already writes the store on render (snapshots, sessions), so a write there is not new | `lib/app.luau` `build`: `Store.refresh_snapshots`, `Store.save_sessions` |
| A transcript read returns no user message for agents without a readable omp chat | `lib/details.luau:199–213`; review finding N4 |
| The behaviours the new scenarios describe (ghost look, closed prefixes, divider rule, closed-tab order, graph's own tab, case-insensitive session match, "Link to" heading, Resume moving links) exist today | `lib/view.luau:190–204, 562–572, 660`, `styles.css:442–454`, `lib/app.luau:448–452, 632–636`, `lib/store.luau:676–686`; review findings E1–E3, G1, G3–G5 |

## Goals / Non-Goals

**Goals:**
- Main specs that say what the code does, with each new or changed statement checked in the headless Tern.
- The three code fixes, nothing else.

**Non-Goals:**
- Changing how ghosts look, how Resume works, or any other behaviour the specs now describe.
- Archived records (separate docs commit).

## Decisions

### D1. A stale tag filter is dropped at render
- In `build` (`lib/app.luau`), after `Store.read()`: if `state.view.tag` is set and `Store.all_tags(state)` doesn't hold it, `Store.set_view` clears it. The view then builds from the cleared settings.
- One place covers every way a tag disappears: unticking it, deleting or removing its objective, Undo, and another window's change.

Alternatives:
- Clearing the filter inside each store change that can drop a tag misses changes made in another window until the next such change.
- Ignoring a stale filter in the view without storing the change would bring it back the day a new objective gets that tag.

### D2. The "you: …" line only for omp agents
- `agent_lines` shows the waiting `you: …` line, and marks the pane stale for a transcript read, only when `agent_name(a, program)` is "omp".
- Other agents never get a "you:" line and cost no transcript read.

Alternative: keep reading and showing the placeholder for every agent, and just accept the flash. Rejected: the spec says agents without an omp chat show the reply line only.

### D3. One open-objective sort
- `lib/view.luau` exports its comparator as `View.sort_open(list)`.
- `sorted_open` in `lib/app.luau` collects the open objectives and calls it; its own comparator goes.
- "Link this tab" then lists objectives in graph order, ties included.

### D4. Docs outside the deltas
- **Purposes:** edited directly in the main specs (OpenSpec deltas don't carry Purpose).
  - objectives-graph: "…The user manages objectives mostly by clicking, with a rename key and typed fields where text is needed…".
  - objective-store: names the review schedules and saved omp chats it also holds.
- **`openspec/config.yaml`:** the specs rule becomes "Every scenario must be observable in the headless Tern (a real click, a screenshot, or a kv dump); plugin-package's repository and install scenarios are observed in the repository, on GitHub, or with an isolated install."
- **README:**
  - the box bullet: done objectives' links can't change "(Resume aside: the reopened tab takes them over)";
  - the tabs bullet: live unlinked tabs are grey and dashed, and ghosts are faint, half strength, struck through when closed;
  - the Prune limit: done objectives keep their links, so a done objective counts there unless it has no links left or only other sessions' or windows' tabs.

## Risks / Trade-offs

- **[A write during render]** D1 writes the store when it clears a stale filter. → Only once per stale filter, as `refresh_snapshots` writes only on change; the render that follows reads the cleared value.
- **[Another window's filter]** View settings are shared by every window's graph. Clearing a stale filter in one window clears it for all. → Intended: the filter is stale everywhere.
- **[Spec-only scenarios]** Most new scenarios describe existing behaviour. → Each is still run in the headless Tern (tasks), so a spec that is wrong about the code shows up as a failed check, not a silent mismatch.
- **[Another agent in the harness]** D2's scenario needs an agent other than omp. → If none can run in the harness, the check uses a helper op that renders a copy of `lib/details.luau` against a non-omp agent entry.

## Migration Plan

Nothing stored changes, except that a stale tag filter is cleared on the first render. Release 0.14.1. To roll back, install `v0.14.0` again.
