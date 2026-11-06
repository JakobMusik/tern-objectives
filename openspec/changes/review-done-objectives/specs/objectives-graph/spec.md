## MODIFIED Requirements

### Requirement: Objective node content
Each objective node SHALL show, on fixed single lines:
- a done box, a priority badge, the title and a ⋯ button, with a trash icon before the ⋯ on done objectives;
- below them, the side note (dimmed), a due chip on open objectives or a review chip on done ones ("review due", or "review in <n>d"), and tag chips.

Text that doesn't fit SHALL end in "…". Hovering the node SHALL show the full title, the full note and the created and done times, and for a done objective its review count and next review date.

#### Scenario: Long note
- **WHEN** an objective has a 200-character side note
- **THEN** its node stays the same height, the note is cut with "…", and the node's tooltip holds the whole note

#### Scenario: Done node
- **WHEN** the user marks an objective with a due date done and opens the Done group
- **THEN** its node shows a trash icon, a "review in 1d" chip and no due chip, and its tooltip gives 0 reviews and tomorrow's date as the next review

### Requirement: Link lines
For each link between an open objective, or an objective listed in review mode, and a tab shown in the right column, a line SHALL join the two nodes:
- coloured by the objective's priority;
- drawn dashed when the tab is closed or elsewhere;
- ending at the nodes' edges, at any graph width from 360 to 1600 pixels.

#### Scenario: Alignment at two widths
- **WHEN** the graph is captured at 1400 and 460 pixels wide
- **THEN** in both captures, each line's ends sit within 2 pixels of the vertical centres of its objective node and tab header

#### Scenario: Lines in review mode
- **WHEN** review mode lists a done objective linked to a live tab
- **THEN** a line joins its node to that tab's header, ending within 2 pixels of both vertical centres

### Requirement: Larger hit areas
The done box, the ⋯ button and the trash icon SHALL each take clicks over at least 22 px of width and the full 18 px height of their line in objective nodes. A pane row's jump button SHALL take clicks over at least 28 px of width and the row's full 22 px height. The Hard, Good and Easy buttons SHALL each be at least 22 px tall. Objective nodes SHALL stay 48 px tall outside review mode, and pane rows 22 px.

#### Scenario: Measured hit areas
- **WHEN** a screenshot's layout data is read outside review mode
- **THEN** every done box, trash icon and ⋯ button is at least 22 × 18 px, every jump button at least 28 × 22 px, objective nodes are 48 px tall, and pane rows are 22 px tall

#### Scenario: Review nodes
- **WHEN** a screenshot's layout data is read in review mode
- **THEN** every Hard, Good and Easy button is at least 22 px tall, and every listed node has the same height

## ADDED Requirements

### Requirement: Done objectives group
Clicking an open objective's done box SHALL mark it done. Done objectives SHALL leave the open list and gather in a "Done (n)" group at the bottom of the left column:
- the group is collapsed by default and opens or closes on click;
- inside it, the most recently done objective comes first;
- done objectives draw no lines outside review mode.

A done objective's box SHALL do nothing.

#### Scenario: Marking done
- **WHEN** the user clicks the done box of a linked open objective
- **THEN** it moves into the Done group, the count goes up by one, and its lines are gone

#### Scenario: Box of a done objective
- **WHEN** the user opens the Done group and clicks a done objective's box
- **THEN** it stays in the Done group, the count is unchanged, and the kv dump shows it still done

## REMOVED Requirements

### Requirement: Done group
**Reason**: From 0.10.0 the done box no longer reopens a done objective, so the scenario "Reopening" goes.
**Migration**: "Done objectives group" replaces it, with the same group, order and lines, and a done box that does nothing.
