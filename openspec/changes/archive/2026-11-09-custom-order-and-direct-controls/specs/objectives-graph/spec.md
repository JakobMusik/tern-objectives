# Spec Delta

## ADDED Requirements

### Requirement: Custom order
Open objectives SHALL be listed in the order the user sets, which is kept with the objectives and shared by every window. Priority, due date and badge clicks SHALL NOT change it. A new objective SHALL take the place set in Configure, top by default. The first open after updating to this version SHALL list the open objectives as before: by priority, P0 first, then by due date, earliest first and none last, then by created time, oldest first.

#### Scenario: Order kept from before
- **WHEN** `kv.json` written by 0.16.0 holds P2 due tomorrow, P2 with no due date, P0 with no due date, and P2 due today, and the graph opens
- **THEN** the order is P0, P2 due today, P2 due tomorrow, P2 with no date

#### Scenario: Badge clicks don't move a node
- **WHEN** the graph lists the P3 objectives "Fix login bug", "Review pull requests" and "Write slides" in that order, the user clicks the badge of "Write slides" three times and then clicks empty graph space
- **THEN** "Write slides" is third after every click, its badge reads P0, and the kv dump holds priority 0 for it

#### Scenario: Due date doesn't move a node
- **WHEN** the user gives "Write slides", third in the list, a due date of today
- **THEN** "Write slides" is still third

#### Scenario: New objective on top
- **WHEN** the list holds "Fix login bug" and "Review pull requests" and the user creates "Write slides" with "＋ New objective"
- **THEN** the list reads "Write slides", "Fix login bug", "Review pull requests"

#### Scenario: Same order in link choices
- **WHEN** the user has moved "Write slides" to the top and runs "Objectives: Link this tab…", then right-clicks a tab node
- **THEN** both the picker and the tab menu list the open objectives in the left column's order, "Write slides" first

### Requirement: Moving objectives
Each open objective node SHALL show a grip ⠿ at its left, outside review mode. A click on the grip SHALL lift the node: it is drawn lifted, and the header shows `Moving “<title>”` with Cancel. While a node is lifted, pointing at another shown open objective's upper or lower half SHALL show an insertion line at that node's top or bottom edge, and a click there SHALL move the lifted objective to that line. Cancel, the grip again, or any other click SHALL end the move with the order unchanged.

#### Scenario: Move to the top
- **WHEN** the list reads "Fix login bug", "Review pull requests", "Write slides", and the user clicks the grip of "Write slides" and then the upper half of "Fix login bug"
- **THEN** the list reads "Write slides", "Fix login bug", "Review pull requests", nothing is lifted, and the kv dump holds the objectives in that order

#### Scenario: Move below
- **WHEN** the user then clicks the grip of "Write slides" and the lower half of "Review pull requests"
- **THEN** the list reads "Fix login bug", "Review pull requests", "Write slides"

#### Scenario: Insertion line
- **WHEN** "Write slides" is lifted and the pointer rests on the lower half of "Fix login bug"
- **THEN** a screenshot shows "Write slides" drawn lifted, the header reading `Moving “Write slides”` with Cancel, and an accent insertion line along the bottom edge of "Fix login bug" only

#### Scenario: Cancelled move
- **WHEN** "Write slides" is lifted and the user clicks empty graph space
- **THEN** nothing is lifted, the header shows no `Moving` notice, and the order and the kv dump are unchanged

#### Scenario: Moving under a tag filter
- **WHEN** "Review pull requests" lacks the tag "api" that the other two hold, the "#api" filter is on, and the user moves "Write slides" above "Fix login bug"
- **THEN** with the filter cleared the list reads "Write slides", "Fix login bug", "Review pull requests"

#### Scenario: No grip on done objectives
- **WHEN** the user opens the Done group
- **THEN** no done node has a grip, and the Done group is still ordered most recently done first

### Requirement: Action bar
The selected objective SHALL show a row of buttons under its lines, below the rating buttons in review mode. An open objective's row SHALL hold Note, Due, Tags and Delete. A done objective's row SHALL hold Note and Tags, and "Close n tabs" while at least one of its linked tabs is open in this window and no open objective links it, n being the number of those tabs. Note, Due and Tags SHALL open the Side note field, Due date picker and Tags picker directly. No node SHALL have a ⋯ button.

#### Scenario: Open objective's bar
- **WHEN** the user selects open objective "Fix login bug"
- **THEN** a row with Note, Due, Tags and Delete shows under its lines, no other node shows one, and no node has a ⋯ button

