## ADDED Requirements

### Requirement: Creation time after the title
Each objective node SHALL show its creation time after the title, dimmed, as `MM-DD HH:MM` in local time, so objectives with the same title can be told apart. A title too long for the line SHALL be cut with "…" before the time is. The time SHALL come from when the objective was created and SHALL NOT be part of its title: renaming SHALL NOT change it, and objectives created before this version SHALL show it too.

#### Scenario: Two with one title
- **WHEN** the user creates "Write slides" with "＋ New objective", and again a minute or more later
- **THEN** both nodes read "Write slides", each followed by its own creation time from the kv dump's `created`, as `MM-DD HH:MM`, and both kv titles are exactly "Write slides"

#### Scenario: Long title
- **WHEN** an objective's title is 120 characters long and the graph is 1400 pixels wide
- **THEN** its node's title ends in "…" and the creation time after it is shown whole

#### Scenario: Rename keeps the time
- **WHEN** the user renames "Write slides" to "Write talk slides"
- **THEN** the rename field held "Write slides" without the time, and the node reads "Write talk slides" followed by the same creation time as before

#### Scenario: Done and review nodes
- **WHEN** the user opens the Done group, and later lists a due objective in review mode
- **THEN** each done node and each review node shows its creation time after the title
