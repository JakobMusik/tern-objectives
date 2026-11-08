## MODIFIED Requirements

### Requirement: README
The README SHALL give:
- the exact install command;
- that it needs nothing on `PATH` but `git`, and nothing on the machines sessions run on;
- the four commands with the ⌃⌘O and ⌥R keys;
- how to close the graph: ⌃⌘O, a click outside, its ×, or Esc after a click on its title bar;
- how reviewing done objectives works;
- where its data lives and how to remove it;
- two screenshots: first the graph with the Done group open, then review mode with its rating buttons.

#### Scenario: README contents
- **WHEN** a reader opens the README
- **THEN** it contains the install command, the commands with ⌃⌘O and ⌥R, the ways to close the graph, that nothing is installed on other machines, how to review done objectives, the data location under `plugin-data/objectives/`, a screenshot of the graph with the Done group open, and after it a screenshot of review mode with Hard, Good and Easy buttons

#### Scenario: Graph screenshot first
- **WHEN** the README is read on GitHub
- **THEN** its first image is `docs/graph.png`, the graph screenshot
