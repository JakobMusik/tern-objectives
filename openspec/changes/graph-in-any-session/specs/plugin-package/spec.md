# Spec Delta

## MODIFIED Requirements

### Requirement: Manifest
The package root SHALL hold a `plugin.toml` with:
- schema 1;
- id `objectives`;
- name "Objectives";
- a version: `0.1.0` for the first release, then the patch number raised for each fix and the minor number for each release that changes behaviour;
- a description;
- a window entry and its style sheet;
- no host entry and no blocks.

Tern's install-time checks SHALL accept the package.

#### Scenario: Local install check
- **WHEN** `tern plugin install <repo folder>` runs against an isolated Tern config
- **THEN** it reports `installed objectives` with the manifest's version, and `tern plugin list` shows the plugin ready with 0 blocks and no problems

### Requirement: README
The README SHALL give:
- the exact install command;
- that it needs nothing on `PATH` but `git`, and nothing on the machines sessions run on;
- the three commands and the ⌃⌘O key;
- how to close the graph: ⌃⌘O, a click outside, its ×, or Esc after a click on its title bar;
- where its data lives and how to remove it;
- one screenshot of the graph.

#### Scenario: README contents
- **WHEN** a reader opens the README
- **THEN** it contains the install command, the commands with ⌃⌘O, the ways to close the graph, that nothing is installed on other machines, the data location under `plugin-data/objectives/`, and a screenshot of the graph
