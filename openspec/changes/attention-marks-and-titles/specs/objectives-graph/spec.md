## MODIFIED Requirements

### Requirement: Objective node content
Each objective node SHALL show:
- a done box, a priority badge, the title and a ⋯ button, with a trash icon before the ⋯ on done objectives;
- below them, the side note (dimmed), a due chip on open objectives or a review chip on done ones, and tag chips.

Text other than the title that doesn't fit SHALL end in "…". Hovering the node SHALL show the full title, the full note and the created and done times, and for a done objective its review count and next review date.

#### Scenario: Long note
- **WHEN** an objective with a one-line title has a 200-character side note
- **THEN** its node stays 48 px tall, the note is cut with "…", and the node's tooltip holds the whole note

#### Scenario: Done node
- **WHEN** the user marks an objective with a due date done and opens the Done group
- **THEN** its node shows a trash icon, a "review in 1d" chip and no due chip, and its tooltip gives 0 reviews and tomorrow's date as the next review

### Requirement: Selection
Clicking an objective node anywhere but its title, done box, badge, trash icon or ⋯ SHALL select it:
- its lines are drawn thicker;
- all other lines fade to about a quarter of their strength;
- when it is open, a link bar appears on every tab node.

Clicking the selected objective there again, or empty graph space, SHALL clear the selection.

#### Scenario: Select and clear
- **WHEN** the user clicks an objective node beside its title and then clicks empty graph space
- **THEN** the first screenshot shows its lines emphasised and a link bar on every tab node, and the second shows neither

#### Scenario: Selecting a done objective
- **WHEN** the user opens the Done group and clicks a done objective's node on its second line
- **THEN** it is drawn selected, its lines show, and no tab node has a link bar

### Requirement: Live refresh
While the graph is shown, it SHALL redraw by itself within one second of any of these:
- a tab or pane opening, closing or moving;
- a title change;
- the current session changing;
- an agent's state changing;
- a pane's unseen alert appearing or clearing;
- a command finishing.

#### Scenario: New tab appears
- **WHEN** a new tab is opened while the graph is shown
- **THEN** the tab appears in the right column without the graph being reopened

### Requirement: Light and dark themes
Lines, badges, chips, the unlinked-tab fill and the two attention rings SHALL stay distinguishable in both Tern's light and dark appearances.

#### Scenario: Both appearances
- **WHEN** the graph is captured in the light appearance and in the dark appearance
- **THEN** both captures show every line, every badge colour, unlinked tabs filled differently from linked ones, and a "needs you" ring in a different colour from a "replied" ring

### Requirement: Larger hit areas
The done box, the ⋯ button and the trash icon SHALL each take clicks over at least 22 px of width and the full 18 px height of their line in objective nodes. A pane row's jump button SHALL take clicks over at least 28 px of width and the row's full 22 px height. The Hard, Good and Easy buttons SHALL each be at least 22 px tall. Objective nodes with a one-line title SHALL stay 48 px tall outside review mode, and pane rows 22 px.

#### Scenario: Measured hit areas
- **WHEN** a screenshot's layout data is read outside review mode
- **THEN** every done box, trash icon and ⋯ button is at least 22 × 18 px, every jump button at least 28 × 22 px, objective nodes with one-line titles are 48 px tall, and pane rows are 22 px tall

#### Scenario: Review nodes
- **WHEN** a screenshot's layout data is read in review mode
- **THEN** every Hard, Good and Easy button is at least 22 px tall, and every listed node with a one-line title has the same height

### Requirement: Creation time after the title
Each objective node SHALL show its creation time after the title's last line, dimmed, as `MM-DD HH:MM` in local time, so objectives with the same title can be told apart. A line too long for the graph's width SHALL be cut with "…" before the time is. The time SHALL come from when the objective was created and SHALL NOT be part of its title: renaming SHALL NOT change it, and objectives created before this version SHALL show it too.

#### Scenario: Two with one title
- **WHEN** the user creates "Write slides" with "＋ New objective", and again a minute or more later
- **THEN** both nodes read "Write slides", each followed by its own creation time from the kv dump's `created`, as `MM-DD HH:MM`, and both kv titles are exactly "Write slides"

#### Scenario: Long title
- **WHEN** an objective's title is 120 characters long and the graph is 1400 pixels wide
- **THEN** its title takes three lines, the third ends in "…", and the creation time after it is shown whole

#### Scenario: Rename keeps the time
- **WHEN** the user renames "Write slides" to "Write talk slides"
- **THEN** the rename field held "Write slides" without the time, and the node reads "Write talk slides" followed by the same creation time as before

#### Scenario: Done and review nodes
- **WHEN** the user opens the Done group, and later lists a due objective in review mode
- **THEN** each done node and each review node shows its creation time after the title

## ADDED Requirements

### Requirement: Controls and titles don't select text
Dragging across an objective's title, a tag chip, a due chip, a P0–P3 badge, the header's "All" and "This session" buttons, "Prune closed tabs", "＋ New objective", or a pane row's type, name or jump button SHALL NOT select its text. Neither dragging across nor double-clicking a group or session heading SHALL select its text: "Done (n)", "Closed tabs", "Other windows", a session heading, the `Linked to` heading or the `Other tabs` divider.

#### Scenario: Drag across the header
- **WHEN** the user presses in the header's empty space, drags across "＋ New objective", the tag filter chips and "All" / "This session", and releases in empty space
- **THEN** the screenshot shows no text highlight on any of them

#### Scenario: Drag across a node's badge and chips
- **WHEN** the user drags from an objective's side note across its due chip and tag chip, and from its title across its P0–P3 badge
- **THEN** the screenshot shows no text highlight on the badge or the chips, and the objective's priority is unchanged

