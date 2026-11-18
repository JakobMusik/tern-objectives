## MODIFIED Requirements

### Requirement: New objective defaults
The page SHALL let the user choose the priority new objectives start at, P0 to P3, P3 by default, and where they go in the custom order, top or bottom, top by default. Sorted by priority, that is the top or bottom of their priority; newest first, it comes first. Both SHALL apply to "＋ New objective", "Objectives: New objective" and "Objectives: New objective for this tab…", SHALL be stored with the objectives in the plugin's `kv.json`, and SHALL hold in every window and after a reload.

#### Scenario: Start at P1, at the bottom
- **WHEN** sorted in Your order, the user picks P1 and Bottom on the settings page, goes back to the graph, creates "Write slides" with "＋ New objective" and clicks empty graph space
- **THEN** "Write slides" has a P1 badge and is the last open objective, and the kv dump holds priority 1 for it and the two settings

#### Scenario: Bottom of its priority
- **WHEN** sorted by priority, the list reads "Release" (P1) and "Fix login bug" (P3), and the user picks P1 and Bottom, creates "Write slides" with "＋ New objective" and clicks empty graph space
- **THEN** the list reads "Release", "Write slides", "Fix login bug"

#### Scenario: First when sorted newest first
- **WHEN** sorted newest first, the list reads "Release" and "Fix login bug", and the user picks Bottom and creates "Write slides" with "＋ New objective"
- **THEN** the list reads "Write slides", "Release", "Fix login bug", and the kv dump holds "Write slides" last

#### Scenario: Defaults survive a reload
- **WHEN** the user picks P1 and Bottom and the plugin is reloaded
- **THEN** the settings page still shows P1 and Bottom selected
