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

#### Scenario: Rename hidden without the graph
- **WHEN** no graph is shown over the current tab, and the palette is opened with the query "objectives"
- **THEN** "Open graph", "Link this tab…" and "New objective for this tab…" appear, and "Rename selected objective" doesn't

#### Scenario: Rename hidden without a selection
- **WHEN** the graph is shown over the current tab with nothing selected, and the palette is opened with the query "objectives"
- **THEN** "Rename selected objective" doesn't appear, and the other three commands do
