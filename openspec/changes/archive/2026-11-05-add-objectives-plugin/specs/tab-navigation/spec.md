# Spec Delta

## Purpose

Turns the graph into a switchboard: one click on a tab or pane node takes the user there, in whatever session it lives. Tabs that cannot be reached say why instead of failing silently.

## ADDED Requirements

### Requirement: Jump to a tab
Clicking a live tab node's header SHALL:
- switch to that tab's session if it isn't shown;
- show the tab;
- focus the pane that was last focused in it.

#### Scenario: Tab in another session
- **WHEN** session "misc" is shown and the user clicks the header of tab 2 of session "web"
- **THEN** session "web" is shown, tab 2 is the visible tab, and its last focused pane has focus

### Requirement: Jump to a pane
Clicking a pane row's label in a live tab SHALL switch to that pane's session and tab and focus that exact pane.

#### Scenario: Second pane of a split
- **WHEN** the user clicks the row of the right-hand pane of a split tab in another session
- **THEN** that session and tab are shown, and the right-hand pane has focus

### Requirement: Jumped-to pane is uncovered
After a jump, the target pane SHALL be visible and not covered by the graph.

#### Scenario: Graph out of the way
- **WHEN** the user jumps to a pane from the graph
- **THEN** a screenshot shows the target pane, focused and unobstructed

### Requirement: Closed tabs don't jump
Clicking a closed tab's header or one of its pane rows SHALL NOT change focus. It SHALL show an info toast that the tab is closed.

#### Scenario: Click a ghost
- **WHEN** the user clicks the header of a closed linked tab
- **THEN** focus is unchanged and a toast says the tab is closed

### Requirement: Other-window tabs don't jump
Clicking an elsewhere tab's header or one of its pane rows SHALL NOT change focus. It SHALL show an info toast that the tab is in another Tern window.

#### Scenario: Click an elsewhere tab
- **WHEN** the user clicks the header of a tab held by another window
- **THEN** focus is unchanged and a toast says the tab is in another window
