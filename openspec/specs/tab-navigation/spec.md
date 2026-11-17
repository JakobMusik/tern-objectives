# tab-navigation Specification

## Purpose
Turns the graph into a switchboard: one click on a tab's "Go to tab" button or on a pane row's jump button takes the user there, in whatever session it lives. Tabs that cannot be reached show no "Go to tab" button, and a click on them selects them instead of failing silently.

## Requirements

### Requirement: Jump to a tab
Clicking a live tab node's "Go to tab" button SHALL:
- switch to that tab's session if it isn't shown;
- show the tab;
- focus the pane that was last focused in it.

The rest of its header, its trash icon, and the header while it asks "Close tab?", SHALL NOT jump.

#### Scenario: Tab in another session
- **WHEN** session "misc" is shown and the user clicks "Go to tab" on tab 2 of session "web"
- **THEN** session "web" is shown, tab 2 is the visible tab, and its last focused pane has focus

#### Scenario: Trash icon doesn't jump
- **WHEN** session "misc" is shown and the user clicks the trash icon on tab 2 of session "web"
- **THEN** session "misc" is still shown, focus is unchanged, and tab 2's header asks "Close tab?"

#### Scenario: Header doesn't jump
- **WHEN** session "misc" is shown and the user clicks the label of tab 2 of session "web"
- **THEN** session "misc" is still shown, focus is unchanged, the graph is still shown, and tab 2 is drawn selected

### Requirement: Jump to a pane
Each pane row in a live tab SHALL end in a jump button, an arrow icon at the row's right end. Clicking it SHALL switch to that pane's session and tab and focus that exact pane. Clicking the rest of the row SHALL NOT jump.

#### Scenario: Second pane of a split
- **WHEN** the user clicks the jump button on the row of the right-hand pane of a split tab in another session
- **THEN** that session and tab are shown, and the right-hand pane has focus

#### Scenario: Row name doesn't jump
- **WHEN** the user clicks a pane row's name in a tab of another session
- **THEN** the shown session, the shown tab and the focus are unchanged

### Requirement: Jumped-to pane is uncovered
After a jump, the target pane SHALL be visible and not covered by the graph.

#### Scenario: Graph out of the way
- **WHEN** the user jumps to a pane from the graph
- **THEN** a screenshot shows the target pane, focused and unobstructed

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

### Requirement: Tab jump button
Each live tab node SHALL end in a row under its pane rows whose left half is a "Go to tab" button: an arrow icon and the words "Go to tab", with the tooltip "Go to this tab", taking clicks over that whole half and at least 22 px of height. The row SHALL show at all times, whatever is selected. Closed and other-window tab nodes SHALL show no such button. Clicking it SHALL NOT select the tab.

#### Scenario: At the foot, on the left
- **WHEN** nothing is selected, a live tab with two panes is shown, and a screenshot's layout data is read
- **THEN** the node ends, below both pane rows, in a row whose left half, within 1 px, is a "Go to tab" button at least 22 px tall, with the tooltip "Go to this tab", and its header shows no arrow

#### Scenario: No button on ghosts
- **WHEN** a closed linked tab and another window's linked tab are shown
- **THEN** neither node shows a "Go to tab" button
