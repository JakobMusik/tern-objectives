# Spec Delta

## MODIFIED Requirements

### Requirement: Closing with Esc
In a session on this machine, while the graph has keyboard focus, Esc SHALL close it on the first press, including after clicks inside the graph. The key SHALL NOT reach any other pane.

#### Scenario: Esc right after opening
- **WHEN** the graph is opened with ⌃⌘O over a pane running `cat -v` and the user presses Esc
- **THEN** the graph closes, and `cat -v` has printed no `^[`

#### Scenario: Esc after clicking inside
- **WHEN** the user opens the graph, clicks an objective's title and presses Esc once
- **THEN** the graph closes

## ADDED Requirements

### Requirement: Graph in sessions on other machines
In a session that runs on another machine, "Objectives: Open graph" SHALL show the same graph as a glimpse over the current tab, with the same clicks, links, menus and jumps, and SHALL need nothing installed on that machine. Pressing ⌃⌘O again SHALL close it. If that machine can't show the graph, an error toast SHALL say so and nothing SHALL open.

#### Scenario: Open and close in a remote session
- **WHEN** the current session runs on another machine and the user presses ⌃⌘O twice
- **THEN** the first press shows the graph over the current tab and the second closes it

#### Scenario: Clicks in a remote session
- **WHEN** the graph is shown in a session on another machine and the user selects an objective and clicks "＋ Link" on a tab node
- **THEN** the objective is selected and `kv.json` shows the new link
