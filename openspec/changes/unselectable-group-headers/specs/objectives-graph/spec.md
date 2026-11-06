## MODIFIED Requirements

### Requirement: Controls don't select text
Dragging across a tag chip, a due chip, a P0–P3 badge, the header's "All" and "This session" buttons, "Prune closed tabs", "＋ New objective", or a pane row's type, name or jump button SHALL NOT select its text. Neither dragging across nor double-clicking a group or session heading SHALL select its text: "Done (n)", "Closed tabs", "Other windows", a session heading, the `Linked to` heading or the `Other tabs` divider.

#### Scenario: Drag across the header
- **WHEN** the user presses in the header's empty space, drags across "＋ New objective", the tag filter chips and "All" / "This session", and releases in empty space
- **THEN** the screenshot shows no text highlight on any of them

#### Scenario: Drag across a node's badge and chips
- **WHEN** the user drags from an objective's side note across its due chip and tag chip, and from its title across its P0–P3 badge
- **THEN** the screenshot shows no text highlight on the badge or the chips, and the objective's priority is unchanged

#### Scenario: Drag along a pane row
- **WHEN** the user drags from a tab's header across a pane row's type and name
- **THEN** the screenshot shows no text highlight on the row

#### Scenario: Double-click on the Done header
- **WHEN** the left column holds done objectives, and the user double-clicks the word "Done" in the "Done (n)" header
- **THEN** the screenshot shows no text highlight on the header

#### Scenario: Double-click on a session heading
- **WHEN** the user double-clicks a session's name in the right column
- **THEN** the screenshot shows no text highlight on the heading

#### Scenario: Titles stay selectable
- **WHEN** the user double-clicks a word in an objective's title
- **THEN** the word is highlighted, as before
