## ADDED Requirements

### Requirement: Resume button on a closed tab
A closed tab node SHALL show a "Resume" button on its header when at least one of its pane rows has a saved omp chat whose file still exists, and none otherwise. Tabs held by another window SHALL NOT show it. Its hit area SHALL be at least 28 × 22 px, and dragging across it SHALL NOT select its text. Clicking the rest of the header SHALL select the tab, with no toast.

#### Scenario: Button on a closed chat tab
- **WHEN** a linked tab holding an omp chat with a saved chat file, and a linked tab holding only a shell, are both closed
- **THEN** the first closed tab's header shows "Resume" and the second's doesn't

#### Scenario: Header click selects
- **WHEN** the user clicks the closed tab's label, beside its Resume button
- **THEN** focus is unchanged, no toast shows, no new tab opens, and the closed tab is drawn selected with its "Resume" still showing

#### Scenario: Chat file gone
- **WHEN** a closed tab's only saved omp chat file is moved away, and the graph draws again
- **THEN** that tab's header shows no "Resume"

## REMOVED Requirements

### Requirement: Resume button
**Reason**: A click on the rest of a closed tab's header now selects the tab instead of saying it is closed, and the scenario "Header click still toasts" can't carry over under its name.
**Migration**: "Resume button on a closed tab" holds the button, its hit area and what the rest of the header does.