#### Scenario: Note directly
- **WHEN** the user selects "Fix login bug", clicks Note and enters "check the session cookie"
- **THEN** no picker opened before the field, and the node's side note reads "check the session cookie"

#### Scenario: Dismissed field
- **WHEN** the user clicks Note in the bar and dismisses the field
- **THEN** the objective is unchanged

#### Scenario: Done objective with tabs to close
- **WHEN** done objective X links two open tabs that no open objective links, and the user selects X
- **THEN** X's row holds Note, Tags and "Close 2 tabs", and selecting an open objective shows no "Close" button

#### Scenario: Nothing to close
- **WHEN** done objective X's only open tab is also linked to an open objective, and the user selects X
- **THEN** X's row holds Note and Tags only

### Requirement: Inline confirmation
An action that asks before acting SHALL ask in place, never in a picker: "Close n tabs" in the action bar or the done notice, and "Close n done tabs" in the header. The control SHALL turn into the question with Close and Cancel. Cancel, or any other click in the graph, SHALL end the question and change nothing.

#### Scenario: Asked in the bar
- **WHEN** done objective X links two open tabs that no open objective links, and the user clicks "Close 2 tabs" in X's bar
- **THEN** no picker opens, and the bar reads "Close 2 tabs?" with Close and Cancel

#### Scenario: Another click cancels
- **WHEN** the bar asks "Close 2 tabs?" and the user clicks empty graph space
- **THEN** both tabs are still open, and selecting X again shows its row with "Close 2 tabs"

### Requirement: New objective key
"Objectives: New objective", default key ⌥N, SHALL ask for a title and create an objective as "＋ New objective" does, selected in the graph. With the graph shown over the current tab, it SHALL act there, the settings page switching back to the graph. Anywhere else it SHALL first show the graph over the current tab. Like any plugin key, ⌥N SHALL run in every pane, whichever Option key is held.

#### Scenario: In the graph
- **WHEN** the graph is shown and the user presses ⌥N and enters "Write slides"
- **THEN** "Write slides" appears selected at the top of the list, and the kv dump holds it

#### Scenario: From a shell
- **WHEN** no graph is shown, focus is in a shell, and the user presses ⌥N and enters "Write slides"
- **THEN** the graph is shown over the current tab with "Write slides" selected, and the shell's prompt is unchanged

#### Scenario: Letters still reach the panes
- **WHEN** focus is in a shell prompt and the user types "n" and "N"
- **THEN** the prompt shows "nN", and no field or toast appears

### Requirement: Closing tabs of done objectives
The header SHALL show "Close n done tabs" while n of the live tabs the graph shows are linked only to done objectives: at least one done objective links each, and no open objective does. Clicking it SHALL ask in place. On Close it SHALL save the omp chats in those tabs, then close every pane of each, as "Close n tabs" does for one objective, and change no links. If the chats can't be saved, it SHALL close nothing and say so.

#### Scenario: Button shows
- **WHEN** done objective X links tab A, done objective Z and open objective Y both link tab B, and tab C is linked to nothing
- **THEN** the header shows "Close 1 done tab"

#### Scenario: Closed after asking
- **WHEN** the user clicks "Close 1 done tab" and then Close
- **THEN** the window holds B and C but not A, the kv dump shows X still linked to A, and the header shows no "done tab" button

#### Scenario: Cancelled
- **WHEN** the user clicks "Close 1 done tab" and then Cancel
- **THEN** A, B and C are all still open, and the header shows "Close 1 done tab" again

#### Scenario: Only the tabs the graph shows
- **WHEN** scope "This session" is on, and the only tab linked only to done objectives is in another session
- **THEN** the header shows no "done tab" button

#### Scenario: The graph's own tab
- **WHEN** the graph was opened over tab D, which only a done objective links, and the user clicks "Close 1 done tab" and then Close
- **THEN** D is gone, no tab is left holding only the graph, and the graph is shown again

### Requirement: Direct controls don't select text
Dragging across a grip, an action bar's buttons, an inline confirmation's buttons, the `Moving` notice, the header's "Close n done tabs", or the settings page's buttons SHALL NOT select their text.

#### Scenario: Drag across the action bar
- **WHEN** the user presses on the selected objective's side note, drags across its Note, Due and Tags buttons and releases beside the bar
- **THEN** the screenshot shows no text highlight on the buttons, and no field or picker opens

## MODIFIED Requirements

### Requirement: Graph returns after its pickers
When a picker or field opened from the graph closes, answered or dismissed, the graph SHALL be shown over the current tab again if a click on the field, or on the graph while the field was open, had closed it.

