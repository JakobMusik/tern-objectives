## MODIFIED Requirements

### Requirement: Objective ordering
Open objectives SHALL be ordered:
1. by priority, P0 first;
2. then by due date, earliest first, with no date last;
3. then by created time, oldest first.

The one exception is the left column while a priority change holds its order (Order held while changing priority).

#### Scenario: Mixed priorities and dates
- **WHEN** the store holds P2 due tomorrow, P2 with no due date, P0 with no due date, and P2 due today
- **THEN** the order is P0, P2 due today, P2 due tomorrow, P2 with no date

### Requirement: Priority badge
Clicking the priority badge SHALL raise the priority one step, P3 → P2 → P1 → P0, and a click on a P0 badge SHALL wrap back to P3. Badge colours SHALL be: P0 red, P1 orange, P2 blue, P3 grey.

#### Scenario: Raise one step
- **WHEN** the user clicks the badge of a P3 objective
- **THEN** the objective becomes P2 and its badge turns blue

#### Scenario: Cycle wraps
- **WHEN** the user clicks the badge of a P0 objective
- **THEN** the objective becomes P3 and its badge turns grey

### Requirement: New objective button
"＋ New objective" in the header SHALL ask for a title, create the objective at P3 with no links, and select it.

#### Scenario: Create and select
- **WHEN** the user clicks "＋ New objective" and enters "Write slides"
- **THEN** "Write slides" appears selected with a P3 badge, and every tab node shows a "＋ Link" bar

## ADDED Requirements

### Requirement: Order held while changing priority
After a click on a priority badge, the left column SHALL keep the order it had before that click, through any further badge clicks on any objective, so a clicked node stays where it was. The next click in the graph on anything else, or a fresh open of the graph, SHALL end the hold and sort the column again. An open objective that appears during the hold SHALL follow the held ones. The "Link this tab" picker and the tab menu SHALL stay sorted.

#### Scenario: Raising in place
- **WHEN** the graph lists the P3 objectives "Fix login bug", "Review pull requests" and "Write slides" in that order, and the user clicks the badge of "Write slides" three times
- **THEN** after each click "Write slides" is still third, and after the third its badge reads P0 and the kv dump holds priority 0 for it

#### Scenario: A click elsewhere sorts again
- **WHEN** the order is held after "Raising in place" and the user clicks empty space in the graph
- **THEN** "Write slides" moves to the top of the left column

#### Scenario: Badges of several objectives
- **WHEN** the user clicks the badge of "Write slides" and then the badge of "Review pull requests"
- **THEN** the left column's order is the same after both clicks as before the first

#### Scenario: Fresh open sorts again
- **WHEN** the order is held after "Raising in place", and the user closes the graph with ⌃⌘O and opens it again
- **THEN** "Write slides" is at the top of the left column

#### Scenario: New objective during the hold
- **WHEN** the order is held and the user runs "Objectives: New objective for this tab…" and enters "Update docs"
- **THEN** "Update docs" is listed after the held objectives, whose order is unchanged

#### Scenario: The picker stays sorted
- **WHEN** the order is held after "Raising in place" and the user runs "Objectives: Link this tab…"
- **THEN** "Write slides" is the picker's first row, while the left column still lists it third
