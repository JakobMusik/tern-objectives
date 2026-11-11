## MODIFIED Requirements

### Requirement: Review button
The header SHALL show "Review (n)" while n is above zero: the done objectives that pass the scope and tag filters and the search, and whose next review is today or earlier. Otherwise it SHALL NOT show.

#### Scenario: One due
- **WHEN** one done objective's next review is today and the filters show it
- **THEN** the header shows "Review (1)"

#### Scenario: Nothing due
- **WHEN** every done objective's next review is after today
- **THEN** the header shows no Review button

#### Scenario: Search narrows the count
- **WHEN** the done objectives "Set up CI" and "Restyle the docs site" are both due, and the user searches for "docs"
- **THEN** the header shows "Review (1)", and clicking it lists "Restyle the docs site" only
