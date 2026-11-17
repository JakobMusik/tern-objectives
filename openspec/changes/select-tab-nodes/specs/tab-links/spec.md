## MODIFIED Requirements

### Requirement: Link button on objective nodes
While a tab is selected, or else while the right column shows the origin pane's tab, every objective node, open or done, in review mode too, SHALL show a link button at the right end of its first line, before a done node's trash icon. On a node not linked to that tab, the button SHALL show only while the pointer is over the node; on a linked one, it SHALL always show, highlighted. Its tooltip SHALL name the tab. Without either tab, or while an objective is lifted, no node SHALL show it.

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

#### Scenario: Selected tab's buttons
- **WHEN** the graph is opened from Guides, the user selects tab "Server", which "Fix login bug" links, and the pointer rests on "Speed up search", which doesn't link Server
- **THEN** a shot shows a highlighted link button on "Fix login bug" with the tooltip `Unlink from “Server”`, a link button on "Speed up search" with the tooltip `Link to “Server”`, and no highlighted button on "Read about rate limiting", which links only Guides

### Requirement: Link button clicks
A click on an objective node's link button SHALL link that objective to the button's tab, the selected tab or else the origin pane's tab, or unlink them when they are linked, as that tab's link bar would. It SHALL NOT select the node, change the selection or jump, and the graph SHALL stay shown. Like any other click in the graph, it SHALL end a question asked in place and the Undo notice.

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

#### Scenario: Link to the selected tab
- **WHEN** the graph was opened from Guides, tab "Server" is selected, and the user clicks the link button on "Speed up search"
- **THEN** the kv dump shows "Speed up search" linked to Server and still not to Guides, "Server" is still selected, and "Speed up search" is tinted with a thick line to "Server"

#### Scenario: Selected closed tab
- **WHEN** closed linked tab A is selected and the user clicks the link button on "Write slides"
- **THEN** the kv dump shows "Write slides" linked to A, and a thick dashed line joins them
