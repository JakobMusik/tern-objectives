## ADDED Requirements

### Requirement: Link button on objective nodes
While the right column shows the origin pane's tab, every objective node, open or done, in review mode too, SHALL show a link button at the right end of its first line, before a done node's trash icon. On a node not linked to that tab, the button SHALL show only while the pointer is over the node; on a linked one, it SHALL always show, highlighted. Its tooltip SHALL name the tab. Without that tab, or while an objective is lifted, no node SHALL show it.

#### Scenario: Shown while pointing
- **WHEN** the graph is opened from a pane in tab "Guides" and the pointer rests on open objective "Speed up search", which doesn't link Guides
- **THEN** a shot shows a link button at the right end of its first line, its tooltip reads `Link to “Guides”`, and no other node that doesn't link Guides shows one

#### Scenario: Linked nodes keep it
- **WHEN** open "Read about rate limiting" and done "Restyle the docs site" link Guides, the Done group is open, the graph is opened from Guides, and the pointer rests on empty graph space
- **THEN** a shot shows a highlighted link button on both nodes and on no other, each with the tooltip `Unlink from “Guides”`

#### Scenario: Review node
- **WHEN** review mode lists done "Set up CI", which doesn't link Guides, and the pointer rests on its node
- **THEN** a shot shows its link button just before its trash icon

#### Scenario: Origin pane closes
- **WHEN** the origin pane, one of two in its tab, closes while the graph is shown
- **THEN** within a second no node shows a link button, linked or not

#### Scenario: While moving
- **WHEN** "Speed up search" is lifted by its grip and the pointer rests on "Read about rate limiting"
- **THEN** no node shows a link button, "Read about rate limiting" included

### Requirement: Link button clicks
A click on an objective node's link button SHALL link that objective to the origin pane's tab, or unlink them when they are linked, as that tab's link bar would. It SHALL NOT select the node, change the selection or jump, and the graph SHALL stay shown. Like any other click in the graph, it SHALL end a question asked in place and the Undo notice.

#### Scenario: Link from the node
- **WHEN** nothing is selected, the graph was opened from Guides, and the user clicks the link button on "Speed up search"
- **THEN** the kv dump shows "Speed up search" linked to Guides, nothing is selected, its node is tinted with a thick line to Guides and a highlighted button, and the graph is still shown, with focus unchanged

#### Scenario: Unlink from the node
- **WHEN** the user then clicks that highlighted button
- **THEN** the kv dump no longer shows the link, the node isn't tinted, and no line joins it to Guides

#### Scenario: Selection kept
- **WHEN** "Fix login bug" is selected and the user clicks the link button on "Speed up search"
- **THEN** "Fix login bug" is still selected, with its action bar, and the kv dump shows "Speed up search" linked to Guides

#### Scenario: Done objective
- **WHEN** the Done group is open and the user clicks the link button on done "Set up CI"
- **THEN** the kv dump shows "Set up CI" linked to Guides and still done, and its button is highlighted

#### Scenario: Origin pane moved
- **WHEN** the graph was opened from a pane of tab "App build", that pane is moved into tab "Server" while the graph is shown, and the user then points at "Speed up search" and clicks its link button
- **THEN** the button's tooltip read `Link to “Server”`, and the kv dump shows "Speed up search" linked to Server and not to App build

#### Scenario: Ends the Undo notice
- **WHEN** the "Marked done" notice shows with its Undo, and the user clicks a link button
- **THEN** the notice is gone, and the kv dump shows the link

## MODIFIED Requirements

### Requirement: Links of done objectives
A done objective's links SHALL change the same way as an open objective's: through the link bars while it is selected, in the Done group or in review mode, and through its node's link button. Nothing else SHALL change them: marking done, Undo, rating, reopening and closing its tabs SHALL leave them as they are, and the only exception SHALL be Resume, which hands a closed tab's links to the tab it opens ("Resuming a closed tab").

#### Scenario: Unlink from a done objective
- **WHEN** done objective X links tabs A and B, and the user opens the Done group, selects X and clicks "× Unlink" on A
- **THEN** the kv dump shows X linked to B only, X is still done and selected, and A shows below the "Other tabs" divider with "＋ Link"

#### Scenario: Link a done objective
- **WHEN** the user then clicks "＋ Link" on tab C
- **THEN** the kv dump shows X linked to B and C, and a green line joins X to C

#### Scenario: Resume moves a done objective's link
- **WHEN** done objective X is linked to closed tab A, which held an omp chat that had replied, and the user selects X and clicks A's "Resume"
- **THEN** the kv dump shows X linked to the new tab instead of A, and X is still done

#### Scenario: Reopening keeps the links
- **WHEN** done objective X links live tab A and tab B, closed with "Close n tabs", and the user reopens X with "Reset review"
- **THEN** the kv dump shows X open and linked to A and B, and B shows under "Closed tabs" with a dashed line to X
