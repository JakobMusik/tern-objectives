## ADDED Requirements

### Requirement: Search
The header SHALL offer a Search button after the scope filter, which opens a one-line field. The left column SHALL then list only the objectives, open and done, whose title, side note or tags contain every word entered, ignoring case. A chip in the button's place SHALL show the text: clicking it SHALL open the field holding the text, and its × SHALL end the search. Entering empty text SHALL end it; dismissing the field SHALL change nothing. The tabs listed SHALL not change.

#### Scenario: A word of the title
- **WHEN** the open objectives are "Fix login bug", "Write slides" and "Login page copy", and the user clicks Search and enters "login"
- **THEN** the left column lists "Fix login bug" and "Login page copy" only, the header shows a chip reading "login" where the Search button was, and the right column lists the same tabs as before

#### Scenario: Every word must match
- **WHEN** "Fix login bug" is tagged "api" and "Login page copy" is tagged "web", and the user searches for "login API"
- **THEN** the left column lists "Fix login bug" only

#### Scenario: Side note
- **WHEN** "Write slides" has the side note "for the Monday demo", and the user searches for "monday"
- **THEN** the left column lists "Write slides" only

#### Scenario: Done objectives
- **WHEN** the done objectives are "Set up CI" and "Restyle the docs site", and the user searches for "docs" and opens the Done group
- **THEN** the group reads "Done (1)" and lists "Restyle the docs site" only

#### Scenario: Nothing matches
- **WHEN** the user searches for "zebra" and no objective holds that word
- **THEN** the left column shows only "No objectives match this filter.", and the chip reads "zebra"

#### Scenario: Lines of hidden objectives
- **WHEN** "Write slides" alone links tab "Docs", and the user searches for "login"
- **THEN** no line ends at the header of "Docs"

#### Scenario: Changing the search
- **WHEN** a search for "login" is on, and the user clicks its chip
- **THEN** the field opens holding "login", and entering "slides" lists "Write slides" only, with the chip reading "slides"

#### Scenario: Ending with ×
- **WHEN** a search for "login" is on, and the user clicks the chip's ×
- **THEN** every objective is listed again, and the header shows the Search button

#### Scenario: Empty text
- **WHEN** a search for "login" is on, and the user clicks its chip, clears the field and presses Enter
- **THEN** every objective is listed again, and the header shows the Search button

#### Scenario: Field dismissed
- **WHEN** a search for "login" is on, and the user clicks its chip and dismisses the field
- **THEN** the graph still lists the same objectives, and the chip still reads "login"

### Requirement: Search and other filters
The search SHALL apply together with the scope and tag filters, and in review mode. Entering a search SHALL clear the selection. While a search is on, the selected objective SHALL stay listed even when it doesn't match, so one created or renamed during the search stays in view until it is no longer selected. The search SHALL end on a fresh open of the graph; showing the graph again after one of its pickers or fields SHALL keep it.

#### Scenario: With the tag filter
- **WHEN** "Fix login bug" is tagged "api", "Login page copy" is tagged "web", the "#web" filter is on, and the user searches for "login"
- **THEN** the left column lists "Login page copy" only

#### Scenario: Selection cleared
- **WHEN** "Write slides" is selected, and the user searches for "login"
- **THEN** no objective is drawn selected, and no action bar shows

#### Scenario: Created during a search
- **WHEN** a search for "login" is on, and the user clicks "＋ New objective" and enters "Write notes"
- **THEN** "Write notes" is listed selected, with "Fix login bug" and "Login page copy", and after a click on empty graph space it is no longer listed

#### Scenario: In review mode
- **WHEN** review mode lists the due done objectives "Set up CI" and "Restyle the docs site", and the user searches for "docs"
- **THEN** review mode lists "Restyle the docs site" only, and the header shows "Review (1)"

#### Scenario: Ended by a fresh open
- **WHEN** a search for "login" is on, and the user presses ⌃⌘O twice
- **THEN** the graph lists every objective, and the header shows the Search button

#### Scenario: Kept after a field
- **WHEN** a search for "login" is on, and the user selects "Fix login bug", clicks Note in its action bar, clicks into the field, types "check the logs" and presses Enter
- **THEN** the graph is shown again with the chip reading "login", the same objectives listed, and "Fix login bug" selected

