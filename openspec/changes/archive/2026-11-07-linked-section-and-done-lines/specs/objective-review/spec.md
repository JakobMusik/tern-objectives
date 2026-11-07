## MODIFIED Requirements

### Requirement: Review mode
Clicking "Review (n)" SHALL draw the button active and list in the left column only those due objectives, earliest next review first, then the most recently done. Each SHALL carry Hard, Good and Easy buttons showing the whole days each would give, as "Good · 3d". Open objectives and the Done group SHALL be hidden; the right column SHALL also show the listed objectives' closed tabs, which are otherwise kept out of it.

#### Scenario: Two due
- **WHEN** two done objectives are due, one of them done yesterday with a fresh schedule, three objectives are open, and the user clicks "Review (2)"
- **THEN** the left column lists only the two due objectives, the fresh one's buttons read "Hard · 1d", "Good · 3d" and "Easy · 4d", and there is no Done group

#### Scenario: Closed tab in review
- **WHEN** a due objective's only linked tab was closed with "Close linked tabs", it held an omp chat that had replied, the user clicks "Review (1)" and then selects the objective
- **THEN** after "Review (1)", that tab shows under "Closed tabs" with "Resume" and no line; after selecting, a dashed green line joins it to the objective, and no tab node has a link bar
