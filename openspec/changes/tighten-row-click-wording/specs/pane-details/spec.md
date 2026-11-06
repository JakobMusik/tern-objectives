## MODIFIED Requirements

### Requirement: Folded pane rows
Each pane row in a live tab SHALL start folded and SHALL show no arrow. A click anywhere on the row except its jump button SHALL show the row's details under it, and another such click SHALL fold them. That click SHALL NOT jump to the pane. Opened rows SHALL be remembered between opens of the graph.

#### Scenario: Folded by default
- **WHEN** the graph opens on a tab with two panes whose rows were never opened
- **THEN** neither row shows details, and neither shows a ▸ or ▾ arrow

#### Scenario: Expand and collapse
- **WHEN** the user clicks a pane row's name and then clicks it again
- **THEN** the details are there after the first click and gone after the second, focus stays on the graph, and the shown tab is unchanged

#### Scenario: Click beside the name
- **WHEN** the user clicks a folded pane row in the gap just left of its jump button, and then clicks the row's type
- **THEN** the details are there after the first click and gone after the second, and the shown session and tab are unchanged

#### Scenario: Opened rows remembered
- **WHEN** the user opens a row's details, closes the graph and opens it again
- **THEN** that row still shows its details, and the kv dump lists its pane as opened
