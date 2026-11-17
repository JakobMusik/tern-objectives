## ADDED Requirements

### Requirement: Selecting a tab
Clicking a tab node's header, anywhere but its trash icon, Resume button and jump arrow, or a closed or other-window tab's pane row, SHALL select the tab, drawn with the accent border and ring of a selected objective. Selecting a tab SHALL clear a selected objective, and selecting an objective SHALL clear a selected tab. Clicking the selected tab's header again, or empty graph space, SHALL clear it. A tab the right column stops showing SHALL be deselected.

#### Scenario: Select and clear
- **WHEN** nothing is selected, and the user clicks the label of tab "Benchmarks" and then clicks empty graph space
- **THEN** after the first click the graph is still shown, focus is unchanged, a screenshot shows "Benchmarks" with the accent border and ring, and no tab node shows a link bar; after the second, "Benchmarks" is drawn as before

#### Scenario: Clicking it again
- **WHEN** "Benchmarks" is selected and the user clicks its header's dimmed second line
- **THEN** no tab node is drawn selected

#### Scenario: Replaces a selected objective
- **WHEN** "Fix login bug" is selected and the user clicks the label of tab "Server"
- **THEN** "Server" is drawn selected, "Fix login bug" shows no ring and no action bar, no tab node shows a link bar, and the right column shows no `Linked to` heading

#### Scenario: Replaced by an objective
- **WHEN** "Server" is selected and the user clicks "Write slides" beside its title
- **THEN** "Write slides" is selected with its action bar, and "Server" is not drawn selected

#### Scenario: Live pane row doesn't select
- **WHEN** nothing is selected and the user clicks the name of a pane row in "Server"
- **THEN** the row's details open, and no tab node is drawn selected

#### Scenario: Trash icon doesn't select
- **WHEN** nothing is selected and the user clicks the trash icon on "Server"
- **THEN** its header asks "Close tab?", and no tab node is drawn selected

#### Scenario: Hidden by the scope
- **WHEN** tab "App build" of session "web" is selected, the current session is "api", and the user clicks "This session" and then "All"
- **THEN** after the first click no node for "App build" shows; after the second, "App build" is listed and not drawn selected

### Requirement: Selected tab's links
While a tab is selected, the lines joining it to listed objectives SHALL be drawn as a selected objective's lines are, over the others, and every other line SHALL fade. This SHALL cover open objectives, done ones in the open Done group and those review mode lists, the done ones with a green line; their other links SHALL get no line. Those objectives SHALL show the accent border on the accent tint, with no ring and no action bar. No node SHALL move. With no such line, no line SHALL fade.

#### Scenario: Open objectives
- **WHEN** open objectives "Fix login bug" and "Speed up search" link tab "Server", "Fix login bug" also links "Benchmarks", "Write slides" links only "Guides", the graph was opened from "Guides", and the user selects "Server"
- **THEN** a screenshot shows thick lines from "Fix login bug" and "Speed up search" to "Server", drawn over the faded lines they cross, every other line faded, those two nodes with an accent border on a tint and no action bar, "Write slides" not tinted, and every objective node where it was before the click

#### Scenario: Done objective in the open Done group
- **WHEN** done objective "Set up CI" links "Server" and "Benchmarks", the Done group is open, and the user selects "Server"
- **THEN** a thick green line joins "Set up CI" to "Server", ending within 2 pixels of both vertical centres, "Set up CI" is tinted, and no line joins it to "Benchmarks"

#### Scenario: Done group folded
- **WHEN** the Done group is folded and the user selects "Server"
- **THEN** no green line shows

#### Scenario: Review mode
- **WHEN** review mode lists done objectives "Set up CI" and "Restyle the docs site", only "Set up CI" links "Server", and the user selects "Server"
- **THEN** a thick green line joins "Set up CI" to "Server", ending within 2 pixels of both vertical centres, "Set up CI" is tinted, and no line joins "Restyle the docs site"

#### Scenario: Tab no objective links
- **WHEN** the user selects a tab no listed objective links
- **THEN** every line is drawn at full strength and normal width, and no node is tinted

#### Scenario: Line ends at two widths
- **WHEN** "Server" is selected and the graph is captured at 1400 and 460 pixels wide
- **THEN** in both captures, each line's ends sit within 2 pixels of the vertical centres of its objective node and tab header

## MODIFIED Requirements

### Requirement: Done objectives' closed tabs
A closed tab that only done objectives link SHALL NOT show in the right column, except while one of those objectives is selected or is listed in review mode, or while the tab itself is selected.

#### Scenario: Out of the way
- **WHEN** done objective X's tab A is closed, no other objective links A, and nothing is selected
- **THEN** the right column has no node for A

#### Scenario: Shown with its objective
- **WHEN** the user selects X
- **THEN** A shows under "Closed tabs" in the `Linked to “X”` section

#### Scenario: Also linked to an open objective
- **WHEN** a closed tab is linked to done objective X and to open objective Y, and nothing is selected
- **THEN** it shows under "Closed tabs"

#### Scenario: Kept while selected
- **WHEN** X is selected, and the user clicks A's label and then clicks empty graph space
- **THEN** after the first click A still shows under "Closed tabs", drawn selected, and X is not selected; after the second, the right column has no node for A

### Requirement: Selection on a fresh open
Each fresh open of the graph SHALL start with no objective or tab selected, whatever was selected when it last closed, and with no search. Review mode, the scope and tag filters, the Done group's fold and open pane rows SHALL stay as they were. Showing the graph again after one of its pickers or fields SHALL keep the selection and the search, and ⌥N SHALL still select the objective it creates.

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

#### Scenario: Filters kept, search ended
- **WHEN** the "#api" filter and a search for "login" are on, and the user closes the graph with ⌃⌘O and opens it again
- **THEN** the "#api" chip is drawn active, every objective tagged "api" is listed, and the header shows the Search button

#### Scenario: Selected tab cleared
- **WHEN** tab "Server" is selected, and the user closes the graph with ⌃⌘O and opens it again with ⌃⌘O
- **THEN** no tab node is drawn selected

#### Scenario: Selected tab kept after a field
- **WHEN** tab "Server" is selected, and the user clicks Search, clicks into the field, types "login" and presses Enter
- **THEN** the graph shown again lists the matching objectives, and "Server" is drawn selected

### Requirement: Origin tab's links
While no objective is selected, outside review mode, the lines joining the origin pane's tab to shown open objectives SHALL be drawn as a selected objective's lines are, over the others, and every other line SHALL fade as for a selection. Those objectives SHALL show an accent border on an accent tint, with no selection ring and no action bar, and no tab node SHALL show a link bar. Selecting an objective or a tab SHALL replace this until it clears. With no such line, no line SHALL fade.

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

#### Scenario: Selecting a tab takes over
- **WHEN** the graph was opened from "Server" and the user selects tab "Guides"
- **THEN** only the line from "Write slides" to "Guides" is thick, "Write slides" is tinted, and neither "Fix login bug" nor "Speed up search" is tinted
