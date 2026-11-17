## ADDED Requirements

### Requirement: Tab jump arrow
Each live tab node's header SHALL end its second line in a jump button: an arrow icon with the tooltip "Go to this tab", taking clicks over at least 28 × 18 px, its right edge within 1 px of the right edges of the tab's pane rows' jump buttons. Closed and other-window tab nodes SHALL show none. Clicking it SHALL NOT select the tab.

#### Scenario: Lined up with the rows
- **WHEN** a live tab with two panes is shown and a screenshot's layout data is read
- **THEN** its header's second line ends in an arrow at least 28 × 18 px, with the tooltip "Go to this tab", whose right edge is within 1 px of both pane rows' jump buttons' right edges

#### Scenario: No arrow on ghosts
- **WHEN** a closed linked tab and another window's linked tab are shown
- **THEN** neither node's header shows an arrow

## MODIFIED Requirements

### Requirement: Jump to a tab
Clicking a live tab node's jump arrow SHALL:
- switch to that tab's session if it isn't shown;
- show the tab;
- focus the pane that was last focused in it.

The rest of its header, its trash icon, and the header while it asks "Close tab?", SHALL NOT jump.

#### Scenario: Tab in another session
- **WHEN** session "misc" is shown and the user clicks the jump arrow on tab 2 of session "web"
- **THEN** session "web" is shown, tab 2 is the visible tab, and its last focused pane has focus

#### Scenario: Trash icon doesn't jump
- **WHEN** session "misc" is shown and the user clicks the trash icon on tab 2 of session "web"
- **THEN** session "misc" is still shown, focus is unchanged, and tab 2's header asks "Close tab?"

#### Scenario: Header doesn't jump
- **WHEN** session "misc" is shown and the user clicks the label of tab 2 of session "web"
- **THEN** session "misc" is still shown, focus is unchanged, the graph is still shown, and tab 2 is drawn selected

### Requirement: Closed tabs don't jump
Clicking a closed tab's header or one of its pane rows SHALL NOT change focus and SHALL show no toast. It SHALL select the tab.

#### Scenario: Click a ghost
- **WHEN** the user clicks the header of a closed linked tab
- **THEN** focus is unchanged, no toast shows, and the tab is drawn selected

#### Scenario: Click a ghost's row
- **WHEN** nothing is selected and the user clicks a pane row of a closed linked tab
- **THEN** focus is unchanged, no toast shows, and the tab is drawn selected

### Requirement: Other-window tabs don't jump
Clicking an elsewhere tab's header or one of its pane rows SHALL NOT change focus and SHALL show no toast. It SHALL select the tab.

#### Scenario: Click an elsewhere tab
- **WHEN** the user clicks the header of a tab held by another window
- **THEN** focus is unchanged, no toast shows, and the tab is drawn selected
