# Spec Delta

## MODIFIED Requirements

### Requirement: Expandable pane rows
Each pane row in a live tab SHALL show its details area under the row by default, with a ▾ toggle. Clicking ▾ SHALL fold the details away and turn the toggle into ▸; clicking ▸ SHALL open them again. Clicking the toggle SHALL NOT jump to the pane. Folded rows SHALL be remembered between opens of the graph.

#### Scenario: Open by default
- **WHEN** the graph opens on a tab with two panes whose rows were never folded
- **THEN** both rows show their details under them, each with a ▾ toggle

#### Scenario: Expand and collapse
- **WHEN** the user clicks ▾ on a pane row and then clicks ▸
- **THEN** the details are gone after the first click and back after the second, and focus stays on the graph
