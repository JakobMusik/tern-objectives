## ADDED Requirements

### Requirement: Closing a done objective's tabs
Choosing "Close linked tabs" SHALL ask for confirmation, naming how many tabs it will close and how many linked tabs stay open because an open objective links them. On confirmation it SHALL save the omp chats in those tabs as it does at a turn, then close every pane of each of them, and change no links. If the chats can't be saved, it SHALL close nothing and say so. Cancelling SHALL change nothing.

#### Scenario: Close two, keep one
- **WHEN** done objective X links open tabs A, B and C, open objective Y also links C, and the user picks "Close linked tabs" in X's menu
- **THEN** the confirmation names 2 tabs to close and 1 that stays open; after confirming, the window holds C but not A or B, and the kv dump shows X still linked to A, B and C

#### Scenario: Chat ready to resume
- **WHEN** tab A held an omp chat that had replied, A was closed this way, and the user selects X
- **THEN** A shows under "Closed tabs" with "Resume", and its row starts with "omp"

#### Scenario: Cancelled
- **WHEN** the user picks "Close linked tabs" and cancels the confirmation
- **THEN** A, B and C are all still open, and `kv.json` is unchanged

### Requirement: Closing tabs from the done notice
When an objective is marked done in the graph and has tabs "Close linked tabs" would close, its "Marked done" notice SHALL also offer "Close <n> tabs" after Undo. Clicking it SHALL ask the same confirmation as the menu row. Confirming SHALL close the tabs and end the notice; cancelling SHALL leave the notice and its Undo as they were. Marking done SHALL NOT close any tab by itself.

#### Scenario: Offered after marking done
- **WHEN** open objective X links two open tabs that no other open objective links, and the user clicks X's done box
- **THEN** the header reads "Marked done “X” · Undo · Close 2 tabs", and both tabs are still open

#### Scenario: Cancel keeps Undo
- **WHEN** the user clicks "Close 2 tabs" and cancels the confirmation, then clicks Undo within 10 seconds of marking done
- **THEN** both tabs are still open, and X is open again

#### Scenario: Confirmed from the notice
- **WHEN** the user clicks "Close 2 tabs" and confirms
- **THEN** both tabs are closed, X stays done and still links them, and the header shows no notice

#### Scenario: Nothing to close
- **WHEN** an objective with no open linked tabs is marked done
- **THEN** the header reads "Marked done “<title>” · Undo", with no close button

### Requirement: Done objectives' closed tabs
A closed tab that only done objectives link SHALL NOT show in the right column, except while one of those objectives is selected or is listed in review mode.

#### Scenario: Out of the way
- **WHEN** done objective X's tab A is closed, no other objective links A, and nothing is selected
- **THEN** the right column has no node for A

#### Scenario: Shown with its objective
- **WHEN** the user selects X
- **THEN** A shows under "Closed tabs" in the `Linked to “X”` section

#### Scenario: Also linked to an open objective
- **WHEN** a closed tab is linked to done objective X and to open objective Y, and nothing is selected
- **THEN** it shows under "Closed tabs"

## MODIFIED Requirements

### Requirement: Objective menu
The ⋯ button SHALL open a picker with Rename, Side note, Due date, Tags and Delete. For a done objective with at least one linked tab open in this window that no open objective links, it SHALL also offer "Close linked tabs", with the number of those tabs.
- Rename and Side note SHALL open a one-line field pre-filled with the current value.
- Dismissing any picker or field SHALL change nothing.

#### Scenario: Rename
- **WHEN** the user picks Rename and enters "Fix login timeout"
- **THEN** the node shows "Fix login timeout"

#### Scenario: Dismissed field
- **WHEN** the user opens Side note and dismisses the field
- **THEN** the objective is unchanged

#### Scenario: Close row on a done objective
- **WHEN** done objective X links two open tabs that no open objective links
- **THEN** X's menu offers "Close linked tabs" with "2 open tabs", and an open objective's menu doesn't offer it

#### Scenario: Nothing to close
- **WHEN** done objective X's only open tab is also linked to an open objective
- **THEN** X's menu doesn't offer "Close linked tabs"

### Requirement: Tab column
The right column SHALL group tabs under session headings, with the current session marked. The session holding the graph's origin pane SHALL come first, with the origin's tab first inside it; the other sessions SHALL follow in Tern's session order, and the other tabs in tab order. Without a live origin, sessions and tabs SHALL keep Tern's order. Shown closed tabs SHALL gather in a final "Closed tabs" group, and linked elsewhere tabs in an "Other windows" group.

#### Scenario: Three sessions
- **WHEN** the window holds sessions "web" (2 tabs), "api" (tabs "Server" and "Benchmarks") and "docs" (1 tab), and the user opens the graph from a pane in api's "Benchmarks"
- **THEN** the right column shows "api" first, marked current, with "Benchmarks" above "Server", then "web" and "docs" with their tabs in order

#### Scenario: New order on a fresh open
- **WHEN** the user closes the graph, focuses a pane in web's second tab and opens the graph again
- **THEN** "web" comes first with its second tab at the top, then "api" and "docs"

#### Scenario: Origin pane closes
- **WHEN** the origin pane closes while the graph is shown
- **THEN** within a second the sessions and tabs are back in Tern's order

### Requirement: Prune button visibility
The header SHALL show "Prune closed tabs" only while at least one closed tab it shows is linked to an open objective.

#### Scenario: Button appears
- **WHEN** a tab linked to an open objective is closed while the graph is shown
- **THEN** "Prune closed tabs" appears in the header

#### Scenario: Only done objectives' tabs
- **WHEN** the only closed tabs are linked to done objectives alone, and the user selects one of those objectives
- **THEN** its closed tabs show, and the header shows no "Prune closed tabs"
