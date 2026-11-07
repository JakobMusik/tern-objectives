## MODIFIED Requirements

### Requirement: Saved sessions follow their tabs
A saved omp chat SHALL be removed once its pane is neither live in the window nor a row of a stored tab snapshot, for example after "Prune closed tabs" removes the closed tab that held it.

#### Scenario: Pruned with its tab
- **WHEN** a linked tab holding an omp chat with a saved chat file is closed, and the user confirms "Prune closed tabs"
- **THEN** the kv dump holds neither the tab's snapshot nor the pane's saved chat

### Requirement: Where a chat resumes
The new tab SHALL open in the closed tab's session: the session with the id stored with the closed tab, else one with its stored name, matched exactly, else ignoring case. It SHALL take the position the closed tab had there, or the last when the session has fewer tabs, and Tern SHALL show that session. With no such session, it SHALL open as the current session's last tab, and a toast SHALL name the missing session. If that session is on another machine, Resume SHALL refuse with a toast.

#### Scenario: Back in its own session
- **WHEN** a linked tab that was tab 2 of session "work", which has three tabs, is closed, the user switches to session "home", opens the graph and clicks the tab's "Resume"
- **THEN** Tern shows session "work", the resumed chat is its tab 2, and "home" has no new tab

#### Scenario: Session renamed
- **WHEN** session "work" is renamed "work-2" after the tab closed, and the user clicks "Resume"
- **THEN** the new tab opens in "work-2"

#### Scenario: Found by name
- **WHEN** session "work" was closed after the tab, a new session named "work" was created, and the user clicks "Resume"
- **THEN** the new tab opens in the new "work" session

#### Scenario: Found by name in another case
- **WHEN** session "work" was closed after the tab, a new session named "Work" was created, and the user clicks "Resume"
- **THEN** the new tab opens in "Work"

#### Scenario: Fewer tabs now
- **WHEN** the closed tab was tab 3 of "work", which now holds one tab, and the user clicks "Resume"
- **THEN** the new tab is tab 2 of "work", its last

#### Scenario: Session gone
- **WHEN** no session has the closed tab's session id or name, and the user clicks "Resume" from session "home"
- **THEN** the new tab is the last tab of "home", and a toast names the missing session
