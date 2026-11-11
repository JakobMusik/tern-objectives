## MODIFIED Requirements

### Requirement: Objective node content
Each objective node SHALL show:
- a grip (open objectives, outside review mode), a done box, a priority badge and the title, plus a trash icon on done objectives, and the link button that "Link button on objective nodes" describes;
- below them, the side note (dimmed), a due chip on open objectives or a review chip on done ones, and tag chips.

Text other than the title that doesn't fit SHALL end in "…". Hovering the node SHALL show the full title, the full note and the created and done times, and for a done objective its review count and next review date.

#### Scenario: Long note
- **WHEN** an objective with a one-line title has a 200-character side note
- **THEN** its node stays 48 px tall, the note is cut with "…", and the node's tooltip holds the whole note

#### Scenario: Done node
- **WHEN** the user marks an objective with a due date done and opens the Done group
- **THEN** its node shows a trash icon, a "review in 1d" chip and no due chip, and its tooltip gives 0 reviews and tomorrow's date as the next review

### Requirement: Selection
Clicking an objective node anywhere but its title, grip, done box, badge, trash icon, link button or action bar SHALL select it:
- its action bar shows under it;
- its lines are drawn thicker;
- all other lines fade to about a quarter of their strength;
- a link bar appears on every tab node, for an open or a done objective.

Clicking the selected objective there again, or empty graph space, SHALL clear the selection.

#### Scenario: Select and clear
- **WHEN** the graph was opened from a tab no objective links, and the user clicks an objective node beside its title and then clicks empty graph space
- **THEN** the first screenshot shows its action bar, its lines emphasised and a link bar on every tab node, and the second shows none of them

#### Scenario: Selecting a done objective
- **WHEN** the user opens the Done group and clicks a done objective's node on its second line
- **THEN** it is drawn selected, its lines show, and every tab node has a link bar

#### Scenario: Link button doesn't select
- **WHEN** nothing is selected and the user clicks an objective node's link button
- **THEN** nothing is selected afterwards, and no action bar or link bar shows

### Requirement: Larger hit areas
The grip, the done box, the trash icon and the link button SHALL each take clicks over at least 22 px of width and the full 18 px height of their line in objective nodes. Action bar buttons SHALL be at least 22 px tall. A pane row's jump button SHALL take clicks over at least 28 px of width and the row's full 22 px height. The Hard, Good and Easy buttons SHALL each be at least 22 px tall. Unselected objective nodes with a one-line title SHALL stay 48 px tall outside review mode, and pane rows 22 px.

#### Scenario: Measured hit areas
- **WHEN** a screenshot's layout data is read outside review mode with one objective selected
- **THEN** every grip, done box, trash icon and link button is at least 22 × 18 px, every action bar button at least 22 px tall, every jump button at least 28 × 22 px, unselected objective nodes with one-line titles are 48 px tall, and pane rows are 22 px tall

#### Scenario: Review nodes
- **WHEN** a screenshot's layout data is read in review mode
- **THEN** every Hard, Good and Easy button is at least 22 px tall, and every listed node with a one-line title has the same height
