# Spec Delta

## MODIFIED Requirements

### Requirement: Opening the graph
"Objectives: Open graph" SHALL be a palette command bound to ⌃⌘O by default. It SHALL show the graph as a glimpse over the current tab, with keyboard focus in the graph. Run while the graph is shown as a glimpse over the current tab, it SHALL close it, so the same key opens and closes the graph. Run anywhere else, it SHALL show the graph over the current tab, replacing a graph left docked or in another tab: the window SHALL hold at most one graph at a time.

#### Scenario: Key toggles
- **WHEN** the user presses ⌃⌘O twice over the same tab
- **THEN** the first press shows the graph with focus in it, and the second closes it, leaving no graph pane in the window

#### Scenario: Toggle after clicking inside
- **WHEN** the user opens the graph, clicks an objective's title and presses ⌃⌘O
- **THEN** the graph closes

#### Scenario: Replacing a docked graph
- **WHEN** a graph was docked into a tab by a session switch and the user presses ⌃⌘O in that tab
- **THEN** a glimpse of the graph is shown over the tab and the window holds exactly one graph pane

### Requirement: Selection
Clicking an objective's title SHALL select it:
- its lines are drawn thicker;
- all other lines fade to about a quarter of their strength;
- a link bar appears on every tab node.

Clicking the selected objective again, or empty graph space, SHALL clear the selection.

#### Scenario: Select and clear
- **WHEN** the user clicks an objective's title and then clicks empty graph space
- **THEN** the first screenshot shows its lines emphasised and a link bar on every tab node, and the second shows neither

### Requirement: New objective button
"＋ New objective" in the header SHALL ask for a title, create the objective at P2 with no links, and select it.

#### Scenario: Create and select
- **WHEN** the user clicks "＋ New objective" and enters "Write slides"
- **THEN** "Write slides" appears selected, and every tab node shows a "＋ Link" bar

## ADDED Requirements

### Requirement: Closing with Esc
While the graph has keyboard focus, Esc SHALL close it on the first press, including after clicks inside the graph. The key SHALL NOT reach any other pane.

#### Scenario: Esc right after opening
- **WHEN** the graph is opened with ⌃⌘O over a pane running `cat -v` and the user presses Esc
- **THEN** the graph closes, and `cat -v` has printed no `^[`

#### Scenario: Esc after clicking inside
- **WHEN** the user opens the graph, clicks an objective's title and presses Esc once
- **THEN** the graph closes

### Requirement: Origin highlight
The pane that has focus when the graph opens SHALL be the graph's origin. While the graph is shown, the tab node holding the origin pane SHALL carry an accent ring, and the origin's pane row an accent bar. The highlight SHALL follow the pane into another tab and SHALL disappear if the pane closes. Each fresh open SHALL take a new origin; showing the graph again after one of its pickers SHALL keep it.

#### Scenario: Opened from a split pane
- **WHEN** focus is in the right-hand pane of a split tab and the user opens the graph
- **THEN** a screenshot shows that tab node ringed and the right-hand pane's row marked, and no other node or row marked

#### Scenario: Origin pane moves
- **WHEN** the origin pane is moved into another tab while the graph is shown
- **THEN** the ring and the row mark move to that tab's node and the pane's new row

#### Scenario: Kept after a picker
- **WHEN** the user opens the graph, clicks "＋ New objective", clicks into the field, types a title and presses Enter
- **THEN** the graph shown again marks the same tab and pane

#### Scenario: New origin on a fresh open
- **WHEN** the user closes the graph, focuses a pane in another tab and opens the graph again
- **THEN** only the new pane's tab node and row are marked

### Requirement: Larger hit areas
The done box, the ⋯ button and the ▸/▾ toggle SHALL each take clicks over at least 22 px of width and the full height of their line: 18 px in objective nodes, 22 px in pane rows. Objective nodes SHALL stay 48 px tall and pane rows 22 px.

#### Scenario: Measured hit areas
- **WHEN** a screenshot's layout data is read
- **THEN** every done box, ⋯ button and ▸/▾ toggle is at least 22 px wide and as tall as its line, objective nodes are 48 px tall, and pane rows are 22 px tall
