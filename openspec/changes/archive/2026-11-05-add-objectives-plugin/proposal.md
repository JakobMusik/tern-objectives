# Proposal

## Why

Work in Tern spreads across many sessions, tabs and panes, but nothing records which tabs serve which goal. The built-in board block writes a `TODO.md` into whatever folder the focused pane is in, and note blocks hold text with no way to jump to the tabs the text is about. The user keeps objective notes by hand elsewhere and still can't see at a glance which tab belongs to which objective, or get to it in one click.

## What Changes

- Add a Tern plugin, id `objectives`, window half only (`window.luau`). It installs with `tern plugin install github.com/JakobMusik/tern-objectives`.
- Keep **one flat global list of objectives**, stored in the plugin's own `kv.json`. Objectives don't belong to sessions. Each objective has:
  - required: a title, a done flag, priority P0–P3, and created/done times;
  - optional: a one-line side note, a due date (date only) and lowercase tags.
- Link objectives to **tabs**, many-to-many. Links survive Tern restarts because tab ids do. A closed linked tab stays as a greyed "ghost" until the user prunes it.
- Add a bipartite **graph** in a canvas opened as a glimpse:
  - Left column: objective nodes with done, priority, ⋯ menu, note, due and tag chips.
  - Right column: tab nodes grouped by session, each listing its pane rows.
  - Lines between them are coloured by priority.
  - Clicking a tab header jumps to that tab, in any session. Clicking a pane row jumps to that exact pane.
  - Header: scope filter (All / This session), tag filter, "＋ New objective", and "Prune closed tabs".
- Add **expandable pane rows**:
  - omp agents show their state, the user's last message and the agent's last reply, each cut to 160 characters.
  - Terminals show the last finished or currently running command.
  - Other panes show their path, URL or title.
- Add three palette commands: "Objectives: Open graph" (⌃⌘O), "Objectives: Link this tab…" and "Objectives: New objective for this tab…".
- Publish the plugin as the public repository `JakobMusik/tern-objectives` (MIT, topic `tern-plugin`, version 0.1.0).

## Capabilities

### New Capabilities

- `objective-store`: the objective record, global storage in `kv.json`, the single writer, saved tab snapshots for ghosts, pruning, and remembered view state.
- `tab-links`: many-to-many links between objectives and tabs, made from the graph or from palette commands, with no automatic linking.
- `objectives-graph`: the canvas view, covering layout, sorting, objective controls, lines and colours, filters, the Done group, selection, and live refresh.
- `pane-details`: expandable pane rows showing agent state and last messages, terminal commands, and other pane facts.
- `tab-navigation`: jumping from the graph to a tab or an exact pane across sessions, and how ghost and other-window tabs behave.
- `plugin-package`: the manifest, the published repository, installation with `tern plugin install`, and the README.

### Modified Capabilities

None. This is the first change in the project.

## Impact

- **New repository content:** `plugin.toml`, `window.luau` (and any modules it requires), `styles.css`, `README.md`, `docs/graph.png` (the README screenshot), `LICENSE`, `.gitignore`, and `openspec/`.
- **Runtime data:**
  - `<Tern config>/plugin-data/objectives/kv.json`. Nothing is written into project folders or the home folder.
  - Runtime CSS sheets installed with `tern.css` (`plugin:local:objectives:*`).
- **Tern APIs used** (window half only):
  - `cx.session`, `cx.sessions`, `cx.layout`, `cx.canvas`, `cx.agents`;
  - `cx:pick`, `cx:prompt`, `cx:toast`;
  - `tern.command`, `tern.on`, `tern.kv`, `tern.css`, `tern.timer`.
- **External:** a new public GitHub repository under `JakobMusik`. The plugin is installed once in the user's live Tern after headless testing.
- **Not affected:** Tern's board, note and canvas blocks, and the user's existing notes, which this plugin neither reads nor replaces.

## Out of scope

- Objective badges or marks on tabs or in the tab bar.
- Reopening the omp chat of a closed pane, or starting agents from an objective.
- Syncing between machines, and any store other than the local `kv.json`.
- Automatic linking by folder, split parent or agent.
- Importing existing objective notes kept elsewhere.
- Jumping to tabs held by another Tern window.
- Keyboard navigation inside the graph, drag and drop, and multi-line notes.
- Links to individual panes. Panes appear only as rows inside tab nodes.
- Submission to a plugin catalog.
