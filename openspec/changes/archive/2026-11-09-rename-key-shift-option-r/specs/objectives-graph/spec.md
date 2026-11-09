## MODIFIED Requirements

### Requirement: Rename key
"Objectives: Rename selected objective", default key ⌥⇧R, SHALL open the one-line Rename field for the selected objective, filled with its title, while the graph is shown over the current tab. The field SHALL behave as from a click on the title, and the selection SHALL stay. With no objective selected, or no graph shown over the tab, it SHALL show an info toast saying to select an objective in the graph, and change nothing.

#### Scenario: Rename by key
- **WHEN** the user selects "Fix login bug" in the graph, presses ⌥⇧R and enters "Fix login timeout"
- **THEN** the node shows "Fix login timeout", the kv dump holds that title, and the objective is still selected

#### Scenario: Nothing selected
- **WHEN** no objective is selected and the user presses ⌥⇧R in the graph
- **THEN** an info toast says to select an objective, and no field opens

#### Scenario: Option+R left to the pane
- **WHEN** no shortcut was changed, an objective is selected in the graph, and the user presses ⌥R
- **THEN** no Rename field opens and no toast appears, and Tern's keymap runs nothing of the plugin's on ⌥R

#### Scenario: Letters still reach the panes
- **WHEN** focus is in a shell prompt and the user types "r" and "R"
- **THEN** the prompt shows "rR", and no field or toast appears

### Requirement: Rename by clicking the title
A click on an objective's title SHALL open the one-line Rename field, filled with the title, as ⌥⇧R does, on open, done and review nodes. Only the title's own text SHALL take this click; the rest of the node SHALL select as before. The click SHALL NOT change the selection.

#### Scenario: Rename by click
- **WHEN** the user clicks the title "Fix login bug" and enters "Fix login timeout"
- **THEN** the field opened holding "Fix login bug", and the node and the kv dump then hold "Fix login timeout"

#### Scenario: Selection unchanged
- **WHEN** "Write slides" is selected and the user clicks the title of "Fix login bug", then dismisses the field
- **THEN** "Write slides" is still selected and "Fix login bug" is not

#### Scenario: Beside a short title
- **WHEN** the user clicks an objective node to the right of its one-line title
- **THEN** the objective is selected and no field opens

#### Scenario: Second line of a title
- **WHEN** the user clicks the second line of a two-line title
- **THEN** the Rename field opens holding the whole title
