## MODIFIED Requirements

### Requirement: Palette commands
The plugin SHALL register four palette commands under the group "Objectives":
- "Objectives: Open graph", default key ⌃⌘O;
- "Objectives: Rename selected objective", default key ⌥R;
- "Objectives: Link this tab…";
- "Objectives: New objective for this tab…".

The palette SHALL list the rename command only while an objective is selected in a graph shown over the current tab. Its key works either way.

#### Scenario: Commands listed
- **WHEN** an objective is selected in the graph shown over the current tab, and the palette is opened with the query "objectives"
- **THEN** the four commands appear, "Open graph" with ⌃⌘O and "Rename selected objective" with ⌥R

#### Scenario: Rename hidden without a selection
- **WHEN** no graph is shown over the current tab, and the palette is opened with the query "objectives"
- **THEN** "Open graph", "Link this tab…" and "New objective for this tab…" appear, and "Rename selected objective" doesn't

### Requirement: README
The README SHALL give:
- the exact install command;
- that it needs nothing on `PATH` but `git`, and nothing on the machines sessions run on;
- the four commands with the ⌃⌘O and ⌥R keys;
- how to close the graph: ⌃⌘O, a click outside, its ×, or Esc after a click on its title bar;
- where its data lives and how to remove it;
- one screenshot of the graph.

#### Scenario: README contents
- **WHEN** a reader opens the README
- **THEN** it contains the install command, the commands with ⌃⌘O and ⌥R, the ways to close the graph, that nothing is installed on other machines, the data location under `plugin-data/objectives/`, and a screenshot of the graph