### Requirement: Search key
"Objectives: Search…", default key ⌃⌥F, SHALL open the search field as the Search button does. With the graph shown over the current tab, it SHALL act there, the settings page switching back to the graph. Anywhere else it SHALL first show the graph over the current tab. Like any plugin key, ⌃⌥F SHALL run in every pane, whichever Control and Option keys are held.

#### Scenario: From a shell
- **WHEN** no graph is shown, focus is in a shell, and the user presses ⌃⌥F and enters "login"
- **THEN** the graph is shown over the current tab, listing the objectives that match "login" with the chip reading "login", and the shell's prompt is unchanged

#### Scenario: In the graph
- **WHEN** the graph is shown with a search for "login", and the user presses ⌃⌥F
- **THEN** the field opens holding "login"

#### Scenario: From the settings page
- **WHEN** the settings page is shown, and the user presses ⌃⌥F and enters "login"
- **THEN** the graph's columns are shown, listing the objectives that match "login"

#### Scenario: Letters still reach the panes
- **WHEN** focus is in a shell prompt and the user types "f" and "F"
- **THEN** the prompt shows "fF", and no field or toast appears

### Requirement: Tab attention marks
A live tab node SHALL show the first mark that applies to the omp chats in its panes, as an objective node does: an amber ring and a "needs you" chip, a green ring and a "replied" chip, or a "working" chip and no ring. The chip SHALL come first on the node's second line, and its tooltip SHALL name the panes. Other agents SHALL NOT mark it. Marks SHALL clear as on objective nodes. Closed and other-window tabs SHALL show none. The origin tab SHALL show its origin ring and its mark together.

#### Scenario: Question waiting
- **WHEN** the omp chat in tab "Server" asks the user a question while the user is in another tab
- **THEN** the "Server" node shows an amber ring and a "needs you" chip before "api · tab 1", whose tooltip names the omp pane's title

#### Scenario: Objective and tab together
- **WHEN** "Fix login bug" links tab "Server", and the omp chat there waits for input
- **THEN** both the "Fix login bug" node and the "Server" node show an amber ring and a "needs you" chip

#### Scenario: Reply unseen
- **WHEN** the omp chat in tab "Release notes" finishes a reply while the user is in another tab
- **THEN** the "Release notes" node shows a green ring and a "replied" chip

#### Scenario: Chat working
- **WHEN** the omp chat in tab "Server" is working on a turn
- **THEN** the "Server" node shows an accent-coloured "working" chip first on its second line, and no ring

#### Scenario: Needs you wins
- **WHEN** tab "Split" holds two omp chats side by side, one waiting for input and the other with a reply the user hasn't seen
- **THEN** the "Split" node shows the amber ring and the "needs you" chip only, and the chip's tooltip names the waiting pane only

#### Scenario: Unlinked tab
- **WHEN** no objective links tab "Server", and the omp chat there waits for input
- **THEN** the "Server" node keeps its grey fill and dashed border, drawn amber, and shows the "needs you" chip

#### Scenario: Focusing the pane clears a reply
- **WHEN** the "Release notes" node shows "replied", and the user focuses the omp pane that replied and opens the graph again
- **THEN** the "Release notes" node has no ring and no chip

#### Scenario: Origin tab marked
- **WHEN** the graph is opened from a shell pane in tab "Server", whose omp chat waits for input
- **THEN** the screenshot shows the "Server" node with the accent origin ring and the amber ring together, and the "needs you" chip

#### Scenario: Closed tab
- **WHEN** a linked tab whose omp chat waited for input is closed
- **THEN** its node under "Closed tabs" shows no ring and no chip

## MODIFIED Requirements

### Requirement: Selection on a fresh open
Each fresh open of the graph SHALL start with no objective selected, whatever was selected when it last closed, and with no search. Review mode, the scope and tag filters, the Done group's fold and open pane rows SHALL stay as they were. Showing the graph again after one of its pickers or fields SHALL keep the selection and the search, and ⌥N SHALL still select the objective it creates.

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