#### Scenario: Clicking into a field
- **WHEN** the user clicks "＋ New objective", clicks into the title field, types "Write slides" and presses Enter
- **THEN** the graph is shown again with "Write slides" selected

#### Scenario: Dismissing by clicking the graph
- **WHEN** the user clicks Note in an objective's action bar, clicks into the field and then clicks where the graph was
- **THEN** the field closes, the note is unchanged and the graph is shown again

### Requirement: Objective node content
Each objective node SHALL show:
- a grip (open objectives, outside review mode), a done box, a priority badge and the title, plus a trash icon on done objectives;
- below them, the side note (dimmed), a due chip on open objectives or a review chip on done ones, and tag chips.

Text other than the title that doesn't fit SHALL end in "…". Hovering the node SHALL show the full title, the full note and the created and done times, and for a done objective its review count and next review date.

#### Scenario: Long note
- **WHEN** an objective with a one-line title has a 200-character side note
- **THEN** its node stays 48 px tall, the note is cut with "…", and the node's tooltip holds the whole note

#### Scenario: Done node
- **WHEN** the user marks an objective with a due date done and opens the Done group
- **THEN** its node shows a trash icon, a "review in 1d" chip and no due chip, and its tooltip gives 0 reviews and tomorrow's date as the next review

### Requirement: Selection
Clicking an objective node anywhere but its title, grip, done box, badge, trash icon or action bar SHALL select it:
- its action bar shows under it;
- its lines are drawn thicker;
- all other lines fade to about a quarter of their strength;
- a link bar appears on every tab node, for an open or a done objective.

Clicking the selected objective there again, or empty graph space, SHALL clear the selection.

#### Scenario: Select and clear
- **WHEN** the user clicks an objective node beside its title and then clicks empty graph space
- **THEN** the first screenshot shows its action bar, its lines emphasised and a link bar on every tab node, and the second shows none of them

#### Scenario: Selecting a done objective
- **WHEN** the user opens the Done group and clicks a done objective's node on its second line
- **THEN** it is drawn selected, its lines show, and every tab node has a link bar

### Requirement: New objective button
"＋ New objective" in the header SHALL ask for a title, create the objective with no links, at the starting priority and place set in Configure (P3 and the top by default), and select it.

#### Scenario: Create and select
- **WHEN** the user clicks "＋ New objective" and enters "Write slides"
- **THEN** "Write slides" appears selected with a P3 badge, and every tab node shows a "＋ Link" bar

### Requirement: Larger hit areas
The grip, the done box and the trash icon SHALL each take clicks over at least 22 px of width and the full 18 px height of their line in objective nodes. Action bar buttons SHALL be at least 22 px tall. A pane row's jump button SHALL take clicks over at least 28 px of width and the row's full 22 px height. The Hard, Good and Easy buttons SHALL each be at least 22 px tall. Unselected objective nodes with a one-line title SHALL stay 48 px tall outside review mode, and pane rows 22 px.

#### Scenario: Measured hit areas
- **WHEN** a screenshot's layout data is read outside review mode with one objective selected
- **THEN** every grip, done box and trash icon is at least 22 × 18 px, every action bar button at least 22 px tall, every jump button at least 28 × 22 px, unselected objective nodes with one-line titles are 48 px tall, and pane rows are 22 px tall

#### Scenario: Review nodes
- **WHEN** a screenshot's layout data is read in review mode
- **THEN** every Hard, Good and Easy button is at least 22 px tall, and every listed node with a one-line title has the same height

### Requirement: Rename key
"Objectives: Rename selected objective", default key ⌥R, SHALL open the one-line Rename field for the selected objective, filled with its title, while the graph is shown over the current tab. The field SHALL behave as from a click on the title, and the selection SHALL stay. With no objective selected, or no graph shown over the tab, it SHALL show an info toast saying to select an objective in the graph, and change nothing.

#### Scenario: Rename by key
- **WHEN** the user selects "Fix login bug" in the graph, presses ⌥R and enters "Fix login timeout"
- **THEN** the node shows "Fix login timeout", the kv dump holds that title, and the objective is still selected

#### Scenario: Nothing selected
- **WHEN** no objective is selected and the user presses ⌥R in the graph
- **THEN** an info toast says to select an objective, and no field opens

#### Scenario: Letters still reach the panes
- **WHEN** focus is in a shell prompt and the user types "r" and "R"
- **THEN** the prompt shows "rR", and no field or toast appears

