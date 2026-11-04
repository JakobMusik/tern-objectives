# Spec Delta

## MODIFIED Requirements

### Requirement: Tab column
The right column SHALL group tabs under session headings, with the current session marked. The session holding the graph's origin pane SHALL come first, with the origin's tab first inside it; the other sessions SHALL follow in Tern's session order, and the other tabs in tab order. Without a live origin, sessions and tabs SHALL keep Tern's order. Linked closed tabs SHALL gather in a final "Closed tabs" group, and linked elsewhere tabs in an "Other windows" group.

#### Scenario: Three sessions
- **WHEN** the window holds sessions "web" (2 tabs), "api" (tabs "Server" and "Benchmarks") and "docs" (1 tab), and the user opens the graph from a pane in api's "Benchmarks"
- **THEN** the right column shows "api" first, marked current, with "Benchmarks" above "Server", then "web" and "docs" with their tabs in order

#### Scenario: New order on a fresh open
- **WHEN** the user closes the graph, focuses a pane in web's second tab and opens the graph again
- **THEN** "web" comes first with its second tab at the top, then "api" and "docs"

#### Scenario: Origin pane closes
- **WHEN** the origin pane closes while the graph is shown
- **THEN** within a second the sessions and tabs are back in Tern's order

### Requirement: Unlinked tabs look different
A tab with no link to an open objective SHALL be drawn with a light grey fill and a dashed border, and a linked tab as a card with a solid border. Both SHALL draw their text at full strength.

#### Scenario: Linking removes the fade
- **WHEN** the user links an unlinked tab to an objective
- **THEN** the node changes from the grey fill with a dashed border to the card with a solid border, and its label's text colour is the same before and after

### Requirement: Light and dark themes
Lines, badges, chips and the unlinked-tab fill SHALL stay distinguishable in both Tern's light and dark appearances.

#### Scenario: Both appearances
- **WHEN** the graph is captured in the light appearance and in the dark appearance
- **THEN** both captures show every line, every badge colour, and unlinked tabs filled differently from linked ones

### Requirement: Larger hit areas
The done box and the ⋯ button SHALL each take clicks over at least 22 px of width and the full 18 px height of their line in objective nodes. The ▸/▾ toggle SHALL take clicks over at least 28 px of width and the full 22 px height of its pane row, with its arrow drawn larger than the row's text. Objective nodes SHALL stay 48 px tall and pane rows 22 px.

#### Scenario: Measured hit areas
- **WHEN** a screenshot's layout data is read
- **THEN** every done box and ⋯ button is at least 22 × 18 px, every ▸/▾ toggle at least 28 × 22 px, objective nodes are 48 px tall, and pane rows are 22 px tall

## ADDED Requirements

### Requirement: Controls don't select text
Dragging across a tag chip, a due chip, a P0–P3 badge, the header's "All" and "This session" buttons, "Prune closed tabs", "＋ New objective" or a ▸/▾ toggle SHALL NOT select its text.

#### Scenario: Drag across the header
- **WHEN** the user presses in the header's empty space, drags across "＋ New objective", the tag filter chips and "All" / "This session", and releases in empty space
- **THEN** the screenshot shows no text highlight on any of them

#### Scenario: Drag across a node's badge and chips
- **WHEN** the user drags from an objective's side note across its due chip and tag chip, then up across its P0–P3 badge
- **THEN** the screenshot shows no text highlight on the badge or the chips, and the objective's priority is unchanged
