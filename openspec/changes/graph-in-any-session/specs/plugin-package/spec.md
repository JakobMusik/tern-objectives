# Spec Delta

## MODIFIED Requirements

### Requirement: README
The README SHALL give:
- the exact install command;
- that the plugin has a window half and a host half, the host half only showing the graph, and that it needs nothing on `PATH`;
- the three commands, the ⌃⌘O key, and that Esc closes the graph;
- that in sessions on other machines the graph opens without installing anything there, and Esc closes it only after a click on the popup's title bar;
- where its data lives and how to remove it;
- one screenshot of the graph.

#### Scenario: README contents
- **WHEN** a reader opens the README
- **THEN** it contains the install command, the commands with ⌃⌘O, that Esc closes the graph, how the graph behaves in sessions on other machines, the data location under `plugin-data/objectives/`, and a screenshot of the graph
