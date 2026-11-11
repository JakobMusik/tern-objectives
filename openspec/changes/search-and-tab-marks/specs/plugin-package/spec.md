## MODIFIED Requirements

### Requirement: Palette commands
The plugin SHALL register seven palette commands in the group "Objectives", four with default keys:
- "Objectives: Open graph", ⌃⌘O;
- "Objectives: Rename selected objective", ⌥⇧R;
- "Objectives: New objective", ⌥N;
- "Objectives: Search…", ⌃⌥F;
- "Objectives: Link this tab…";
- "Objectives: New objective for this tab…";
- "Objectives: Configure".

The palette SHALL list the rename command only while an objective is selected in a graph shown over the current tab. Its key works either way.

#### Scenario: Commands listed
- **WHEN** an objective is selected in the graph shown over the current tab, and the palette is opened with the query "objectives"
- **THEN** the seven commands appear, "Open graph" with ⌃⌘O, "Rename selected objective" with ⌥⇧R, "New objective" with ⌥N and "Search…" with ⌃⌥F

#### Scenario: Rename hidden without the graph
- **WHEN** no graph is shown over the current tab, and the palette is opened with the query "objectives"
- **THEN** "Open graph", "New objective", "Search…", "Link this tab…", "New objective for this tab…" and "Configure" appear, and "Rename selected objective" doesn't

#### Scenario: Rename hidden without a selection
- **WHEN** the graph is shown over the current tab with nothing selected, and the palette is opened with the query "objectives"
- **THEN** "Rename selected objective" doesn't appear, and the other six commands do

### Requirement: README
The README SHALL give:
- the exact install command;
- that it needs only `git` on `PATH`, and nothing on the machines sessions run on;
- the seven commands with the ⌃⌘O, ⌥⇧R, ⌥N and ⌃⌥F keys;
- how to close the graph: ⌃⌘O, a click outside, its ×, or Esc after clicking its title bar;
- how searching and reviewing done objectives work;
- where its data lives and how to remove it;
- two screenshots: the graph with the Done group open and a marked tab, then review mode with its rating buttons.

#### Scenario: README contents
- **WHEN** a reader opens the README
- **THEN** it contains the install command, the commands with ⌃⌘O, ⌥⇧R, ⌥N and ⌃⌥F, the ways to close the graph, that nothing is installed on other machines, how to search, how to review done objectives, the data location under `plugin-data/objectives/`, a screenshot of the graph with the Done group open and a tab node marked "needs you", and after it a screenshot of review mode with Hard, Good and Easy buttons

#### Scenario: Graph screenshot first
- **WHEN** the README is read on GitHub
- **THEN** its first image is `docs/graph.png`, the graph screenshot
