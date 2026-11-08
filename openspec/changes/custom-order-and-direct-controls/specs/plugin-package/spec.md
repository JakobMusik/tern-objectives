# Spec Delta

## MODIFIED Requirements

### Requirement: Palette commands
The plugin SHALL register six palette commands under the group "Objectives":
- "Objectives: Open graph", default key ⌃⌘O;
- "Objectives: Rename selected objective", default key ⌥R;
- "Objectives: New objective", default key ⌥N;
- "Objectives: Link this tab…";
- "Objectives: New objective for this tab…";
- "Objectives: Configure".

The palette SHALL list the rename command only while an objective is selected in a graph shown over the current tab. Its key works either way.

#### Scenario: Commands listed
- **WHEN** an objective is selected in the graph shown over the current tab, and the palette is opened with the query "objectives"
- **THEN** the six commands appear, "Open graph" with ⌃⌘O, "Rename selected objective" with ⌥R and "New objective" with ⌥N

#### Scenario: Rename hidden without the graph
- **WHEN** no graph is shown over the current tab, and the palette is opened with the query "objectives"
- **THEN** "Open graph", "New objective", "Link this tab…", "New objective for this tab…" and "Configure" appear, and "Rename selected objective" doesn't

#### Scenario: Rename hidden without a selection
- **WHEN** the graph is shown over the current tab with nothing selected, and the palette is opened with the query "objectives"
- **THEN** "Rename selected objective" doesn't appear, and the other five commands do

### Requirement: README
The README SHALL give:
- the exact install command;
- that it needs nothing on `PATH` but `git`, and nothing on the machines sessions run on;
- the six commands with the ⌃⌘O, ⌥R and ⌥N keys;
- how to close the graph: ⌃⌘O, a click outside, its ×, or Esc after a click on its title bar;
- how reviewing done objectives works;
- where its data lives and how to remove it;
- two screenshots: first the graph with the Done group open, then review mode with its rating buttons.

#### Scenario: README contents
- **WHEN** a reader opens the README
- **THEN** it contains the install command, the commands with ⌃⌘O, ⌥R and ⌥N, the ways to close the graph, that nothing is installed on other machines, how to review done objectives, the data location under `plugin-data/objectives/`, a screenshot of the graph with the Done group open, and after it a screenshot of review mode with Hard, Good and Easy buttons

#### Scenario: Graph screenshot first
- **WHEN** the README is read on GitHub
- **THEN** its first image is `docs/graph.png`, the graph screenshot

## ADDED Requirements

### Requirement: README on the direct controls
The README SHALL explain how to move objectives with the grip, what the action bar offers, and how Configure changes shortcuts and the new-objective defaults. It SHALL say that changed shortcuts are saved in Tern's keybinds, not in the plugin's data folder. Its screenshots SHALL show this version's nodes.

#### Scenario: Direct controls explained
- **WHEN** a reader opens the README
- **THEN** it explains moving with the grip, the action bar's buttons, Configure, and that changed shortcuts live in Tern's keybinds

#### Scenario: Screenshots match this version
- **WHEN** a reader looks at both screenshots
- **THEN** the graph's open objectives show grips, and no node in either shows a ⋯ button
