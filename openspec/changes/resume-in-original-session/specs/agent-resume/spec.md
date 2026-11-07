## ADDED Requirements

### Requirement: Where a chat resumes
The new tab SHALL open in the closed tab's session: the session with the id stored with the closed tab, else one with its stored name. It SHALL take the position the closed tab had there, or the last when the session has fewer tabs, and Tern SHALL show that session. With no such session, it SHALL open as the current session's last tab, and a toast SHALL name the missing session. If that session is on another machine, Resume SHALL refuse with a toast.

#### Scenario: Back in its own session
- **WHEN** a linked tab that was tab 2 of session "work", which has three tabs, is closed, the user switches to session "home", opens the graph and clicks the tab's "Resume"
- **THEN** Tern shows session "work", the resumed chat is its tab 2, and "home" has no new tab

#### Scenario: Session renamed
- **WHEN** session "work" is renamed "work-2" after the tab closed, and the user clicks "Resume"
- **THEN** the new tab opens in "work-2"

#### Scenario: Found by name
- **WHEN** session "work" was closed after the tab, a new session named "work" was created, and the user clicks "Resume"
- **THEN** the new tab opens in the new "work" session

#### Scenario: Fewer tabs now
- **WHEN** the closed tab was tab 3 of "work", which now holds one tab, and the user clicks "Resume"
- **THEN** the new tab is tab 2 of "work", its last

#### Scenario: Session gone
- **WHEN** no session has the closed tab's session id or name, and the user clicks "Resume" from session "home"
- **THEN** the new tab is the last tab of "home", and a toast names the missing session

## MODIFIED Requirements

### Requirement: Resuming a closed tab
Clicking "Resume" SHALL close the graph, open a new tab in the first saved chat's folder, in the session "Where a chat resumes" names, and run `omp --resume <file>` there. Each further saved chat of that tab SHALL run the same way in a split to the right, in row order. Every objective linking the closed tab SHALL then link the new tab instead, and the closed tab's snapshot SHALL be removed. Panes without a saved chat SHALL NOT be recreated.

#### Scenario: One chat comes back
- **WHEN** a linked tab holding one omp chat with a saved chat file F and one shell is closed, and the user clicks its "Resume"
- **THEN** a new tab shows an omp chat started with `omp --resume F` that holds the earlier messages, and it has no shell pane

#### Scenario: Links move to the new tab
- **WHEN** that closed tab was linked to objectives X and Y, and the user clicks its "Resume" and opens the graph again
- **THEN** the kv dump shows X and Y linked to the new tab and not the closed one, the closed tab's snapshot is gone, and the graph shows the new tab linked under its session with no ghost left
