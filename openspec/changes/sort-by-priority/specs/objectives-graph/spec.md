## ADDED Requirements

### Requirement: Sorting by priority
With "Sort by priority" on, open objectives SHALL be listed P0 first and P3 last, in the user's own order within one priority. The left column, the "Link this tab…" picker and the tab menu SHALL all show this order. Sorting SHALL NOT change the stored order. The Done group and review mode SHALL keep their own order.

#### Scenario: Sorted list
- **WHEN** sorting is on, the kv dump lists the open objectives "Fix login bug" (P3), "Review pull requests" (P1), "Write slides" (P3) and "Update dependencies" (P0) in that order, and the graph opens
- **THEN** the left column reads "Update dependencies", "Review pull requests", "Fix login bug", "Write slides", and the kv dump still lists them in their old order

#### Scenario: Link choices sorted too
- **WHEN** the objectives are as in "Sorted list", and the user runs "Objectives: Link this tab…", then right-clicks a tab node
- **THEN** both the picker and the tab menu list "Update dependencies", "Review pull requests", "Fix login bug", "Write slides"

#### Scenario: Sorting turned off
- **WHEN** the objectives are as in "Sorted list", and the user turns "Sort by priority" off on the settings page and goes back to the graph
- **THEN** the left column reads "Fix login bug", "Review pull requests", "Write slides", "Update dependencies"

#### Scenario: Done group keeps its order
- **WHEN** sorting is on, done objective "Set up CI" (P0) was marked done before done objective "Read docs" (P3), and the user opens the Done group
- **THEN** the Done group lists "Read docs" before "Set up CI"

### Requirement: Sorting waits for another click
With sorting on, a click on a priority badge SHALL change the badge at once and move no node. The list SHALL keep that order while the user clicks priority badges, on any objective, and through redraws such as live refreshes. The next other click in the graph, or the next fresh open of the graph, SHALL sort the list.

#### Scenario: Badge clicks hold the order
- **WHEN** sorting is on, the list reads "Fix login bug" (P0), "Review pull requests" (P2), "Write slides" (P3), and the user clicks the badge of "Write slides" twice
- **THEN** "Write slides" is third after each click, its badge reads P2 and then P1, and the kv dump holds priority 1 for it

#### Scenario: Another click sorts
- **WHEN** "Write slides" was raised to P1 as above, and the user then clicks empty graph space
- **THEN** the list reads "Fix login bug", "Write slides", "Review pull requests"

#### Scenario: Other badges hold it too
- **WHEN** "Write slides" was raised to P1 as above, the stored order is "Fix login bug", "Review pull requests", "Write slides", and the user clicks the badge of "Review pull requests"
- **THEN** no node moves and its badge reads P1; after a click on empty graph space, the list reads "Fix login bug", "Review pull requests", "Write slides"

#### Scenario: Refresh keeps the order
- **WHEN** "Write slides" was raised to P1 as above, and a new tab opens in the window, so the graph redraws
- **THEN** "Write slides" is still third

#### Scenario: Fresh open sorts
- **WHEN** "Write slides" was raised to P1 as above, and the user presses ⌃⌘O twice
- **THEN** the reopened graph lists "Write slides" second

### Requirement: Moving while sorted
While "Sort by priority" is on, a lifted objective SHALL take a drop only on shown open objectives of its own priority. Pointing at an objective of another priority SHALL show no insertion line, and a click on it SHALL end the move with the order unchanged.

#### Scenario: Move within a priority
- **WHEN** sorting is on, the list reads "Release" (P1), "Fix login bug", "Review pull requests" and "Write slides" (all P3), and the user clicks the grip of "Write slides" and then the upper half of "Fix login bug"
- **THEN** the list reads "Release", "Write slides", "Fix login bug", "Review pull requests", and the kv dump holds "Write slides" before "Fix login bug"

#### Scenario: Another priority takes no drop
- **WHEN** "Write slides" is lifted as above and the pointer rests on the lower half of "Release"
- **THEN** a screenshot shows no insertion line, and a click there ends the move with the list and the kv dump unchanged

## MODIFIED Requirements

### Requirement: Custom order
Open objectives SHALL be listed in the order the user sets, which is kept with the objectives and shared by every window; "Sort by priority" applies it within each priority. Priority, due date and badge clicks SHALL NOT change it. A new objective SHALL take the place set in Configure, top by default. The first open after updating to this version SHALL list the open objectives as before: by priority, P0 first, then by due date, earliest first and none last, then by created time, oldest first.

#### Scenario: Order kept from before
- **WHEN** `kv.json` written by 0.16.0 holds P2 due tomorrow, P2 with no due date, P0 with no due date, and P2 due today, and the graph opens
- **THEN** the order is P0, P2 due today, P2 due tomorrow, P2 with no date

#### Scenario: Badge clicks don't move a node
- **WHEN** "Sort by priority" is off, the graph lists the P3 objectives "Fix login bug", "Review pull requests" and "Write slides" in that order, the user clicks the badge of "Write slides" three times and then clicks empty graph space
- **THEN** "Write slides" is third after every click, its badge reads P0, and the kv dump holds priority 0 for it

#### Scenario: Due date doesn't move a node
- **WHEN** the user gives "Write slides", third in the list, a due date of today
- **THEN** "Write slides" is still third

#### Scenario: New objective on top
- **WHEN** the list holds "Fix login bug" and "Review pull requests" and the user creates "Write slides" with "＋ New objective"
- **THEN** the list reads "Write slides", "Fix login bug", "Review pull requests"

#### Scenario: Same order in link choices
- **WHEN** the user has moved "Write slides" to the top and runs "Objectives: Link this tab…", then right-clicks a tab node
- **THEN** both the picker and the tab menu list the open objectives in the left column's order, "Write slides" first
