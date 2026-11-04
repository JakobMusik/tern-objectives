# Spec Delta

## MODIFIED Requirements

### Requirement: Manifest
The package root SHALL hold a `plugin.toml` with:
- schema 1;
- id `objectives`;
- name "Objectives";
- a version: `0.1.0` for the first release, its patch number raised for each fix released after it (the live check's fixes shipped as `0.1.1` and `0.1.2`), and its minor number raised for each release that changes behaviour (`0.2.0` for the block surface);
- a description;
- a window entry and its style sheet;
- a host entry defining one block, `graph`, which the palette does not offer.

Tern's install-time checks SHALL accept the package.

#### Scenario: Local install check
- **WHEN** `tern plugin install <repo folder>` runs against an isolated Tern config
- **THEN** it reports `installed objectives` with the manifest's version, and `tern plugin list` shows the plugin ready with no problems

### Requirement: README
The README SHALL give:
- the exact install command;
- that the plugin has a window half and a host half, the host half only showing the graph, and that it needs nothing on `PATH`;
- the three commands, the ⌃⌘O key, and that Esc closes the graph;
- that the graph opens only in sessions on the local machine;
- where its data lives and how to remove it;
- one screenshot of the graph.

#### Scenario: README contents
- **WHEN** a reader opens the README
- **THEN** it contains the install command, the commands with ⌃⌘O, that Esc closes the graph, the local-sessions limit, the data location under `plugin-data/objectives/`, and a screenshot of the graph
