## MODIFIED Requirements

### Requirement: Link lines
For each link between an open objective and a tab shown in the right column, a line SHALL join the two nodes. A done objective's links SHALL get lines only while it is selected, in review mode too. Each line SHALL be:
- coloured by the objective's priority, or green (`#30a46c`) for a done objective;
- drawn dashed when the tab is closed or elsewhere;
- ending at the nodes' edges, at any graph width from 360 to 1600 pixels.

#### Scenario: Alignment at two widths
- **WHEN** the graph is captured at 1400 and 460 pixels wide
- **THEN** in both captures, each line's ends sit within 2 pixels of the vertical centres of its objective node and tab header

#### Scenario: Done objective selected
- **WHEN** the user opens the Done group and selects done objective X, linked to a live tab and a closed tab, while open objective Y links another tab
- **THEN** thick green lines join X to both tabs, the one to the closed tab dashed, and Y's line is faded

#### Scenario: Done objective not selected
- **WHEN** the user then clicks empty graph space
- **THEN** no green line shows, and Y's line is at full strength

#### Scenario: Lines in review mode
- **WHEN** review mode lists a done objective linked to a live tab
- **THEN** no line shows until the user selects that objective; then a green line joins its node to that tab's header, ending within 2 pixels of both vertical centres

### Requirement: Selection
Clicking an objective's title SHALL select it:
- its lines are drawn thicker;
- all other lines fade to about a quarter of their strength;
- when it is open, a link bar appears on every tab node.

Clicking the selected objective again, or empty graph space, SHALL clear the selection.

#### Scenario: Select and clear
- **WHEN** the user clicks an objective's title and then clicks empty graph space
- **THEN** the first screenshot shows its lines emphasised and a link bar on every tab node, and the second shows neither

#### Scenario: Selecting a done objective
- **WHEN** the user opens the Done group and clicks a done objective's title
- **THEN** it is drawn selected, its lines show, and no tab node has a link bar

### Requirement: Done objectives group
Clicking an open objective's done box SHALL mark it done. Done objectives SHALL leave the open list and gather in a "Done (n)" group at the bottom of the left column:
- the group is collapsed by default and opens or closes on click;
- inside it, the most recently done objective comes first;
- a done objective draws lines only while it is selected.

A done objective's box SHALL do nothing.

#### Scenario: Marking done
- **WHEN** the user clicks the done box of a linked open objective that is not selected
- **THEN** it moves into the Done group, the count goes up by one, and its lines are gone

#### Scenario: Box of a done objective
- **WHEN** the user opens the Done group and clicks a done objective's box
- **THEN** it stays in the Done group, the count is unchanged, and the kv dump shows it still done

## ADDED Requirements

### Requirement: Linked tabs section
While an objective is selected, the right column SHALL start with a section headed `Linked to “<title>”`: the shown tabs linked to it. The "Other tabs" divider and every other shown tab SHALL follow, each part ordered as "Tab column" says. Linking or unlinking a tab SHALL move it across the divider at once. Deselecting SHALL restore the normal order. With no such tab, neither heading nor divider SHALL show.

#### Scenario: Linked tabs on top
- **WHEN** the window holds sessions "web" (tabs "App build" and "Components") and "api" (tabs "Server" and "Benchmarks"), objective X is linked to "Components" and "Benchmarks", the graph was opened from "Server", and the user selects X
- **THEN** the column reads: `Linked to “X”`, "api" with "Benchmarks", "web" with "Components", the "Other tabs" divider, "api" with "Server", then "web" with "App build"

#### Scenario: Linked closed tab
- **WHEN** X is also linked to a closed tab and the user selects X
- **THEN** that tab shows under a "Closed tabs" heading inside the top section, after the live tabs, and not again below the divider

#### Scenario: Linking moves a tab up
- **WHEN** X is selected and the user clicks "＋ Link" on "App build", below the divider
- **THEN** "App build" shows at once in the top section, under "web" before "Components", its bar reading "× Unlink", and the kv dump holds the link

#### Scenario: Unlinking moves a tab down
- **WHEN** the user then clicks "× Unlink" on "Benchmarks"
- **THEN** "Benchmarks" shows at once below the divider, under "api" with the "Server" tab, its bar reading "＋ Link", and the kv dump no longer holds that link

#### Scenario: Last link removed
- **WHEN** X is selected, linked to one shown tab, and the user clicks that tab's "× Unlink"
- **THEN** the heading and the divider are gone, the column is in its normal order, and every bar reads "＋ Link"

#### Scenario: Deselect and select again
- **WHEN** the user clicks X to deselect it, and clicks it again
- **THEN** after the first click there is no heading or divider and the column is in its normal order; after the second, the top section holds the same tabs as before

#### Scenario: Nothing linked
- **WHEN** the user creates "Write slides" with "＋ New objective", which selects it
- **THEN** the column shows no `Linked to` heading and no divider

#### Scenario: First link
- **WHEN** "Write slides" is selected with nothing linked and the user clicks "＋ Link" on a tab
- **THEN** the column starts with `Linked to “Write slides”` and that tab, followed by the divider and every other tab

#### Scenario: This session
- **WHEN** the scope is "This session", X is linked to tabs in the current session and in another, and the user selects X
- **THEN** the top section holds only the current session's linked tabs

### Requirement: Other tabs divider
The divider between the `Linked to` section and the other tabs SHALL be a 3 px accent-coloured bar across the right column, with "Other tabs" on an accent-outlined pill in its middle. Its row SHALL be 32 px tall, and the lines SHALL stay on their nodes.

#### Scenario: Divider look
- **WHEN** X is selected and linked to one of three shown tabs
- **THEN** a screenshot shows the accent bar across the right column between the two sections, with "Other tabs" on a pill in its middle, and each line's ends sit within 2 pixels of the vertical centres of its objective node and tab header

## REMOVED Requirements

### Requirement: Linked tabs first
**Reason**: Its section was fixed when the objective was selected, so linking or unlinking never moved a tab, and its divider was a 1 px grey rule. The user asked for linked tabs to move up at once and for a bolder divider (2026-11-07).
**Migration**: Replaced by "Linked tabs section", whose top section follows the selected objective's links as they change, and "Other tabs divider". Nothing stored changes.
