# Spec Delta

## MODIFIED Requirements

### Requirement: Review mode
Clicking "Review (n)" SHALL draw the button active and list in the left column only those due objectives, earliest next review first, then the most recently done. Each SHALL carry Hard, Good and Easy buttons showing the whole days each would give, as "Good · 3d". Open objectives and the Done group SHALL be hidden; the right column SHALL also show the listed objectives' closed tabs, which are otherwise kept out of it.

#### Scenario: Two due
- **WHEN** two done objectives are due, one of them done yesterday with a fresh schedule, three objectives are open, and the user clicks "Review (2)"
- **THEN** the left column lists only the two due objectives, the fresh one's buttons read "Hard · 1d", "Good · 3d" and "Easy · 4d", and there is no Done group

#### Scenario: Closed tab in review
- **WHEN** a due objective's only linked tab was closed with "Close linked tabs", it held an omp chat that had replied, the user clicks "Review (1)" and then selects the objective
- **THEN** after "Review (1)", that tab shows under "Closed tabs" with "Resume" and no line; after selecting, a dashed green line joins it to the objective, every tab node has a link bar, and that tab's reads "× Unlink"

### Requirement: Leaving review mode
Review mode SHALL end when its list becomes empty, when the active "Review (n)" button is clicked, or when the graph closes, except when one of the graph's own pickers closed it and it is shown again. It SHALL NOT be remembered across opens of the graph.

#### Scenario: Last one rated
- **WHEN** review mode lists one objective and the user clicks Easy
- **THEN** the left column shows the open objectives and the Done group again, and the header shows no Review button

#### Scenario: Button clicked again
- **WHEN** review mode lists two objectives and the user clicks the active "Review (2)"
- **THEN** the left column shows the open objectives and the Done group, and the header still shows "Review (2)"

#### Scenario: Picker from review mode
- **WHEN** review mode lists two objectives, the user selects one, clicks Tags in its action bar and dismisses the picker with Esc
- **THEN** the graph is shown again, still in review mode with the same two objectives

### Requirement: Undo after done or remove
After an objective is marked done or removed in the graph, the header SHALL show "Marked done “<title>” · Undo" or "Removed “<title>” · Undo". The notice SHALL stay until the next click elsewhere in the graph, the graph closing (unless one of its own pickers closed it and it is shown again), or 10 seconds. Clicking Undo SHALL restore the objective as it was before: its fields, links, place in the list, and the tab snapshots removed with it.

#### Scenario: Undo marking done
- **WHEN** the user marks a linked objective done and clicks Undo
- **THEN** the kv dump holds its record exactly as before the first click, with no done time and no schedule, and it is back in the open list with its lines

#### Scenario: Undo removing
- **WHEN** the user removes a done objective that was the only one linked to a closed tab, and clicks Undo
- **THEN** the kv dump holds the objective at its former place in the list, with its links, and the closed tab's snapshot is back

#### Scenario: Undo deleting an open objective
- **WHEN** the list reads "Fix login bug", "Review pull requests", "Write slides", and the user deletes "Review pull requests" from its action bar and clicks Undo
- **THEN** the list reads "Fix login bug", "Review pull requests", "Write slides" again, and the kv dump holds its record as before, with its links

#### Scenario: Notice expires
- **WHEN** the user marks an objective done and 10 seconds pass without a click
- **THEN** the header no longer shows the notice, and the objective stays done

#### Scenario: Notice dropped by another click
- **WHEN** the user marks an objective done and then clicks another objective's title
- **THEN** the header no longer shows the notice
