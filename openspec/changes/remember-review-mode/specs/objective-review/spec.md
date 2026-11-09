## MODIFIED Requirements

### Requirement: Leaving review mode
Review mode SHALL end when its list becomes empty, an open with nothing due included, when the active "Review (n)" button is clicked, or when "Objectives: New objective" runs. Closing the graph SHALL NOT end it: the next open in the same window SHALL show review mode again, listing the objectives due then. Each window SHALL keep its own, and a plugin reload, as on every Tern restart, SHALL forget it.

#### Scenario: Last one rated
- **WHEN** review mode lists one objective and the user clicks Easy
- **THEN** the left column shows the open objectives and the Done group again, and the header shows no Review button

#### Scenario: Button clicked again
- **WHEN** review mode lists two objectives and the user clicks the active "Review (2)"
- **THEN** the left column shows the open objectives and the Done group, and the header still shows "Review (2)"

#### Scenario: Picker from review mode
- **WHEN** review mode lists two objectives, the user selects one, clicks Tags in its action bar and dismisses the picker with Esc
- **THEN** the graph is shown again, still in review mode with the same two objectives

#### Scenario: Reopened in review mode
- **WHEN** review mode lists two objectives and the user presses ⌃⌘O twice
- **THEN** the first press closes the graph, and the second shows it with "Review (2)" active and only those two objectives in the left column

#### Scenario: Left before closing
- **WHEN** review mode lists two objectives, the user clicks the active "Review (2)" and then presses ⌃⌘O twice
- **THEN** the reopened graph shows the open objectives and the Done group, with "Review (2)" not active

#### Scenario: Nothing due at the next open
- **WHEN** the graph was closed in review mode listing one objective, that objective's record is removed from `kv.json` from outside the window, the graph is opened and closed, and the record is put back
- **THEN** the first of those opens shows no Review button, and the next shows the open objectives and the Done group with "Review (1)" not active

#### Scenario: Forgotten on reload
- **WHEN** review mode lists two objectives, the graph is closed and the plugin is reloaded
- **THEN** opening the graph shows the open objectives and the Done group, with "Review (2)" not active