### Requirement: Closing a done objective's tabs
"Close n tabs" in a done objective's action bar SHALL ask in the bar, naming how many tabs it will close and how many linked tabs stay open because an open objective links them. On Close it SHALL save the omp chats in those tabs as it does at a turn, then close every pane of each of them, and change no links. A graph sitting in one of them SHALL close first and show again after. If the chats can't be saved, it SHALL close nothing and say so. Cancel SHALL change nothing.

#### Scenario: Close two, keep one
- **WHEN** done objective X links open tabs A, B and C, open objective Y also links C, and the user selects X and clicks "Close 2 tabs" in its bar
- **THEN** the bar asks to close 2 tabs and says 1 stays open; after Close, the window holds C but not A or B, and the kv dump shows X still linked to A, B and C

#### Scenario: Chat ready to resume
- **WHEN** tab A held an omp chat that had replied, A was closed this way, and the user selects X
- **THEN** A shows under "Closed tabs" with "Resume", and its row starts with "omp"

#### Scenario: Cancelled
- **WHEN** the user clicks "Close 2 tabs" in X's bar and then Cancel
- **THEN** A, B and C are all still open, the bar shows its buttons again, and `kv.json` is unchanged

#### Scenario: The graph's own tab
- **WHEN** done objective X links only tab D, the graph was opened over D, and the user clicks "Close 1 tab" in X's bar and then Close
- **THEN** D is gone, no tab is left holding only the graph, and the graph is shown again

### Requirement: Closing tabs from the done notice
When an objective is marked done in the graph and has tabs "Close n tabs" would close, its "Marked done" notice SHALL also offer "Close <n> tabs" after Undo. Clicking it SHALL turn the notice into the same question, with Close and Cancel. Close SHALL close the tabs and end the notice; Cancel SHALL bring back the notice and its Undo as they were. Marking done SHALL NOT close any tab by itself.

#### Scenario: Offered after marking done
- **WHEN** open objective X links two open tabs that no other open objective links, and the user clicks X's done box
- **THEN** the header reads "Marked done “X” · Undo · Close 2 tabs", and both tabs are still open

#### Scenario: Cancel keeps Undo
- **WHEN** the user clicks "Close 2 tabs" and then Cancel, then clicks Undo within 10 seconds of marking done
- **THEN** both tabs are still open, and X is open again

#### Scenario: Confirmed from the notice
- **WHEN** the user clicks "Close 2 tabs" and then Close
- **THEN** both tabs are closed, X stays done and still links them, and the header shows no notice

#### Scenario: Nothing to close
- **WHEN** an objective with no open linked tabs is marked done
- **THEN** the header reads "Marked done “<title>” · Undo", with no close button

### Requirement: Rename by clicking the title
A click on an objective's title SHALL open the one-line Rename field, filled with the title, as ⌥R does, on open, done and review nodes. Only the title's own text SHALL take this click; the rest of the node SHALL select as before. The click SHALL NOT change the selection.

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

### Requirement: Controls and titles don't select text
Dragging across an objective's title, a tag chip, a due chip, a P0–P3 badge, the header's "All" and "This session" buttons, "＋ New objective", or a pane row's type, name or jump button SHALL NOT select its text. Neither dragging across nor double-clicking a group or session heading SHALL select its text: "Done (n)", "Closed tabs", "Other windows", a session heading, the `Linked to` heading or the `Other tabs` divider.

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

## REMOVED Requirements

### Requirement: Objective ordering
**Reason**: Open objectives now follow the user's own order (Custom order); priority and due date no longer sort them.
**Migration**: The first open after the update lists the open objectives in the old order, which then becomes the stored order. Use the grip to move them.

### Requirement: Objective menu
**Reason**: The ⋯ picker is replaced by the selected objective's action bar, whose buttons act directly (Action bar, Inline confirmation).
**Migration**: Select the objective and use Note, Due, Tags, Delete or "Close n tabs" in its bar; click the title, or press ⌥R, to rename.

### Requirement: Order held while changing priority
**Reason**: Badge clicks no longer move nodes at all (Custom order), so nothing needs holding.
**Migration**: None needed; the column keeps the user's order through any number of badge clicks.

### Requirement: Prune button visibility
**Reason**: "Prune closed tabs" removed links in bulk, and links now change only when the user clicks a link bar, or when Resume hands them over.
**Migration**: Resume a closed tab, or select its objective and click "× Unlink" on it. "Close n done tabs" closes the live tabs that only done objectives link.
