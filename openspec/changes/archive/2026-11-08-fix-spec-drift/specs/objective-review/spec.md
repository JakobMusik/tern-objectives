## MODIFIED Requirements

### Requirement: Leaving review mode
Review mode SHALL end when its list becomes empty, when the active "Review (n)" button is clicked, or when the graph closes, except when one of the graph's own pickers closed it and it is shown again. It SHALL NOT be remembered across opens of the graph.

#### Scenario: Last one rated
- **WHEN** review mode lists one objective and the user clicks Easy
- **THEN** the left column shows the open objectives and the Done group again, and the header shows no Review button

#### Scenario: Button clicked again
- **WHEN** review mode lists two objectives and the user clicks the active "Review (2)"
- **THEN** the left column shows the open objectives and the Done group, and the header still shows "Review (2)"

#### Scenario: Picker from review mode
- **WHEN** review mode lists two objectives, the user opens one's ⋯ menu and dismisses it with Esc
- **THEN** the graph is shown again, still in review mode with the same two objectives

### Requirement: Undo after done or remove
After an objective is marked done or removed in the graph, the header SHALL show "Marked done “<title>” · Undo" or "Removed “<title>” · Undo". The notice SHALL stay until the next click elsewhere in the graph, the graph closing (unless one of its own pickers closed it and it is shown again), or 10 seconds. Clicking Undo SHALL restore the objective as it was before: its fields, links, place in the list, and the tab snapshots removed with it.

#### Scenario: Undo marking done
- **WHEN** the user marks a linked objective done and clicks Undo
- **THEN** the kv dump holds its record exactly as before the first click, with no done time and no schedule, and it is back in the open list with its lines

#### Scenario: Undo removing
- **WHEN** the user removes a done objective that was the only one linked to a closed tab, and clicks Undo
- **THEN** the kv dump holds the objective at its former place in the list, with its links, and the closed tab's snapshot is back

#### Scenario: Notice expires
- **WHEN** the user marks an objective done and 10 seconds pass without a click
- **THEN** the header no longer shows the notice, and the objective stays done

#### Scenario: Notice dropped by another click
- **WHEN** the user marks an objective done and then clicks another objective's title
- **THEN** the header no longer shows the notice
