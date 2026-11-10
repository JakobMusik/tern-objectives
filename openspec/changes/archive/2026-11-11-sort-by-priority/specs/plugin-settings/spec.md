## ADDED Requirements

### Requirement: Sort setting
The page SHALL offer "Sort by priority", On or Off, in an "Order" section after "New objectives". It SHALL be On by default, also for objectives stored before this version. The choice SHALL be stored with the objectives in the plugin's `kv.json`, and SHALL hold in every window and after a reload. Turning it off SHALL show the user's own order again, unchanged.

#### Scenario: On by default
- **WHEN** `kv.json` was written by 0.23.0, and the user opens the settings page
- **THEN** the "Order" section shows "Sort by priority" with On selected

#### Scenario: Turned off and saved
- **WHEN** the user picks Off for "Sort by priority"
- **THEN** Off is selected, and the kv dump's settings hold sorting off next to the starting priority and place

#### Scenario: Off survives a reload
- **WHEN** the user picks Off and the plugin is reloaded
- **THEN** the settings page still shows Off selected, and the graph lists the open objectives in the stored order

## MODIFIED Requirements

### Requirement: Settings page
"Objectives: Configure" and a ⚙ button in the graph's header SHALL show a settings page in the graph, over the current tab, in place of the columns. It SHALL list the shortcuts, the new-objective defaults and the order setting, and offer "Back to graph", which shows the graph again. ⌃⌘O SHALL close it like the graph, and the next open SHALL show the graph. Fields opened from the page SHALL bring the page back when they close.

#### Scenario: From the header
- **WHEN** the graph is shown and the user clicks ⚙
- **THEN** the graph shows the settings page with a "Shortcuts" section, a "New objectives" section and an "Order" section, and no objective or tab nodes

#### Scenario: From the palette
- **WHEN** no graph is shown and the user runs "Objectives: Configure"
- **THEN** the settings page is shown over the current tab

#### Scenario: Back to graph
- **WHEN** the settings page is shown and the user clicks "Back to graph"
- **THEN** the graph's columns are shown again with the same selection as before

#### Scenario: Next open shows the graph
- **WHEN** the settings page is shown and the user presses ⌃⌘O twice
- **THEN** the first press closes it, and the second shows the graph's columns

### Requirement: New objective defaults
The page SHALL let the user choose the priority new objectives start at, P0 to P3, P3 by default, and where they go in the custom order, top or bottom, top by default. With "Sort by priority" on, that is the top or bottom of their priority. Both SHALL apply to "＋ New objective", "Objectives: New objective" and "Objectives: New objective for this tab…", SHALL be stored with the objectives in the plugin's `kv.json`, and SHALL hold in every window and after a reload.

#### Scenario: Start at P1, at the bottom
- **WHEN** "Sort by priority" is off, and the user picks P1 and Bottom on the settings page, goes back to the graph and creates "Write slides" with "＋ New objective"
- **THEN** "Write slides" has a P1 badge and is the last open objective, and the kv dump holds priority 1 for it and the two settings

#### Scenario: Bottom of its priority
- **WHEN** "Sort by priority" is on, the list reads "Release" (P1) and "Fix login bug" (P3), and the user picks P1 and Bottom and creates "Write slides" with "＋ New objective"
- **THEN** the list reads "Release", "Write slides", "Fix login bug"

#### Scenario: Defaults survive a reload
- **WHEN** the user picks P1 and Bottom and the plugin is reloaded
- **THEN** the settings page still shows P1 and Bottom selected
