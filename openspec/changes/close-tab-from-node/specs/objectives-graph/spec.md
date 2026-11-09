## ADDED Requirements

### Requirement: Closing a tab from its node
While the pointer is over a live tab node, it SHALL show a trash icon at the right end of its header's first line, taking clicks over at least 22 × 18 px. Closed and other-window tab nodes SHALL show none. Clicking it SHALL ask in place: that line turns into "Close tab?" with Cancel and, at the icon's place, Close. Close SHALL save the omp chats, then close every pane of the tab, as "Close n tabs" does, closing nothing if they can't be saved, and change no links.

#### Scenario: Icon while pointing
- **WHEN** the pointer rests on live tab node A
- **THEN** a shot shows a trash icon at the right end of A's first header line, at least 22 × 18 px, and none on any other tab node

#### Scenario: No icon on ghosts
- **WHEN** the pointer rests on a closed tab node, then on an other-window tab node
- **THEN** neither shows a trash icon

#### Scenario: Asked in the header
- **WHEN** the user clicks the trash icon on live tab A
- **THEN** no picker opens, the window still holds A, A's first header line reads "Close tab?" with Cancel and Close, Close ends where the icon did, and every node and line stays where it was

#### Scenario: Closed after asking
- **WHEN** tab A, linked to open objective X, asks "Close tab?" and the user clicks Close
- **THEN** the window no longer holds A, a toast reads "Closed “A”", A shows under "Closed tabs", and the kv dump shows X still linked to A

#### Scenario: Chat ready to resume
- **WHEN** tab A held an omp chat that had replied, and A was closed from its node
- **THEN** A's node under "Closed tabs" shows "Resume", and its row starts with "omp"

#### Scenario: Unlinked tab
- **WHEN** tab C, which no objective links, is closed from its node
- **THEN** the window no longer holds C, and the right column shows no node for it

#### Scenario: Cancelled
- **WHEN** the user clicks the trash icon on tab A, then Cancel
- **THEN** A is still open, its header shows its label again, and `kv.json` is unchanged

#### Scenario: Header clicked while asking
- **WHEN** tab A asks "Close tab?" and the user clicks the question's text
- **THEN** A is still open, the graph is still shown, focus is unchanged, and A's header shows its label again

#### Scenario: The graph's own tab
- **WHEN** the graph was opened over tab D, and the user clicks D's trash icon and then Close
- **THEN** D is gone, no tab is left holding only the graph, and the graph is shown again

#### Scenario: Last tab of its session
- **WHEN** the graph was opened over tab D, the only tab of session "docs", and the user closes D from its node
- **THEN** D is gone, session "docs" is still listed, and no error toast shows

#### Scenario: Narrow graph
- **WHEN** the window is 460 px wide and a tab node asks "Close tab?"
- **THEN** Cancel and Close sit inside the tab node

#### Scenario: Another click ends the question
- **WHEN** tab A asks "Close tab?" and the user clicks empty graph space
- **THEN** A is still open, and its header shows its label again
