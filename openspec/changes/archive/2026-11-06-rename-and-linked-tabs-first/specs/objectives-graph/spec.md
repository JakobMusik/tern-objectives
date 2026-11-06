## ADDED Requirements

### Requirement: Rename key
"Objectives: Rename selected objective", default key ⌥R, SHALL open the one-line Rename field for the selected objective, filled with its title, while the graph is shown over the current tab. The field SHALL behave as from ⋯ › Rename, and the selection SHALL stay. With no objective selected, or no graph shown over the tab, it SHALL show an info toast saying to select an objective in the graph, and change nothing.

#### Scenario: Rename by key
- **WHEN** the user selects "Fix login bug" in the graph, presses ⌥R and enters "Fix login timeout"
- **THEN** the node shows "Fix login timeout", the kv dump holds that title, and the objective is still selected

#### Scenario: Nothing selected
- **WHEN** no objective is selected and the user presses ⌥R in the graph
- **THEN** an info toast says to select an objective, and no field opens

#### Scenario: Letters still reach the panes
- **WHEN** focus is in a shell prompt and the user types "r" and "R"
- **THEN** the prompt shows "rR", and no field or toast appears

### Requirement: Linked tabs first
While an objective is selected, the right column SHALL start with a section headed `Linked to “<title>”`: the shown tabs that were linked to it when it was selected. A divider "Other tabs" and every other shown tab SHALL follow, each part ordered as "Tab column" says. Linking or unlinking while it stays selected SHALL NOT move a tab. Deselecting SHALL restore the normal order. With no such tab, neither heading nor divider SHALL show.

#### Scenario: Linked tabs on top
- **WHEN** the window holds sessions "web" (tabs "App build" and "Components") and "api" (tabs "Server" and "Benchmarks"), objective X is linked to "Components" and "Benchmarks", the graph was opened from "Server", and the user selects X
- **THEN** the column reads: `Linked to “X”`, "api" with "Benchmarks", "web" with "Components", the "Other tabs" divider, "api" with "Server", then "web" with "App build"

#### Scenario: Linked closed tab
- **WHEN** X is also linked to a closed tab and the user selects X
- **THEN** that tab shows under a "Closed tabs" heading inside the top section, after the live tabs, and not again below the divider

#### Scenario: Order kept while linking
- **WHEN** X is selected and the user clicks "＋ Link" on a tab below the divider, then "× Unlink" on a tab in the top section
- **THEN** both tabs stay where they were, their bars now read "× Unlink" and "＋ Link", and the kv dump holds both changes

#### Scenario: Deselect and select again
- **WHEN** the user then clicks X to deselect it, and clicks it again
- **THEN** after the first click there is no heading or divider and the column is in its normal order; after the second, the newly linked tab is in the top section and the unlinked one below the divider

#### Scenario: Nothing linked
- **WHEN** the user creates "Write slides" with "＋ New objective", which selects it
- **THEN** the column shows no `Linked to` heading and no divider

#### Scenario: This session
- **WHEN** the scope is "This session", X is linked to tabs in the current session and in another, and the user selects X
- **THEN** the top section holds only the current session's linked tabs
