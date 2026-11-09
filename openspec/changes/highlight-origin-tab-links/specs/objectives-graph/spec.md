# Spec Delta

## ADDED Requirements

### Requirement: Selection on a fresh open
Each fresh open of the graph SHALL start with no objective selected, whatever was selected when it last closed. Review mode, the filters, the Done group's fold and open pane rows SHALL stay as they were. Showing the graph again after one of its pickers or fields SHALL keep the selection, and ⌥N SHALL still select the objective it creates.

#### Scenario: Closed and opened again
- **WHEN** the user selects "Fix login bug", closes the graph with ⌃⌘O and opens it again with ⌃⌘O
- **THEN** no objective is drawn selected, no action bar shows, and ⌥⇧R shows the toast "Select an objective in the graph to rename it"

#### Scenario: Kept after a picker
- **WHEN** "Fix login bug" is selected and the user clicks Note in its action bar, clicks into the field, types "check the logs" and presses Enter
- **THEN** the graph shown again has "Fix login bug" selected with its action bar

#### Scenario: Review mode kept
- **WHEN** review mode lists two objectives, the user selects one, closes the graph and opens it again
- **THEN** review mode still lists both, and neither is selected

#### Scenario: New objective by key
- **WHEN** "Fix login bug" was selected when the graph closed, focus is in a shell, and the user presses ⌥N and enters "Write slides"
- **THEN** the graph is shown with "Write slides" selected and "Fix login bug" not selected

### Requirement: Origin tab's links
While no objective is selected, outside review mode, the lines joining the origin pane's tab to shown open objectives SHALL be drawn as a selected objective's lines are, over the others, and every other line SHALL fade as for a selection. Those objectives SHALL show an accent border on an accent tint, with no selection ring and no action bar, and no tab node SHALL show a link bar. Selecting an objective SHALL replace this until the selection clears. With no such line, no line SHALL fade.

#### Scenario: Opened from a linked tab
- **WHEN** open objectives "Fix login bug" and "Speed up search" link tab "Server", "Fix login bug" also links "Benchmarks", "Write slides" links only "Guides", and the user opens the graph from a pane in "Server"
- **THEN** a screenshot shows thick lines from "Fix login bug" and "Speed up search" to "Server", drawn over the faded lines they cross, every other line faded, those two nodes with an accent border on a tint and no action bar, and no link bar on any tab node

#### Scenario: Selecting takes over
- **WHEN** the user then selects "Write slides"
- **THEN** only its line is thick, every other line is faded, and neither "Fix login bug" nor "Speed up search" is tinted

#### Scenario: Clearing brings it back
- **WHEN** the user then clicks empty graph space
- **THEN** the lines to "Server" are thick again, the other lines faded, and "Fix login bug" and "Speed up search" tinted

#### Scenario: Origin tab unlinked
- **WHEN** the user opens the graph from a pane in a tab no shown open objective links
- **THEN** every line is drawn at full strength and normal width, and no node is tinted

#### Scenario: Origin pane moves
- **WHEN** the origin pane is moved from "Server" into "Guides" while the graph is shown
- **THEN** the line from "Write slides" to "Guides" is thick and its node tinted, and the lines to "Server" are faded

#### Scenario: Done objectives
- **WHEN** done objective "Set up CI" also links "Server", the Done group is open, and the user opens the graph from "Server"
- **THEN** "Set up CI" is not tinted and no line joins it to "Server"

#### Scenario: Review mode
- **WHEN** the graph is opened from "Server" in review mode
- **THEN** no node is tinted and no line shows until the user selects a listed objective

#### Scenario: Highlighted and marked
- **WHEN** the omp chat in "Server" waits for input and the user opens the graph from "Server"
- **THEN** a screenshot shows "Fix login bug" with the amber ring and the "needs you" chip on the accent tint

#### Scenario: Node size unchanged
- **WHEN** the graph is opened from "Server" and a screenshot's layout data is read
- **THEN** the tinted nodes with one-line titles are 48 px tall, as the others

## MODIFIED Requirements

### Requirement: Selection
Clicking an objective node anywhere but its title, grip, done box, badge, trash icon or action bar SHALL select it:
- its action bar shows under it;
- its lines are drawn thicker;
- all other lines fade to about a quarter of their strength;
- a link bar appears on every tab node, for an open or a done objective.

Clicking the selected objective there again, or empty graph space, SHALL clear the selection.

#### Scenario: Select and clear
- **WHEN** the graph was opened from a tab no objective links, and the user clicks an objective node beside its title and then clicks empty graph space
- **THEN** the first screenshot shows its action bar, its lines emphasised and a link bar on every tab node, and the second shows none of them

#### Scenario: Selecting a done objective
- **WHEN** the user opens the Done group and clicks a done objective's node on its second line
- **THEN** it is drawn selected, its lines show, and every tab node has a link bar