#### Scenario: Drag along a pane row
- **WHEN** the user drags from a tab's header across a pane row's type and name
- **THEN** the screenshot shows no text highlight on the row

#### Scenario: Double-click on the Done header
- **WHEN** the left column holds done objectives, and the user double-clicks the word "Done" in the "Done (n)" header
- **THEN** the screenshot shows no text highlight on the header

#### Scenario: Double-click on a session heading
- **WHEN** the user double-clicks a session's name in the right column
- **THEN** the screenshot shows no text highlight on the heading

#### Scenario: Drag across a title
- **WHEN** the user presses on an objective's side note, drags up across its title and releases beside the title
- **THEN** the screenshot shows no text highlight on the title, and no Rename field is open

### Requirement: Title lines
An objective's title SHALL break at spaces into lines of at most 36 characters, onto at most three lines; only a word longer than a line SHALL be split. A title that needs more SHALL end its third line in "…". The breaks SHALL be the same at every graph width. Each line past the first SHALL make the node 18 px taller, and its link lines SHALL still meet it at its vertical centre.

#### Scenario: Short title
- **WHEN** an objective is titled "Fix login bug"
- **THEN** its title takes one line and its node is 48 px tall

#### Scenario: Two lines
- **WHEN** an open objective linked to a tab is titled "Write the onboarding guide for new contributors to the API"
- **THEN** its title reads "Write the onboarding guide for new" over "contributors to the API", its node is 66 px tall, and its link line meets the node's vertical centre

#### Scenario: More than three lines
- **WHEN** an objective's title is 120 characters long
- **THEN** its title takes three lines, the third ends in "…", its node is 84 px tall, and the node's tooltip holds the whole title

#### Scenario: Same breaks at any width
- **WHEN** the graph shows the two-line title of "Two lines" at 1400 and at 900 pixels wide
- **THEN** both shots break it after "new"

### Requirement: Rename by clicking the title
A click on an objective's title SHALL open the one-line Rename field, filled with the title, as ⋯ › Rename does, on open, done and review nodes. Only the title's own text SHALL take this click; the rest of the node SHALL select as before. The click SHALL NOT change the selection.

#### Scenario: Rename by click
- **WHEN** the user clicks the title "Fix login bug" and enters "Fix login timeout"
- **THEN** the field opened holding "Fix login bug", and the node and the kv dump then hold "Fix login timeout"

#### Scenario: Selection unchanged
- **WHEN** "Write slides" is selected and the user clicks the title of "Fix login bug", then dismisses the field
- **THEN** "Write slides" is still selected and "Fix login bug" is not

#### Scenario: Beside a short title
- **WHEN** the user clicks an objective node to the right of its one-line title, short of the ⋯ button
- **THEN** the objective is selected and no field opens

#### Scenario: Second line of a title
- **WHEN** the user clicks the second line of a two-line title
- **THEN** the Rename field opens holding the whole title

### Requirement: Attention marks
An objective node SHALL be marked when a live tab of this window that it links holds an omp chat that needs the user:
- **needs you:** the chat waits for the user's input. An amber ring, and a "needs you" chip first on its second line.
- **replied:** otherwise, the chat finished a reply the user hasn't seen yet. A green ring and a "replied" chip.

Other agents, closed tabs and other windows' tabs SHALL NOT mark it. The chip's tooltip SHALL name the tabs.

#### Scenario: Question waiting
- **WHEN** "Fix login bug" links tab "Server", and the omp chat there asks the user a question while the user is in another tab
- **THEN** the graph shows "Fix login bug" with an amber ring and a "needs you" chip whose tooltip names "Server"

#### Scenario: Reply unseen
- **WHEN** "Fix login bug" links tab "Server", and the omp chat there finishes a reply while the user is in another tab
- **THEN** the graph shows "Fix login bug" with a green ring and a "replied" chip

#### Scenario: Needs you wins
- **WHEN** an objective links one tab whose omp chat waits for input and another whose omp chat has an unseen reply
- **THEN** its node shows the amber ring and the "needs you" chip only

#### Scenario: Not linked
- **WHEN** the omp chat in tab "Server" waits for input, and "Write slides" doesn't link "Server"
- **THEN** "Write slides" has no ring and no chip of either kind

### Requirement: Attention marks clear
A "replied" mark SHALL go once the user has viewed the tab. A "needs you" mark SHALL stay until the chat stops waiting for input, even after the user has viewed the tab. Marks SHALL show on open, done and review nodes. A selected node SHALL show its selection ring and its mark together.

#### Scenario: Viewing clears a reply
- **WHEN** "Fix login bug" shows "replied" for tab "Server", and the user views "Server" and opens the graph again
- **THEN** "Fix login bug" has no ring and no chip of either kind

#### Scenario: Viewing keeps a question
- **WHEN** "Fix login bug" shows "needs you" for tab "Server", and the user views "Server" without answering and opens the graph again
- **THEN** "Fix login bug" still shows "needs you"

#### Scenario: Selected and marked
- **WHEN** "Fix login bug" shows "needs you" and the user selects it
- **THEN** the screenshot shows the accent selection ring and the amber ring together, and the "needs you" chip

## REMOVED Requirements

### Requirement: Controls don't select text
**Reason**: Its scenario "Titles stay selectable" no longer holds: a click on a title opens the Rename field, so titles join the controls whose text can't be selected. A MODIFIED block can't drop a scenario.

**Migration**: Replaced by "Controls and titles don't select text", with the same rules plus titles, and "Drag across a title" in place of "Titles stay selectable".
